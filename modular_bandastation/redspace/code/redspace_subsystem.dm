SUBSYSTEM_DEF(redspace)
	name = "Редспейс"
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	ss_flags = SS_BACKGROUND | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS

	/// Round context: background, active z-levels, profile and zone coefficients.
	var/datum/redspace_context/context
	/// Station z-levels currently covered by the MVP field.
	var/list/station_z_levels = list()
	/// Sparse associative table: "z:q:r" -> /datum/redspace_field_cell.
	var/list/field_cells = list()
	/// Active spatial contributions. Sources are keyed by their runtime identifier.
	var/list/field_sources = list()
	/// Sources that need expiry checks or cell refreshes while they exist.
	var/list/processing_sources = list()
	var/next_source_id = 1
	/// Cells whose cached value changed and may need event/signal processing.
	var/list/dirty_cells = list()
	/// Resumable copy of dirty_cells for MC_TICK_CHECK support.
	var/list/currentrun = list()

/datum/controller/subsystem/redspace/Initialize()
	context = new /datum/redspace_context(list(new /datum/redspace_context_provider/default()))
	context.refresh()
	station_z_levels = context.active_z_levels.Copy()
	if(!context.enabled || !length(station_z_levels))
		can_fire = FALSE
		initialization_failure_message = "No station z-level was available for the redspace field."
		return SS_INIT_NO_NEED

	field_sources = list()
	processing_sources = list()
	next_source_id = 1

	// There is no work until a source, listener, or test changes a cell.
	can_fire = FALSE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/redspace/Destroy()
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(!source)
			continue
		qdel(source)
	field_sources.Cut()
	processing_sources.Cut()
	field_cells.Cut()
	dirty_cells.Cut()
	currentrun.Cut()
	QDEL_NULL(context)
	return ..()

/datum/controller/subsystem/redspace/stat_entry(msg)
	var/background_label = context ? round(context.background_value, 0.1) : 0
	msg = "B:[background_label] Cells:[length(field_cells)] Sources:[length(field_sources)] Dirty:[length(dirty_cells)]"
	return ..()

/datum/controller/subsystem/redspace/fire(resumed = FALSE)
	if(!resumed)
		process_sources()
		currentrun = dirty_cells.Copy()
		dirty_cells.Cut()

	var/list/current_run = currentrun
	while(length(current_run))
		var/datum/redspace_field_cell/cell = current_run[length(current_run)]
		current_run.len--
		if(QDELETED(cell))
			continue

		// Event and signal dispatch will consume this queue in the next layer.
		if(MC_TICK_CHECK)
			return

	if(!length(dirty_cells) && !length(processing_sources))
		can_fire = FALSE

/// Expires timed sources and refreshes cached cells while moving waves exist.
/datum/controller/subsystem/redspace/proc/process_sources()
	if(!length(processing_sources))
		return

	var/wave_present = FALSE
	for(var/source_key in processing_sources.Copy())
		var/datum/redspace_field_source/source = processing_sources[source_key]
		if(QDELETED(source))
			processing_sources[source_key] = null
			continue
		if(source.is_expired())
			source.change_reason = "истёк срок жизни источника"
			remove_source(source.source_id)
			continue
		if(istype(source, /datum/redspace_field_source/wave))
			wave_present = TRUE

	if(wave_present)
		refresh_cells()

/// Enables the subsystem after a new cell update or registered listener needs processing.
/datum/controller/subsystem/redspace/proc/wake()
	if(!initialized || can_fire)
		return
	can_fire = TRUE
	update_nextfire(reset_time = TRUE)

/datum/controller/subsystem/redspace/proc/is_supported_z(z_level)
	return z_level && z_level in station_z_levels

/// Gets a sparse cell for a turf, optionally creating it.
/datum/controller/subsystem/redspace/proc/get_cell(turf/target, create = FALSE) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return

	var/list/hex_coordinates = redspace_hex_coordinates(target)
	if(!hex_coordinates)
		return

	return get_cell_by_coordinates(target.z, hex_coordinates[1], hex_coordinates[2], create, target)

/// Gets a sparse cell by axial coordinates, optionally creating it.
/datum/controller/subsystem/redspace/proc/get_cell_by_coordinates(z_level, q, r, create = FALSE, turf/sample_turf = null) as /datum/redspace_field_cell
	if(!is_supported_z(z_level))
		return

	var/key = redspace_hex_key(z_level, q, r)
	var/datum/redspace_field_cell/cell = field_cells[key]
	if(!cell && create)
		cell = new(z_level, q, r, key, context.background_value, sample_turf)
		field_cells[key] = cell

	return cell

/// Returns the cached field value at a station turf. Empty cells use the background value.
/datum/controller/subsystem/redspace/proc/get_value(turf/target)
	if(!target || !is_supported_z(target.z))
		return

	var/datum/redspace_field_cell/cell = get_cell(target)
	var/value = calculate_value(target, cell)
	if(cell && cell.sample_x == target.x && cell.sample_y == target.y)
		if(cell.set_value(value))
			mark_cell_dirty(cell)
	return value

/// Calculates the field at a tile from the background, local cell override, active sources
/// and the zone susceptibility coefficient.
/datum/controller/subsystem/redspace/proc/calculate_value(turf/target, datum/redspace_field_cell/cell)
	if(!target || !is_supported_z(target.z))
		return

	// Explicit scenario overrides ignore zone susceptibility by design.
	if(cell && !isnull(cell.forced_value))
		return cell.forced_value

	var/value = context.background_value
	if(cell)
		value += cell.local_delta
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(!source)
			continue
		value += source.get_contribution(target)

	value *= get_zone_coefficient(target, cell)

	// Ordinary sources cannot create an event-only invasion state.
	return min(value, REDSPACE_MAX_NORMAL_VALUE)

/// Returns the zone susceptibility coefficient for a tile's hex.
/datum/controller/subsystem/redspace/proc/get_zone_coefficient(turf/target, datum/redspace_field_cell/cell)
	if(!context)
		return REDSPACE_DEFAULT_COEFFICIENT

	var/q = cell?.q
	var/r = cell?.r
	if(isnull(q) || isnull(r))
		var/list/hex_coordinates = redspace_hex_coordinates(target)
		if(!hex_coordinates)
			return REDSPACE_DEFAULT_COEFFICIENT
		q = hex_coordinates[1]
		r = hex_coordinates[2]

	return context.get_zone_coefficient(target.z, q, r)

/// Returns the gameplay range at a station turf.
/datum/controller/subsystem/redspace/proc/get_state(turf/target)
	var/value = get_value(target)
	return isnull(value) ? null : redspace_state_from_value(value)

/// Changes the background value and refreshes existing sparse cells.
/datum/controller/subsystem/redspace/proc/set_background_value(new_value, reason = null)
	new_value = min(new_value, REDSPACE_MAX_NORMAL_VALUE)
	if(context.background_value == new_value)
		return

	context.background_value = new_value
	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell)
			continue
		var/turf/sample_turf = cell.get_sample_turf()
		var/changed = sample_turf ? cell.set_value(calculate_value(sample_turf, cell)) : cell.set_delta(cell.local_delta, context.background_value)
		if(changed)
			mark_cell_dirty(cell)
	wake()

/// Sets an absolute value for the hex containing a turf. This is the temporary low-level source API.
/// allow_invasion is reserved for an explicit event override above the normal storm ceiling.
/datum/controller/subsystem/redspace/proc/set_cell_value(turf/target, new_value, allow_invasion = FALSE) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return
	if(!allow_invasion)
		new_value = min(new_value, REDSPACE_MAX_NORMAL_VALUE)

	var/datum/redspace_field_cell/cell = get_cell(target, new_value != context.background_value)
	if(!cell)
		return

	cell.local_delta = 0
	if(cell.set_forced_value(new_value, allow_invasion))
		mark_cell_dirty(cell)

	return cell

/// Sets a local contribution relative to the background value.
/datum/controller/subsystem/redspace/proc/set_cell_delta(turf/target, new_delta) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return
	new_delta = min(new_delta, REDSPACE_MAX_NORMAL_VALUE - context.background_value)

	var/datum/redspace_field_cell/cell = get_cell(target, new_delta != 0)
	if(!cell)
		return

	var/was_forced = cell.clear_forced_value()
	cell.local_delta = new_delta
	var/turf/sample_turf = cell.get_sample_turf()
	var/changed = sample_turf ? cell.set_value(calculate_value(sample_turf, cell)) : cell.set_delta(new_delta, context.background_value)
	if(was_forced || changed)
		mark_cell_dirty(cell)

	return cell

/// Removes the sparse cell and any explicit value attached to it.
/datum/controller/subsystem/redspace/proc/clear_cell_value(turf/target)
	if(!target || !is_supported_z(target.z))
		return FALSE

	var/datum/redspace_field_cell/cell = get_cell(target)
	if(!cell)
		return FALSE

	field_cells[cell.key] = null
	dirty_cells -= cell
	currentrun -= cell
	qdel(cell)
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
	source.source_id = next_source_id++
	field_sources["[source.source_id]"] = source
	if(source.requires_processing())
		processing_sources["[source.source_id]"] = source

	get_cell(locate(source.origin_x, source.origin_y, source.z_level), TRUE)
	refresh_cells()
	wake()
	return source

/// Registers a static source. Kept as the plain entry point for debug tooling.
/datum/controller/subsystem/redspace/proc/register_source(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEBUG, lifetime = null, reason = null) as /datum/redspace_field_source
	return add_source(new /datum/redspace_field_source(0, origin, source_strength, source_radius, source_profile_id, lifetime, reason))

/// Registers a stable hot zone: a persistent local anomaly with its own type.
/datum/controller/subsystem/redspace/proc/register_hotspot(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEMONIC, reason = null, description = null) as /datum/redspace_field_source/hotspot
	var/datum/redspace_field_source/hotspot/hotspot = new(0, origin, source_strength, source_radius, source_profile_id, null, reason)
	hotspot.description = description
	return add_source(hotspot)

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
	if(!source || !source.set_strength(new_strength, reason))
		return FALSE
	refresh_cells()
	wake()
	return TRUE

/// Moves a source to another tile on the same z-level and refreshes observed cells.
/datum/controller/subsystem/redspace/proc/update_source_position(source_id, turf/new_origin, reason = null)
	var/datum/redspace_field_source/source = field_sources["[source_id]"]
	if(!source || !source.set_position(new_origin, reason))
		return FALSE
	get_cell(new_origin, TRUE)
	refresh_cells()
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
	field_sources[source_key] = null
	processing_sources[source_key] = null
	qdel(source)
	refresh_cells()
	wake()
	return TRUE

/// Recalculates cached values for all sparse cells. The number of cells is bounded by observers and tests.
/datum/controller/subsystem/redspace/proc/refresh_cells()
	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell)
			continue
		var/turf/sample_turf = cell.get_sample_turf()
		if(!sample_turf)
			continue
		if(cell.set_value(calculate_value(sample_turf, cell)))
			mark_cell_dirty(cell)

/// Removes all field state created during the current round.
/datum/controller/subsystem/redspace/proc/reset_debug_state()
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(!source)
			continue
		qdel(source)
	field_sources.Cut()
	processing_sources.Cut()
	next_source_id = 1

	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell)
			continue
		qdel(cell)
	field_cells.Cut()
	dirty_cells.Cut()
	currentrun.Cut()

	QDEL_NULL(context)
	context = new /datum/redspace_context(list(new /datum/redspace_context_provider/default()))
	context.refresh()
	station_z_levels = context.active_z_levels.Copy()
	can_fire = FALSE

/datum/controller/subsystem/redspace/proc/mark_cell_dirty(datum/redspace_field_cell/cell)
	if(!(cell in dirty_cells))
		dirty_cells += cell
	wake()
