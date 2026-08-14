SUBSYSTEM_DEF(redspace)
	name = "Редспейс"
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	ss_flags = SS_BACKGROUND | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS

	/// Station z-levels currently covered by the MVP field.
	var/list/station_z_levels = list()
	/// Sparse associative table: "z:q:r" -> /datum/redspace_field_cell.
	var/list/field_cells = list()
	/// Cells whose cached value changed and may need event/signal processing.
	var/list/dirty_cells = list()
	/// Resumable copy of dirty_cells for MC_TICK_CHECK support.
	var/list/currentrun = list()
	/// Value returned for station tiles that have no local cell.
	var/background_value = REDSPACE_DEFAULT_VALUE

/datum/controller/subsystem/redspace/Initialize()
	station_z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION).Copy()
	if(!length(station_z_levels))
		can_fire = FALSE
		initialization_failure_message = "No station z-level was available for the redspace field."
		return SS_INIT_NO_NEED

	// There is no work until a source, listener, or test changes a cell.
	can_fire = FALSE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/redspace/Destroy()
	field_cells.Cut()
	dirty_cells.Cut()
	currentrun.Cut()
	return ..()

/datum/controller/subsystem/redspace/stat_entry(msg)
	msg = "Cells:[length(field_cells)] Dirty:[length(dirty_cells)]"
	return ..()

/datum/controller/subsystem/redspace/fire(resumed = FALSE)
	if(!resumed)
		currentrun = dirty_cells.Copy()
		dirty_cells.Cut()

	var/list/current_run = currentrun
	while(length(current_run))
		var/datum/redspace_field_cell/cell = current_run[length(current_run)]
		current_run.len--
		if(QDELETED(cell))
			continue

		// Event and signal dispatch will consume this queue in the next layer.
		if(MC_TICK_CHECK)
			return

	if(!length(dirty_cells))
		can_fire = FALSE

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

	return get_cell_by_coordinates(target.z, hex_coordinates[1], hex_coordinates[2], create)

/// Gets a sparse cell by axial coordinates, optionally creating it.
/datum/controller/subsystem/redspace/proc/get_cell_by_coordinates(z_level, q, r, create = FALSE) as /datum/redspace_field_cell
	if(!is_supported_z(z_level))
		return

	var/key = redspace_hex_key(z_level, q, r)
	var/datum/redspace_field_cell/cell = field_cells[key]
	if(!cell && create)
		cell = new(z_level, q, r, key, background_value)
		field_cells[key] = cell

	return cell

/// Returns the cached field value at a station turf. Empty cells use the background value.
/datum/controller/subsystem/redspace/proc/get_value(turf/target)
	if(!target || !is_supported_z(target.z))
		return

	var/datum/redspace_field_cell/cell = get_cell(target)
	return cell ? cell.value : background_value

/// Returns the gameplay range at a station turf.
/datum/controller/subsystem/redspace/proc/get_state(turf/target)
	var/value = get_value(target)
	return isnull(value) ? null : redspace_state_from_value(value)

/// Changes the background value and refreshes existing sparse cells.
/datum/controller/subsystem/redspace/proc/set_background_value(new_value)
	new_value = min(new_value, REDSPACE_MAX_NORMAL_VALUE)
	if(background_value == new_value)
		return

	background_value = new_value
	for(var/datum/redspace_field_cell/cell as anything in field_cells)
		if(cell.set_delta(cell.local_delta, background_value))
			mark_cell_dirty(cell)

/// Sets an absolute value for the hex containing a turf. This is the temporary low-level source API.
/// allow_invasion is reserved for an explicit event override above the normal storm ceiling.
/datum/controller/subsystem/redspace/proc/set_cell_value(turf/target, new_value, allow_invasion = FALSE) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return
	if(!allow_invasion)
		new_value = min(new_value, REDSPACE_MAX_NORMAL_VALUE)

	var/datum/redspace_field_cell/cell = get_cell(target, new_value != background_value)
	if(!cell)
		return

	if(cell.set_delta(new_value - background_value, background_value))
		mark_cell_dirty(cell)

	return cell

/// Sets a local contribution relative to the background value.
/datum/controller/subsystem/redspace/proc/set_cell_delta(turf/target, new_delta) as /datum/redspace_field_cell
	if(!target || !is_supported_z(target.z))
		return
	new_delta = min(new_delta, REDSPACE_MAX_NORMAL_VALUE - background_value)

	var/datum/redspace_field_cell/cell = get_cell(target, new_delta != 0)
	if(!cell)
		return

	if(cell.set_delta(new_delta, background_value))
		mark_cell_dirty(cell)

	return cell

/datum/controller/subsystem/redspace/proc/mark_cell_dirty(datum/redspace_field_cell/cell)
	if(!(cell in dirty_cells))
		dirty_cells += cell
	wake()
