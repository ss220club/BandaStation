// SSredspace owns shared state and the subsystem lifecycle.
// Implementations are grouped in subsystem/{field,sources,scheduler,events,listeners,debug}.dm.
// Keep fire() ordering and resumable MC_TICK_CHECK behavior here.

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
	register_spawn_event_type(/datum/redspace_event/spawn/mob/demonic_lesser_demon/mature_beholder)

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

/// Enables the subsystem after a new cell update or registered listener needs processing.
/datum/controller/subsystem/redspace/proc/wake()
	if(!initialized || can_fire)
		return
	can_fire = TRUE
	update_nextfire(reset_time = TRUE)
