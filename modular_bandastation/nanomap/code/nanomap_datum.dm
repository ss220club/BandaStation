/// Value by which the number of floors in the station will be subtracted
#define FLOOR_SUBSTRACTION 1

/datum/nanomap
	/// Current station name.
	var/static/map_name
	/// Minimum possible station level..
	var/static/min_floor
	/// Level of main station floor.
	var/static/main_floor
	/// Maximum possible station level.
	var/static/max_floor
	/// Lavaland level, if we have lavaland.
	var/static/lavaland_level

/datum/nanomap/New()
	. = ..()
	if(!map_name)
		map_name = SSmapping.current_map.map_name

	if(!min_floor)
		for(var/datum/space_level/level in SSmapping.z_list)
			if(!findtext(level.name, "Station"))
				continue
			min_floor = level.z_value
			break

	if(!main_floor)
		main_floor = min_floor + (SSmapping.current_map.main_floor - FLOOR_SUBSTRACTION || 0)

	if(!max_floor)
		var/levels = 0
		if(islist(SSmapping.current_map.traits))
			for(var/level in SSmapping.current_map.traits)
				levels++

		max_floor = min_floor + levels - FLOOR_SUBSTRACTION

	if(!lavaland_level)
		if(SSmapping.current_map.minetype != "none")
			for(var/datum/space_level/level in SSmapping.z_list)
				if(!findtext(level.name, "Lavaland"))
					continue
				lavaland_level = level.z_value
				break
		else
			lavaland_level = FALSE

/datum/nanomap/proc/get_tgui_data()
	return list(
		"name" = map_name,
		"minFloor" = min_floor,
		"mainFloor" = main_floor,
		"maxFloor" = max_floor,
		"lavalandLevel" = lavaland_level,
	)

#undef FLOOR_SUBSTRACTION
