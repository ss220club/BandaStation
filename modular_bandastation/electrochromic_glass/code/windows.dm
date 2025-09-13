/obj/structure/window
	var/electrochromic_id
	/// Is this windows electrochromic?
	var/electrochromic = FALSE

/obj/structure/window/Initialize(mapload)
	. = ..()
	var/area/current_area = get_area(src)
	if(electrochromic && current_area.window_tint)
		toggle_polarization()

/obj/structure/window/fulltile/unanchored/electrochromic
	name = "full tile electrochromic window"
	glass_amount = 4
	electrochromic = TRUE

/obj/structure/window/reinforced/fulltile/unanchored/electrochromic
	name = "full tile reinforced electrochromic window"
	glass_amount = 4
	electrochromic = TRUE

/obj/structure/window/fulltile/electrochromic
	name = "full tile electrochromic window"
	glass_amount = 4
	electrochromic = TRUE

/obj/structure/window/reinforced/fulltile/electrochromic
	name = "full tile reinforced electrochromic window"
	glass_amount = 4
	electrochromic = TRUE

/obj/structure/window/proc/toggle_polarization()
	if(opacity)
		animate(src, color = generate_glass_matrix(src), time = TINT_DURATION)
		set_opacity(FALSE)
	else
		animate(src, color = generate_glass_matrix(src, TINTED_ALPHA), time = TINT_DURATION)
		set_opacity(TRUE)
