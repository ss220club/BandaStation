// Round activity, automatic event queues and candidate selection.
// These procs extend SSredspace; shared state and lifecycle live in ../redspace_subsystem.dm.

/// Removes pending automatic-event attempts without touching manually started events.
/datum/controller/subsystem/redspace/proc/clear_scheduled_event_attempts()
	for(var/zone_key in event_budgets.Copy())
		var/datum/redspace_event_budget/budget = event_budgets[zone_key]
		if(!budget)
			continue
		budget.next_attempt_at = 0
		budget.next_turf_attempt_at = 0
		budget.scheduled_state = null
		budget.turf_scheduled_state = null
		cleanup_event_budget(zone_key)
	clear_event_wake_timer()

/datum/controller/subsystem/redspace/proc/clear_event_wake_timer()
	if(event_wake_timer_id != TIMER_ID_NULL)
		deltimer(event_wake_timer_id)
	event_wake_timer_id = TIMER_ID_NULL
	event_wake_at = 0

/datum/controller/subsystem/redspace/proc/wake_scheduled_events()
	event_wake_timer_id = TIMER_ID_NULL
	event_wake_at = 0
	wake()

/datum/controller/subsystem/redspace/proc/schedule_event_wake_at(attempt_at)
	if(!attempt_at)
		return
	if(event_wake_timer_id != TIMER_ID_NULL && event_wake_at <= attempt_at)
		return
	clear_event_wake_timer()
	event_wake_at = attempt_at
	event_wake_timer_id = addtimer(CALLBACK(src, PROC_REF(wake_scheduled_events)), max(1, attempt_at - world.time), TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/controller/subsystem/redspace/proc/schedule_event_wake()
	var/earliest_attempt
	for(var/zone_key in event_budgets)
		var/datum/redspace_event_budget/budget = event_budgets[zone_key]
		if(!budget)
			continue
		if(budget.next_attempt_at && (isnull(earliest_attempt) || budget.next_attempt_at < earliest_attempt))
			earliest_attempt = budget.next_attempt_at
		if(budget.next_turf_attempt_at && (isnull(earliest_attempt) || budget.next_turf_attempt_at < earliest_attempt))
			earliest_attempt = budget.next_turf_attempt_at

	if(isnull(earliest_attempt))
		clear_event_wake_timer()
		return
	schedule_event_wake_at(earliest_attempt)

/// Returns the live station trait that owns the round's redspace activity, if any.
/datum/controller/subsystem/redspace/proc/get_round_trait() as /datum/station_trait/redspace_activity
	if(!SSstation)
		return
	for(var/datum/station_trait/trait as anything in SSstation.station_traits)
		if(istype(trait, /datum/station_trait/redspace_activity))
			return trait

/// Returns whether the round configuration allows automatic redspace events.
/datum/controller/subsystem/redspace/proc/automatic_events_enabled()
	var/datum/station_trait/redspace_activity/round_trait = get_round_trait()
	return !round_trait || round_trait.redspace_intensity != REDSPACE_INTENSITY_NONE

/// Creates a live base trait when an administrator enables redspace in a round
/// that did not roll one from the station-trait pool.
/datum/controller/subsystem/redspace/proc/ensure_round_trait() as /datum/station_trait/redspace_activity
	var/datum/station_trait/redspace_activity/round_trait = get_round_trait()
	if(round_trait)
		return round_trait
	if(!SSstation)
		return

	round_trait = new /datum/station_trait/redspace_activity
	SSstation.station_traits += round_trait
	if(SSticker?.HasRoundStarted())
		round_trait.on_round_start()
	return round_trait

/// Changes the declared redspace intensity through the live round feature.
/datum/controller/subsystem/redspace/proc/set_round_intensity(new_intensity, reason = null)
	var/datum/station_trait/redspace_activity/trait = ensure_round_trait()
	if(!trait || !trait.set_intensity(new_intensity))
		return FALSE
	var/change_reason = reason || "изменена интенсивность особенности раунда"
	log_game("[change_reason]: [new_intensity]")
	return TRUE

/// Returns the event cadence profile for a gameplay range of the active influence profile.
/datum/controller/subsystem/redspace/proc/get_event_profile(state) as /datum/redspace_event_profile
	return context?.active_profile?.get_event_profile(state)

/// Returns whether a profile has an automatic event in the requested queue.
/datum/controller/subsystem/redspace/proc/event_profile_has_automatic_event(datum/redspace_event_profile/event_profile, target_category = null)
	if(!event_profile)
		return FALSE
	var/cache_key = isnull(target_category) ? "normal" : target_category
	if(!isnull(event_profile.automatic_event_cache[cache_key]))
		return event_profile.automatic_event_cache[cache_key]

	var/has_automatic_event = FALSE
	for(var/event_id in event_profile.event_weights)
		var/event_type = event_registry[event_id]
		if(!event_type)
			continue
		var/datum/redspace_event/event = new event_type
		var/event_category = event.get_spawn_category()
		var/category_matches = isnull(target_category) ? event_category != REDSPACE_EVENT_CATEGORY_TURF_SPAWN : event_category == target_category
		var/is_match = event.automatic && category_matches
		qdel(event)
		if(is_match)
			has_automatic_event = TRUE
			break
	event_profile.automatic_event_cache[cache_key] = has_automatic_event
	return has_automatic_event

/// Ensures that a sparse active cell participates in both profile event queues.
/datum/controller/subsystem/redspace/proc/schedule_event_attempt(datum/redspace_field_cell/cell, immediate = FALSE)
	if(!automatic_events_enabled())
		if(cell)
			clear_event_schedule(cell)
		return FALSE
	if(!cell)
		return FALSE
	if(!cell_has_event_anchor(cell))
		clear_event_schedule(cell)
		return FALSE

	var/datum/redspace_event_profile/event_profile = get_event_profile(cell.state)
	var/datum/redspace_event_budget/budget = get_event_budget(cell.key, TRUE)
	if(!event_profile || !event_profile.has_events())
		clear_event_schedule(cell)
		return FALSE

	var/has_normal_events = event_profile_has_automatic_event(event_profile)
	var/has_turf_events = event_profile_has_automatic_event(event_profile, REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
	if(!has_normal_events && !has_turf_events)
		clear_event_schedule(cell)
		return FALSE

	if(has_normal_events)
		if(immediate)
			budget.next_attempt_at = world.time
		else if(budget.scheduled_state != cell.state || !budget.next_attempt_at)
			budget.next_attempt_at = world.time + get_event_attempt_delay(cell, event_profile)
		budget.scheduled_state = cell.state
	else
		budget.next_attempt_at = 0
		budget.scheduled_state = null

	if(has_turf_events)
		if(immediate)
			budget.next_turf_attempt_at = world.time
		else if(budget.turf_scheduled_state != cell.state || !budget.next_turf_attempt_at)
			budget.next_turf_attempt_at = world.time + get_event_attempt_delay(cell, event_profile)
		budget.turf_scheduled_state = cell.state
	else
		budget.next_turf_attempt_at = 0
		budget.turf_scheduled_state = null

	schedule_event_wake()
	wake()
	return TRUE

/datum/controller/subsystem/redspace/proc/get_event_attempt_delay(datum/redspace_field_cell/cell, datum/redspace_event_profile/event_profile)
	if(!event_profile)
		return 0

	var/attempt_delay = event_profile.get_next_attempt_delay()
	if(!is_sealing_active_in_cell(cell))
		return attempt_delay

	return max(round(attempt_delay / max(REDSPACE_RIFT_SEALING_EVENT_FREQUENCY_MULTIPLIER, 1)), 1)

/datum/controller/subsystem/redspace/proc/clear_event_schedule(datum/redspace_field_cell/cell)
	if(!cell)
		return
	var/datum/redspace_event_budget/budget = event_budgets[cell.key]
	if(!budget)
		return
	budget.next_attempt_at = 0
	budget.next_turf_attempt_at = 0
	budget.scheduled_state = null
	budget.turf_scheduled_state = null
	if(budget.active_event_count || budget.active_spawn_event_count)
		return
	event_budgets -= cell.key
	qdel(budget)

/datum/controller/subsystem/redspace/proc/cell_has_event_anchor(datum/redspace_field_cell/cell)
	if(!cell)
		return FALSE
	return cell_has_active_source(cell) || !isnull(cell.forced_value) || !isnull(cell.event_override_value) || cell.local_delta

/// Makes one bounded attempt for each due profile queue in every active zone.
/datum/controller/subsystem/redspace/proc/process_scheduled_events()
	if(!automatic_events_enabled())
		clear_scheduled_event_attempts()
		return TRUE
	if(!length(event_budgets) || (event_wake_at && world.time < event_wake_at))
		return TRUE

	for(var/zone_key in event_budgets.Copy())
		if(MC_TICK_CHECK)
			return FALSE
		var/datum/redspace_event_budget/budget = event_budgets[zone_key]
		if(!budget)
			continue
		var/normal_attempt_due = budget.next_attempt_at && world.time >= budget.next_attempt_at
		var/turf_attempt_due = budget.next_turf_attempt_at && world.time >= budget.next_turf_attempt_at
		if(!normal_attempt_due && !turf_attempt_due)
			continue

		var/datum/redspace_field_cell/cell = field_cells[zone_key]
		if(!cell)
			budget.next_attempt_at = 0
			budget.next_turf_attempt_at = 0
			cleanup_event_budget(zone_key)
			continue
		if(!cell_has_event_anchor(cell))
			clear_event_schedule(cell)
			continue

		var/datum/redspace_event_profile/event_profile = get_event_profile(cell.state)
		if(!event_profile || !event_profile.has_events())
			clear_event_schedule(cell)
			continue

		if((normal_attempt_due && budget.scheduled_state != cell.state) || (turf_attempt_due && budget.turf_scheduled_state != cell.state))
			schedule_event_attempt(cell)
			continue

		// The next attempt is scheduled even when the profile rolls no event or
		// the zone budget rejects the candidate. This prevents a hot zone from
		// turning into a per-tick random-event loop.
		if(normal_attempt_due)
			budget.next_attempt_at = world.time + get_event_attempt_delay(cell, event_profile)
			if(event_profile.should_attempt())
				try_start_automatic_event(cell)
				if(MC_TICK_CHECK)
					return FALSE
		if(turf_attempt_due)
			budget.next_turf_attempt_at = world.time + get_event_attempt_delay(cell, event_profile)
			if(event_profile.should_attempt())
				try_start_automatic_event(cell, REDSPACE_EVENT_CATEGORY_TURF_SPAWN)
		if(MC_TICK_CHECK)
			return FALSE

	schedule_event_wake()
	return TRUE

/// Builds the common set of usable local targets for one sparse cell.
/// Event-specific checks are applied after this list is shared by all candidates.
/datum/controller/subsystem/redspace/proc/get_event_candidate_turfs(datum/redspace_field_cell/cell) as /list
	if(!cell)
		return
	if(event_candidate_cache_time != world.time)
		event_candidate_cache.Cut()
		event_candidate_cache_time = world.time
	var/list/cached_candidates = event_candidate_cache[cell.key]
	if(!isnull(cached_candidates))
		return cached_candidates

	var/turf/anchor = cell.get_sample_turf() || redspace_hex_representative_turf(cell.z_level, cell.q, cell.r)
	if(!anchor || !is_supported_z(anchor.z))
		return

	var/list/possible_targets = list()
	if(is_turf_in_cell(anchor, cell) && is_event_target_turf_valid(anchor))
		possible_targets += anchor
	for(var/turf/candidate as anything in RANGE_TURFS(REDSPACE_HEX_RADIUS, anchor))
		if(MC_TICK_CHECK)
			return possible_targets
		if(candidate == anchor)
			continue
		if(is_turf_in_cell(candidate, cell) && is_event_target_turf_valid(candidate))
			possible_targets += candidate
	if(!length(possible_targets))
		event_candidate_cache[cell.key] = list()
		return
	event_candidate_cache[cell.key] = possible_targets
	return possible_targets

/// Finds a target satisfying an event definition from a shared candidate list.
/// The anchor remains preferred when it is valid, matching the old fast path.
/datum/controller/subsystem/redspace/proc/get_event_target_turf(datum/redspace_field_cell/cell, datum/redspace_event/target_event = null, list/candidate_turfs = null) as /turf
	if(!cell)
		return
	if(!candidate_turfs)
		candidate_turfs = get_event_candidate_turfs(cell)
	if(!length(candidate_turfs))
		return
	if(!target_event)
		return pick(candidate_turfs)

	var/turf/anchor = candidate_turfs[1]
	var/list/possible_targets = list()
	for(var/turf/candidate as anything in candidate_turfs)
		if(MC_TICK_CHECK)
			return
		if(!target_event.can_start(candidate))
			continue
		if(candidate == anchor)
			return candidate
		possible_targets += candidate
	if(!length(possible_targets))
		return
	return pick(possible_targets)

/datum/controller/subsystem/redspace/proc/is_event_target_turf_valid(turf/target)
	if(!target || !is_supported_z(target.z) || target.density || is_space_or_openspace(target))
		return FALSE
	var/area/target_area = get_area(target)
	// VALID_TERRITORY is intentionally disabled by ordinary station areas such as
	// commons storage; it controls cult/CRAB-17 placement, not redspace activity.
	if(!target_area || (target_area.area_flags & EVENT_PROTECTED))
		return FALSE
	for(var/obj/obstacle in target)
		if(obstacle.density)
			return FALSE
	return TRUE

/datum/controller/subsystem/redspace/proc/is_turf_in_cell(turf/target, datum/redspace_field_cell/cell)
	if(!target || !cell)
		return FALSE
	var/list/coordinates = redspace_hex_coordinates(target)
	return coordinates && coordinates[1] == cell.q && coordinates[2] == cell.r && target.z == cell.z_level

/// Rejects events whose cell budget or cooldown is already exhausted before
/// scanning every candidate turf in the cell.
/datum/controller/subsystem/redspace/proc/can_attempt_event_in_cell(datum/redspace_event/event, datum/redspace_field_cell/cell)
	if(!event || !cell)
		return FALSE
	var/cooldown_key = "[event.event_id]:[cell.key]"
	var/available_at = event_cooldowns[cooldown_key]
	if(available_at && world.time < available_at)
		return FALSE
	var/datum/redspace_event_budget/budget = event_budgets[cell.key]
	if(budget && !budget.can_start(event))
		return FALSE
	return TRUE

/// Cleans temporary event definitions kept while selecting automatic targets.
/datum/controller/subsystem/redspace/proc/clear_automatic_event_candidates(list/candidate_events)
	if(!candidate_events)
		return
	for(var/event_id in candidate_events)
		var/datum/redspace_event/event = candidate_events[event_id]
		if(event)
			qdel(event)

/// Selects one eligible registered event for the cell's current state profile.
/// The default queue excludes turf spawns; a category selects a dedicated queue.
/datum/controller/subsystem/redspace/proc/try_start_automatic_event(datum/redspace_field_cell/cell, target_category = null)
	if(!automatic_events_enabled())
		return FALSE
	if(!cell || !length(event_registry))
		return FALSE
	if(!isnull(automatic_event_attempts_remaining))
		if(automatic_event_attempts_remaining <= 0)
			return FALSE
		automatic_event_attempts_remaining--

	var/datum/redspace_event_profile/event_profile = get_event_profile(cell.state)
	if(!event_profile || !event_profile.has_events())
		return FALSE

	var/list/candidates = list()
	var/list/candidate_targets = list()
	var/list/candidate_events = list()
	for(var/event_id in event_profile.event_weights)
		if(MC_TICK_CHECK)
			clear_automatic_event_candidates(candidate_events)
			return FALSE
		var/profile_weight = event_profile.get_event_weight(event_id)
		if(!isnum(profile_weight) || profile_weight <= 0)
			continue
		var/datum/redspace_event/event = create_registered_event(event_id)
		if(!event || !event.automatic)
			qdel(event)
			continue
		var/event_category = event.get_spawn_category()
		if(isnull(target_category) ? event_category == REDSPACE_EVENT_CATEGORY_TURF_SPAWN : event_category != target_category)
			qdel(event)
			continue
		if(!can_attempt_event_in_cell(event, cell))
			qdel(event)
			continue
		candidate_events[event_id] = event
		candidates[event_id] = profile_weight

	if(!length(candidates))
		return FALSE

	// Do not build candidate turf lists when every event was already blocked by
	// its cooldown or cell budget. This is common during a wave front.
	var/list/possible_targets = get_event_candidate_turfs(cell)
	if(!length(possible_targets))
		clear_automatic_event_candidates(candidate_events)
		return FALSE

	// Several event definitions inspect the same turfs. Reuse their exact field
	// values for this attempt, but discard the cache before starting an event.
	event_value_cache = list()
	for(var/event_id in candidate_events)
		if(MC_TICK_CHECK)
			event_value_cache = null
			clear_automatic_event_candidates(candidate_events)
			return FALSE
		var/datum/redspace_event/event = candidate_events[event_id]
		var/turf/target = get_event_target_turf(cell, event, possible_targets)
		if(!target || !can_start_event_instance(event, target))
			continue
		candidate_targets[event_id] = target

	event_value_cache = null
	clear_automatic_event_candidates(candidate_events)
	if(!length(candidate_targets))
		return FALSE
	var/chosen_event_id = pick_weight(candidates)
	while(!candidate_targets[chosen_event_id])
		candidates -= chosen_event_id
		if(!length(candidates))
			return FALSE
		chosen_event_id = pick_weight(candidates)
	return start_registered_event(chosen_event_id, null, candidate_targets[chosen_event_id], null, TRUE)
