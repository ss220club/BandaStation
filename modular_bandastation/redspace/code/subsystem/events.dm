// Event registry, budget reservations and explicit event lifecycle.
// These procs extend SSredspace; shared state and lifecycle live in ../redspace_subsystem.dm.

/datum/controller/subsystem/redspace/proc/cancel_active_events(reason)
	while(length(active_events))
		var/datum/redspace_event/event = active_events[1]
		if(!event)
			active_events.Cut(1, 2)
			continue
		finish_registered_event(event, event.event_target, reason || "событие отменено")

/// Cancels events that were selected automatically when automatic activity is disabled.
/datum/controller/subsystem/redspace/proc/cancel_automatic_events(reason)
	for(var/datum/redspace_event/event as anything in active_events.Copy())
		if(!event || !event.started_automatically)
			continue
		finish_registered_event(event, event.event_target, reason || "автоматическое событие отменено")

/// Adds an event definition to the registry without coupling it to the field cycle.
/datum/controller/subsystem/redspace/proc/register_event_type(event_type)
	if(!ispath(event_type, /datum/redspace_event))
		return FALSE
	var/datum/redspace_event/prototype = new event_type
	if(!prototype || !prototype.event_id || event_registry[prototype.event_id])
		qdel(prototype)
		return FALSE
	var/event_id = prototype.event_id
	event_registry[event_id] = event_type
	qdel(prototype)
	for(var/state in context?.active_profile?.event_profiles)
		var/datum/redspace_event_profile/event_profile = context.active_profile.event_profiles[state]
		if(event_profile)
			event_profile.automatic_event_cache.Cut()
	return TRUE

/// Registers a spawn event explicitly while keeping it in the common profile registry.
/datum/controller/subsystem/redspace/proc/register_spawn_event_type(event_type)
	if(!ispath(event_type, /datum/redspace_event/spawn))
		return FALSE
	return register_event_type(event_type)

/// Creates a fresh instance of a registered event definition.
/datum/controller/subsystem/redspace/proc/create_registered_event(event_id, list/event_args) as /datum/redspace_event
	var/event_type = event_registry[event_id]
	if(!event_type)
		return
	if(length(event_args))
		return new event_type(arglist(event_args))
	return new event_type

/datum/controller/subsystem/redspace/proc/get_event_zone_key(turf/target)
	if(!target || !is_supported_z(target.z))
		return
	var/list/hex_coordinates = redspace_hex_coordinates(target)
	if(!hex_coordinates)
		return
	return redspace_hex_key(target.z, hex_coordinates[1], hex_coordinates[2])

/datum/controller/subsystem/redspace/proc/get_event_budget(zone_key, create = FALSE) as /datum/redspace_event_budget
	if(!zone_key)
		return
	var/datum/redspace_event_budget/budget = event_budgets[zone_key]
	if(!budget && create)
		budget = new(zone_key)
		event_budgets[zone_key] = budget
	return budget

/datum/controller/subsystem/redspace/proc/get_event_cooldown_key(datum/redspace_event/event, turf/target)
	if(!event || !target)
		return
	var/zone_key = get_event_zone_key(target)
	if(!zone_key)
		return
	return "[event.event_id]:[zone_key]"

/datum/controller/subsystem/redspace/proc/can_start_event_instance(datum/redspace_event/event, turf/target)
	if(!event || !event.can_start(target))
		return FALSE

	var/zone_key = get_event_zone_key(target)
	if(!zone_key)
		return FALSE
	event.budget_zone_key = zone_key

	var/cooldown_key = get_event_cooldown_key(event, target)
	var/available_at = event_cooldowns[cooldown_key]
	if(available_at && world.time < available_at)
		return FALSE

	var/datum/redspace_event_budget/budget = get_event_budget(zone_key)
	if(budget && !budget.can_start(event))
		return FALSE
	return TRUE

/// Runs a short registered event and applies its per-zone cooldown.
/// Long-lived invasion scenarios will get a separate lifecycle manager later.
/datum/controller/subsystem/redspace/proc/start_registered_event(event_id, client/admin, turf/target, list/event_args, started_automatically = FALSE)
	var/datum/redspace_event/event = create_registered_event(event_id, event_args)
	if(!event)
		return FALSE
	event.started_automatically = started_automatically
	if(started_automatically && !automatic_events_enabled())
		qdel(event)
		return FALSE
	if(!can_start_event_instance(event, target))
		qdel(event)
		return FALSE
	event.event_target = target

	var/datum/redspace_event_budget/budget = get_event_budget(event.budget_zone_key, TRUE)
	if(!budget.reserve(event))
		qdel(event)
		return FALSE

	active_events += event
	var/succeeded = event.start(admin, target)
	// Event start may create an obstacle or replace a turf, so do not reuse
	// candidate geometry for another queue in the same tick.
	event_candidate_cache.Cut()
	// A start callback may synchronously cancel or delete the event.
	if(QDELETED(event) || !(event in active_events))
		return FALSE
	if(!succeeded)
		finish_registered_event(event, target, "событие не удалось запустить", refund = TRUE, notify_finished = event.event_started_notified)
		return FALSE

	// Spawn events keep the instance alive, so emit their start signal here just
	// like short-lived events do from their start() implementation.
	if(!event.event_started_notified)
		notify_event_started(event, target, "событие началось")
	if(QDELETED(event) || !(event in active_events))
		return FALSE
	var/cooldown_key = get_event_cooldown_key(event, target)
	if(event.cooldown && cooldown_key)
		event_cooldowns[cooldown_key] = world.time + event.cooldown
	if(!event.continues_after_start)
		finish_registered_event(event, target, "событие завершено")
	return TRUE

/datum/controller/subsystem/redspace/proc/release_event_budget(datum/redspace_event/event, refund = FALSE)
	if(!event || !event.budget_zone_key)
		return FALSE
	var/datum/redspace_event_budget/budget = get_event_budget(event.budget_zone_key)
	if(!budget)
		return FALSE
	return budget.release(event, refund)

/datum/controller/subsystem/redspace/proc/cleanup_event_budget(zone_key)
	if(!zone_key)
		return
	var/datum/redspace_event_budget/budget = event_budgets[zone_key]
	if(!budget || budget.active_event_count || budget.active_spawn_event_count || budget.next_attempt_at || budget.next_turf_attempt_at)
		return
	event_budgets -= zone_key
	qdel(budget)

/// Finalizes an active event exactly once, including cancellation and external qdel().
/// Failed starts refund their reservation and stay silent unless start was already notified.
/// Remove the event before callbacks so reentrant finishes and Destroy() cannot release it twice.
/datum/controller/subsystem/redspace/proc/finish_registered_event(datum/redspace_event/event, turf/target, reason = null, refund = FALSE, notify_finished = TRUE)
	if(!event || !(event in active_events))
		return FALSE
	active_events -= event
	var/zone_key = event.budget_zone_key
	release_event_budget(event, refund)
	if(notify_finished)
		notify_event_finished(event, target, reason || "событие завершено")
	// Destroy() also enters here; qdel() must never recurse on a deleting datum.
	if(!QDELETED(event))
		qdel(event)
	cleanup_event_budget(zone_key)
	prune_event_cell(zone_key)
	wake()
	return TRUE
