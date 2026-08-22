#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_core

/datum/unit_test/redspace_core/Run()
	if(redspace_state_with_hysteresis(3.5, REDSPACE_STATE_DISTURBANCE) != REDSPACE_STATE_DISTURBANCE)
		return Fail("Disturbance must survive values above its exit threshold")
	if(redspace_state_with_hysteresis(3, REDSPACE_STATE_DISTURBANCE) != REDSPACE_STATE_CALM)
		return Fail("Disturbance must leave at its exit threshold")
	if(redspace_state_with_hysteresis(10, REDSPACE_STATE_CALM) != REDSPACE_STATE_STORM)
		return Fail("A large increase must skip directly to storm")
	if(redspace_state_with_hysteresis(6.5, REDSPACE_STATE_STORM) != REDSPACE_STATE_STORM)
		return Fail("Storm must survive values above its exit threshold")
	if(redspace_state_with_hysteresis(6, REDSPACE_STATE_STORM) != REDSPACE_STATE_DISTURBANCE)
		return Fail("Storm must leave at its exit threshold")
	if(redspace_state_with_hysteresis(0, REDSPACE_STATE_STORM) != REDSPACE_STATE_CALM)
		return Fail("A large decrease must skip directly to calm")
	if(redspace_state_with_hysteresis(0, REDSPACE_STATE_EBB) != REDSPACE_STATE_EBB)
		return Fail("Ebb must not end at zero")
	if(redspace_state_with_hysteresis(1, REDSPACE_STATE_EBB) != REDSPACE_STATE_CALM)
		return Fail("Ebb must end after returning to a stable positive value")
	if(!redspace_state_is_escalation(REDSPACE_STATE_CALM, REDSPACE_STATE_DISTURBANCE))
		return Fail("Calm to disturbance must be an automatic-event escalation")
	if(!redspace_state_is_escalation(REDSPACE_STATE_DISTURBANCE, REDSPACE_STATE_STORM))
		return Fail("Disturbance to storm must be an automatic-event escalation")
	if(redspace_state_is_escalation(REDSPACE_STATE_STORM, REDSPACE_STATE_DISTURBANCE))
		return Fail("Storm recovery must not start an automatic event")
	if(redspace_state_is_escalation(REDSPACE_STATE_EBB, REDSPACE_STATE_CALM))
		return Fail("Ebb recovery into calm must not start an automatic event")
	if(redspace_state_is_escalation(REDSPACE_STATE_STORM, REDSPACE_STATE_INVASION))
		return Fail("Event-only invasion must not start an automatic event")

	var/datum/redspace_profile/demonic/profile = new
	if(profile.profile_id != REDSPACE_PROFILE_DEMONIC || !profile.is_event_allowed("storm_pulse") || profile.is_event_allowed("unknown_event"))
		return Fail("The demonic profile must expose only its registered event set")
	var/datum/redspace_event_profile/calm_profile = profile.get_event_profile(REDSPACE_STATE_CALM)
	var/datum/redspace_event_profile/disturbance_profile = profile.get_event_profile(REDSPACE_STATE_DISTURBANCE)
	var/datum/redspace_event_profile/storm_profile = profile.get_event_profile(REDSPACE_STATE_STORM)
	if(!calm_profile || !disturbance_profile || !storm_profile)
		return Fail("The demonic profile must expose state-specific event profiles")
	if(profile.get_event_profile(REDSPACE_STATE_INVASION))
		return Fail("Invasion must not have an ordinary automatic-event profile")
	if(calm_profile.attempt_probability >= disturbance_profile.attempt_probability || !calm_profile.get_event_weight("calm_echo"))
		return Fail("Calm profile must be sparse and use only the harmless echo event")
	if(!disturbance_profile.get_event_weight("local_distortion") || disturbance_profile.get_event_weight("storm_pulse"))
		return Fail("Disturbance profile must keep storm events out of the low range")
	if(storm_profile.attempt_probability <= disturbance_profile.attempt_probability || storm_profile.get_event_weight("storm_pulse") <= 0)
		return Fail("Storm profile must attempt events more often and allow the storm pulse")
	qdel(profile)

	var/datum/redspace_field_cell/cell = new(1, 0, 0, "core_test", 0)
	cell.set_value(4, 10, "enter disturbance")
	cell.set_value(3.5, 20, "falling")
	if(cell.state != REDSPACE_STATE_DISTURBANCE)
		return Fail("Cell updates must use hysteresis")
	if(!cell.set_event_override(10.1, 30, "start invasion") || cell.state != REDSPACE_STATE_INVASION)
		return Fail("Event override must enter invasion")
	cell.clear_event_override()
	cell.set_value(3, 40, "finish invasion")
	if(cell.state != REDSPACE_STATE_CALM)
		return Fail("Clearing invasion must restore the ordinary range")
	qdel(cell)

	var/datum/redspace_event/calm_echo/calm_event = new
	if(calm_event.min_value != 0 || calm_event.max_value != 3 || !calm_event.automatic || calm_event.dangerous)
		return Fail("The calm echo must be harmless and limited to the calm range")
	qdel(calm_event)

	var/datum/redspace_event/local_distortion/event = new
	if(event.event_id != "local_distortion" || event.min_value != 4 || event.max_value != 6)
		return Fail("The safe redspace event must expose its 4-6 range")
	if(event.event_only || event.dangerous || !event.automatic || event.budget_cost != 1)
		return Fail("The safe redspace event must be automatic, non-dangerous and cost one budget point")
	qdel(event)

	var/datum/redspace_event/storm_pulse/storm_event = new
	if(storm_event.min_value != 7 || storm_event.max_value != 10 || !storm_event.continues_after_start || !storm_event.automatic)
		return Fail("The storm event must expose a delayed 7-10 lifecycle")
	if(!storm_event.dangerous || storm_event.budget_cost != 2)
		return Fail("The storm event must be marked as dangerous and cost two budget points")

	var/datum/redspace_event_budget/budget = new("budget_test")
	var/datum/redspace_event/local_distortion/budget_safe = new
	if(!budget.can_start(budget_safe) || !budget.reserve(budget_safe))
		return Fail("An empty event budget must accept a safe event")
	if(budget.active_event_count != 1 || budget.spent_points != 1)
		return Fail("The event budget must track active events and spent points")

	var/datum/redspace_event/storm_pulse/budget_storm = new
	budget.last_event_time = world.time - REDSPACE_EVENT_BUDGET_COOLDOWN
	if(!budget.can_start(budget_storm) || !budget.reserve(budget_storm))
		return Fail("The event budget must accept a dangerous event after cooldown")
	if(budget.active_dangerous_count != 1 || budget.spent_points != 3)
		return Fail("The event budget must track dangerous events and their cost")

	var/datum/redspace_event/storm_pulse/blocked_storm = new
	budget.last_event_time = world.time - REDSPACE_EVENT_BUDGET_COOLDOWN
	if(budget.can_start(blocked_storm))
		return Fail("The event budget must block a second active dangerous event")
	qdel(blocked_storm)

	budget.release(budget_storm)
	budget.release(budget_safe)
	budget.window_started = world.time - REDSPACE_EVENT_BUDGET_WINDOW
	budget.last_event_time = world.time - REDSPACE_EVENT_BUDGET_COOLDOWN
	if(!budget.can_start(budget_safe))
		return Fail("The event budget must reset spent points after its window")
	budget.release(budget_safe)

	var/datum/redspace_event/spawn/turf/turf_spawn = new
	var/datum/redspace_event/spawn/object/object_spawn = new
	var/datum/redspace_event/spawn/mob/mob_spawn = new
	if(turf_spawn.event_category != REDSPACE_EVENT_CATEGORY_TURF_SPAWN || object_spawn.event_category != REDSPACE_EVENT_CATEGORY_OBJECT_SPAWN || mob_spawn.event_category != REDSPACE_EVENT_CATEGORY_MOB_SPAWN)
		return Fail("Spawn event families must expose separate turf, object and mob categories")
	if(!turf_spawn.uses_spawn_budget() || turf_spawn.get_spawn_count() != 1 || turf_spawn.get_spawn_budget_cost() != 1)
		return Fail("Spawn event families must expose independent spawn budget metadata")

	var/datum/redspace_event/spawn/turf/too_many_turfs = new
	too_many_turfs.spawn_count = REDSPACE_SPAWN_BUDGET_MAX_TURFS + 1
	budget.last_spawn_event_time = world.time - REDSPACE_SPAWN_BUDGET_COOLDOWN
	if(budget.can_start(too_many_turfs))
		return Fail("Spawn budgets must enforce category-specific turf limits")

	// A mob spawn is allowed even when the ordinary dangerous-event budget is full.
	mob_spawn.dangerous = TRUE
	budget.active_dangerous_count = REDSPACE_EVENT_BUDGET_MAX_DANGEROUS
	budget.spent_points = REDSPACE_EVENT_BUDGET_MAX_POINTS
	budget.last_event_time = world.time
	budget.last_spawn_event_time = world.time - REDSPACE_SPAWN_BUDGET_COOLDOWN
	if(!budget.can_start(mob_spawn) || !budget.reserve(mob_spawn))
		return Fail("Spawn events must use their own budget instead of the dangerous-event limit")
	if(budget.active_dangerous_count != REDSPACE_EVENT_BUDGET_MAX_DANGEROUS || budget.active_spawn_event_count != 1 || budget.active_spawn_mob_count != 1)
		return Fail("Spawn reservations must not consume ordinary dangerous-event counters")
	budget.release(mob_spawn)

	qdel(too_many_turfs)
	qdel(turf_spawn)
	qdel(object_spawn)
	qdel(mob_spawn)
	qdel(budget_safe)
	qdel(budget_storm)
	qdel(budget)
	qdel(storm_event)

#endif
