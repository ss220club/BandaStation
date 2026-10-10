/// One resumable automatic selection. No reservation or cooldown is committed
/// until selection completes; temporary definitions belong to this job.
/datum/redspace_event_attempt
	var/queue_key
	var/datum/redspace_field_cell/cell
	var/cell_state
	var/target_category
	var/datum/redspace_event_profile/event_profile
	var/datum/redspace_event_budget/scheduled_budget
	var/scheduled_at
	var/probability_pending = FALSE
	var/admitted = FALSE
	var/list/event_weights
	var/definition_cursor = 1
	var/list/candidate_events = list()
	var/list/candidate_weights = list()
	var/list/candidate_targets = list()
	var/list/scan_turfs
	var/scan_cursor = 1
	var/list/possible_targets = list()
	var/turfs_ready = FALSE
	var/target_event_cursor = 1
	var/target_turf_cursor = 1
	var/list/eligible_targets = list()
	var/list/point_values = list()
	var/point_values_at = -1

/datum/redspace_event_attempt/New(datum/redspace_field_cell/new_cell, new_category, datum/redspace_event_budget/new_budget = null)
	. = ..()
	cell = new_cell
	cell_state = cell.state
	target_category = new_category
	event_profile = SSredspace.get_event_profile(cell_state)
	scheduled_budget = new_budget
	if(scheduled_budget)
		scheduled_at = target_category == REDSPACE_EVENT_CATEGORY_TURF_SPAWN ? scheduled_budget.next_turf_attempt_at : scheduled_budget.next_attempt_at
		probability_pending = TRUE

/datum/redspace_event_attempt/Destroy()
	SSredspace.clear_automatic_event_candidates(candidate_events)
	candidate_events.Cut()
	candidate_weights.Cut()
	candidate_targets.Cut()
	possible_targets.Cut()
	eligible_targets.Cut()
	point_values.Cut()
	scan_turfs = null
	event_weights = null
	cell = null
	event_profile = null
	scheduled_budget = null
	return ..()

/// Completed rejections include probability, cooldown/budget and target failures.
/// DEFERRED leaves every cursor intact. LIMIT_REACHED leaves an unadmitted job
/// for the next normal fire, without spending its scheduled attempt.
/datum/redspace_event_attempt/proc/advance()
	if(QDELETED(cell) || SSredspace.field_cells[cell.key] != cell || cell.state != cell_state || SSredspace.get_event_profile(cell_state) != event_profile || !event_profile?.has_events() || !SSredspace.cell_has_event_anchor(cell))
		return REDSPACE_ATTEMPT_REJECTED
	if(scheduled_budget)
		if(QDELETED(scheduled_budget))
			return REDSPACE_ATTEMPT_REJECTED
		var/current_at = target_category == REDSPACE_EVENT_CATEGORY_TURF_SPAWN ? scheduled_budget.next_turf_attempt_at : scheduled_budget.next_attempt_at
		if(SSredspace.event_budgets[cell.key] != scheduled_budget || current_at != scheduled_at)
			return REDSPACE_ATTEMPT_REJECTED
	if(!admitted)
		if(!isnull(SSredspace.automatic_event_attempts_remaining) && SSredspace.automatic_event_attempts_remaining <= 0)
			return REDSPACE_ATTEMPT_LIMIT_REACHED
		if(probability_pending)
			probability_pending = FALSE
			if(!event_profile.should_attempt())
				return REDSPACE_ATTEMPT_REJECTED
		if(!isnull(SSredspace.automatic_event_attempts_remaining))
			SSredspace.automatic_event_attempts_remaining--
		SSredspace.metric_automatic_attempts++
		admitted = TRUE
		event_weights = event_profile.event_weights.Copy()

	while(definition_cursor <= length(event_weights))
		if(SSredspace.redspace_work_should_yield())
			return REDSPACE_ATTEMPT_DEFERRED
		var/event_id = event_weights[definition_cursor++]
		var/weight = event_weights[event_id]
		if(!isnum(weight) || weight <= 0)
			continue
		var/datum/redspace_event/event = SSredspace.create_registered_event(event_id)
		if(!event)
			continue
		var/category = event.get_spawn_category()
		if(!event.automatic || (isnull(target_category) ? category == REDSPACE_EVENT_CATEGORY_TURF_SPAWN : category != target_category) || !SSredspace.can_attempt_event_in_cell(event, cell))
			qdel(event)
			continue
		candidate_events[event_id] = event
		candidate_weights[event_id] = weight
	if(!length(candidate_events))
		return REDSPACE_ATTEMPT_REJECTED

	if(!turfs_ready)
		if(isnull(scan_turfs))
			if(SSredspace.event_candidate_cache_time == world.time && !isnull(SSredspace.event_candidate_cache[cell.key]))
				possible_targets = SSredspace.event_candidate_cache[cell.key].Copy()
				turfs_ready = TRUE
			else
				var/turf/anchor = cell.get_sample_turf()
				if(!anchor || !SSredspace.is_supported_z(anchor.z))
					return REDSPACE_ATTEMPT_REJECTED
				if(SSredspace.is_turf_in_cell(anchor, cell) && SSredspace.is_event_target_turf_valid(anchor))
					possible_targets += anchor
				scan_turfs = RANGE_TURFS(REDSPACE_HEX_RADIUS, anchor)
				scan_turfs -= anchor
		while(!turfs_ready && scan_cursor <= length(scan_turfs))
			if(SSredspace.redspace_work_should_yield())
				return REDSPACE_ATTEMPT_DEFERRED
			var/turf/candidate = scan_turfs[scan_cursor++]
			if(SSredspace.is_turf_in_cell(candidate, cell) && SSredspace.is_event_target_turf_valid(candidate))
				possible_targets += candidate
		if(!turfs_ready)
			turfs_ready = TRUE
			if(SSredspace.event_candidate_cache_time != world.time)
				SSredspace.event_candidate_cache.Cut()
				SSredspace.event_candidate_cache_time = world.time
			SSredspace.event_candidate_cache[cell.key] = possible_targets.Copy()
	if(!length(possible_targets))
		return REDSPACE_ATTEMPT_REJECTED

	if(point_values_at != world.time)
		point_values.Cut()
		point_values_at = world.time
	SSredspace.event_value_cache = point_values
	var/targets_result = find_targets()
	SSredspace.event_value_cache = null
	if(targets_result == REDSPACE_ATTEMPT_DEFERRED)
		return targets_result
	if(!length(candidate_targets))
		return REDSPACE_ATTEMPT_REJECTED
	if(SSredspace.redspace_work_should_yield())
		return REDSPACE_ATTEMPT_DEFERRED
	var/chosen_id = pick_weight(candidate_weights)
	while(!candidate_targets[chosen_id])
		candidate_weights -= chosen_id
		chosen_id = pick_weight(candidate_weights)
	return SSredspace.start_registered_event(chosen_id, null, candidate_targets[chosen_id], null, TRUE) ? REDSPACE_ATTEMPT_STARTED : REDSPACE_ATTEMPT_REJECTED

/datum/redspace_event_attempt/proc/find_targets()
	while(target_event_cursor <= length(candidate_events))
		var/event_id = candidate_events[target_event_cursor]
		var/datum/redspace_event/event = candidate_events[event_id]
		while(target_turf_cursor <= length(possible_targets))
			if(SSredspace.redspace_work_should_yield())
				return REDSPACE_ATTEMPT_DEFERRED
			var/turf/target = possible_targets[target_turf_cursor++]
			if(!SSredspace.is_event_target_turf_valid(target) || !event.can_start(target))
				continue
			if(target == possible_targets[1])
				eligible_targets = list(target)
				break
			eligible_targets += target
		if(length(eligible_targets))
			var/turf/target = pick(eligible_targets)
			if(SSredspace.can_start_event_instance(event, target))
				candidate_targets[event_id] = target
		target_event_cursor++
		target_turf_cursor = 1
		eligible_targets.Cut()
	return REDSPACE_ATTEMPT_STARTED
