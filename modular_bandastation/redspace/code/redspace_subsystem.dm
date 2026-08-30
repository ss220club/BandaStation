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
	/// Maximum combined negative contribution from overlapping stabilizers at one point.
	/// A single stabilizer remains limited by its own -5 contribution cap.
	var/max_stabilizer_negative_contribution = 8
	/// Cells whose cached value changed and may need event/signal processing.
	var/list/dirty_cells = list()
	/// Resumable copy of dirty_cells for MC_TICK_CHECK support.
	var/list/currentrun = list()
	/// Resumable source refresh queue. A new request waits until the current pass finishes.
	var/list/refresh_currentrun = list()
	var/refresh_in_progress = FALSE
	var/refresh_requested = FALSE
	var/refresh_requested_full = FALSE
	var/list/pending_refresh_keys = list()
	var/refresh_reason
	var/pending_refresh_reason
	/// Pruning is deferred until the normal subsystem pass so source updates
	/// cannot trigger several full sparse-table scans in one tick.
	var/prune_requested = FALSE
	/// Wake timer for the next profile-based event attempt.
	var/event_wake_timer_id = TIMER_ID_NULL
	var/event_wake_at = 0
	/// Recent gameplay-range transitions, newest entry last.
	var/list/transition_log = list()
	/// Listener -> canonical cell key for point observers such as sensors.
	var/list/field_listeners = list()
	/// Listener -> exact canonical turf used for its point sample.
	var/list/field_listener_targets = list()
	/// Last exact value and hysteresis state delivered to each field listener.
	var/list/field_listener_values = list()
	var/list/field_listener_states = list()
	/// Registered scenario listeners for explicit event lifecycle signals.
	var/list/event_listeners = list()
	/// Event id -> event typepath. Definitions stay independent from the field cycle.
	var/list/event_registry = list()
/// Event-specific cooldowns, keyed by event id and hex zone.
	var/list/event_cooldowns = list()
	/// Sparse zone key -> /datum/redspace_event_budget.
	var/list/event_budgets = list()
	/// Events that remain alive between telegraph and resolution.
	var/list/active_events = list()
	/// Null outside an automatic-event pass; limits wave-front bursts without
	/// affecting manually started events.
	var/automatic_event_attempts_remaining
	/// Temporary values shared by all event definitions scanning one cell.
	var/list/event_value_cache
	/// Candidate turf lists shared by normal and turf queues during one tick.
	var/list/event_candidate_cache = list()
	var/event_candidate_cache_time = -1
	/// Listener datums that currently have a QDELETING cleanup hook.
	var/list/listener_cleanup = list()

	/// Cumulative counters used to profile the sparse field without scanning the map.
	var/metric_sample_count = 0
	var/metric_value_calculation_count = 0
	var/metric_source_check_count = 0
	var/metric_dirty_cells_enqueued = 0
	var/metric_dirty_cells_processed = 0
	var/metric_events_started = 0
	var/metric_events_finished = 0
	var/metric_peak_field_cells = 0
	var/metric_peak_dirty_cells = 0
	var/metric_peak_processing_sources = 0

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
	field_cells = list()
	dirty_cells = list()
	currentrun = list()
	refresh_currentrun = list()
	refresh_in_progress = FALSE
	refresh_requested = FALSE
	refresh_requested_full = FALSE
	pending_refresh_keys = list()
	refresh_reason = null
	pending_refresh_reason = null
	prune_requested = FALSE
	event_wake_timer_id = TIMER_ID_NULL
	event_wake_at = 0
	transition_log = list()
	field_listeners = list()
	field_listener_targets = list()
	field_listener_values = list()
	field_listener_states = list()
	event_listeners = list()
	event_registry = list()
	event_cooldowns = list()
	event_budgets = list()
	active_events = list()
	automatic_event_attempts_remaining = null
	event_value_cache = null
	event_candidate_cache = list()
	event_candidate_cache_time = -1
	listener_cleanup = list()
	next_source_id = 1
	reset_metrics()
	register_event_type(/datum/redspace_event/calm_echo)
	register_event_type(/datum/redspace_event/local_distortion)
	register_event_type(/datum/redspace_event/storm_pulse)
	register_spawn_event_type(/datum/redspace_event/spawn/object/demonic_crystal)
	register_spawn_event_type(/datum/redspace_event/spawn/turf/demonic_necropolis)
	register_spawn_event_type(/datum/redspace_event/spawn/mob/demonic_lesser_demon)
	register_spawn_event_type(/datum/redspace_event/spawn/mob/demonic_lesser_demon/ranged)
	register_spawn_event_type(/datum/redspace_event/spawn/mob/demonic_lesser_demon/soldier)
	register_spawn_event_type(/datum/redspace_event/spawn/mob/demonic_lesser_demon/moderate_minotaur)
	register_spawn_event_type(/datum/redspace_event/spawn/mob/demonic_lesser_demon/devourer)

	// There is no work until a source, listener, or test changes a cell.
	can_fire = FALSE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/redspace/Destroy()
	clear_event_wake_timer()
	cancel_active_events("подсистема уничтожена")
	clear_listener_registrations()
	for(var/zone_key in event_budgets)
		var/datum/redspace_event_budget/budget = event_budgets[zone_key]
		if(budget)
			qdel(budget)
	event_budgets.Cut()
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(!source)
			continue
		UnregisterSignal(source, COMSIG_QDELETING)
		SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, "подсистема уничтожена")
		qdel(source)
	field_sources.Cut()
	processing_sources.Cut()
	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(cell)
			qdel(cell)
	field_cells.Cut()
	dirty_cells.Cut()
	currentrun.Cut()
	refresh_currentrun.Cut()
	pending_refresh_keys.Cut()
	transition_log.Cut()
	event_cooldowns.Cut()
	event_budgets.Cut()
	active_events.Cut()
	automatic_event_attempts_remaining = null
	event_value_cache = null
	event_candidate_cache.Cut()
	QDEL_NULL(context)
	return ..()

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

/datum/controller/subsystem/redspace/fire(resumed = FALSE)
	if(!resumed)
		automatic_event_attempts_remaining = REDSPACE_MAX_AUTOMATIC_EVENT_ATTEMPTS_PER_FIRE
		process_sources()
		currentrun = dirty_cells.Copy()
		for(var/datum/redspace_field_cell/dirty_cell as anything in currentrun)
			if(dirty_cell)
				dirty_cell.dirty_queued = FALSE
				dirty_cell.dirty_processing = TRUE
		dirty_cells.Cut()

	if(!process_refresh_cells())
		return

	var/list/current_run = currentrun
	while(length(current_run))
		var/datum/redspace_field_cell/cell = current_run[length(current_run)]
		current_run.len--
		if(cell)
			cell.dirty_processing = FALSE
		if(QDELETED(cell))
			continue

		process_dirty_cell(cell)
		if(MC_TICK_CHECK)
			return

	if(prune_requested)
		prune_requested = FALSE
		prune_unused_cells(FALSE)
	if(!process_scheduled_events())
		return
	if(!length(dirty_cells) && !length(processing_sources) && !refresh_in_progress && !refresh_requested && !prune_requested)
		can_fire = FALSE
		schedule_event_wake()
	automatic_event_attempts_remaining = null

/// Expires timed sources and refreshes cached cells while moving waves exist.
/datum/controller/subsystem/redspace/proc/process_sources()
	if(!length(processing_sources))
		return

	var/refresh_needed = FALSE
	var/list/refresh_cell_keys = list()
	for(var/source_key in processing_sources.Copy())
		var/datum/redspace_field_source/source = processing_sources[source_key]
		if(QDELETED(source))
			processing_sources -= source_key
			continue
		if(source.is_expired())
			source.change_reason = "истёк срок жизни источника"
			remove_source(source.source_id)
			continue
		if(istype(source, /datum/redspace_field_source/hotspot))
			var/datum/redspace_field_source/hotspot/hotspot = source
			hotspot.process_growth()
		var/coverage_pending = length(source.coverage_turfs)
		var/coverage_rebuild_needed = source.coverage_needs_refresh()
		var/coverage_complete = TRUE
		if(istype(source, /datum/redspace_field_source/wave) || coverage_pending)
			coverage_complete = ensure_source_cells(source)
			refresh_needed ||= coverage_pending || !coverage_complete
			refresh_cell_keys |= source.get_coverage_refresh_keys()
			if(coverage_rebuild_needed)
				prune_requested = TRUE
		if(istype(source, /datum/redspace_field_source/wave))
			refresh_needed = TRUE
		if(!source.requires_processing() && coverage_complete)
			processing_sources -= source_key

	if(refresh_needed)
		if(length(refresh_cell_keys))
			refresh_cells("обновляются пространственные источники", refresh_cell_keys)
		else
			refresh_cells("обновляются пространственные источники")

/datum/controller/subsystem/redspace/proc/ensure_source_cells(datum/redspace_field_source/source)
	if(!source || !source.z_level || !is_supported_z(source.z_level))
		return TRUE
	if(!length(source.coverage_turfs))
		if(!source.coverage_needs_refresh())
			return TRUE
		var/list/center = list(source.origin_x, source.origin_y)
		if(istype(source, /datum/redspace_field_source/wave))
			var/datum/redspace_field_source/wave/wave_source = source
			center = wave_source.get_current_center()
		var/turf/center_turf = locate(round(center[1]), round(center[2]), source.z_level)
		if(!center_turf)
			return TRUE
		var/coverage_radius = source.radius
		if(istype(source, /datum/redspace_field_source/wave))
			// Keep a margin so a wave can move within one cell without rebuilding
			// the coverage list while still refreshing every affected cell.
			coverage_radius += REDSPACE_HEX_RADIUS
		var/list/center_coordinates = redspace_hex_coordinates(center_turf)
		var/list/coverage_candidates = list()
		if(center_coordinates)
			// Enumerate the sparse hex grid directly. The margin covers cells
			// whose representative turf lies outside the source circle while
			// one of their exact listener turfs is still inside it.
			var/effective_radius = coverage_radius + REDSPACE_HEX_RADIUS
			var/effective_radius_squared = effective_radius * effective_radius
			var/coordinate_range = ceil(effective_radius * 2 / (3 * REDSPACE_HEX_RADIUS)) + 2
			for(var/q_offset in -coordinate_range to coordinate_range)
				for(var/r_offset in -coordinate_range to coordinate_range)
					var/q = center_coordinates[1] + q_offset
					var/r = center_coordinates[2] + r_offset
					var/turf/representative_turf = redspace_hex_representative_turf(source.z_level, q, r)
					if(!representative_turf)
						continue
					var/delta_x = representative_turf.x - center[1]
					var/delta_y = representative_turf.y - center[2]
					if(delta_x * delta_x + delta_y * delta_y <= effective_radius_squared)
						coverage_candidates += representative_turf
		source.coverage_turfs = coverage_candidates
		source.coverage_seen_cells = list()
		source.coverage_cursor = 1
		source.coverage_center_x = center[1]
		source.coverage_center_y = center[2]
		source.coverage_refresh_cell_keys |= source.coverage_cell_keys

	while(source.coverage_cursor <= length(source.coverage_turfs))
		var/turf/candidate = source.coverage_turfs[source.coverage_cursor++]
		var/list/coordinates = redspace_hex_coordinates(candidate)
		if(!coordinates)
			continue
		var/cell_key = redspace_hex_key(candidate.z, coordinates[1], coordinates[2])
		if(source.coverage_seen_cells[cell_key])
			continue
		source.coverage_seen_cells[cell_key] = TRUE
		source.coverage_refresh_cell_keys |= cell_key
		get_cell_by_coordinates(candidate.z, coordinates[1], coordinates[2], TRUE, candidate)
		if(MC_TICK_CHECK)
			return FALSE

	var/list/current_coverage_keys = list()
	for(var/cell_key in source.coverage_seen_cells)
		current_coverage_keys += cell_key
	source.coverage_cell_keys = current_coverage_keys
	source.coverage_cell_lookup = list()
	for(var/cell_key in current_coverage_keys)
		source.coverage_cell_lookup[cell_key] = TRUE
	source.coverage_turfs = null
	source.coverage_seen_cells = null
	source.coverage_cursor = 1
	return TRUE

/// Enables the subsystem after a new cell update or registered listener needs processing.
/datum/controller/subsystem/redspace/proc/wake()
	if(!initialized || can_fire)
		return
	can_fire = TRUE
	update_nextfire(reset_time = TRUE)

/datum/controller/subsystem/redspace/proc/cancel_active_events(reason)
	while(length(active_events))
		var/datum/redspace_event/event = active_events[1]
		if(!event)
			active_events.Cut(1, 2)
			continue
		var/zone_key = event.budget_zone_key
		active_events -= event
		release_event_budget(event)
		notify_event_finished(event, event.event_target, reason || "событие отменено")
		qdel(event)
		cleanup_event_budget(zone_key)
		prune_event_cell(zone_key)

/datum/controller/subsystem/redspace/proc/is_supported_z(z_level)
	if(!z_level)
		return FALSE
	return z_level in station_z_levels

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

	// Explicit event overrides and ordinary test values ignore zone susceptibility by design.
	if(cell && !isnull(cell.event_override_value))
		return cell.event_override_value
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

/// Returns the live station trait that owns the round's redspace activity, if any.
/datum/controller/subsystem/redspace/proc/get_round_trait() as /datum/station_trait/redspace_activity
	if(!SSstation)
		return
	for(var/datum/station_trait/trait as anything in SSstation.station_traits)
		if(istype(trait, /datum/station_trait/redspace_activity))
			return trait

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
			budget.next_attempt_at = world.time + event_profile.get_next_attempt_delay()
		budget.scheduled_state = cell.state
	else
		budget.next_attempt_at = 0
		budget.scheduled_state = null

	if(has_turf_events)
		if(immediate)
			budget.next_turf_attempt_at = world.time
		else if(budget.turf_scheduled_state != cell.state || !budget.next_turf_attempt_at)
			budget.next_turf_attempt_at = world.time + event_profile.get_next_attempt_delay()
		budget.turf_scheduled_state = cell.state
	else
		budget.next_turf_attempt_at = 0
		budget.turf_scheduled_state = null

	schedule_event_wake()
	wake()
	return TRUE

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
			budget.next_attempt_at = world.time + event_profile.get_next_attempt_delay()
			if(event_profile.should_attempt())
				try_start_automatic_event(cell)
				if(MC_TICK_CHECK)
					return FALSE
		if(turf_attempt_due)
			budget.next_turf_attempt_at = world.time + event_profile.get_next_attempt_delay()
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
	return start_registered_event(chosen_event_id, null, candidate_targets[chosen_event_id])

/// Runs a short registered event and applies its per-zone cooldown.
/// Long-lived invasion scenarios will get a separate lifecycle manager later.
/datum/controller/subsystem/redspace/proc/start_registered_event(event_id, client/admin, turf/target, list/event_args)
	var/datum/redspace_event/event = create_registered_event(event_id, event_args)
	if(!event)
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
	if(!succeeded)
		active_events -= event
		budget.release(event, TRUE)
		qdel(event)
		return FALSE

	// Spawn events keep the instance alive, so emit their start signal here just
	// like short-lived events do from their start() implementation.
	if(!event.event_started_notified)
		notify_event_started(event, target, "событие началось")
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

/// Finishes a registered event that stayed alive after its start phase.
/datum/controller/subsystem/redspace/proc/finish_registered_event(datum/redspace_event/event, turf/target, reason = null)
	if(!event || !(event in active_events))
		return FALSE
	active_events -= event
	release_event_budget(event)
	var/zone_key = event.budget_zone_key
	notify_event_finished(event, target, reason || "событие завершено")
	qdel(event)
	cleanup_event_budget(zone_key)
	prune_event_cell(zone_key)
	wake()
	return TRUE

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
	source.radius_squared = source.radius * source.radius
	source.source_id = next_source_id++
	field_sources["[source.source_id]"] = source
	var/coverage_complete = ensure_source_cells(source)
	// Registration performs a full refresh below, so do not repeat the same
	// coverage pass on the next subsystem fire.
	source.get_coverage_refresh_keys()
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	metric_peak_processing_sources = max(metric_peak_processing_sources, length(processing_sources))
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_source_deleted))

	get_cell(locate(source.origin_x, source.origin_y, source.z_level), TRUE)
	var/registration_reason = source.change_reason || "источник зарегистрирован"
	source.change_reason = registration_reason
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_ADDED, source.profile_id, null, source, registration_reason)
	refresh_cells(registration_reason)
	wake()
	return source

/// Registers a static source. Kept as the plain entry point for debug tooling.
/datum/controller/subsystem/redspace/proc/register_source(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEBUG, lifetime = null, reason = null) as /datum/redspace_field_source
	return add_source(new /datum/redspace_field_source(0, origin, source_strength, source_radius, source_profile_id, lifetime, reason))

/// Registers a machine-owned negative source and keeps it separate from ordinary
/// positive/debug sources for the shared stabilizer cap.
/datum/controller/subsystem/redspace/proc/register_stabilizer_source(turf/origin, source_strength, source_radius, reason = null) as /datum/redspace_field_source/stabilizer
	if(!isnum(source_strength))
		return
	return add_source(new /datum/redspace_field_source/stabilizer(0, origin, min(source_strength, 0), source_radius, REDSPACE_PROFILE_STABILIZER, null, reason))

/// Registers a stable hot zone: a persistent local anomaly with its own type.
/datum/controller/subsystem/redspace/proc/register_hotspot(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEMONIC, reason = null, description = null, counts_as_active_hotspot = TRUE) as /datum/redspace_field_source/hotspot
	var/datum/redspace_field_source/hotspot/hotspot = new(0, origin, source_strength, source_radius, source_profile_id, null, reason)
	hotspot.description = description
	hotspot.counts_as_active_hotspot = counts_as_active_hotspot
	return add_source(hotspot)

/// Finds the closest positive hotspot to a turf. Rift sealers use the source origin,
/// not the source's falloff radius, for their placement restriction.
/datum/controller/subsystem/redspace/proc/get_nearest_hotspot(turf/target, max_distance = REDSPACE_RIFT_SEALER_PLACEMENT_RADIUS) as /datum/redspace_field_source/hotspot
	if(!target || !is_supported_z(target.z))
		return

	var/datum/redspace_field_source/hotspot/nearest_hotspot
	var/nearest_distance = INFINITY
	for(var/source_key in field_sources)
		var/datum/redspace_field_source/hotspot/hotspot = field_sources[source_key]
		if(!istype(hotspot) || hotspot.strength <= 0)
			continue
		var/turf/origin = locate(hotspot.origin_x, hotspot.origin_y, hotspot.z_level)
		if(!origin || origin.z != target.z)
			continue
		var/distance = get_dist(target, origin)
		if(distance > max_distance || distance >= nearest_distance)
			continue
		nearest_hotspot = hotspot
		nearest_distance = distance

	return nearest_hotspot

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
	if(!source)
		return FALSE
	var/old_strength = source.strength
	var/change_reason = reason || "изменена сила источника"
	if(!source.set_strength(new_strength, change_reason))
		return FALSE
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys()
	var/coverage_complete = TRUE
	if(source.strength)
		coverage_complete = ensure_source_cells(source)
		refresh_cell_keys |= source.get_coverage_refresh_keys()
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_STRENGTH, source.profile_id, old_strength, source.strength, change_reason)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Moves a source to another tile on the same z-level and refreshes observed cells.
/datum/controller/subsystem/redspace/proc/update_source_position(source_id, turf/new_origin, reason = null)
	var/datum/redspace_field_source/source = field_sources["[source_id]"]
	if(!source || !new_origin || !is_supported_z(new_origin.z) || new_origin.z != source.z_level)
		return FALSE
	var/list/old_position = list(source.origin_x, source.origin_y, source.z_level)
	var/change_reason = reason || "перемещён источник"
	if(!source.set_position(new_origin, change_reason))
		return FALSE
	var/coverage_complete = ensure_source_cells(source)
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	else
		processing_sources -= "[source.source_id]"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys()
	get_cell(new_origin, TRUE)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_POSITION, source.profile_id, old_position, list(source.origin_x, source.origin_y, source.z_level), change_reason)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Changes a source radius and refreshes observed cells.
/datum/controller/subsystem/redspace/proc/update_source_radius(source_id, new_radius, reason = null)
	var/datum/redspace_field_source/source = field_sources["[source_id]"]
	if(!source)
		return FALSE
	var/old_radius = source.radius
	var/change_reason = reason || "изменён радиус источника"
	if(!source.set_radius(new_radius, change_reason))
		return FALSE
	var/coverage_complete = ensure_source_cells(source)
	if(source.requires_processing() || !coverage_complete)
		processing_sources["[source.source_id]"] = source
	else
		processing_sources -= "[source.source_id]"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys()
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_RADIUS, source.profile_id, old_radius, source.radius, change_reason)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
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
	var/change_reason = reason || source.change_reason || "источник удалён"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys(include_in_progress = TRUE)
	UnregisterSignal(source, COMSIG_QDELETING)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, change_reason)
	field_sources -= source_key
	processing_sources -= source_key
	qdel(source)
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()
	return TRUE

/// Keeps the registry consistent when a source is deleted outside remove_source().
/datum/controller/subsystem/redspace/proc/on_source_deleted(datum/redspace_field_source/source)
	SIGNAL_HANDLER
	if(!source)
		return
	var/source_key = "[source.source_id]"
	if(field_sources[source_key] != source)
		return
	var/change_reason = source.change_reason || "источник уничтожен"
	var/list/refresh_cell_keys = source.get_coverage_refresh_keys(include_in_progress = TRUE)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, change_reason)
	field_sources -= source_key
	processing_sources -= source_key
	if(length(refresh_cell_keys))
		refresh_cells(change_reason, refresh_cell_keys)
	else
		refresh_cells(change_reason)
	prune_requested = TRUE
	wake()

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
