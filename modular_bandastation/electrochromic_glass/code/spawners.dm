/obj/effect/spawner/structure/window
	var/id = TINT_CONTROL_GROUP_NONE
	/// Is created window will be electrochromic?
	var/electrochromic = FALSE

/obj/effect/spawner/structure/window/electrochromic
	name = "electrochromic window spawner"
	icon = 'modular_bandastation/electrochromic_glass/icons/spawners.dmi'
	icon_state = "electrochromic_window_spawner"
	electrochromic = TRUE

/obj/effect/spawner/structure/window/reinforced/electrochromic
	name = "electrochromic reinforced window spawner"
	icon = 'modular_bandastation/electrochromic_glass/icons/spawners.dmi'
	icon_state = "electrochromic_rwindow_spawner"
	electrochromic = TRUE

/obj/effect/spawner/structure/window/Initialize(mapload)
	. = ..()
	if(electrochromic)
		var/obj/structure/window/window = locate(/obj/structure/window) in loc
		window.electrochromic = TRUE
		window.electrochromic_id = id
		window.glass_amount = 4
		window.flags_1 |= UNPAINTABLE_1 // Painting unsupported. For now.
		window.base_color = generate_glass_matrix(window)
		window.electrochromic_color = generate_glass_matrix(window, TINTED_ALPHA)
		window.desc += span_info("\nОно может становиться непрозрачным.")

// Airlock
/obj/effect/mapping_helpers/airlock/electrochromic
	name = "electrochromic airlock helper"
	icon = 'modular_bandastation/electrochromic_glass/icons/spawners.dmi'
	icon_state = "electrochromic_airlock"
	var/id = TINT_CONTROL_GROUP_NONE

/obj/effect/mapping_helpers/airlock/electrochromic/payload(obj/machinery/door/airlock/door)
	if(!door.glass)
		log_world("[src] at [AREACOORD(src)] tried to make a non-glass door electrochromic!")
		return

	door.electrochromic_id = id
