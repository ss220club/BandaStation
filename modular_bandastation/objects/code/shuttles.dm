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
	circuit = /obj/item/circuitboard/computer/specops
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

// MARK: Shuttle Docking Ports
/obj/docking_port/mobile
	/// Object effect that places the landing zone effect in the center of the landing area
	var/drop_landing_effect = null
	/// Sound that played before drop landing
	var/drop_landing_sound = null
	/// If mobile docking is in progress
	var/drop_landing_in_progress = FALSE

/// Initiate the landing zone effect
/obj/docking_port/mobile/proc/initiate_drop_landing(obj/docking_port/stationary/S1, animate_time)
	if(!S1 || S1.roundstart_template || drop_landing_in_progress || (!drop_landing_sound && !drop_landing_effect))
		return

	drop_landing_in_progress = TRUE

	// Find the center of the landing area
	var/list/bounding_corners = return_coords(S1.x, S1.y, S1.dir)
	var/min_x = bounding_corners[1]
	var/min_y = bounding_corners[2]
	var/max_x = bounding_corners[3]
	var/max_y = bounding_corners[4]

	// Calculate the central point of the landing zone
	var/center_x = round((min_x + max_x) / 2)
	var/center_y = round((min_y + max_y) / 2)
	var/center_z = S1.z

	var/turf/effect_turf = locate(center_x, center_y, center_z)
	if(!effect_turf)
		return

	if(drop_landing_sound)
		playsound(effect_turf, drop_landing_sound, vol = 100, vary = FALSE, pressure_affected = FALSE)

	if(drop_landing_effect)
		create_drop_landing_effect(S1, effect_turf, animate_time)

	var/mutable_appearance/alert_overlay = mutable_appearance('icons/mob/telegraphing/telegraph_holographic.dmi', "target_box")
	notify_ghosts("Зона посадки десантной капсулы!", source = effect_turf, header = "Десант", alert_overlay = alert_overlay)

/// Create the landing zone effect in center of landing area
/obj/docking_port/mobile/proc/create_drop_landing_effect(obj/docking_port/stationary/S1, turf/effect_turf, animate_time)
	var/obj/landing_zone_effect = new drop_landing_effect(effect_turf, animate_time)

	// Constants for icon size calculation (in pixels)
	var/list/landing_icon_dimensions = get_icon_dimensions(landing_zone_effect.icon)
	var/landing_icon_size_px = max(landing_icon_dimensions["width"], landing_icon_dimensions["height"])

	// Calculate the required scale based on shuttle's tile size
	// We'll use the larger dimension to ensure the effect covers the entire shuttle
	var/shuttle_size_px = max(width, height) * ICON_SIZE_ALL
	var/shuttle_scale = shuttle_size_px / landing_icon_size_px

	animate(landing_zone_effect, time = animate_time, alpha = 255, transform = matrix().Scale(shuttle_scale, shuttle_scale))
	QDEL_IN(landing_zone_effect, animate_time)

// Checks for drop landing effects, if non of them present, then call parent proc instead. Reuses logic from our parent
/obj/docking_port/mobile/check_effects()
	if(!drop_landing_effect && !drop_landing_sound)
		return ..()

	if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
		var/tl = timeLeft(1)
		if(tl <= SHUTTLE_RIPPLE_TIME)
			initiate_drop_landing(destination, tl)

/obj/docking_port/mobile/initiate_docking(obj/docking_port/stationary/S1, force = FALSE)
    . = ..()
    // Failsafe reset to FALSE, even if it's already FALSE because initiate_drop_landing() isn't called
    drop_landing_in_progress = FALSE

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

/obj/docking_port/mobile/assault_pod
	drop_landing_sound = 'sound/effects/alert.ogg'

/obj/docking_port/mobile/assault_pod/nanotrasen
	name = "Nanotrasen assault pod"
	shuttle_id = "assault_pod_nt"
	drop_landing_effect = /obj/effect/abstract/landing_zone
	drop_landing_sound = 'modular_bandastation/objects/sounds/landing_specops.ogg'

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

/area/shuttle/assault_pod/nanotrasen
	name = "Nanotrasen Assault Pod"

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
	lzname = "assault_pod_nt"

// Drop-Landing Zone Effect
/obj/effect/abstract/landing_zone
	name = "Landing Zone Indicator"
	desc = "Голографическая проекция, обозначающая зону приземления чего-либо. Вероятно, лучше отойти в сторону."
	icon = 'modular_bandastation/objects/icons/obj/effects/landing_zone_96x96.dmi'
	icon_state = "target_largebox"
	layer = RIPPLE_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	pixel_x = -32
	pixel_y = -32
	alpha = 150

/obj/effect/abstract/landing_zone/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/abstract/landing_zone/update_overlays()
	. = ..()
	// Set the emissive appearance to make the glow effect
	. += emissive_appearance(icon, icon_state, src)
