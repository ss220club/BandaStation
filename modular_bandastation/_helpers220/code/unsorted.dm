/**
 * Checks if the target's Z-level is the "main" station floor for the current map.
 *
 * This proc compares the Z-level of the target atom with the main station floor Z-level
 * specified in the map's JSON configuration. If the target's Z-level matches the main floor,
 * it returns TRUE; otherwise, it returns FALSE.
 *
 * @param target The atom whose Z-level is being checked.
 * @return TRUE if the target is on the main station floor, FALSE otherwise.
 */
/datum/controller/subsystem/mapping/proc/is_main_station_floor(atom/target)
	// If main_floor is not specified in the JSON, assume the target is ON the main floor
	if(isnull(current_map.main_floor))
		return TRUE

	// Get Z-levels associated with the station
	var/list/station_levels = levels_by_trait(ZTRAIT_STATION)

	return target.z == station_levels[current_map.main_floor]

/datum/reagents/proc/set_reacting(react = TRUE)
	if(react)
		flags &= ~(NO_REACT)
	else
		flags |= NO_REACT
