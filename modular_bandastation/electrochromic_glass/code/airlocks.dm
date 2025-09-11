/obj/machinery/door/airlock
	var/electrochromic_id
	/// Is airlock currently with active electrochrome glass?
	var/electrochromed = FALSE

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	var/area/current_area = get_area(src)
	if(glass && current_area.window_tint)
		toggle_polarization()

/obj/machinery/door/airlock/proc/toggle_polarization()
	electrochromed = !electrochromed
	if(operating || !density)
		return // It's toggled, but don't try to animate the effect.

	var/animate_color
	var/image_color
	var/list/polarized_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file, src, em_block = TRUE)
	var/image/polarized_image = polarized_overlay[1]

	if(!electrochromed)
		image_color = generate_glass_matrix(src, TINTED_ALPHA)
		animate_color = generate_glass_matrix(src)
		set_opacity(FALSE)
		if(multi_tile)
			filler.set_opacity(FALSE)
	else
		image_color = generate_glass_matrix(src)
		animate_color = generate_glass_matrix(src, TINTED_ALPHA)
		set_opacity(TRUE)
		if(multi_tile)
			filler.set_opacity(TRUE)

	cut_overlay(polarized_overlay)

	// Animate() does not work on overlays, so a temporary effect is used
	new /obj/effect/temp_visual/polarized_airlock(get_turf(src), polarized_image, image_color, animate_color)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), TINT_DURATION)

/obj/effect/temp_visual/polarized_airlock
	layer = OPEN_DOOR_LAYER
	duration = TINT_DURATION
	randomdir = FALSE

/obj/effect/temp_visual/polarized_airlock/Initialize(mapload, image/airlock_overlay, image_color, animate_color)
	. = ..()
	icon = airlock_overlay.icon
	icon_state = airlock_overlay.icon_state
	color = image_color
	dir = airlock_overlay.dir
	animate(src, color = animate_color, time = TINT_DURATION)
