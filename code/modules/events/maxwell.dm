/datum/round_event_control/spawn_maxwell
	name = "Maxwell Appearance"
	description = "A legendary cat named Maxwell appears on the station. Find him!"
	typepath = /datum/round_event/spawn_maxwell
	weight = 30
	category = EVENT_CATEGORY_HOLIDAY
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/spawn_maxwell

/datum/round_event/spawn_maxwell/proc/get_spawn_loc()
	var/turf/spawn_loc = get_safe_random_station_turf(subtypesof(/area/station/maintenance))
	if(!spawn_loc)
		spawn_loc = get_safe_random_station_turf()
	return spawn_loc

/datum/round_event/spawn_maxwell/start()
	var/turf/spawn_loc = get_spawn_loc()
	if(!spawn_loc)
		return
	var/obj/item/toy/plush/maxwell/maxwell = new /obj/item/toy/plush/maxwell(spawn_loc, TRUE, TRUE)
	priority_announce("Легендарный МАКСВЕЛЛ появился на [station_name()]! Весь персонал должен попытаться найти котика!", "МАКСВЕЛЛ!!!", 'sound/items/maxwell.ogg', ANNOUNCEMENT_TYPE_PRIORITY)
	announce_to_ghosts(maxwell)
