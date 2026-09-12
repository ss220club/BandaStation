// Sparse field sampling, overrides, refresh queues and cell pruning.
// These procs extend SSredspace; shared state and lifecycle live in ../redspace_subsystem.dm.

/datum/controller/subsystem/redspace/proc/is_supported_z(z_level)
	if(!z_level)
		return FALSE
	return z_level in station_z_levels

/// Gets a sparse cell for a turf, optionally creating it.
/datum/controller/subsystem/redspace/proc/get_cell(turf/target, create = FALSE) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return

	var/list/hex_coordinates = redspace_hex_coordinates(target)
	if(!hex_coordinates)
		return

	var/datum/redspace_field_cell/cell = get_cell_by_coordinates(target.z, hex_coordinates[1], hex_coordinates[2], create, target)
	if(cell && create)
		schedule_event_attempt(cell)
	return cell

/// Gets a sparse cell by axial coordinates, optionally creating it.
/datum/controller/subsystem/redspace/proc/get_cell_by_coordinates(z_level, q, r, create = FALSE, turf/sample_turf = null) as /datum/redspace_field_cell
	if(!is_supported_z(z_level))
		return

	var/key = redspace_hex_key(z_level, q, r)
	var/datum/redspace_field_cell/cell = field_cells[key]
	if(!cell && create)
		var/turf/representative_turf = redspace_hex_representative_turf(z_level, q, r) || sample_turf
		cell = new(z_level, q, r, key, context.background_value, representative_turf)
		field_cells[key] = cell
		metric_peak_field_cells = max(metric_peak_field_cells, length(field_cells))

	return cell

/// Returns the cached field value at a station turf. Empty cells use the background value.
/datum/controller/subsystem/redspace/proc/get_value(turf/target)
	return get_value_without_source(target)

/// Calculates a point value while ignoring one source. Stabilizers use this to
/// measure the pressure they need to counter without feeding their own output back
/// into the requested correction.
/datum/controller/subsystem/redspace/proc/get_value_without_source(turf/target, datum/redspace_field_source/excluded_source = null)
	if(!target || !is_supported_z(target.z))
		return
	if(!excluded_source && event_value_cache)
		var/cached_event_value = event_value_cache[target]
		if(!isnull(cached_event_value))
			return cached_event_value
	metric_sample_count++

	var/datum/redspace_field_cell/cell = get_cell(target)
	var/value = calculate_value(target, cell, excluded_source)
	if(!excluded_source && cell && cell.sample_x == target.x && cell.sample_y == target.y)
		if(cell.set_value(value, world.time, "локальная выборка"))
			mark_cell_dirty(cell)
	if(!excluded_source && event_value_cache)
		event_value_cache[target] = value
	return value

/// Calculates the field at a tile from the background, local cell override, active sources
/// and the zone susceptibility coefficient.
/datum/controller/subsystem/redspace/proc/calculate_value(turf/target, datum/redspace_field_cell/cell, datum/redspace_field_source/excluded_source = null)
	if(!target || !is_supported_z(target.z))
		return
	metric_value_calculation_count++

	// Explicit event overrides ignore zone susceptibility by design.
	if(cell && !isnull(cell.event_override_value))
		return cell.event_override_value
	// Sealing pressure is deliberately not reducible by the background or stabilizers.
	if(is_sealing_active_at(target, excluded_source))
		return REDSPACE_MAX_NORMAL_VALUE
	// Ordinary test values ignore zone susceptibility by design.
	if(cell && !isnull(cell.forced_value))
		return cell.forced_value

	var/value = context.background_value
	if(cell)
		value += cell.local_delta
	var/stabilizer_delta = 0
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(!source || source == excluded_source || !source.strength)
			continue
		var/contribution = source.get_contribution(target)
		if(!contribution)
			continue
		metric_source_check_count++
		if(istype(source, /datum/redspace_field_source/stabilizer))
			stabilizer_delta += contribution
		else
			value += contribution

	if(stabilizer_delta)
		value += max(stabilizer_delta, -max(0, max_stabilizer_negative_contribution))

	value *= get_zone_coefficient(target, cell)

	// Ordinary sources cannot create an event-only invasion state.
	return min(value, REDSPACE_MAX_NORMAL_VALUE)

/datum/controller/subsystem/redspace/proc/is_sealing_active_at(turf/target, datum/redspace_field_source/excluded_source = null)
	if(!target)
		return FALSE
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/hotspot/hotspot = field_sources[source_key]
		if(!istype(hotspot) || hotspot == excluded_source || !hotspot.sealing_active)
			continue
		if(hotspot.can_affect(target))
			return TRUE
	return FALSE

/datum/controller/subsystem/redspace/proc/is_sealing_active_in_cell(datum/redspace_field_cell/cell)
	if(!cell)
		return FALSE
	if(is_sealing_active_at(cell.get_sample_turf()))
		return TRUE

	// Coverage includes the neighboring cells that may contain an affected tile even
	// when their representative tile is just outside the source radius.
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/hotspot/hotspot = field_sources[source_key]
		if(!istype(hotspot) || !hotspot.sealing_active)
			continue
		if(hotspot.coverage_cell_lookup && hotspot.coverage_cell_lookup[cell.key])
			return TRUE
	return FALSE

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
	if(isnull(value))
		return
	var/datum/redspace_field_cell/cell = get_cell(target)
	// Range transitions are cell-level; the exact point value remains available through get_value().
	if(cell)
		return cell.state
	return redspace_state_from_value(value)

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
		var/changed = cell.set_value(get_cached_cell_value(cell), world.time, reason)
		if(changed)
			mark_cell_dirty(cell, reason)
	wake()

/// Sets an ordinary explicit value for the hex containing a turf.
/datum/controller/subsystem/redspace/proc/set_cell_value(turf/target, new_value, reason = null) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return
	if(!isnum(new_value))
		return
	new_value = min(new_value, REDSPACE_MAX_NORMAL_VALUE)

	var/datum/redspace_field_cell/cell = get_cell(target, TRUE)
	if(!cell)
		return

	cell.local_delta = 0
	var/changed = cell.set_forced_value(new_value, world.time, reason)
	if(changed)
		mark_cell_dirty(cell, reason)
	schedule_event_attempt(cell)

	return cell

/// Sets a scenario-owned event-only value above the normal storm ceiling.
/datum/controller/subsystem/redspace/proc/set_event_override(turf/target, new_value, reason = null) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z) || !isnum(new_value) || new_value <= REDSPACE_MAX_NORMAL_VALUE)
		return

	var/datum/redspace_field_cell/cell = get_cell(target, TRUE)
	if(!cell)
		return

	if(cell.set_event_override(new_value, world.time, reason))
		mark_cell_dirty(cell, reason)
	schedule_event_attempt(cell)
	return cell

/// Sets a local contribution relative to the background value.
/datum/controller/subsystem/redspace/proc/set_cell_delta(turf/target, new_delta, reason = null) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return
	if(!isnum(new_delta))
		return
	new_delta = min(new_delta, REDSPACE_MAX_NORMAL_VALUE - context.background_value)

	var/datum/redspace_field_cell/cell = get_cell(target, new_delta != 0)
	if(!cell)
		return

	var/was_forced = cell.clear_forced_value()
	cell.local_delta = new_delta
	var/changed = cell.set_value(get_cached_cell_value(cell), world.time, reason)
	if(was_forced || changed)
		mark_cell_dirty(cell, reason)
	schedule_event_attempt(cell)

	return cell

/// Clears the event-only override and reveals the ordinary field value again.
/datum/controller/subsystem/redspace/proc/clear_event_override(turf/target, reason = null)
	if(!target || !is_supported_z(target.z))
		return FALSE

	var/datum/redspace_field_cell/cell = get_cell(target)
	if(!cell || !cell.clear_event_override())
		return FALSE

	var/changed = cell.set_value(get_cached_cell_value(cell), world.time, reason)
	if(changed)
		mark_cell_dirty(cell, reason)
	schedule_event_attempt(cell)
	prune_unused_cells()
	return TRUE

/// Removes the sparse cell and any explicit value attached to it.
/datum/controller/subsystem/redspace/proc/clear_cell_value(turf/target)
	if(!target || !is_supported_z(target.z))
		return FALSE

	var/datum/redspace_field_cell/cell = get_cell(target)
	if(!cell)
		return FALSE

	if(length(cell.listeners) || cell_has_active_source(cell))
		cell.local_delta = 0
		cell.clear_forced_value()
		cell.clear_event_override()
		if(cell.set_value(get_cached_cell_value(cell), world.time, "ячейка очищена"))
			mark_cell_dirty(cell, "ячейка очищена")
		schedule_event_attempt(cell)
		return TRUE

	remove_field_cell(cell)
	return TRUE

/// Requests a resumable refresh of sparse cells. A null key list means all
/// cells; source updates pass only the cells covered by that source.
/datum/controller/subsystem/redspace/proc/refresh_cells(reason = null, list/cell_keys = null)
	if(refresh_in_progress)
		if(!isnull(cell_keys) && !length(cell_keys))
			return
		refresh_requested = TRUE
		if(isnull(cell_keys))
			refresh_requested_full = TRUE
		else if(!refresh_requested_full)
			pending_refresh_keys |= cell_keys
		if(!isnull(reason))
			pending_refresh_reason = reason
		return

	if(!isnull(cell_keys) && !length(cell_keys))
		return
	refresh_in_progress = TRUE
	refresh_reason = reason
	refresh_currentrun = list()
	if(isnull(cell_keys))
		for(var/field_cell_key in field_cells)
			refresh_currentrun += field_cell_key
	else
		for(var/field_cell_key in cell_keys)
			if(field_cells[field_cell_key])
				refresh_currentrun += field_cell_key
	wake()

/datum/controller/subsystem/redspace/proc/process_refresh_cells()
	if(!refresh_in_progress)
		return TRUE

	while(TRUE)
		while(length(refresh_currentrun))
			var/cell_key = refresh_currentrun[length(refresh_currentrun)]
			refresh_currentrun.len--
			var/datum/redspace_field_cell/cell = field_cells[cell_key]
			if(!cell)
				continue

			var/changed = cell.set_value(get_cached_cell_value(cell), world.time, refresh_reason)
			if(changed || length(cell.listeners))
				mark_cell_dirty(cell, refresh_reason)
			if(cell_has_event_anchor(cell))
				var/datum/redspace_event_budget/budget = event_budgets[cell.key]
				var/datum/redspace_event_profile/event_profile = get_event_profile(cell.state)
				var/normal_schedule_missing = event_profile_has_automatic_event(event_profile) && (!budget || !budget.next_attempt_at || budget.scheduled_state != cell.state)
				var/turf_schedule_missing = event_profile_has_automatic_event(event_profile, REDSPACE_EVENT_CATEGORY_TURF_SPAWN) && (!budget || !budget.next_turf_attempt_at || budget.turf_scheduled_state != cell.state)
				if(changed || normal_schedule_missing || turf_schedule_missing)
					schedule_event_attempt(cell)
			else
				clear_event_schedule(cell)
			if(MC_TICK_CHECK)
				return FALSE

		if(!refresh_requested)
			refresh_in_progress = FALSE
			refresh_reason = null
			return TRUE

		refresh_requested = FALSE
		refresh_reason = pending_refresh_reason
		pending_refresh_reason = null
		refresh_currentrun = list()
		if(refresh_requested_full)
			for(var/field_cell_key in field_cells)
				refresh_currentrun += field_cell_key
		else
			refresh_currentrun = pending_refresh_keys.Copy()
		refresh_requested_full = FALSE
		pending_refresh_keys.Cut()


/// Returns the value that should be cached for a sparse cell without requiring a caller to know its sample turf.
/datum/controller/subsystem/redspace/proc/get_cached_cell_value(datum/redspace_field_cell/cell)
	if(!cell)
		return
	var/turf/sample_turf = cell.get_sample_turf()
	if(sample_turf)
		return calculate_value(sample_turf, cell)
	if(!isnull(cell.event_override_value))
		return cell.event_override_value
	if(!isnull(cell.forced_value))
		return cell.forced_value
	return context.background_value + cell.local_delta

/// Removes a sparse cell and all listener references to it.
/datum/controller/subsystem/redspace/proc/remove_field_cell(datum/redspace_field_cell/cell)
	if(!cell)
		return
	for(var/datum/listener as anything in cell.listeners.Copy())
		unregister_field_listener(listener, FALSE)
	field_cells -= cell.key
	dirty_cells -= cell
	currentrun -= cell
	cell.dirty_queued = FALSE
	cell.dirty_processing = FALSE
	var/datum/redspace_event_budget/budget = event_budgets[cell.key]
	if(budget && !budget.active_event_count && !budget.active_spawn_event_count)
		budget.next_attempt_at = 0
		budget.next_turf_attempt_at = 0
		event_budgets -= cell.key
		qdel(budget)
	qdel(cell)

/// Removes observer-free cells that no longer have a meaningful source or override.
/datum/controller/subsystem/redspace/proc/prune_unused_cells(schedule_wake = TRUE)
	for(var/cell_key in field_cells.Copy())
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell || length(cell.listeners) || !isnull(cell.forced_value) || !isnull(cell.event_override_value) || cell.local_delta)
			continue
		if(cell.dirty_queued || cell.dirty_processing)
			continue
		var/source_present = cell_has_active_source(cell)
		var/datum/redspace_event_budget/budget = event_budgets[cell.key]
		if(budget && !source_present && !budget.active_event_count && !budget.active_spawn_event_count && !budget.next_attempt_at && !budget.next_turf_attempt_at)
			budget.next_attempt_at = 0
			budget.next_turf_attempt_at = 0
			event_budgets -= cell.key
			qdel(budget)
			budget = null
		if(budget && (budget.active_event_count || budget.active_spawn_event_count || budget.next_attempt_at || budget.next_turf_attempt_at))
			continue
		if(!source_present)
			remove_field_cell(cell)
	if(schedule_wake)
		schedule_event_wake()

/datum/controller/subsystem/redspace/proc/prune_event_cell(zone_key)
	if(!zone_key)
		return
	var/datum/redspace_field_cell/cell = field_cells[zone_key]
	if(!cell || length(cell.listeners) || !isnull(cell.forced_value) || !isnull(cell.event_override_value) || cell.local_delta)
		return
	// A lifecycle callback can run while this cell is still waiting for its
	// dirty pass. Let the normal prune path remove it after processing.
	if(cell.dirty_queued || cell.dirty_processing)
		return
	var/source_present = cell_has_active_source(cell)
	var/datum/redspace_event_budget/budget = event_budgets[cell.key]
	if(budget && !source_present && !budget.active_event_count && !budget.active_spawn_event_count && !budget.next_attempt_at && !budget.next_turf_attempt_at)
		budget.next_attempt_at = 0
		budget.next_turf_attempt_at = 0
		event_budgets -= cell.key
		qdel(budget)
		budget = null
	if(budget && (budget.active_event_count || budget.active_spawn_event_count || budget.next_attempt_at || budget.next_turf_attempt_at))
		return
	if(!source_present)
		remove_field_cell(cell)

/datum/controller/subsystem/redspace/proc/cell_has_active_source(datum/redspace_field_cell/cell)
	if(!cell)
		return FALSE
	var/turf/sample_turf = cell.get_sample_turf()
	if(!sample_turf)
		return FALSE
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(!source || !source.strength)
			continue
		if(source.z_level != cell.z_level)
			continue
		if(source.coverage_cell_lookup && source.coverage_cell_lookup[cell.key])
			return TRUE
		if(source.can_affect(sample_turf))
			return TRUE
		var/center_x = source.origin_x
		var/center_y = source.origin_y
		if(istype(source, /datum/redspace_field_source/wave))
			var/datum/redspace_field_source/wave/wave_source = source
			wave_source.update_current_center()
			center_x = wave_source.current_center_x
			center_y = wave_source.current_center_y
		if(!center_x || !center_y)
			continue
		var/coverage_radius = source.radius + REDSPACE_HEX_RADIUS
		var/delta_x = sample_turf.x - center_x
		var/delta_y = sample_turf.y - center_y
		if(delta_x * delta_x + delta_y * delta_y <= coverage_radius * coverage_radius)
			return TRUE
	return FALSE

/// Adds a cell to the bounded dirty queue and wakes the subsystem if needed.
/datum/controller/subsystem/redspace/proc/mark_cell_dirty(datum/redspace_field_cell/cell, reason = null)
	if(!cell || QDELETED(cell))
		return
	if(!isnull(reason))
		cell.pending_change_reason = reason
	if(!cell.dirty_queued)
		cell.dirty_queued = TRUE
		dirty_cells += cell
		metric_dirty_cells_enqueued++
		metric_peak_dirty_cells = max(metric_peak_dirty_cells, length(dirty_cells))
	wake()

/// Processes one cached cell after its value has been refreshed.
/datum/controller/subsystem/redspace/proc/process_dirty_cell(datum/redspace_field_cell/cell)
	if(!cell || QDELETED(cell))
		return
	metric_dirty_cells_processed++

	var/value_changed = cell.value != cell.last_notified_value
	var/state_changed = cell.state != cell.last_notified_state
	var/reason = cell.pending_change_reason || cell.last_change_reason || "обновление поля"
	var/old_value = cell.last_notified_value
	var/old_state = cell.last_notified_state
	if(state_changed)
		record_state_transition(cell, old_state, cell.state, old_value, cell.value, reason)
		if(cell_has_event_anchor(cell) && redspace_state_is_escalation(old_state, cell.state))
			var/datum/redspace_event_profile/event_profile = get_event_profile(cell.state)
			if(event_profile_has_automatic_event(event_profile) && event_profile.should_attempt())
				try_start_automatic_event(cell)
			if(event_profile_has_automatic_event(event_profile, REDSPACE_EVENT_CATEGORY_TURF_SPAWN) && event_profile.should_attempt())
				try_start_automatic_event(cell, REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
		if(cell_has_event_anchor(cell))
			schedule_event_attempt(cell)
		else
			clear_event_schedule(cell)

	if(value_changed || state_changed)
		cell.last_notified_value = cell.value
		cell.last_notified_state = cell.state
	cell.pending_change_reason = null
	if(!value_changed && !state_changed && !length(cell.listeners))
		return

	for(var/datum/listener as anything in cell.listeners.Copy())
		if(!listener || QDELETED(listener))
			unregister_field_listener(listener)
			continue
		var/turf/listener_target = field_listener_targets[listener]
		if(!listener_target || QDELETED(listener_target) || !is_supported_z(listener_target.z))
			unregister_field_listener(listener)
			continue
		var/new_listener_value = calculate_value(listener_target, cell)
		var/old_listener_value = field_listener_values[listener]
		var/old_listener_state = field_listener_states[listener]
		var/new_listener_state = redspace_state_with_hysteresis(new_listener_value, old_listener_state)
		if(old_listener_value == new_listener_value && old_listener_state == new_listener_state)
			continue
		field_listener_values[listener] = new_listener_value
		field_listener_states[listener] = new_listener_state
		SEND_SIGNAL(listener, COMSIG_REDSPACE_FIELD_CHANGED, cell, old_listener_value, new_listener_value, old_listener_state, new_listener_state, reason)
