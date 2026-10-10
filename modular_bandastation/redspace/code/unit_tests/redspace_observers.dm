#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Synchronous observer tests with isolated field state and no automatic events.
/datum/unit_test/redspace_observers
	abstract_type = /datum/unit_test/redspace_observers
	var/list/saved_state = list()
	var/list/saved_station_traits
	var/turf/start_turf
	var/turf/same_hex_turf
	var/turf/other_hex_turf
	var/restore_type
	var/list/restore_baseturfs
	var/list/turf_element_arguments

/datum/unit_test/redspace_observers/New()
	. = ..()
	for(var/variable in list("source_currentrun", "source_refresh_keys", "event_schedule_currentrun", "event_attempt_queue", "event_attempt_lookup", "field_cells", "field_sources", "processing_sources", "dirty_cells", "currentrun", "refresh_currentrun", "pending_refresh_keys", "pending_prune_keys", "transition_log", "field_listeners", "field_listener_targets", "field_listener_values", "field_listener_states", "event_listeners", "event_registry", "event_cooldowns", "event_budgets", "active_events", "event_candidate_cache", "listener_cleanup"))
		saved_state[variable] = SSredspace.vars[variable]
		SSredspace.vars[variable] = list()
	for(var/variable in list("source_cursor", "source_pass_in_progress", "source_step_started", "source_refresh_needed", "dirty_pass_started", "event_wake_dirty", "event_schedule_cursor", "event_pass_in_progress", "unit_test_work_remaining", "context", "initialized", "can_fire", "state", "station_z_levels", "refresh_in_progress", "refresh_requested", "refresh_requested_full", "refresh_reason", "pending_refresh_reason", "prune_requested", "event_wake_timer_id", "event_wake_at", "automatic_event_attempts_remaining", "event_value_cache", "event_candidate_cache_time"))
		saved_state[variable] = SSredspace.vars[variable]
	for(var/variable in SSredspace.vars)
		if(findtext(variable, "metric_") == 1)
			saved_state[variable] = SSredspace.vars[variable]
	SSredspace.clear_source_processing()
	SSredspace.clear_automatic_event_work()
	SSredspace.dirty_pass_started = FALSE
	SSredspace.event_wake_dirty = FALSE
	SSredspace.unit_test_work_remaining = null
	SSredspace.reset_metrics()
	SSredspace.context = new /datum/redspace_context(list())
	SSredspace.context.background_value = 0
	SSredspace.initialized = TRUE
	SSredspace.can_fire = TRUE
	SSredspace.state = SS_RUNNING
	SSredspace.station_z_levels = list(run_loc_floor_bottom_left.z)
	SSredspace.refresh_in_progress = FALSE
	SSredspace.refresh_requested = FALSE
	SSredspace.refresh_requested_full = FALSE
	SSredspace.refresh_reason = null
	SSredspace.pending_refresh_reason = null
	SSredspace.prune_requested = FALSE
	SSredspace.event_wake_timer_id = TIMER_ID_NULL
	SSredspace.event_wake_at = 0
	SSredspace.automatic_event_attempts_remaining = null
	SSredspace.event_value_cache = null
	SSredspace.event_candidate_cache_time = -1
	// A reset must not alter the real round trait's timers or managed sources.
	saved_station_traits = SSstation.station_traits
	SSstation.station_traits = list()
	start_turf = run_loc_floor_bottom_left
	restore_type = start_turf.type
	restore_baseturfs = islist(start_turf.baseturfs) ? start_turf.baseturfs.Copy() : start_turf.baseturfs ? list(start_turf.baseturfs) : list()
	var/list/start_coordinates = redspace_hex_coordinates(start_turf)
	var/start_key = redspace_hex_key(start_turf.z, start_coordinates[1], start_coordinates[2])
	for(var/turf/candidate in range(2, start_turf))
		if(candidate == start_turf || !isopenturf(candidate))
			continue
		var/list/coordinates = redspace_hex_coordinates(candidate)
		if(redspace_hex_key(candidate.z, coordinates[1], coordinates[2]) == start_key)
			same_hex_turf = candidate
			break
	other_hex_turf = locate(start_turf.x + REDSPACE_HEX_RADIUS * 3, start_turf.y, start_turf.z)

/datum/unit_test/redspace_observers/Destroy()
	if(turf_element_arguments)
		start_turf.RemoveElement(/datum/element/redspace_threshold/revert_turf_below, -100000, restore_type, restore_baseturfs)
	QDEL_LIST(allocated)
	SSredspace.clear_event_wake_timer()
	SSredspace.clear_automatic_event_work()
	SSredspace.clear_source_processing()
	SSredspace.clear_listener_registrations()
	QDEL_LIST_ASSOC_VAL(SSredspace.event_budgets)
	QDEL_LIST_ASSOC_VAL(SSredspace.field_cells)
	QDEL_NULL(SSredspace.context)
	if(start_turf.type != restore_type)
		start_turf.ChangeTurf(restore_type, restore_baseturfs, CHANGETURF_FORCEOP)
	for(var/variable in saved_state)
		SSredspace.vars[variable] = saved_state[variable]
	SSstation.station_traits = saved_station_traits
	saved_state.Cut()
	return ..()

/datum/unit_test/redspace_observers/proc/drain_prunes()
	// MC_TICK_CHECK may yield even in a synchronous test. Each call still visits
	// at least one key, so a bounded retry drains all non-dirty requests.
	var/remaining_passes = length(SSredspace.pending_prune_keys) + 1
	while(length(SSredspace.pending_prune_keys) && remaining_passes-- > 0)
		SSredspace.state = SS_RUNNING
		SSredspace.process_pending_cell_prunes()

/datum/unit_test/redspace_observers/transfer

/datum/unit_test/redspace_observers/transfer/Run()
	if(!same_hex_turf || !other_hex_turf)
		return Fail("Observer tests require two points in one hex and a point in another hex")
	var/datum/listener = allocate(/datum)
	var/datum/redspace_field_source/source = allocate(/datum/redspace_field_source, "observer_test", start_turf, 6, 3)
	SSredspace.field_sources[source.source_id] = source
	if(!SSredspace.register_field_listener(listener, start_turf))
		return Fail("A supported point must register a listener")
	var/first_key = SSredspace.field_listeners[listener]
	var/datum/redspace_field_cell/first_cell = SSredspace.field_cells[first_key]
	var/first_value = SSredspace.field_listener_values[listener]
	SSredspace.register_event_listener(listener)
	if(!SSredspace.move_field_listener(listener, same_hex_turf))
		return Fail("Moving within a hex must keep the listener registered")
	if(SSredspace.field_listeners[listener] != first_key || length(first_cell.listeners) != 1 || !(listener in first_cell.listeners))
		return Fail("Moving within a hex must preserve cell membership without duplicates")
	if(SSredspace.field_listener_targets[listener] != same_hex_turf || SSredspace.field_listener_values[listener] == first_value || SSredspace.field_listener_values[listener] != SSredspace.get_value(same_hex_turf))
		return Fail("Same-hex movement must update the exact point value, not use the representative point")
	if(length(SSredspace.pending_prune_keys) || SSredspace.metric_full_prune_count || SSredspace.metric_prune_cell_check_count)
		return Fail("Same-hex movement must not request or perform cell pruning")
	if(!SSredspace.move_field_listener(listener, other_hex_turf))
		return Fail("Cross-hex movement must register at the destination")
	if(listener in first_cell.listeners || !(first_key in SSredspace.pending_prune_keys) || !SSredspace.listener_cleanup[listener] || !SSredspace.event_listeners[listener])
		return Fail("Cross-hex movement must abandon only the old cell and preserve event/cleanup subscriptions")
	var/second_key = SSredspace.field_listeners[listener]
	var/other_z = start_turf.z == 1 ? 2 : 1
	var/turf/other_level = locate(other_hex_turf.x, other_hex_turf.y, other_z)
	SSredspace.station_z_levels += other_z
	if(!other_level || !SSredspace.move_field_listener(listener, other_level) || SSredspace.field_listener_targets[listener] != other_level || SSredspace.field_listeners[listener] == second_key)
		return Fail("Movement between supported z-levels must transfer membership")
	SSredspace.station_z_levels -= other_z
	if(SSredspace.move_field_listener(listener, other_level) || SSredspace.field_listeners[listener] || SSredspace.field_listener_targets[listener] || !SSredspace.event_listeners[listener])
		return Fail("An unsupported z-level must remove only the field subscription")
	qdel(listener)
	if(SSredspace.listener_cleanup[listener] || SSredspace.event_listeners[listener])
		return Fail("Deleting a listener must clear its remaining registrations")

/datum/unit_test/redspace_observers/pruning

/datum/unit_test/redspace_observers/pruning/Run()
	var/datum/listener = allocate(/datum)
	SSredspace.register_field_listener(listener, start_turf)
	var/cell_key = SSredspace.field_listeners[listener]
	var/datum/redspace_field_cell/cell = SSredspace.field_cells[cell_key]
	var/datum/redspace_event_budget/budget = SSredspace.get_event_budget(cell_key, TRUE)
	SSredspace.mark_cell_dirty(cell)
	SSredspace.can_fire = FALSE
	qdel(listener)
	if(!SSredspace.can_fire || SSredspace.field_listeners[listener] || SSredspace.field_listener_targets[listener] || SSredspace.field_listener_values[listener] || SSredspace.field_listener_states[listener] || SSredspace.listener_cleanup[listener] || length(cell.listeners))
		return Fail("Deleting the owner must wake cleanup and clear every listener reference")
	SSredspace.state = SS_RUNNING
	SSredspace.process_pending_cell_prunes()
	if(QDELETED(cell) || !(cell_key in SSredspace.pending_prune_keys))
		return Fail("A pending dirty cell must survive cleanup and retain its targeted retry")
	SSredspace.dirty_cells -= cell
	cell.dirty_queued = FALSE
	cell.dirty_processing = TRUE
	SSredspace.prune_event_cell(cell_key)
	if(QDELETED(cell))
		return Fail("A cell in the resumed dirty pass must survive cleanup")
	cell.dirty_processing = FALSE
	SSredspace.process_dirty_cell(cell)
	drain_prunes()
	if(!QDELETED(cell) || !QDELETED(budget) || SSredspace.field_cells[cell_key] || length(SSredspace.pending_prune_keys) || SSredspace.metric_full_prune_count)
		return Fail("Observer cleanup must delete the abandoned cell and empty budget without a full scan")

	// All cleanup entry points obey the same retention rules.
	cell = SSredspace.get_cell(start_turf, TRUE)
	cell.forced_value = 1
	SSredspace.request_cell_prune(cell.key)
	drain_prunes()
	SSredspace.prune_unused_cells(FALSE)
	if(QDELETED(cell))
		return Fail("Both targeted and full cleanup must retain explicit values")
	cell.forced_value = null
	budget = SSredspace.get_event_budget(cell.key, TRUE)
	budget.next_turf_attempt_at = world.time + 1 MINUTES
	SSredspace.prune_event_cell(cell.key)
	if(QDELETED(cell) || QDELETED(budget))
		return Fail("A scheduled turf event must retain its cell and budget")
	budget.next_turf_attempt_at = 0
	budget.active_spawn_event_count = 1
	SSredspace.prune_event_cell(cell.key)
	if(QDELETED(cell))
		return Fail("An active spawn event must retain its cell")
	budget.active_spawn_event_count = 0
	SSredspace.prune_event_cell(cell.key)
	if(!QDELETED(cell) || !QDELETED(budget))
		return Fail("Event cleanup must remove the cell once its final retention reason ends")

	cell = SSredspace.get_cell(start_turf, TRUE)
	var/datum/redspace_field_cell/other_cell = SSredspace.get_cell(other_hex_turf, TRUE)
	SSredspace.request_cell_prune(cell.key)
	SSredspace.request_cell_prune(other_cell.key)
	var/checks_before = SSredspace.metric_prune_cell_check_count
	SSredspace.state = SS_IDLE
	if(SSredspace.process_pending_cell_prunes() || length(SSredspace.pending_prune_keys) != 1 || SSredspace.metric_prune_cell_check_count != checks_before + 1)
		return Fail("A tick-budget interruption must preserve the unvisited cleanup key")
	drain_prunes()
	if(!QDELETED(cell) || !QDELETED(other_cell) || length(SSredspace.pending_prune_keys))
		return Fail("Resuming targeted cleanup must finish the remaining cell")

/datum/unit_test/redspace_observers/consumers

/datum/unit_test/redspace_observers/consumers/Run()
	SSredspace.initialized = FALSE
	var/mob/living/basic/demon/redspace/demon = allocate(/mob/living/basic/demon/redspace, start_turf)
	demon.ai_controller.force_ai_off()
	var/datum/component/redspace_energy/energy = demon.GetComponent(/datum/component/redspace_energy)
	var/obj/item/target = allocate(/obj/item, start_turf)
	target.AddElement(/datum/element/redspace_threshold/delete_below, -100000)
	var/datum/element/redspace_threshold/element = SSdcs.GetElement(list(/datum/element/redspace_threshold/delete_below, -100000), FALSE)
	var/datum/redspace_threshold_listener/threshold_listener = element.find_target_listener(target)
	turf_element_arguments = list(/datum/element/redspace_threshold/revert_turf_below, -100000, restore_type, restore_baseturfs)
	start_turf.AddElement(/datum/element/redspace_threshold/revert_turf_below, -100000, restore_type, restore_baseturfs)
	var/datum/element/redspace_threshold/revert_turf_below/turf_element = SSdcs.GetElement(turf_element_arguments, FALSE)
	var/datum/redspace_threshold_listener/turf_listener = turf_element.find_target_listener(start_turf)
	var/obj/item/redspace_sensor/sensor = allocate(/obj/item/redspace_sensor, start_turf)
	if(!energy.field_observer.waiting_for_redspace || !threshold_listener.field_observer.waiting_for_redspace || !turf_listener.field_observer.waiting_for_redspace || !sensor.field_observer.waiting_for_redspace)
		return Fail("All three consumers must wait for redspace initialization")
	SSredspace.initialized = TRUE
	SEND_SIGNAL(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	if(length(SSredspace.field_listeners) != 4 || energy.field_observer.waiting_for_redspace || threshold_listener.field_observer.waiting_for_redspace || turf_listener.field_observer.waiting_for_redspace || sensor.field_observer.waiting_for_redspace)
		return Fail("Initialization must register all waiting consumers exactly once")
	var/first_key = SSredspace.field_listeners[sensor]
	var/turf/replaced_turf = start_turf.ChangeTurf(/turf/open/floor, restore_baseturfs, CHANGETURF_FORCEOP)
	if(energy.field_observer.listener_turf != replaced_turf || threshold_listener.field_observer.listener_turf != replaced_turf || sensor.field_observer.listener_turf != replaced_turf || SSredspace.field_listener_targets[sensor] != replaced_turf || SSredspace.field_listeners[sensor] != first_key)
		return Fail("ChangeTurf must preserve every consumer's canonical subscription")
	if(QDELETED(turf_listener) || turf_listener.target != replaced_turf || turf_listener.field_observer.listener_turf != replaced_turf || turf_element.find_target_listener(replaced_turf) != turf_listener)
		return Fail("A threshold listener owned by the replaced turf must survive ChangeTurf")
	SSredspace.set_cell_value(replaced_turf, 5, "observer test")
	var/datum/redspace_field_cell/cell = SSredspace.field_cells[first_key]
	SSredspace.process_dirty_cell(cell)
	if(energy.environment_state != REDSPACE_ENERGY_ENVIRONMENT_RECHARGE || sensor.last_sample_value != 5)
		return Fail("Energy and sensor consumers must still receive field changes after ChangeTurf")
	var/obj/item/storage/box/container = allocate(/obj/item/storage/box, replaced_turf)
	sensor.forceMove(container)
	if(SSredspace.field_listeners[sensor] || sensor.field_observer.listener_turf || !isnull(sensor.last_sample_value))
		return Fail("A contained sensor must not observe its container's turf")
	demon.forceMove(container)
	if(!SSredspace.field_listeners[energy] || energy.environment_state != REDSPACE_ENERGY_ENVIRONMENT_RECHARGE)
		return Fail("A contained mob must still observe its current turf")
	sensor.forceMove(replaced_turf)
	if(!SSredspace.field_listeners[sensor] || sensor.last_sample_value != 5)
		return Fail("Putting the sensor back on the floor must restore exact sampling")
	replaced_turf.RemoveElement(/datum/element/redspace_threshold/revert_turf_below, -100000, restore_type, restore_baseturfs)
	turf_element_arguments = null
	qdel(demon)
	qdel(target)
	qdel(sensor)
	if(length(SSredspace.field_listeners) || length(SSredspace.listener_cleanup) || length(cell.listeners))
		return Fail("Deleting consumer owners must clear registrations and observer hooks")
	SSredspace.initialized = FALSE
	demon = allocate(/mob/living/basic/demon/redspace, replaced_turf)
	demon.ai_controller.force_ai_off()
	energy = demon.GetComponent(/datum/component/redspace_energy)
	var/datum/redspace_field_observer/waiting_observer = energy.field_observer
	qdel(demon)
	if(!QDELETED(waiting_observer) || waiting_observer.waiting_for_redspace)
		return Fail("Deleting a waiting consumer must remove its initialization hook")
	SSredspace.initialized = TRUE
	SEND_SIGNAL(SSredspace, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	if(length(SSredspace.field_listeners))
		return Fail("A deleted waiting consumer must not reappear after initialization")

/datum/unit_test/redspace_observers/movement_cost

/datum/unit_test/redspace_observers/movement_cost/Run()
	if(!same_hex_turf || !other_hex_turf)
		return Fail("Movement cost test needs points in the same and different hexes")
	var/list/demons = list()
	for(var/index in 1 to 4)
		var/mob/living/basic/demon/redspace/demon = allocate(/mob/living/basic/demon/redspace, start_turf)
		demon.ai_controller.force_ai_off()
		demons += demon
	for(var/index in 1 to 100)
		SSredspace.get_cell_by_coordinates(start_turf.z, index, 0, TRUE)
	var/old_key = SSredspace.get_cell(start_turf).key
	SSredspace.reset_metrics()
	for(var/step in 1 to 50)
		for(var/mob/living/basic/demon/redspace/demon as anything in demons)
			demon.forceMove(step % 2 ? same_hex_turf : start_turf)
	if(SSredspace.metric_full_prune_count || SSredspace.metric_prune_cell_check_count || length(SSredspace.pending_prune_keys))
		return Fail("200 same-hex demon steps must not scan or queue any cells for cleanup")
	for(var/mob/living/basic/demon/redspace/demon as anything in demons)
		demon.forceMove(other_hex_turf)
	if(length(SSredspace.pending_prune_keys) != 1 || !(old_key in SSredspace.pending_prune_keys))
		return Fail("Several demons leaving the same hex must deduplicate its cleanup request")
	drain_prunes()
	if(SSredspace.metric_full_prune_count || SSredspace.metric_prune_cell_check_count != 1 || SSredspace.field_cells[old_key])
		return Fail("Cross-hex movement must inspect only the abandoned cell, irrespective of field size")

/datum/unit_test/redspace_observers/reset

/datum/unit_test/redspace_observers/reset/Run()
	var/list/default_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(default_z_levels))
		return Fail("Reset test requires a station z-level")
	var/turf/station_point = locate(1, 1, default_z_levels[1])
	SSredspace.station_z_levels |= station_point.z
	var/obj/item/redspace_sensor/sensor = allocate(/obj/item/redspace_sensor, station_point)
	SSredspace.set_cell_value(station_point, 5, "before reset")
	SSredspace.process_dirty_cell(SSredspace.get_cell(station_point))
	var/datum/abandoned_listener = allocate(/datum)
	SSredspace.register_field_listener(abandoned_listener, start_turf)
	SSredspace.unregister_field_listener(abandoned_listener)
	if(!length(SSredspace.pending_prune_keys))
		return Fail("Reset test must begin with pending observer cleanup")
	SSredspace.reset_debug_state()
	if(length(SSredspace.pending_prune_keys) || !SSredspace.field_listeners[sensor] || SSredspace.field_listener_targets[sensor] != station_point || sensor.last_sample_value != SSredspace.get_value(station_point))
		return Fail("Field reset must drop obsolete prune requests and restore exact observer subscriptions")
	sensor.take_sample("after reset")
	if(!SSredspace.field_listeners[sensor] || sensor.field_observer.listener_turf != station_point)
		return Fail("The shared observer must remain usable after a field reset")

#endif
