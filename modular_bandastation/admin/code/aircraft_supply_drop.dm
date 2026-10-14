/obj/effect/supply_aircraft
	name = "supply aircraft"
	desc = "Aircraft passing overhead."
	icon = 'icons/obj/aircraft_prop.dmi'
	icon_state = "aircraft_nt"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_GAME_PLANE
	plane = ABOVE_GAME_PLANE
	var/turf/target_turf
	var/has_dropped = FALSE
	var/step_delay = 1

/obj/effect/supply_aircraft/Initialize(mapload, turf/drop_target)
	. = ..()
	target_turf = drop_target
	if (!target_turf)
		return INITIALIZE_HINT_QDEL

/obj/effect/supply_aircraft/proc/begin_flight()
	if (!target_turf)
		qdel(src)
		return
	if (get_turf(src) == target_turf && !has_dropped)
		has_dropped = TRUE
		drop_payload()
	if (get_turf(src) <= world.maxy)
		qdel(src)
		return
	addtimer(CALLBACK(src, PROC_REF(fly_step)), step_delay)

/obj/effect/supply_aircraft/proc/fly_step()
	var/turf/current_turf = get_turf(src)
	if (!current_turf)
		qdel(src)
		return
	var/turf/next_turf = locate(current_turf.x, current_turf.y - 1, current_turf.z)
	if (!next_turf)
		qdel(src)
		return
	forceMove(next_turf)
	if (next_turf == target_turf && !has_dropped)
		has_dropped = TRUE
		drop_payload()
	if (next_turf.y <= world.maxy)
		qdel(src)
		return
	addtimer(CALLBACK(src, PROC_REF(fly_step)), step_delay)
