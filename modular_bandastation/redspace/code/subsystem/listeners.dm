// Field and event subscriptions, signal payloads and listener cleanup.
// These procs extend SSredspace; shared state and lifecycle live in ../redspace_subsystem.dm.

/// Registers a datum for changes at the canonical tile containing target.
/datum/controller/subsystem/redspace/proc/register_field_listener(datum/listener, turf/target)
	if(!listener || !target || !is_supported_z(target.z))
		return FALSE
	if(field_listeners[listener])
		unregister_field_listener(listener)

	var/datum/redspace_field_cell/cell = get_cell(target, TRUE)
	if(!cell)
		return FALSE
	field_listeners[listener] = cell.key
	field_listener_targets[listener] = target
	var/initial_value = calculate_value(target, cell)
	field_listener_values[listener] = initial_value
	field_listener_states[listener] = redspace_state_from_value(initial_value)
	cell.listeners |= listener
	ensure_listener_cleanup(listener)
	return TRUE

/// Removes a datum's field listener registration.
/datum/controller/subsystem/redspace/proc/unregister_field_listener(datum/listener, prune = TRUE)
	if(!listener)
		return FALSE
	var/cell_key = field_listeners[listener]
	if(!isnull(cell_key))
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(cell)
			cell.listeners -= listener
		field_listeners -= listener
		field_listener_targets -= listener
		field_listener_values -= listener
		field_listener_states -= listener
		remove_listener_cleanup(listener)
		if(prune)
			prune_unused_cells()
		return TRUE
	return FALSE

/// Registers a datum for explicit redspace event lifecycle signals.
/datum/controller/subsystem/redspace/proc/register_event_listener(datum/listener)
	if(!listener)
		return FALSE
	event_listeners[listener] = TRUE
	ensure_listener_cleanup(listener)
	return TRUE

/// Removes a datum from the explicit event lifecycle listener set.
/datum/controller/subsystem/redspace/proc/unregister_event_listener(datum/listener)
	if(!listener || !event_listeners[listener])
		return FALSE
	event_listeners -= listener
	remove_listener_cleanup(listener)
	return TRUE

/// Sends an event-start signal only to registered scenario listeners.
/datum/controller/subsystem/redspace/proc/notify_event_started(datum/event, event_context = null, reason = null)
	if(isturf(event_context))
		event_context = get_event_context(event, event_context)
	var/datum/redspace_event/redspace_event = event
	if(redspace_event)
		if(redspace_event.event_started_notified)
			return
		redspace_event.event_started_notified = TRUE
	metric_events_started++
	for(var/datum/listener as anything in event_listeners.Copy())
		if(!listener || QDELETED(listener))
			unregister_event_listener(listener)
			continue
		SEND_SIGNAL(listener, COMSIG_REDSPACE_EVENT_STARTED, event, event_context, reason)

/// Sends an event-finished signal only to registered scenario listeners.
/datum/controller/subsystem/redspace/proc/notify_event_finished(datum/event, event_context = null, reason = null)
	if(isturf(event_context))
		event_context = get_event_context(event, event_context)
	var/datum/redspace_event/redspace_event = event
	if(redspace_event)
		if(redspace_event.event_finished_notified)
			return
		redspace_event.event_finished_notified = TRUE
	metric_events_finished++
	for(var/datum/listener as anything in event_listeners.Copy())
		if(!listener || QDELETED(listener))
			unregister_event_listener(listener)
			continue
		SEND_SIGNAL(listener, COMSIG_REDSPACE_EVENT_FINISHED, event, event_context, reason)

/// Builds the stable context payload shared by event lifecycle signals.
/datum/controller/subsystem/redspace/proc/get_event_context(datum/redspace_event/event, turf/target) as /list
	var/list/event_context = list(
		"target_turf" = target,
		"zone_key" = target ? get_event_zone_key(target) : null,
		"profile_id" = event?.profile_id,
		"event_category" = event?.event_category,
	)
	if(event?.source_id)
		event_context["source_id"] = event.source_id
	if(event && event.uses_spawn_budget())
		var/datum/redspace_event/spawn/spawn_event = event
		event_context["spawn_count"] = event.get_spawn_count()
		event_context["spawn_policy_id"] = spawn_event.spawn_policy_id
	return event_context

/// Sends an exposure signal directly to the object affected by an event.
/datum/controller/subsystem/redspace/proc/notify_exposure(datum/target, datum/redspace_event/event, amount, reason = null, source_id = null)
	if(!target || QDELETED(target))
		return
	if(isnull(source_id))
		source_id = event?.source_id
	return SEND_SIGNAL(target, COMSIG_REDSPACE_EXPOSURE, event, event?.profile_id, source_id, amount, reason)

/// Registers cleanup for a datum used by either listener registry.
/datum/controller/subsystem/redspace/proc/ensure_listener_cleanup(datum/listener)
	if(!listener || listener_cleanup[listener])
		return
	RegisterSignal(listener, COMSIG_QDELETING, PROC_REF(on_registered_listener_deleted))
	listener_cleanup[listener] = TRUE

/// Drops the cleanup hook once a datum has no redspace registrations left.
/datum/controller/subsystem/redspace/proc/remove_listener_cleanup(datum/listener)
	if(!listener || field_listeners[listener] || event_listeners[listener])
		return
	UnregisterSignal(listener, COMSIG_QDELETING)
	listener_cleanup -= listener

/// Removes a datum from every registry after it is deleted.
/datum/controller/subsystem/redspace/proc/on_registered_listener_deleted(datum/listener)
	SIGNAL_HANDLER
	var/cell_key = field_listeners[listener]
	if(!isnull(cell_key))
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(cell)
			cell.listeners -= listener
	field_listeners -= listener
	field_listener_targets -= listener
	field_listener_values -= listener
	field_listener_states -= listener
	event_listeners -= listener
	UnregisterSignal(listener, COMSIG_QDELETING)
	listener_cleanup -= listener
	prune_unused_cells()

/// Unregisters every field and event listener during round/reset cleanup.
/datum/controller/subsystem/redspace/proc/clear_listener_registrations()
	var/list/listeners = list()
	for(var/datum/listener as anything in field_listeners)
		listeners |= listener
	for(var/datum/listener as anything in event_listeners)
		listeners |= listener
	for(var/datum/listener as anything in listeners)
		if(listener)
			UnregisterSignal(listener, COMSIG_QDELETING)
	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(cell)
			cell.listeners.Cut()
	field_listeners.Cut()
	field_listener_targets.Cut()
	field_listener_values.Cut()
	field_listener_states.Cut()
	event_listeners.Cut()
	listener_cleanup.Cut()
