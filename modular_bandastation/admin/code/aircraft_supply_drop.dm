/obj/effect/supply_aircraft
	name = "supply aircraft"
	desc = "Aircraft passing overhead."
	icon = 'icons/obj/aircraft_prop.dmi'
	icon_state = "aircraft_nt"
	pixel_x = -112
	pixel_y = -112
	density = FALSE
	anchored = TRUE
	layer = ABOVE_GAME_PLANE
	plane = ABOVE_GAME_PLANE
	var/turf/target_turf
	var/datum/centcom_podlauncher/launcher
	var/has_dropped = FALSE
	var/step_delay = 0.1 SECONDS
	var/trail_pixel_x = 0
	var/trail_pixel_y = 20
	var/sound_interval = 3 SECONDS

	COOLDOWN_DECLARE(flight_sound_cooldown)

/obj/effect/supply_aircraft/Initialize(mapload, turf/drop_target, datum/centcom_podlauncher/launch_controller)
	. = ..()
	target_turf = drop_target
	launcher = launch_controller
	if (!target_turf ||  QDELETED(launcher))
		return INITIALIZE_HINT_QDEL
	begin_flight()

/obj/effect/supply_aircraft/proc/begin_flight()
	if (!target_turf || QDELETED(launcher))
		qdel(src)
		return
	if (get_turf(src) == target_turf)
		drop_payload()
	addtimer(CALLBACK(src, PROC_REF(fly_step)), step_delay)

/obj/effect/supply_aircraft/proc/fly_step()
	if (QDELETED(src))
		return
	var/turf/current_turf = get_turf(src)
	if (!current_turf)
		qdel(src)
		return
	var/turf/next_turf = locate(current_turf.x, current_turf.y - 1, current_turf.z)
	if (!next_turf)
		qdel(src)
		return
	forceMove(next_turf)
	spawn_trail(next_turf)
	play_flight_sound()
	if (next_turf == target_turf && !has_dropped)
		drop_payload()
	if (next_turf.y <= 1)
		qdel(src)
		return
	addtimer(CALLBACK(src, PROC_REF(fly_step)), step_delay)

/obj/effect/supply_aircraft/proc/spawn_trail(turf/center)
	if (!center)
		return
	for (var/offset_x in -1 to 1)
		var/turf/trail_turf = locate(center.x + offset_x, center.y, center.z)
		if (!trail_turf)
			continue
		var/obj/effect/temp_visual/supply_aircraft_trail/trail = new(trail_turf)
		trail.pixel_y = trail_pixel_y
		trail.pixel_x = trail_pixel_x

/obj/effect/supply_aircraft/proc/play_flight_sound()
	if (!COOLDOWN_FINISHED(src, flight_sound_cooldown))
		return
	COOLDOWN_START(src, flight_sound_cooldown, sound_interval)
	playsound(src, 'modular_bandastation/admin/sound/fly.ogg', 40, FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/effect/supply_aircraft/proc/drop_payload()
	if (has_dropped || | QDELETED(launcher) || !target_turf)
		return
	has_dropped = TRUE
	launcher.launch(target_turf)

/obj/effect/temp_visual/supply_aircraft_trail
	name = "engine trail"
	icon = 'icons/effects/effects.dmi'
	icon_state = "ion_fade_flight"
	duration = 1 SECONDS
	plane = ABOVE_GAME_PLANE
	layer = ABOVE_GAME_PLANE + 0.1
