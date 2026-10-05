#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Harmless definitions exercise real selection, budgets and lifecycle signals.
/datum/redspace_event/unit_test_scheduler
	event_id = "scheduler_effect"
	automatic = TRUE
	budget_cost = 0

/datum/redspace_event/unit_test_scheduler/start(client/admin, turf/target)
	return TRUE

/datum/redspace_event/spawn/turf/unit_test_scheduler
	event_id = "scheduler_turf"
	automatic = TRUE
	spawn_budget_cost = 0
	continues_after_start = FALSE

/datum/redspace_event/spawn/turf/unit_test_scheduler/start(client/admin, turf/target)
	return TRUE

/datum/redspace_field_source/hotspot/unit_test_scheduler
	var/growth_calls = 0
	var/list/growth_coverage_turfs
	var/delete_on_growth = FALSE

/datum/redspace_field_source/hotspot/unit_test_scheduler/process_growth()
	growth_calls++
	if(delete_on_growth)
		SSredspace.remove_source(source_id)
		return
	if(growth_coverage_turfs)
		coverage_turfs = growth_coverage_turfs
		growth_coverage_turfs = null

/datum/redspace_field_source/hotspot/unit_test_scheduler/requires_processing()
	return TRUE

/datum/unit_test/redspace_scheduler
	parent_type = /datum/unit_test/redspace_observers
	abstract_type = /datum/unit_test/redspace_scheduler
	var/list/datum/redspace_field_cell/test_cells = list()
	var/list/started_keys = list()
	var/normal_started = 0
	var/turf_started = 0
	var/saved_tick_limit

/datum/unit_test/redspace_scheduler/New()
	. = ..()
	// Work-step budgets drive these synchronous tests; real MC load must not
	// repeatedly stop them before the first step. Always restore in Destroy().
	saved_tick_limit = Master.current_ticklimit
	Master.current_ticklimit = INFINITY
	SSredspace.context.background_value = 10
	var/datum/redspace_profile/profile = new("scheduler_test")
	profile.event_profiles["[REDSPACE_STATE_STORM]"] = new /datum/redspace_event_profile(REDSPACE_STATE_STORM, 1 MINUTES, 1 MINUTES, 100, list("scheduler_effect" = 1, "scheduler_turf" = 1))
	SSredspace.context.active_profile = profile
	SSredspace.context.active_profile_id = profile.profile_id
	SSredspace.register_event_type(/datum/redspace_event/unit_test_scheduler)
	SSredspace.register_event_type(/datum/redspace_event/spawn/turf/unit_test_scheduler)
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_levels))
		return
	SSredspace.station_z_levels |= station_levels[1]
	var/list/seen_keys = list()
	var/turf/station_center = locate(128, 128, station_levels[1])
	for(var/turf/open/floor/candidate as anything in RANGE_TURFS(40, station_center))
		if(!SSredspace.is_event_target_turf_valid(candidate))
			continue
		var/datum/redspace_field_cell/cell = SSredspace.get_cell(candidate, TRUE)
		if(seen_keys[cell.key])
			continue
		seen_keys[cell.key] = TRUE
		cell.forced_value = 10
		SSredspace.schedule_event_attempt(cell)
		test_cells += cell
		SSredspace.event_candidate_cache[cell.key] = list(candidate)
		if(length(test_cells) == 5)
			break
	SSredspace.event_candidate_cache_time = world.time
	SSredspace.register_event_listener(src)
	RegisterSignal(src, COMSIG_REDSPACE_EVENT_STARTED, PROC_REF(on_started))

/datum/unit_test/redspace_scheduler/Destroy()
	UnregisterSignal(src, COMSIG_REDSPACE_EVENT_STARTED)
	SSredspace.unregister_event_listener(src)
	Master.current_ticklimit = saved_tick_limit
	return ..()

/datum/unit_test/redspace_scheduler/proc/on_started(datum/source, datum/redspace_event/event, list/event_context, reason)
	SIGNAL_HANDLER
	if(event.get_spawn_category() == REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
		turf_started++
	else
		normal_started++
	started_keys += "[event_context["zone_key"]]:[event.event_id]"

/datum/unit_test/redspace_scheduler/proc/make_due(cell_count = 5)
	for(var/index in 1 to min(cell_count, length(test_cells)))
		var/datum/redspace_field_cell/cell = test_cells[index]
		var/datum/redspace_event_budget/budget = SSredspace.event_budgets[cell.key]
		budget.next_attempt_at = world.time
		budget.next_turf_attempt_at = world.time
	SSredspace.event_wake_dirty = TRUE

/datum/unit_test/redspace_scheduler/proc/drain_schedule(step_budget = 1)
	for(var/pass in 1 to 2000)
		SSredspace.state = SS_RUNNING
		SSredspace.unit_test_work_remaining = step_budget
		if(SSredspace.process_scheduled_events())
			return TRUE
	return FALSE

/datum/unit_test/redspace_scheduler/selection_resume

/datum/unit_test/redspace_scheduler/selection_resume/Run()
	if(length(test_cells) != 5)
		return Fail("Scheduler tests require five usable station hexes")
	var/datum/redspace_field_cell/cell = test_cells[1]
	var/datum/redspace_event_budget/budget = SSredspace.event_budgets[cell.key]
	budget.next_attempt_at = world.time
	var/due_at = budget.next_attempt_at
	SSredspace.event_candidate_cache.Cut()
	var/datum/redspace_event_attempt/attempt = SSredspace.queue_automatic_event_attempt(cell, null, budget)
	SSredspace.automatic_event_attempts_remaining = 8
	SSredspace.unit_test_work_remaining = 0
	if(SSredspace.try_start_automatic_event(attempt) != REDSPACE_ATTEMPT_DEFERRED || budget.next_attempt_at != due_at || SSredspace.automatic_event_attempts_remaining != 7)
		return Fail("A yielded selection must retain its deadline and charge the attempt only once")
	var/result
	var/saw_partial_scan = FALSE
	for(var/pass in 1 to 2000)
		SSredspace.state = SS_RUNNING
		SSredspace.unit_test_work_remaining = 1
		result = SSredspace.try_start_automatic_event(attempt)
		if(SSredspace.automatic_event_attempts_remaining != 7 || SSredspace.event_value_cache)
			return Fail("Resuming selection must neither spend another attempt nor leak the point cache")
		if(attempt.scan_cursor > 1 && !attempt.turfs_ready)
			saw_partial_scan = TRUE
			if(!isnull(SSredspace.event_candidate_cache[cell.key]))
				return Fail("An interrupted turf scan must not publish a partial candidate cache")
		if(result != REDSPACE_ATTEMPT_DEFERRED)
			break
	if(result != REDSPACE_ATTEMPT_STARTED || !saw_partial_scan || normal_started != 1 || budget.next_attempt_at != due_at)
		return Fail("One-step resumes must finish the whole definition/turf/target scan and start exactly once")
	SSredspace.finish_automatic_event_attempt(attempt)
	if(budget.next_attempt_at != world.time + 1 MINUTES || length(SSredspace.event_attempt_queue))
		return Fail("Only a completed scheduled attempt may advance the cadence")

/datum/unit_test/redspace_scheduler/zones_and_categories

/datum/unit_test/redspace_scheduler/zones_and_categories/Run()
	make_due(3)
	SSredspace.automatic_event_attempts_remaining = 8
	if(!drain_schedule() || normal_started != 3 || turf_started != 3 || SSredspace.metric_automatic_attempts != 6 || SSredspace.automatic_event_attempts_remaining != 2)
		return Fail("A tiny work budget must finish both queues in all three due zones exactly once")
	var/list/unique_starts = list()
	for(var/start_key in started_keys)
		if(unique_starts[start_key])
			return Fail("A scheduled zone/category must not restart after an MC yield")
		unique_starts[start_key] = TRUE
	for(var/index in 1 to 3)
		var/datum/redspace_field_cell/cell = test_cells[index]
		var/datum/redspace_event_budget/budget = SSredspace.event_budgets[cell.key]
		if(budget.next_attempt_at != world.time + 1 MINUTES || budget.next_turf_attempt_at != world.time + 1 MINUTES)
			return Fail("Completed normal and turf attempts must retain the profile cadence")
	if(!drain_schedule() || length(started_keys) != 6)
		return Fail("Calling the scheduler before the next deadline must not create extra events")

/datum/unit_test/redspace_scheduler/fire_limit

/datum/unit_test/redspace_scheduler/fire_limit/Run()
	make_due()
	var/resumed = FALSE
	for(var/pass in 1 to 2000)
		SSredspace.state = SS_RUNNING
		SSredspace.unit_test_work_remaining = 1
		SSredspace.fire(resumed)
		if(SSredspace.metric_automatic_attempts > REDSPACE_MAX_AUTOMATIC_EVENT_ATTEMPTS_PER_FIRE)
			return Fail("Resumed fire calls must not replenish the global attempt quota")
		if(SSredspace.state != SS_PAUSED)
			break
		resumed = TRUE
	if(length(started_keys) != 8 || length(SSredspace.event_attempt_queue) != 2 || !SSredspace.can_fire)
		return Fail("The first fire must start eight attempts and retain the last zone's two jobs")
	var/datum/redspace_field_cell/last_cell = test_cells[5]
	var/datum/redspace_event_budget/last_budget = SSredspace.event_budgets[last_cell.key]
	if(last_budget.next_attempt_at != world.time || last_budget.next_turf_attempt_at != world.time)
		return Fail("The global quota must not consume the deferred zone's scheduled deadlines")
	SSredspace.unit_test_work_remaining = null
	SSredspace.state = SS_RUNNING
	SSredspace.fire(FALSE)
	if(normal_started != 5 || turf_started != 5 || length(SSredspace.event_attempt_queue) || SSredspace.event_pass_in_progress)
		return Fail("The next normal fire must resume the final zone without preferring the start of the list")

/datum/unit_test/redspace_scheduler/rejections

/datum/unit_test/redspace_scheduler/rejections/Run()
	var/datum/redspace_event_profile/profile = SSredspace.get_event_profile(REDSPACE_STATE_STORM)
	profile.attempt_probability = 0
	make_due(1)
	SSredspace.automatic_event_attempts_remaining = 8
	if(!drain_schedule() || SSredspace.metric_automatic_attempts || length(started_keys))
		return Fail("A probability miss must complete its cadence without spending a selection quota")
	var/datum/redspace_field_cell/cell = test_cells[1]
	var/datum/redspace_event_budget/budget = SSredspace.event_budgets[cell.key]
	if(budget.next_attempt_at <= world.time || budget.next_turf_attempt_at <= world.time)
		return Fail("A probability miss must not become a per-tick event loop")
	profile.attempt_probability = 100
	budget.next_attempt_at = world.time
	SSredspace.event_cooldowns["scheduler_effect:[cell.key]"] = world.time + 1 MINUTES
	SSredspace.event_wake_dirty = TRUE
	if(!drain_schedule() || SSredspace.metric_automatic_attempts != 1 || budget.next_attempt_at <= world.time || length(started_keys))
		return Fail("A cooldown rejection must consume one complete attempt and schedule the next cadence")
	SSredspace.event_cooldowns.Cut()
	SSredspace.event_candidate_cache[cell.key] = list()
	SSredspace.event_candidate_cache_time = world.time
	budget.next_attempt_at = world.time
	SSredspace.event_wake_dirty = TRUE
	if(!drain_schedule() || SSredspace.metric_automatic_attempts != 2 || budget.next_attempt_at <= world.time || length(started_keys))
		return Fail("A missing-target rejection must consume its cadence and release its temporary definitions")

/datum/unit_test/redspace_scheduler/cancellation

/datum/unit_test/redspace_scheduler/cancellation/Run()
	var/datum/redspace_field_cell/cell = test_cells[1]
	var/datum/redspace_event_budget/budget = SSredspace.event_budgets[cell.key]
	budget.next_attempt_at = world.time
	var/datum/redspace_event_attempt/attempt = SSredspace.queue_automatic_event_attempt(cell, null, budget)
	SSredspace.unit_test_work_remaining = 1
	if(SSredspace.try_start_automatic_event(attempt) != REDSPACE_ATTEMPT_DEFERRED || !length(attempt.candidate_events))
		return Fail("Cancellation test must hold a live temporary definition across a yield")
	var/datum/redspace_event/temporary_event = attempt.candidate_events[1] ? attempt.candidate_events[attempt.candidate_events[1]] : null
	budget.next_attempt_at = world.time + 10 MINUTES
	SSredspace.state = SS_RUNNING
	if(SSredspace.try_start_automatic_event(attempt) != REDSPACE_ATTEMPT_REJECTED)
		return Fail("A selection with an obsolete scheduled deadline must be rejected")
	SSredspace.finish_automatic_event_attempt(attempt)
	if(!QDELETED(temporary_event) || budget.next_attempt_at != world.time + 10 MINUTES)
		return Fail("Cancelling old work must delete its definitions without overwriting a newer schedule")
	attempt = SSredspace.queue_automatic_event_attempt(cell)
	SSredspace.state = SS_RUNNING
	SSredspace.unit_test_work_remaining = 1
	SSredspace.try_start_automatic_event(attempt)
	SSredspace.clear_scheduled_event_attempts()
	if(!QDELETED(attempt) || length(SSredspace.event_attempt_queue) || length(SSredspace.event_attempt_lookup) || SSredspace.event_pass_in_progress || SSredspace.event_value_cache)
		return Fail("Disabling automatic schedules must clear all resumable jobs and caches")

/datum/unit_test/redspace_scheduler/source_resume

/datum/unit_test/redspace_scheduler/source_resume/Run()
	var/list/sources = list()
	for(var/index in 1 to 3)
		var/datum/redspace_field_cell/cell = test_cells[index]
		var/datum/redspace_field_source/hotspot/unit_test_scheduler/source = allocate(/datum/redspace_field_source/hotspot/unit_test_scheduler, index, cell.get_sample_turf(), 0, 1, "scheduler_test")
		source.coverage_turfs = list(test_cells[1].get_sample_turf(), test_cells[2].get_sample_turf(), test_cells[3].get_sample_turf())
		source.coverage_seen_cells = list()
		if(index == 1)
			// Real growth may begin coverage discovery inside process_growth().
			source.growth_coverage_turfs = source.coverage_turfs
			source.coverage_turfs = null
		source.coverage_center_x = source.origin_x
		source.coverage_center_y = source.origin_y
		SSredspace.field_sources["[index]"] = source
		SSredspace.processing_sources["[index]"] = source
		sources += source
	var/completed = FALSE
	for(var/pass in 1 to 100)
		SSredspace.state = SS_RUNNING
		SSredspace.unit_test_work_remaining = 2
		if(SSredspace.process_sources())
			completed = TRUE
			break
	if(!completed || SSredspace.source_pass_in_progress || length(SSredspace.source_currentrun) || !SSredspace.refresh_in_progress)
		return Fail("The outer source pass must resume coverage and publish its accumulated refresh")
	for(var/datum/redspace_field_source/hotspot/unit_test_scheduler/source as anything in sources)
		if(source.growth_calls != 1 || length(source.coverage_cell_keys) != 3 || source.coverage_turfs)
			return Fail("Resuming coverage must grow every source once and finish every source's coverage")

/datum/unit_test/redspace_scheduler/source_removal

/datum/unit_test/redspace_scheduler/source_removal/Run()
	var/list/sources = list()
	for(var/index in 1 to 3)
		var/datum/redspace_field_cell/cell = test_cells[index]
		var/datum/redspace_field_source/hotspot/unit_test_scheduler/source = allocate(/datum/redspace_field_source/hotspot/unit_test_scheduler, index, cell.get_sample_turf(), 0, 1, "scheduler_test")
		SSredspace.field_sources["[index]"] = source
		SSredspace.processing_sources["[index]"] = source
		sources += source
	var/datum/redspace_field_source/hotspot/unit_test_scheduler/removed_source = sources[1]
	removed_source.delete_on_growth = TRUE
	var/datum/redspace_field_source/hotspot/unit_test_scheduler/expired_source = sources[2]
	expired_source.expires_at = world.time - 1
	var/completed = FALSE
	for(var/pass in 1 to 100)
		SSredspace.state = SS_RUNNING
		SSredspace.unit_test_work_remaining = 1
		if(SSredspace.process_sources())
			completed = TRUE
			break
	var/datum/redspace_field_source/hotspot/unit_test_scheduler/remaining_source = sources[3]
	if(!completed || !QDELETED(removed_source) || !QDELETED(expired_source) || remaining_source.growth_calls != 1 || length(SSredspace.processing_sources) != 1 || length(SSredspace.field_sources) != 1)
		return Fail("Deletion during growth and expiry must not skip or restart the next source")

/datum/unit_test/redspace_scheduler/timer_batch

/datum/unit_test/redspace_scheduler/timer_batch/Run()
	var/datum/redspace_event_profile/profile = SSredspace.get_event_profile(REDSPACE_STATE_STORM)
	profile.attempt_probability = 0
	SSredspace.reset_metrics()
	SSredspace.event_wake_at = world.time + 10 MINUTES
	for(var/pass in 1 to 10)
		for(var/datum/redspace_field_cell/cell as anything in test_cells)
			SSredspace.schedule_event_attempt(cell, TRUE)
	if(SSredspace.metric_event_wake_scans || !SSredspace.event_wake_dirty)
		return Fail("Scheduling fifty cell updates must defer the timer-table scan")
	if(!drain_schedule() || SSredspace.metric_event_wake_scans != 1 || SSredspace.event_wake_dirty || SSredspace.event_wake_at != world.time + 1 MINUTES)
		return Fail("One completed batch must recompute the earliest wake once and handle newly due schedules")

/datum/unit_test/redspace_scheduler/timer_rearm

/datum/unit_test/redspace_scheduler/timer_rearm/Run()
	SSredspace.schedule_event_wake()
	for(var/datum/redspace_field_cell/cell as anything in test_cells)
		var/datum/redspace_event_budget/budget = SSredspace.event_budgets[cell.key]
		budget.next_attempt_at = world.time + 5 MINUTES
		budget.next_turf_attempt_at = world.time + 6 MINUTES
	SSredspace.schedule_event_wake()
	if(SSredspace.event_wake_at != world.time + 5 MINUTES)
		return Fail("A completed batch must move an existing timer to the new earliest deadline")
	// Emulate the expired timer without leaving a live test callback behind.
	SSredspace.clear_event_wake_timer()
	SSredspace.wake_scheduled_events()
	if(!SSredspace.event_wake_dirty || !drain_schedule() || SSredspace.event_wake_timer_id == TIMER_ID_NULL || SSredspace.event_wake_at != world.time + 5 MINUTES || length(started_keys))
		return Fail("An early wake must re-arm future schedules even when no zone is due yet")

#endif
