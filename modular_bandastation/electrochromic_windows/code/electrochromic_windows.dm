/obj/structure/window
	var/id
	/// Is this windows electrochromic?
	var/electrochromic = FALSE
	/// Color before enabling electrochromic window
	var/base_color
	/// Color which will be applied when electrochromic window is enabled
	var/electrochromic_color

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

// MARK: Spawners
/obj/effect/spawner/structure/window
	/// Is created window will be electrochromic?
	var/electrochromic = FALSE

/obj/effect/spawner/structure/window/electrochromic
	name = "electrochromic window spawner"
	icon = 'modular_bandastation/aesthetics/windows/icons/spawners.dmi'
	icon_state = "electrochromic_window_spawner"
	electrochromic = TRUE

/obj/effect/spawner/structure/window/reinforced/electrochromic
	name = "electrochromic reinforced window spawner"
	icon = 'modular_bandastation/aesthetics/windows/icons/spawners.dmi'
	icon_state = "electrochromic_rwindow_spawner"
	electrochromic = TRUE

/obj/effect/spawner/structure/window/Initialize(mapload)
	. = ..()
	if(electrochromic)
		var/obj/structure/window/window = locate(/obj/structure/window) in loc
		window.electrochromic = TRUE
		window.glass_amount = 4
		window.flags_1 |= UNPAINTABLE_1 // Painting unsupported. For now.
		window.base_color = generate_glass_matrix(window)
		window.electrochromic_color = generate_glass_matrix(window, TINTED_ALPHA)
		window.desc += "Оно может становиться непрозрачным."
