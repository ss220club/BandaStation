/obj/structure/window
	var/electrochromic_id
	/// Is this windows electrochromic?
	var/electrochromic = FALSE
	/// Color before enabling electrochromic window
	var/base_color
	/// Color which will be applied when electrochromic window is enabled
	var/electrochromic_color

/obj/structure/window/fulltile/unanchored/electrochromic
	glass_amount = 4
	electrochromic = TRUE
	flags_1 = UNPAINTABLE_1

/obj/structure/window/reinforced/fulltile/unanchored/electrochromic
	glass_amount = 4
	electrochromic = TRUE
	flags_1 = UNPAINTABLE_1

/obj/structure/window/proc/toggle_polarization()
	if(!base_color)
		base_color = generate_glass_matrix(src)

	if(!electrochromic_color)
		electrochromic_color = generate_glass_matrix(src, TINTED_ALPHA)

	if(opacity)
		animate(src, color = base_color, time = TINT_DURATION)
		set_opacity(FALSE)
	else
		animate(src, color = electrochromic_color, time = TINT_DURATION)
		set_opacity(TRUE)
