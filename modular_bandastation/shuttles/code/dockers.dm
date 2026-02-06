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
	y_offset = 8
	view_range = 5.5
	lock_override = CAMERA_LOCK_STATION
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/soundhand/checkLandingTurf(turf/T, list/overlappers)
	if(!T || T.x <= 10 || T.y <= 10 || T.x >= world.maxx - 10 || T.y >= world.maxy - 10)
		return SHUTTLE_DOCKER_BLOCKED

	if(!T.z || SSmapping.level_has_any_trait(T.z, locked_traits))
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
