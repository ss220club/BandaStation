// Subsystem statistics, transition journal and debug reset.
// These procs extend SSredspace; shared state and lifecycle live in ../redspace_subsystem.dm.

/datum/controller/subsystem/redspace/stat_entry(msg)
	var/background_label = context ? round(context.background_value, 0.1) : 0
	msg = "B:[background_label] Cells:[length(field_cells)] Sources:[length(field_sources)] Active:[length(active_events)]"
	return ..()

/datum/controller/subsystem/redspace/proc/reset_metrics()
	metric_sample_count = 0
	metric_value_calculation_count = 0
	metric_source_check_count = 0
	metric_dirty_cells_enqueued = 0
	metric_dirty_cells_processed = 0
	metric_events_started = 0
	metric_events_finished = 0
	metric_peak_field_cells = 0
	metric_peak_dirty_cells = 0
	metric_peak_processing_sources = 0

/// Removes all field state created during the current round.
/datum/controller/subsystem/redspace/proc/reset_debug_state()
	clear_event_wake_timer()
	cancel_active_events("событие отменено при сбросе поля")
	var/list/field_listeners_to_restore = list()
	for(var/datum/listener as anything in field_listeners)
		var/turf/listener_target = field_listener_targets[listener]
		if(!listener || QDELETED(listener) || !listener_target || QDELETED(listener_target))
			continue
		field_listeners_to_restore[listener] = list(
			"target" = listener_target,
			"value" = field_listener_values[listener],
			"state" = field_listener_states[listener],
		)
	var/list/event_listeners_to_restore = event_listeners.Copy()
	clear_listener_registrations()
	for(var/source_key in field_sources.Copy())
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(source)
			remove_source(source.source_id, "сброшено из debug-панели")
	field_sources.Cut()
	processing_sources.Cut()
	// Keep runtime ids monotonic through an in-round reset so stale admin
	// references cannot target a newly created source.

	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell)
			continue
		qdel(cell)
	field_cells.Cut()
	dirty_cells.Cut()
	currentrun.Cut()
	refresh_currentrun.Cut()
	refresh_in_progress = FALSE
	refresh_requested = FALSE
	refresh_requested_full = FALSE
	pending_refresh_keys.Cut()
	refresh_reason = null
	pending_refresh_reason = null
	prune_requested = FALSE
	transition_log.Cut()
	event_cooldowns.Cut()
	automatic_event_attempts_remaining = null
	event_value_cache = null
	event_candidate_cache.Cut()
	event_candidate_cache_time = -1
	for(var/zone_key in event_budgets)
		var/datum/redspace_event_budget/budget = event_budgets[zone_key]
		if(budget)
			qdel(budget)
	event_budgets.Cut()
	clear_event_wake_timer()
	reset_metrics()

	QDEL_NULL(context)
	context = new /datum/redspace_context(list(new /datum/redspace_context_provider/default()))
	context.refresh()
	station_z_levels = context.active_z_levels.Copy()
	for(var/datum/listener as anything in field_listeners_to_restore)
		var/list/restore_data = field_listeners_to_restore[listener]
		var/turf/listener_target = restore_data["target"]
		if(!listener || QDELETED(listener) || !listener_target || QDELETED(listener_target))
			continue
		if(!register_field_listener(listener, listener_target))
			continue
		var/datum/redspace_field_cell/cell = field_cells[field_listeners[listener]]
		var/new_value = field_listener_values[listener]
		var/new_state = field_listener_states[listener]
		var/old_value = restore_data["value"]
		var/old_state = restore_data["state"]
		if(old_value != new_value || old_state != new_state)
			SEND_SIGNAL(listener, COMSIG_REDSPACE_FIELD_CHANGED, cell, old_value, new_value, old_state, new_state, "поле сброшено")
	for(var/datum/listener as anything in event_listeners_to_restore)
		if(listener && !QDELETED(listener))
			register_event_listener(listener)
	can_fire = FALSE
	var/datum/station_trait/redspace_activity/round_trait = get_round_trait()
	if(round_trait)
		round_trait.on_redspace_reset()

/// Stores a bounded diagnostic entry for a gameplay-range transition.
/datum/controller/subsystem/redspace/proc/record_state_transition(datum/redspace_field_cell/cell, old_state, new_state, old_value, new_value, reason)
	if(!cell || old_state == new_state)
		return
	transition_log += list(list(
		"time" = world.time,
		"cell_key" = cell.key,
		"z" = cell.z_level,
		"q" = cell.q,
		"r" = cell.r,
		"sample_x" = cell.sample_x,
		"sample_y" = cell.sample_y,
		"old_state" = old_state,
		"new_state" = new_state,
		"old_value" = old_value,
		"new_value" = new_value,
		"reason" = reason,
	))
	while(length(transition_log) > REDSPACE_TRANSITION_LOG_LIMIT)
		transition_log.Cut(1, 2)
