// Register certain shuttles in subsystem
/datum/controller/subsystem/shuttle
	/// The current gamma shuttle's mobile docking port.
	var/obj/docking_port/mobile/gamma/gamma

// MARK: Shuttle Dockers
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

// MARK: Shuttle Control Terminals
/obj/machinery/computer/shuttle/syndicate/sit
	name = "syndicate shuttle recall terminal"
	desc = "Use this if your friends left you behind."
	shuttleId = "syndicate_sit"
	possible_destinations = "syndicate_sit;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"

/obj/machinery/computer/shuttle/syndicate/sst
	name = "syndicate shuttle recall terminal"
	desc = "Use this if your friends left you behind."
	shuttleId = "syndicate_sst"
	possible_destinations = "syndicate_sst;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"

/obj/machinery/computer/shuttle/argos
	name = "transport argos console"
	desc = "A console that controls the transport Argos."
	icon_screen = "teleport"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/argos
	shuttleId = "argos"
	possible_destinations = "argos_home;argos_trurl;argos_custom"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle/specops
	name = "transport specops shuttle console"
	desc = "A console that controls the transport Specops shuttle."
	icon_screen = "teleport"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/argos
	shuttleId = "specops"
	possible_destinations = "specops_home;specops_trurl;specops_custom"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle/nanotrasen/drop_pod
	name = "nanotrasen assault pod control"
	desc = "Controls the drop pod's launch system."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "pod_off"
	icon_keyboard = null
	icon_screen = "pod_on"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(ACCESS_CENT_GENERAL)
	shuttleId = "assault_pod_nt"
	possible_destinations = null

/**
 * Not sure now if we need to declare war if we use these shuttles
 * Probably not. If we want it, so we'll have to modify "is_infiltrator_docked_at_syndiebase" proc
 */
/obj/machinery/computer/shuttle/syndicate/sit/launch_check(mob/user)
	return allowed(user)

/obj/machinery/computer/shuttle/syndicate/sst/launch_check(mob/user)
	return allowed(user)

// MARK: Shutte Docking Ports
/obj/docking_port/mobile/syndicate_sit
	name = "syndicate sit shuttle"
	shuttle_id = "syndicate_sit"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = EAST
	port_direction = WEST
	preferred_direction = NORTH

/obj/docking_port/mobile/syndicate_sst
	name = "syndicate sst shuttle"
	shuttle_id = "syndicate_sst"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = WEST
	port_direction = EAST
	preferred_direction = NORTH

/obj/docking_port/mobile/argos
	name = "argos shuttle"
	shuttle_id = "argos"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = NORTH

/obj/docking_port/mobile/specops
	name = "specops shuttle"
	shuttle_id = "specops"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = SOUTH
	port_direction = NORTH
	preferred_direction = NORTH

/obj/docking_port/mobile/gamma
	name = "gamma armory shuttle"
	shuttle_id = "gamma"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = EAST
	port_direction = WEST
	preferred_direction = NORTH

/obj/docking_port/mobile/gamma/register()
	. = ..()
	SSshuttle.gamma = src

/obj/docking_port/mobile/assault_pod/nanotrasen
	name = "Nanotrasen assault pod"
	shuttle_id = "assault_pod_nt"
	/// If assault pod landing is in progress
	var/landing_in_progress = FALSE

// Rewritten logic from our parent that uses ripples effect
/obj/docking_port/mobile/assault_pod/nanotrasen/check_effects()
	if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
		var/tl = timeLeft(1)
		if(tl <= SHUTTLE_RIPPLE_TIME)
			initiate_effects(destination, tl)

/obj/docking_port/mobile/assault_pod/nanotrasen/initiate_docking(obj/docking_port/stationary/S1, force = FALSE)
    . = ..()
    // Reset the flag after landing is complete
    landing_in_progress = FALSE

/// Initiate the landing zone effect
/obj/docking_port/mobile/assault_pod/nanotrasen/proc/initiate_effects(obj/docking_port/stationary/S1, animate_time)
	// Check if we're already in the process of landing to avoid duplicates
	if(landing_in_progress)
		return

	// Find the center of the landing area
	var/list/all_landing_turfs = S1.return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)
	if(!all_landing_turfs || !all_landing_turfs.len)
		return

	// Find the min/max coordinates to determine the boundaries of the landing zone
	var/turf/first_turf = all_landing_turfs[1]
	if(!first_turf)
		return
	var/min_x = first_turf.x
	var/max_x = first_turf.x
	var/min_y = first_turf.y
	var/max_y = first_turf.y

	for(var/turf/T in all_landing_turfs)
		if(!T)
			continue
		min_x = min(T.x, min_x)
		max_x = max(T.x, max_x)
		min_y = min(T.y, min_y)
		max_y = max(T.y, max_y)

	// Calculate the central point of the landing zone
	var/center_x = round((min_x + max_x) / 2)
	var/center_y = round((min_y + max_y) / 2)
	var/center_z = S1.z

	var/turf/effect_turf = locate(center_x, center_y, center_z)

	// Create the landing zone effect in center of landing area
	landing_in_progress = TRUE
	playsound(effect_turf, 'modular_bandastation/objects/sounds/landing_specops.ogg', vol = 100, vary = FALSE, pressure_affected = FALSE)
	var/obj/effect/abstract/landing_zone/landing_zone_effect = new /obj/effect/abstract/landing_zone(effect_turf, animate_time)
	animate(landing_zone_effect, time = animate_time, alpha = 255, transform = matrix().Scale(2.5, 2.5))
	// Deletes the landing zone effect when landing is complete
	if(!QDELETED(landing_zone_effect))
		QDEL_IN(landing_zone_effect, animate_time)

// MARK: Shuttle Areas
/area/shuttle/syndicate_sit
	name = "Syndicate SIT Shuttle"

/area/shuttle/syndicate_sst
	name = "Syndicate SST Shuttle"

/area/shuttle/argos
	name = "Argos Shuttle"

/area/shuttle/specops
	name = "Specops Shuttle"

/area/shuttle/gamma
	name = "Gamma Armory Shuttle"

// MARK: Shuttle Items
// Shuttle Circuitboard
/obj/item/circuitboard/computer/argos
	name = "Transport Argos"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/shuttle/argos

/obj/item/circuitboard/computer/specops
	name = "Transport Specops"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/shuttle/specops

// Assault Pod Control
/obj/item/assault_pod/nanotrasen
	shuttle_id = "assault_pod_nt"
	dwidth = 3
	dheight = 0
	width = 7
	height = 7
	lz_dir = 1
	lzname = "assault_pod_nt"

// Assault Pod Landing Effect
/obj/effect/abstract/landing_zone
	name = "Landing Zone Indicator"
	desc = "Голографическая проекция, обозначающая зону приземления чего-либо. Вероятно, лучше отойти в сторону."
	icon = 'modular_bandastation/objects/icons/obj/effects/landing_zone_96x96.dmi'
	icon_state = "target_largebox"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	alpha = 100
	anchored = TRUE
	density = FALSE
