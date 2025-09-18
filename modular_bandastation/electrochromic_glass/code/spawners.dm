/obj/effect/spawner/structure/window
	var/id = TINT_CONTROL_GROUP_NONE
	/// Is created window will be electrochromic?
	var/electrochromic = FALSE

/obj/effect/spawner/structure/window/electrochromic
	name = "electrochromic window spawner"
	icon_state = "electrochromic_window_spawner"
	electrochromic = TRUE

/obj/effect/spawner/structure/window/reinforced/electrochromic
	name = "electrochromic reinforced window spawner"
	icon_state = "electrochromic_rwindow_spawner"
	electrochromic = TRUE

/obj/effect/spawner/structure/window/Initialize(mapload)
	. = ..()
	if(electrochromic)
		var/obj/structure/window/window = locate(/obj/structure/window) in loc
		window.electrochromic = TRUE
		window.id_tag = id
		window.glass_amount = 4
