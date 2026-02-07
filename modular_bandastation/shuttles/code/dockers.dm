/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/sit
	name = "syndicate infiltrator navigation computer"
	desc = "Used to pilot the syndicate infiltration team to board enemy stations and ships."
	shuttleId = "syndicate_sit"
	shuttlePortId = "syndicate_sit_custom"
	x_offset = 0
	y_offset = 3

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/sst
	name = "syndicate striker navigation computer"
	desc = "Used to pilot the syndicate strike team to board enemy stations and ships."
	shuttleId = "syndicate_sst"
	shuttlePortId = "syndicate_sst_custom"
	x_offset = 0
	y_offset = 3

/obj/machinery/computer/camera_advanced/shuttle_docker/argos
	name = "argos shuttle navigation computer"
	desc = "Used to pilot Argos shuttle."
	icon_screen = "shuttle"
	icon_keyboard = "rd_key"
	shuttleId = "argos"
	shuttlePortId = "argos_custom"
	x_offset = 0
	y_offset = 8
	view_range = 5.5
	lock_override = CAMERA_LOCK_STATION
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/specops
	name = "Specops navigation computer"
	desc = "Used to pilot ERT shuttle."
	icon_screen = "shuttle"
	icon_keyboard = "rd_key"
	shuttleId = "specops"
	shuttlePortId = "specops_custom"
	x_offset = 0
	y_offset = 3
	lock_override = CAMERA_LOCK_STATION
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	resistance_flags = INDESTRUCTIBLE

// Shuttle Dockers Override
/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate
	x_offset = 0
	y_offset = 10

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand
	name = "soundhand shuttle navigation computer"
	desc = "Used to pilot Soundhand shuttle."
	icon_screen = "shuttle"
	icon_keyboard = "rd_key"
	shuttleId = "soundhand"
	shuttlePortId = "soundhand_custom"
	x_offset = 0
	y_offset = -9
	view_range = 9
	lock_override = NONE
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	locked_traits = list()
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand/checkLandingSpot()
	var/mob/eye/camera/remote/shuttle_docker/the_eye = eyeobj
	var/turf/eyeturf = get_turf(the_eye)
	if(!eyeturf)
		return SHUTTLE_DOCKER_BLOCKED

	. = SHUTTLE_DOCKER_LANDING_CLEAR
	var/list/image_cache = the_eye.placement_images
	for(var/i in 1 to image_cache.len)
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T

		if(checkLandingTurf(T, null) == SHUTTLE_DOCKER_LANDING_CLEAR)
			I.icon_state = "green"
		else
			I.icon_state = "red"
			. = SHUTTLE_DOCKER_BLOCKED

	var/list/extra_image_cache = the_eye.extra_images
	for(var/i in 1 to extra_image_cache.len)
		var/image/img = extra_image_cache[i]
		var/list/coords = extra_image_cache[img]
		img.loc = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)

/mob/eye/camera/remote/shuttle_docker/soundhand/allow_z_transition(datum/space_level/from, datum/space_level/into)
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand/checkLandingTurf(turf/T, list/overlappers)
	if(!T || T.x <= 10 || T.y <= 10 || T.x >= world.maxx - 10 || T.y >= world.maxy - 10)
		return SHUTTLE_DOCKER_BLOCKED

	return SHUTTLE_DOCKER_LANDING_CLEAR

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand/placeLandingSpot()
	. = ..()
	if(!.)
		return

	var/obj/docking_port/mobile/soundhand/S = SSshuttle.getShuttle(shuttleId)
	if(!istype(S) || QDELETED(my_port))
		return

	if(current_user)
		to_chat(current_user, span_warning("SOUNDHAND RAM MODE: impact inbound."))

	S.ram_to(my_port)

#define SOUNDHAND_RAM_WARN_TIME (15 SECONDS)
/obj/docking_port/mobile/soundhand/proc/ram_to(obj/docking_port/stationary/target)
	if(QDELETED(src) || QDELETED(target))
		return FALSE

	if(!ram_warned)
		ram_warned = TRUE
		announce_ram_warning()

	initiate_drop_landing(target, SOUNDHAND_RAM_WARN_TIME)
	addtimer(CALLBACK(src, PROC_REF(_do_ram_to), target), SOUNDHAND_RAM_WARN_TIME)
	return TRUE
#undef SOUNDHAND_RAM_WARN_TIME

/obj/docking_port/mobile/soundhand/proc/announce_ram_warning()
	priority_announce(
		text = "ВНИМАНИЕ: автоматическая система шаттла сообщает об ошибках в навигационных расчётах. Возможна потеря точности выхода и столкновение при заходе. Немедленно освободите предполагаемую зону стыковки и прилегающие коридоры.",
		title = "Аварийное предупреждение: шаттл",
		sound = SSstation.announcer.get_rand_report_sound(),
		sender_override = "Автоматическая система шаттла",
		color_override = "red",
	)

/obj/docking_port/mobile/soundhand/proc/_do_ram_to(obj/docking_port/stationary/target)
	if(QDELETED(src) || QDELETED(target))
		return

	ram_clear_landing_zone(target)
	initiate_docking(target, force = TRUE)

/obj/docking_port/mobile/soundhand/proc/ram_clear_landing_zone(obj/docking_port/stationary/target)
	var/list/bounds = return_coords(target.x, target.y, target.dir)
	var/min_x = bounds[1]
	var/min_y = bounds[2]
	var/max_x = bounds[3]
	var/max_y = bounds[4]

	for(var/x in min_x to max_x)
		for(var/y in min_y to max_y)
			var/turf/T = locate(x, y, target.z)
			if(!T)
				continue

			if(shuttle_areas && shuttle_areas[T.loc])
				continue

			for(var/atom/movable/A as anything in T)
				if(QDELETED(A))
					continue
				if(A.density)
					qdel(A)

			if(T.density)
				T.ex_act(EXPLODE_HEAVY)

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand/add_jumpable_port(port_id)
	if(!length(jump_to_ports))
		actions += new /datum/action/innate/camera_jump/shuttle_docker/soundhand(src)
	jump_to_ports[port_id] = TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand/remove_jumpable_port(port_id)
	jump_to_ports -= port_id
	if(!length(jump_to_ports))
		var/datum/action/to_remove = locate(/datum/action/innate/camera_jump/shuttle_docker/soundhand) in actions
		if(to_remove)
			actions -= to_remove
			qdel(to_remove)

/datum/action/innate/camera_jump/shuttle_docker/soundhand
	name = "Jump to Location"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/shuttle_docker/soundhand/Activate()
	if(QDELETED(owner) || !isliving(owner))
		return

	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	if(QDELETED(remote_eye) || !istype(remote_eye, /mob/eye/camera/remote/shuttle_docker))
		return

	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = remote_eye.origin_ref?.resolve()
	if(QDELETED(console))
		return

	playsound(console, 'sound/machines/terminal/terminal_prompt.ogg', 25, FALSE)
	var/list/L = list()
	for(var/z in 1 to world.maxz)
		if(!z || SSmapping.level_has_any_trait(z, console.locked_traits))
			continue

		var/datum/space_level/SL = SSmapping.get_level(z)
		var/level_name = SL?.name
		var/turf/anchor = console.get_anchor_turf_for_z(z)
		if(!anchor)
			continue

		L[level_name] = anchor

	if(!length(L))
		playsound(console, 'sound/machines/terminal/terminal_prompt_deny.ogg', 25, FALSE)
		to_chat(owner, span_warning("No valid z-levels available."))
		return

	var/selected = tgui_input_list(owner, "Jump to which Z-level?", "Z Jump", sort_list(L))
	if(isnull(selected))
		playsound(console, 'sound/machines/terminal/terminal_prompt_deny.ogg', 25, FALSE)
		return

	if(QDELETED(src) || QDELETED(owner) || !isliving(owner))
		return

	var/turf/T = L[selected]
	if(isnull(T))
		return

	playsound(console, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 25, FALSE)
	remote_eye.setLoc(T, TRUE)
	to_chat(owner, span_notice("Jumped to [selected]."))
	owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
	owner.clear_fullscreen("flash", 3)

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/get_anchor_turf_for_z(z_level)
	var/center = locate(round(world.maxx / 2), round(world.maxy / 2), z_level)
	if(istype(center, /turf/open))
		return center

	for(var/turf/open/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		return T

	return center
