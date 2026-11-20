#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Isolate event registries for synchronous lifecycle tests, restoring them even on failure.
/datum/unit_test/redspace_event_lifecycle
	abstract_type = /datum/unit_test/redspace_event_lifecycle
	var/list/saved_state = list()
	var/started_count = 0
	var/finished_count = 0
	var/finish_on_start = FALSE
	var/reenter_on_finish = FALSE
	var/reentrant_finish_result
	var/datum/redspace_event/last_event
	var/list/last_finish_context
	var/last_finish_reason

/datum/unit_test/redspace_event_lifecycle/New()
	. = ..()
	// These tests do not sleep or run the MC while the registries are isolated.
	for(var/variable in list("active_events", "event_budgets", "event_registry", "event_cooldowns", "event_listeners", "event_candidate_cache", "field_cells"))
		saved_state[variable] = SSredspace.vars[variable]
		SSredspace.vars[variable] = list()
	for(var/variable in list("initialized", "station_z_levels", "metric_events_started", "metric_events_finished", "metric_peak_field_cells"))
		saved_state[variable] = SSredspace.vars[variable]
	SSredspace.initialized = FALSE
	SSredspace.station_z_levels = list(run_loc_floor_bottom_left.z)
	SSredspace.register_event_listener(src)
	RegisterSignal(src, COMSIG_REDSPACE_EVENT_STARTED, PROC_REF(on_event_started))
	RegisterSignal(src, COMSIG_REDSPACE_EVENT_FINISHED, PROC_REF(on_event_finished))

/datum/unit_test/redspace_event_lifecycle/Destroy()
	SSredspace.unregister_event_listener(src)
	UnregisterSignal(src, list(COMSIG_REDSPACE_EVENT_STARTED, COMSIG_REDSPACE_EVENT_FINISHED))
	SSredspace.cancel_active_events("lifecycle test cleanup")
	QDEL_LIST(allocated)
	QDEL_LIST_ASSOC_VAL(SSredspace.event_budgets)
	QDEL_LIST_ASSOC_VAL(SSredspace.field_cells)
	for(var/variable in saved_state)
		SSredspace.vars[variable] = saved_state[variable]
	saved_state.Cut()
	return ..()

/datum/unit_test/redspace_event_lifecycle/proc/on_event_started(datum/source, datum/redspace_event/event, list/event_context, reason)
	SIGNAL_HANDLER
	started_count++
	last_event = event
	if(finish_on_start)
		SSredspace.finish_registered_event(event, event.event_target, "cancelled by start listener")

/datum/unit_test/redspace_event_lifecycle/proc/on_event_finished(datum/source, datum/redspace_event/event, list/event_context, reason)
	SIGNAL_HANDLER
	finished_count++
	last_finish_context = event_context
	last_finish_reason = reason
	if(reenter_on_finish)
		reentrant_finish_result = SSredspace.finish_registered_event(event, event.event_target, "duplicate finish", refund = TRUE)

/// Reserve a real budget while keeping its queue alive so spent points remain inspectable.
/datum/unit_test/redspace_event_lifecycle/proc/track_event(datum/redspace_event/event)
	event.event_target = run_loc_floor_bottom_left
	event.budget_zone_key = SSredspace.get_event_zone_key(event.event_target)
	var/datum/redspace_event_budget/budget = SSredspace.get_event_budget(event.budget_zone_key, TRUE)
	budget.next_attempt_at = world.time + 1 MINUTES
	if(!budget.reserve(event))
		Fail("Could not reserve the test event budget")
		return
	SSredspace.active_events += event
	SSredspace.notify_event_started(event, event.event_target, "test event started")
	return budget

/datum/unit_test/redspace_event_lifecycle/finish_once

/datum/unit_test/redspace_event_lifecycle/finish_once/Run()
	var/datum/redspace_event/storm_pulse/event = allocate(/datum/redspace_event/storm_pulse)
	var/datum/redspace_event_budget/budget = track_event(event)
	event.telegraph_timer_id = addtimer(CALLBACK(event, TYPE_PROC_REF(/datum/redspace_event/storm_pulse, resolve)), 1 MINUTES, TIMER_STOPPABLE | TIMER_DELETE_ME)
	reenter_on_finish = TRUE
	if(!(SSredspace.finish_registered_event(event, event.event_target, "normal finish")))
		return Fail("First finish must succeed")
	if(!(!reentrant_finish_result))
		return Fail("A finish listener must not finalize the event twice")
	if(!(!SSredspace.finish_registered_event(event, event.event_target, "repeat", refund = TRUE)))
		return Fail("A repeated finish must not refund spent points")
	if(!(QDELETED(event)))
		return Fail("Finish must delete the event")
	if(!isnull(event.telegraph_timer_id))
		return Fail("Finish must cancel the telegraph timer")
	if(finished_count != 1)
		return Fail("Finish and Destroy must emit only one signal")
	if(last_finish_reason != "normal finish")
		return Fail("Lifecycle check failed: last_finish_reason != \"normal finish\"")
	if(last_finish_context["target_turf"] != run_loc_floor_bottom_left)
		return Fail("Lifecycle check failed: last_finish_context\[\"target_turf\"\] != run_loc_floor_bottom_left")
	if(budget.active_event_count != 0)
		return Fail("Lifecycle check failed: budget.active_event_count != 0")
	if(budget.active_dangerous_count != 0)
		return Fail("Lifecycle check failed: budget.active_dangerous_count != 0")
	if(budget.spent_points != event.budget_cost)
		return Fail("Completion must retain spent budget")
	if(length(budget.reserved_events) != 0)
		return Fail("Lifecycle check failed: length(budget.reserved_events) != 0")
	if(length(SSredspace.active_events) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.active_events) != 0")

/datum/unit_test/redspace_event_lifecycle/external_delete

/datum/unit_test/redspace_event_lifecycle/external_delete/Run()
	var/datum/redspace_event/spawn/mob/event = allocate(/datum/redspace_event/spawn/mob)
	var/datum/redspace_event_budget/budget = track_event(event)
	event.spawn_timer_id = addtimer(CALLBACK(event, TYPE_PROC_REF(/datum/redspace_event/spawn/mob, resolve_spawn)), 1 MINUTES, TIMER_STOPPABLE | TIMER_DELETE_ME)
	reenter_on_finish = TRUE
	qdel(event)
	if(!(QDELETED(event)))
		return Fail("External qdel must complete without a recursive Destroy")
	if(!isnull(event.spawn_timer_id))
		return Fail("External qdel must cancel pending mob spawns")
	if(!(!reentrant_finish_result))
		return Fail("External deletion must also reject a reentrant finish")
	if(finished_count != 1)
		return Fail("Lifecycle check failed: finished_count != 1")
	if(last_finish_reason != "событие уничтожено")
		return Fail("Lifecycle check failed: last_finish_reason != \"событие уничтожено\"")
	if(budget.active_spawn_event_count != 0)
		return Fail("Lifecycle check failed: budget.active_spawn_event_count != 0")
	if(budget.active_spawn_mob_count != 0)
		return Fail("Lifecycle check failed: budget.active_spawn_mob_count != 0")
	if(budget.mob_spawn_spent_points != event.spawn_budget_cost)
		return Fail("Lifecycle check failed: budget.mob_spawn_spent_points != event.spawn_budget_cost")
	if(length(budget.reserved_spawn_events) != 0)
		return Fail("Lifecycle check failed: length(budget.reserved_spawn_events) != 0")
	if(length(SSredspace.active_events) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.active_events) != 0")

/datum/unit_test/redspace_event_lifecycle/failed_start

/datum/unit_test/redspace_event_lifecycle/failed_start/Run()
	SSredspace.register_event_type(/datum/redspace_event/lifecycle_test/failed)
	SSredspace.register_event_type(/datum/redspace_event/lifecycle_test/failed/notifies)
	var/zone_key = SSredspace.get_event_zone_key(run_loc_floor_bottom_left)
	var/datum/redspace_event_budget/budget = SSredspace.get_event_budget(zone_key, TRUE)
	budget.next_attempt_at = world.time + 1 MINUTES
	if(!(!SSredspace.start_registered_event("lifecycle_test_failed", null, run_loc_floor_bottom_left)))
		return Fail("Failed start must return FALSE")
	if(budget.spent_points != 0)
		return Fail("Failed start must refund its reservation")
	if(budget.active_event_count != 0)
		return Fail("Lifecycle check failed: budget.active_event_count != 0")
	if(length(budget.reserved_events) != 0)
		return Fail("Lifecycle check failed: length(budget.reserved_events) != 0")
	if(started_count != 0)
		return Fail("Lifecycle check failed: started_count != 0")
	if(finished_count != 0)
		return Fail("A start that never notified listeners must finish silently")
	if(length(SSredspace.active_events) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.active_events) != 0")
	if(length(SSredspace.event_cooldowns) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.event_cooldowns) != 0")
	if(!(!SSredspace.start_registered_event("lifecycle_test_failed_notifies", null, run_loc_floor_bottom_left)))
		return Fail("Lifecycle check failed: !(!SSredspace.start_registered_event(\"lifecycle_test_failed_notifies\", null, run_loc_floor_bottom_left))")
	if(budget.spent_points != 0)
		return Fail("A failed start must refund even after its start signal")
	if(started_count != 1)
		return Fail("Lifecycle check failed: started_count != 1")
	if(finished_count != 1)
		return Fail("An announced start must have a matching finish on failure")
	// If no queue needs the budget, failed starts must also remove the empty budget.
	budget.next_attempt_at = 0
	if(!(!SSredspace.start_registered_event("lifecycle_test_failed", null, run_loc_floor_bottom_left)))
		return Fail("Lifecycle check failed: !(!SSredspace.start_registered_event(\"lifecycle_test_failed\", null, run_loc_floor_bottom_left))")
	if(!isnull(SSredspace.event_budgets[zone_key]))
		return Fail("Failed start must remove an unused budget")

/datum/unit_test/redspace_event_lifecycle/cancel_during_start

/datum/unit_test/redspace_event_lifecycle/cancel_during_start/Run()
	SSredspace.register_event_type(/datum/redspace_event/lifecycle_test)
	SSredspace.register_event_type(/datum/redspace_event/lifecycle_test/notifies)
	finish_on_start = TRUE
	// Exercise notification both inside start() and in the subsystem after start().
	for(var/event_id in list("lifecycle_test", "lifecycle_test_notifies"))
		if(!(!SSredspace.start_registered_event(event_id, null, run_loc_floor_bottom_left)))
			return Fail("Cancellation by a listener must prevent a successful start")
		if(!(QDELETED(last_event)))
			return Fail("Lifecycle check failed: !(QDELETED(last_event))")
		if(length(SSredspace.active_events) != 0)
			return Fail("Lifecycle check failed: length(SSredspace.active_events) != 0")
		if(length(SSredspace.event_budgets) != 0)
			return Fail("Lifecycle check failed: length(SSredspace.event_budgets) != 0")
		if(length(SSredspace.event_cooldowns) != 0)
			return Fail("Do not apply cooldown after cancellation during start")
	if(started_count != 2)
		return Fail("Lifecycle check failed: started_count != 2")
	if(finished_count != 2)
		return Fail("Lifecycle check failed: finished_count != 2")

/datum/unit_test/redspace_event_lifecycle/cancel_all

/datum/unit_test/redspace_event_lifecycle/cancel_all/Run()
	var/datum/redspace_event/event = allocate(/datum/redspace_event)
	var/datum/redspace_event_budget/budget = track_event(event)
	budget.next_attempt_at = 0
	var/zone_key = event.budget_zone_key
	var/datum/redspace_field_cell/cell = SSredspace.get_cell(event.event_target, TRUE)
	var/datum/redspace_event/spawn/object/spawn_event = allocate(/datum/redspace_event/spawn/object)
	track_event(spawn_event)
	budget.next_attempt_at = 0
	SSredspace.cancel_active_events("test cancellation")
	SSredspace.cancel_active_events("repeated cancellation")
	if(!(QDELETED(event) && QDELETED(spawn_event)))
		return Fail("Lifecycle check failed: !(QDELETED(event) && QDELETED(spawn_event))")
	if(finished_count != 2)
		return Fail("Lifecycle check failed: finished_count != 2")
	if(last_finish_reason != "test cancellation")
		return Fail("Lifecycle check failed: last_finish_reason != \"test cancellation\"")
	if(length(SSredspace.active_events) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.active_events) != 0")
	if(!isnull(SSredspace.event_budgets[zone_key]))
		return Fail("Cancel must remove an unused budget")
	if(!(QDELETED(cell)))
		return Fail("Cancel must prune an unused event cell")
	if(!isnull(SSredspace.field_cells[zone_key]))
		return Fail("Cancelled events must leave no unused cell")

/datum/unit_test/redspace_event_lifecycle/lightning_cancel

/datum/unit_test/redspace_event_lifecycle/lightning_cancel/Run()
	var/datum/redspace_event/lightning/event = allocate(/datum/redspace_event/lightning)
	// Debug lightning is tracked without a budget reservation.
	event.event_target = run_loc_floor_bottom_left
	event.target_turf = event.event_target
	SSredspace.active_events += event
	SSredspace.notify_event_started(event, event.event_target)
	event.resolve()
	if(!(QDELETED(event)))
		return Fail("Lightning without a valid target must be finalized")
	if(finished_count != 1)
		return Fail("Lifecycle check failed: finished_count != 1")
	if(length(SSredspace.active_events) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.active_events) != 0")
	if(length(SSredspace.event_budgets) != 0)
		return Fail("Lifecycle check failed: length(SSredspace.event_budgets) != 0")

/// Replacement must keep the spawn reservation until the replacement itself is removed.
/datum/unit_test/redspace_event_lifecycle/spawn_replacement

/datum/unit_test/redspace_event_lifecycle/spawn_replacement/Run()
	var/datum/redspace_event/storm_pulse/pulse = allocate(/datum/redspace_event/storm_pulse)
	if(!track_event(pulse))
		return
	var/datum/redspace_event/spawn/object/event = allocate(/datum/redspace_event/spawn/object)
	var/datum/redspace_event_budget/budget = track_event(event)
	if(!budget)
		return
	var/obj/item/original = allocate(/obj/item)
	var/obj/item/replacement = allocate(/obj/item)
	if(!event.register_spawned_atom(original) || SSredspace.get_spawn_event_for_atom(original) != event)
		return Fail("Owner lookup must skip the ordinary event preceding the spawn event")
	if(SSredspace.get_spawn_event_for_atom(null) || SSredspace.get_spawn_event_for_atom(replacement))
		return Fail("Missing or untracked atoms must not have a spawn event owner")
	if(event.replace_spawned_atom(original, null) || !(original in event.spawned_atoms))
		return Fail("A failed replacement must retain the original atom")
	if(!event.replace_spawned_atom(original, original) || length(event.spawned_atoms) != 1)
		return Fail("Replacing an atom with itself must keep its registration")
	if(!event.replace_spawned_atom(original, replacement))
		return Fail("A tracked atom must be replaceable")
	if(SSredspace.get_spawn_event_for_atom(original) || SSredspace.get_spawn_event_for_atom(replacement) != event)
		return Fail("Replacement must transfer the spawn event owner")
	qdel(original)
	if(QDELETED(event) || finished_count || budget.active_spawn_object_count != 1 || length(budget.reserved_spawn_events) != 1)
		return Fail("Deleting the original atom must not finish the event or release its reservation")
	qdel(replacement)
	if(!QDELETED(event) || finished_count != 1 || budget.active_spawn_event_count || budget.active_spawn_object_count || length(budget.reserved_spawn_events))
		return Fail("Deleting the replacement must finish the spawn event and release its reservation exactly once")
	if(SSredspace.finish_registered_event(event, event.event_target) || finished_count != 1 || QDELETED(pulse))
		return Fail("Repeated completion must leave the ordinary event and finish count unchanged")

/// Both Devourer outcomes must transfer their spawn owner through a mixed event registry.
/datum/unit_test/redspace_event_lifecycle/devourer_spawn_transfer
	abstract_type = /datum/unit_test/redspace_event_lifecycle/devourer_spawn_transfer
	var/player_controlled = FALSE

/datum/unit_test/redspace_event_lifecycle/devourer_spawn_transfer/Run()
	var/datum/redspace_event/storm_pulse/pulse = allocate(/datum/redspace_event/storm_pulse)
	var/datum/redspace_event_budget/budget = track_event(pulse)
	if(!budget)
		return
	// An ordinary event stays first in the registry for owned and unowned transformations.
	for(var/has_spawn_owner in list(TRUE, FALSE))
		var/mob/living/basic/demon/redspace/devourer/devourer = allocate(/mob/living/basic/demon/redspace/devourer)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
		victim.stat = HARD_CRIT
		if(!devourer.capture_victim(victim))
			return Fail("The transfer test must capture a transformation victim")
		var/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer/event
		if(has_spawn_owner)
			event = allocate(/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer)
			if(!track_event(event) || !event.register_spawned_atom(devourer))
				return Fail("The transfer test must reserve and track its Devourer spawn")
		var/finished_before = finished_count
		var/mob/living/basic/demon/redspace/moderate/transformed
		if(player_controlled)
			transformed = devourer.transform_with_victim("redspace_spawn_transfer_test")
		else
			transformed = devourer.transform_with_minotaur()
		if(!transformed || QDELETED(transformed))
			return Fail("Transformation must succeed with or without a spawn owner")
		allocated += transformed
		transformed.ckey = null
		var/expected_type = player_controlled ? /mob/living/basic/demon/redspace/moderate/ravager : /mob/living/basic/demon/redspace/moderate/minotaur
		if(!istype(transformed, expected_type) || !QDELETED(devourer))
			return Fail("Transformation must replace the Devourer with the expected demon")
		if(victim.loc != transformed || transformed.stored_victim != victim || !HAS_TRAIT(victim, TRAIT_STASIS))
			return Fail("Spawn owner transfer must preserve the captured body and its stasis")
		if(SSredspace.get_spawn_event_for_atom(transformed) != event || finished_count != finished_before)
			return Fail("Transformation must preserve the spawn owner without finishing an event")
		if(has_spawn_owner && (QDELETED(event) || length(event.spawned_atoms) != 1 || !(transformed in event.spawned_atoms) || budget.active_spawn_mob_count != 1 || length(budget.reserved_spawn_events) != 1 || budget.mob_spawn_spent_points != event.spawn_budget_cost))
			return Fail("Transformation must preserve the original spawn reservation")
		qdel(transformed)
		if(finished_count != finished_before + has_spawn_owner || budget.active_spawn_event_count || budget.active_spawn_mob_count || length(budget.reserved_spawn_events))
			return Fail("Removing the transformed demon must release only its own spawn reservation once")
		if(QDELETED(pulse) || budget.active_event_count != 1 || budget.active_dangerous_count != 1 || SSredspace.active_events[1] != pulse)
			return Fail("Transformation and cleanup must leave the ordinary storm event active")

/datum/unit_test/redspace_event_lifecycle/devourer_spawn_transfer/ravager
	player_controlled = TRUE

/datum/unit_test/redspace_event_lifecycle/devourer_spawn_transfer/minotaur

/// Deterministic event definitions exercise the public start API without gameplay effects.
/datum/redspace_event/lifecycle_test
	event_id = "lifecycle_test"
	continues_after_start = TRUE
	cooldown = 30 SECONDS

/datum/redspace_event/lifecycle_test/can_start(turf/target)
	return !!target

/datum/redspace_event/lifecycle_test/start(client/admin, turf/target)
	return TRUE

/datum/redspace_event/lifecycle_test/failed
	event_id = "lifecycle_test_failed"

/datum/redspace_event/lifecycle_test/failed/start(client/admin, turf/target)
	return FALSE

/datum/redspace_event/lifecycle_test/failed/notifies
	event_id = "lifecycle_test_failed_notifies"

/datum/redspace_event/lifecycle_test/failed/notifies/start(client/admin, turf/target)
	SSredspace.notify_event_started(src, target)
	return FALSE

/datum/redspace_event/lifecycle_test/notifies
	event_id = "lifecycle_test_notifies"

/datum/redspace_event/lifecycle_test/notifies/start(client/admin, turf/target)
	SSredspace.notify_event_started(src, target)
	return TRUE

#endif
