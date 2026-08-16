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
	var/max_stabilizer_negative_contribution = 6
	/// Cells whose cached value changed and may need event/signal processing.
	var/list/dirty_cells = list()
	/// Resumable copy of dirty_cells for MC_TICK_CHECK support.
	var/list/currentrun = list()
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
	/// Listener datums that currently have a QDELETING cleanup hook.
	var/list/listener_cleanup = list()

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
	listener_cleanup = list()
	next_source_id = 1
	register_event_type(/datum/redspace_event/local_distortion)
	register_event_type(/datum/redspace_event/storm_pulse)

	// There is no work until a source, listener, or test changes a cell.
	can_fire = FALSE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/redspace/Destroy()
	clear_listener_registrations()
	for(var/datum/redspace_event/event as anything in active_events.Copy())
		if(event)
			qdel(event)
	active_events.Cut()
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
	transition_log.Cut()
	event_cooldowns.Cut()
	event_budgets.Cut()
	active_events.Cut()
	QDEL_NULL(context)
	return ..()

/datum/controller/subsystem/redspace/stat_entry(msg)
	var/background_label = context ? round(context.background_value, 0.1) : 0
	msg = "B:[background_label] Cells:[length(field_cells)] Sources:[length(field_sources)] Dirty:[length(dirty_cells)] Transitions:[length(transition_log)] Listeners:[length(field_listeners)] Events:[length(event_registry)] ActiveEvents:[length(active_events)] Budgets:[length(event_budgets)]"
	return ..()

/datum/controller/subsystem/redspace/fire(resumed = FALSE)
	if(!resumed)
		process_sources()
		currentrun = dirty_cells.Copy()
		dirty_cells.Cut()

	var/list/current_run = currentrun
	while(length(current_run))
		var/datum/redspace_field_cell/cell = current_run[length(current_run)]
		current_run.len--
		if(QDELETED(cell))
			continue

		process_dirty_cell(cell)
		if(MC_TICK_CHECK)
			return

	prune_unused_cells()
	if(!length(dirty_cells) && !length(processing_sources))
		can_fire = FALSE

/// Expires timed sources and refreshes cached cells while moving waves exist.
/datum/controller/subsystem/redspace/proc/process_sources()
	if(!length(processing_sources))
		return

	var/wave_present = FALSE
	for(var/source_key in processing_sources.Copy())
		var/datum/redspace_field_source/source = processing_sources[source_key]
		if(QDELETED(source))
			processing_sources -= source_key
			continue
		if(source.is_expired())
			source.change_reason = "истёк срок жизни источника"
			remove_source(source.source_id)
			continue
		if(istype(source, /datum/redspace_field_source/wave))
			wave_present = TRUE

	if(wave_present)
		refresh_cells("волна перемещается")

/// Enables the subsystem after a new cell update or registered listener needs processing.
/datum/controller/subsystem/redspace/proc/wake()
	if(!initialized || can_fire)
		return
	can_fire = TRUE
	update_nextfire(reset_time = TRUE)

/datum/controller/subsystem/redspace/proc/is_supported_z(z_level)
	return z_level && z_level in station_z_levels

/// Gets a sparse cell for a turf, optionally creating it.
/datum/controller/subsystem/redspace/proc/get_cell(turf/target, create = FALSE) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return

	var/list/hex_coordinates = redspace_hex_coordinates(target)
	if(!hex_coordinates)
		return

	return get_cell_by_coordinates(target.z, hex_coordinates[1], hex_coordinates[2], create, target)

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

	var/datum/redspace_field_cell/cell = get_cell(target)
	var/value = calculate_value(target, cell, excluded_source)
	if(!excluded_source && cell && cell.sample_x == target.x && cell.sample_y == target.y)
		if(cell.set_value(value, world.time, "локальная выборка"))
			mark_cell_dirty(cell)
	return value

/// Calculates the field at a tile from the background, local cell override, active sources
/// and the zone susceptibility coefficient.
/datum/controller/subsystem/redspace/proc/calculate_value(turf/target, datum/redspace_field_cell/cell, datum/redspace_field_source/excluded_source = null)
	if(!target || !is_supported_z(target.z))
		return

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
		if(!source || source == excluded_source)
			continue
		var/contribution = source.get_contribution(target)
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
	return TRUE

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

/// Selects one eligible registered event when an active cell enters a new range.
/datum/controller/subsystem/redspace/proc/try_start_automatic_event(datum/redspace_field_cell/cell)
	if(!cell || !length(event_registry))
		return FALSE

	var/turf/target = cell.get_sample_turf() || redspace_hex_representative_turf(cell.z_level, cell.q, cell.r)
	if(!target)
		return FALSE

	var/list/candidates = list()
	for(var/event_id in event_registry)
		var/datum/redspace_event/event = create_registered_event(event_id)
		if(!event || !event.automatic || event.weight <= 0 || !can_start_event_instance(event, target))
			qdel(event)
			continue
		candidates[event_id] = event.weight
		qdel(event)

	if(!length(candidates))
		return FALSE
	var/chosen_event_id = pick_weight(candidates)
	return start_registered_event(chosen_event_id, null, target)

/// Runs a short registered event and applies its per-zone cooldown.
/// Long-lived invasion scenarios will get a separate lifecycle manager later.
/datum/controller/subsystem/redspace/proc/start_registered_event(event_id, client/admin, turf/target, list/event_args)
	var/datum/redspace_event/event = create_registered_event(event_id, event_args)
	if(!event)
		return FALSE
	if(!can_start_event_instance(event, target))
		qdel(event)
		return FALSE

	var/datum/redspace_event_budget/budget = get_event_budget(event.budget_zone_key, TRUE)
	if(!budget.reserve(event))
		qdel(event)
		return FALSE

	active_events += event
	var/succeeded = event.start(admin, target)
	if(!succeeded)
		active_events -= event
		budget.release(event, TRUE)
		qdel(event)
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

/// Finishes a registered event that stayed alive after its start phase.
/datum/controller/subsystem/redspace/proc/finish_registered_event(datum/redspace_event/event, turf/target, reason = null)
	if(!event || !(event in active_events))
		return FALSE
	active_events -= event
	release_event_budget(event)
	notify_event_finished(event, target, reason || "событие завершено")
	qdel(event)
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
	prune_unused_cells()
	return TRUE

/// Removes the sparse cell and any explicit value attached to it.
/datum/controller/subsystem/redspace/proc/clear_cell_value(turf/target)
	if(!target || !is_supported_z(target.z))
		return FALSE

	var/datum/redspace_field_cell/cell = get_cell(target)
	if(!cell)
		return FALSE

	if(length(cell.listeners))
		cell.local_delta = 0
		cell.clear_forced_value()
		cell.clear_event_override()
		if(cell.set_value(get_cached_cell_value(cell), world.time, "ячейка очищена"))
			mark_cell_dirty(cell, "ячейка очищена")
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
	source.source_id = next_source_id++
	field_sources["[source.source_id]"] = source
	if(source.requires_processing())
		processing_sources["[source.source_id]"] = source
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
/datum/controller/subsystem/redspace/proc/register_hotspot(turf/origin, source_strength, source_radius, source_profile_id = REDSPACE_PROFILE_DEMONIC, reason = null, description = null) as /datum/redspace_field_source/hotspot
	var/datum/redspace_field_source/hotspot/hotspot = new(0, origin, source_strength, source_radius, source_profile_id, null, reason)
	hotspot.description = description
	return add_source(hotspot)

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
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_STRENGTH, source.profile_id, old_strength, source.strength, change_reason)
	refresh_cells(change_reason)
	prune_unused_cells()
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
	get_cell(new_origin, TRUE)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_POSITION, source.profile_id, old_position, list(source.origin_x, source.origin_y, source.z_level), change_reason)
	refresh_cells(change_reason)
	prune_unused_cells()
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
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_RADIUS, source.profile_id, old_radius, source.radius, change_reason)
	refresh_cells(change_reason)
	prune_unused_cells()
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
	UnregisterSignal(source, COMSIG_QDELETING)
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, change_reason)
	field_sources -= source_key
	processing_sources -= source_key
	qdel(source)
	refresh_cells(change_reason)
	prune_unused_cells()
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
	SEND_SIGNAL(source, COMSIG_REDSPACE_SOURCE_CHANGED, REDSPACE_SOURCE_CHANGE_REMOVED, source.profile_id, source, null, change_reason)
	field_sources -= source_key
	processing_sources -= source_key
	refresh_cells(change_reason)
	prune_unused_cells()
	wake()

/// Recalculates cached values for all sparse cells. The number of cells is bounded by observers and tests.
/datum/controller/subsystem/redspace/proc/refresh_cells(reason = null)
	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell)
			continue
		var/changed = cell.set_value(get_cached_cell_value(cell), world.time, reason)
		if(changed || !isnull(reason))
			mark_cell_dirty(cell, reason)

/// Removes all field state created during the current round.
/datum/controller/subsystem/redspace/proc/reset_debug_state()
	clear_listener_registrations()
	for(var/source_key in field_sources.Copy())
		var/datum/redspace_field_source/source = field_sources[source_key]
		if(source)
			remove_source(source.source_id, "сброшено из debug-панели")
	field_sources.Cut()
	processing_sources.Cut()
	next_source_id = 1

	for(var/cell_key in field_cells)
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell)
			continue
		qdel(cell)
	field_cells.Cut()
	dirty_cells.Cut()
	currentrun.Cut()
	transition_log.Cut()
	event_cooldowns.Cut()
	for(var/datum/redspace_event/event as anything in active_events.Copy())
		if(event)
			qdel(event)
	active_events.Cut()
	for(var/zone_key in event_budgets)
		var/datum/redspace_event_budget/budget = event_budgets[zone_key]
		if(budget)
			qdel(budget)
	event_budgets.Cut()

	QDEL_NULL(context)
	context = new /datum/redspace_context(list(new /datum/redspace_context_provider/default()))
	context.refresh()
	station_z_levels = context.active_z_levels.Copy()
	can_fire = FALSE


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
	qdel(cell)

/// Removes observer-free cells that no longer have a meaningful source or override.
/datum/controller/subsystem/redspace/proc/prune_unused_cells()
	for(var/cell_key in field_cells.Copy())
		var/datum/redspace_field_cell/cell = field_cells[cell_key]
		if(!cell || length(cell.listeners) || !isnull(cell.forced_value) || !isnull(cell.event_override_value) || cell.local_delta)
			continue
		if(cell in dirty_cells || cell in currentrun)
			continue
		var/turf/sample_turf = cell.get_sample_turf()
		var/source_present = FALSE
		if(sample_turf)
			for(var/source_key in field_sources)
				var/datum/redspace_field_source/source = field_sources[source_key]
				if(source && source.get_contribution(sample_turf))
					source_present = TRUE
					break
		if(!source_present)
			remove_field_cell(cell)

/// Adds a cell to the bounded dirty queue and wakes the subsystem if needed.
/datum/controller/subsystem/redspace/proc/mark_cell_dirty(datum/redspace_field_cell/cell, reason = null)
	if(!cell || QDELETED(cell))
		return
	if(!isnull(reason))
		cell.pending_change_reason = reason
	if(!(cell in dirty_cells))
		dirty_cells += cell
	wake()

/// Processes one cached cell after its value has been refreshed.
/datum/controller/subsystem/redspace/proc/process_dirty_cell(datum/redspace_field_cell/cell)
	if(!cell || QDELETED(cell))
		return

	var/value_changed = cell.value != cell.last_notified_value
	var/state_changed = cell.state != cell.last_notified_state
	var/reason = cell.pending_change_reason || cell.last_change_reason || "обновление поля"
	var/old_value = cell.last_notified_value
	var/old_state = cell.last_notified_state
	if(state_changed)
		record_state_transition(cell, old_state, cell.state, old_value, cell.value, reason)

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

	if(state_changed && redspace_state_is_escalation(old_state, cell.state))
		try_start_automatic_event(cell)

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
	for(var/datum/listener as anything in event_listeners.Copy())
		if(!listener || QDELETED(listener))
			unregister_event_listener(listener)
			continue
		SEND_SIGNAL(listener, COMSIG_REDSPACE_EVENT_STARTED, event, event_context, reason)

/// Sends an event-finished signal only to registered scenario listeners.
/datum/controller/subsystem/redspace/proc/notify_event_finished(datum/event, event_context = null, reason = null)
	if(isturf(event_context))
		event_context = get_event_context(event, event_context)
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
	)
	if(event?.source_id)
		event_context["source_id"] = event.source_id
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
