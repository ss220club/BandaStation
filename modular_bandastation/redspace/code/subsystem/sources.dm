// Source registration, coverage discovery, updates and expiry.
// These procs extend SSredspace; shared state and lifecycle live in ../redspace_subsystem.dm.

/// Expires timed sources and refreshes cached cells while moving waves exist.
/datum/controller/subsystem/redspace/proc/process_sources()
	if(!length(processing_sources))
		return

	var/refresh_needed = FALSE
	var/list/refresh_cell_keys = list()
	for(var/source_key in processing_sources.Copy())
		var/datum/redspace_field_source/source = processing_sources[source_key]
		if(QDELETED(source))
			processing_sources -= source_key
			continue
		if(source.is_expired())
			source.change_reason = "истёк срок жизни источника"
			remove_source(source.source_id)
			continue
		if(istype(source, /datum/redspace_field_source/hotspot))
			var/datum/redspace_field_source/hotspot/hotspot = source
			hotspot.process_growth()
		var/coverage_pending = length(source.coverage_turfs)
		var/coverage_rebuild_needed = source.coverage_needs_refresh()
		var/coverage_complete = TRUE
		if(istype(source, /datum/redspace_field_source/wave) || coverage_pending)
			coverage_complete = ensure_source_cells(source)
			refresh_needed ||= coverage_pending || !coverage_complete
			refresh_cell_keys |= source.get_coverage_refresh_keys()
			if(coverage_rebuild_needed)
				prune_requested = TRUE
		if(istype(source, /datum/redspace_field_source/wave))
			refresh_needed = TRUE
		if(!source.requires_processing() && coverage_complete)
			processing_sources -= source_key

	if(refresh_needed)
		if(length(refresh_cell_keys))
			refresh_cells("обновляются пространственные источники", refresh_cell_keys)
		else
			refresh_cells("обновляются пространственные источники")

/datum/controller/subsystem/redspace/proc/ensure_source_cells(datum/redspace_field_source/source)
	if(!source || !source.z_level || !is_supported_z(source.z_level))
		return TRUE
	if(!length(source.coverage_turfs))
		if(!source.coverage_needs_refresh())
			return TRUE
		var/list/center = list(source.origin_x, source.origin_y)
		if(istype(source, /datum/redspace_field_source/wave))
			var/datum/redspace_field_source/wave/wave_source = source
			center = wave_source.get_current_center()
		var/turf/center_turf = locate(round(center[1]), round(center[2]), source.z_level)
		if(!center_turf)
			return TRUE
		var/coverage_radius = source.radius
		if(istype(source, /datum/redspace_field_source/wave))
			// Keep a margin so a wave can move within one cell without rebuilding
			// the coverage list while still refreshing every affected cell.
			coverage_radius += REDSPACE_HEX_RADIUS
		var/list/center_coordinates = redspace_hex_coordinates(center_turf)
		var/list/coverage_candidates = list()
		if(center_coordinates)
			// Enumerate the sparse hex grid directly. The margin covers cells
			// whose representative turf lies outside the source circle while
			// one of their exact listener turfs is still inside it.
			var/effective_radius = coverage_radius + REDSPACE_HEX_RADIUS
			var/effective_radius_squared = effective_radius * effective_radius
			var/coordinate_range = ceil(effective_radius * 2 / (3 * REDSPACE_HEX_RADIUS)) + 2
			for(var/q_offset in -coordinate_range to coordinate_range)
				for(var/r_offset in -coordinate_range to coordinate_range)
					var/q = center_coordinates[1] + q_offset
					var/r = center_coordinates[2] + r_offset
					var/turf/representative_turf = redspace_hex_representative_turf(source.z_level, q, r)
					if(!representative_turf)
						continue
					var/delta_x = representative_turf.x - center[1]
					var/delta_y = representative_turf.y - center[2]
					if(delta_x * delta_x + delta_y * delta_y <= effective_radius_squared)
						coverage_candidates += representative_turf
		source.coverage_turfs = coverage_candidates
		source.coverage_seen_cells = list()
		source.coverage_cursor = 1
		source.coverage_center_x = center[1]
		source.coverage_center_y = center[2]
		source.coverage_refresh_cell_keys |= source.coverage_cell_keys

	while(source.coverage_cursor <= length(source.coverage_turfs))
		var/turf/candidate = source.coverage_turfs[source.coverage_cursor++]
		var/list/coordinates = redspace_hex_coordinates(candidate)
		if(!coordinates)
			continue
		var/cell_key = redspace_hex_key(candidate.z, coordinates[1], coordinates[2])
		if(source.coverage_seen_cells[cell_key])
			continue
		source.coverage_seen_cells[cell_key] = TRUE
		source.coverage_refresh_cell_keys |= cell_key
		get_cell_by_coordinates(candidate.z, coordinates[1], coordinates[2], TRUE, candidate)
		if(MC_TICK_CHECK)
			return FALSE

	var/list/current_coverage_keys = list()
	for(var/cell_key in source.coverage_seen_cells)
		current_coverage_keys += cell_key
	source.coverage_cell_keys = current_coverage_keys
	source.coverage_cell_lookup = list()
	for(var/cell_key in current_coverage_keys)
		source.coverage_cell_lookup[cell_key] = TRUE
	source.coverage_turfs = null
	source.coverage_seen_cells = null
	source.coverage_cursor = 1
	return TRUE

/// Validates and registers any source datum. Returns the registered source with its final id.
/datum/controller/subsystem/redspace/proc/add_source(datum/redspace_field_source/source) as /datum/redspace_field_source
	if(!initialized || !source)
		return
	if(!isnum(source.strength) || !isnum(source.radius) || !source.z_level || !is_supported_z(source.z_level))
		qdel(source)
		return
	if(!islist(field_sources))
		field_sources = list()
	if(!islist(processing_sources))
		processing_sources = list()
	if(!isnum(next_source_id) || next_source_id < 1)
		next_source_id = 1

	source.radius = clamp(floor(source.radius + 0.5), 0, REDSPACE_MAX_SOURCE_RADIUS)
	source.radius_squared = source.radius * source.radius
	source.source_id = next_source_id++
	field_sources["[source.source_id]"] = source
	var/coverage_complete = ensure_source_cells(source)
	// Registration performs a full refresh below, so do not repeat the same
	// coverage pass on the next subsystem fire.
	source.get_coverage_refresh_keys()
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	metric_peak_processing_sources = max(metric_peak_processing_sources, length(processing_sources))
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_source_deleted))

	get_cell(locate(source.origin_x, source.origin_y, source.z_level), TRUE)
	var/registration_reason = source.change_reason || "источник зарегистрирован"
	source.change_reason = registration_reason
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_ADDED, source.profile_id, null, source, registration_reason)
	refresh_cells(registration_reason)
	wake()
	return source

/// Registers a static source. Kept as the plain entry point for debug tooling.
/datum/controller/subsystem/redspace/proc/register_source(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEBUG, lifetime = null, reason = null) as /datum/redspace_field_source
	return add_source(new /datum/redspace_field_source(0, origin, source_strength, source_radius, source_profile_id, lifetime, reason))

/// Registers a machine-owned negative source and keeps it separate from ordinary
/// positive/debug sources for the shared stabilizer cap.
/datum/controller/subsystem/redspace/proc/register_stabilizer_source(turf/origin, source_strength, source_radius, reason = null) as /datum/redspace_field_source/stabilizer
	if(!isnum(source_strength))
		return
	return add_source(new /datum/redspace_field_source/stabilizer(0, origin, min(source_strength, 0), source_radius, REDSPACE_PROFILE_STABILIZER, null, reason))

/// Registers a stable hot zone: a persistent local anomaly with its own type.
/datum/controller/subsystem/redspace/proc/register_hotspot(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEMONIC, reason = null, description = null, counts_as_active_hotspot = TRUE) as /datum/redspace_field_source/hotspot
	var/datum/redspace_field_source/hotspot/hotspot = new(0, origin, source_strength, source_radius, source_profile_id, null, reason)
	hotspot.description = description
	hotspot.counts_as_active_hotspot = counts_as_active_hotspot
	return add_source(hotspot)

/// Finds the closest positive hotspot to a turf. Rift sealers use the source origin,
/// not the source's falloff radius, for their placement restriction.
/datum/controller/subsystem/redspace/proc/get_nearest_hotspot(turf/target, max_distance = REDSPACE_RIFT_SEALER_PLACEMENT_RADIUS) as /datum/redspace_field_source/hotspot
	if(!target || !is_supported_z(target.z))
		return

	var/datum/redspace_field_source/hotspot/nearest_hotspot
	var/nearest_distance = INFINITY
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/hotspot/hotspot = field_sources[source_key]
		if(!istype(hotspot) || hotspot.strength <= 0)
			continue
		var/turf/origin = locate(hotspot.origin_x, hotspot.origin_y, hotspot.z_level)
		if(!origin || origin.z != target.z)
			continue
		var/distance = get_dist(target, origin)
		if(distance > max_distance || distance >= nearest_distance)
			continue
		nearest_hotspot = hotspot
		nearest_distance = distance

	return nearest_hotspot

/// Registers a moving wave with amplitude, radius, velocity in tiles per second and a lifetime.
/datum/controller/subsystem/redspace/proc/register_wave_source(turf/origin, amplitude, source_radius, velocity_x, velocity_y, lifetime, source_profile_id = REDSPACE_PROFILE_DEMONIC, reason = null) as /datum/redspace_field_source/wave
	if(!isnum(lifetime) || lifetime <= 0)
		return
	if(!isnum(velocity_x) || !isnum(velocity_y))
		return
	return add_source(new /datum/redspace_field_source/wave(0, origin, amplitude, source_radius, source_profile_id, lifetime, reason, velocity_x, velocity_y))

/// Changes a source strength and refreshes observed cells.
/datum/controller/subsystem/redspace/proc/update_source_strength(source_id, new_strength, reason = null)
	var/datum/redspace_field_source/source = field_sources["[source_id]"]
	if(!source)
		return FALSE
	var/old_strength = source.strength
	var/change_reason = reason || "изменена сила источника"
	if(!source.set_strength(new_strength, change_reason))
		return FALSE
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys()
	var/coverage_complete = TRUE
	if(source.strength)
		coverage_complete = ensure_source_cells(source)
		refresh_cell_keys |= source.get_coverage_refresh_keys()
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_STRENGTH, source.profile_id, old_strength, source.strength, change_reason)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Moves a source to another tile on the same z-level and refreshes observed cells.
/datum/controller/subsystem/redspace/proc/update_source_position(source_id, turf/new_origin, reason = null)
	var/datum/redspace_field_source/source = field_sources["[source_id]"]
	if(!source || !new_origin || !is_supported_z(new_origin.z) || new_origin.z != source.z_level)
		return FALSE
	var/list/old_position = list(source.origin_x, source.origin_y, source.z_level)
	var/change_reason = reason || "перемещён источник"
	if(!source.set_position(new_origin, change_reason))
		return FALSE
	var/coverage_complete = ensure_source_cells(source)
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	else
		processing_sources -= "[source.source_id]"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys()
	get_cell(new_origin, TRUE)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_POSITION, source.profile_id, old_position, list(source.origin_x, source.origin_y, source.z_level), change_reason)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Changes a source radius and refreshes observed cells.
/datum/controller/subsystem/redspace/proc/update_source_radius(source_id, new_radius, reason = null)
	var/datum/redspace_field_source/source = field_sources["[source_id]"]
	if(!source)
		return FALSE
	var/old_radius = source.radius
	var/change_reason = reason || "изменён радиус источника"
	if(!source.set_radius(new_radius, change_reason))
		return FALSE
	var/coverage_complete = ensure_source_cells(source)
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	else
		processing_sources -= "[source.source_id]"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys()
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_RADIUS, source.profile_id, old_radius, source.radius, change_reason)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Removes a registered source by its runtime identifier.
/datum/controller/subsystem/redspace/proc/remove_source(source_id, reason = null)
	var/source_key = "[source_id]"
	var/datum/redspace_field_source/source = field_sources[source_key]
	if(!source)
		return FALSE

	if(reason)
		source.change_reason = reason
	var/change_reason = reason || source.change_reason || "источник удалён"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys(include_in_progress = TRUE)
	UnregisterSignal(source, COMSIG_QDELETING)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, change_reason)
	field_sources -= source_key
	processing_sources -= source_key
	qdel(source)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Keeps the registry consistent when a source is deleted outside remove_source().
/datum/controller/subsystem/redspace/proc/on_source_deleted(datum/redspace_field_source/source)
	SIGNAL_HANDLER
	if(!source)
		return
	var/source_key = "[source.source_id]"
	if(field_sources[source_key] != source)
		return
	var/change_reason = source.change_reason || "источник уничтожен"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys(include_in_progress = TRUE)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, change_reason)
	field_sources -= source_key
	processing_sources -= source_key
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
