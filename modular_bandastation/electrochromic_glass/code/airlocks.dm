/atom
	/// Color which applied by spraycan.
	var/spraycan_color

/obj/machinery/door/airlock
	var/electrochromic_id
	/// Is airlock currently with active electrochrome glass?
	var/electrochromed = FALSE

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	var/area/current_area = get_area(src)
	if(glass && current_area.window_tint)
		toggle_polarization()

	RegisterSignal(src, COMSIG_OBJ_PAINTED, PROC_REF(on_painted))

/obj/machinery/door/airlock/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_OBJ_PAINTED)

// We can't get airlock color after painting in easy way, so we catch it from spraycan
// Needed for smooth polarization animation, without it, default window color will be used for animation
// which looks bad...
/obj/machinery/door/airlock/proc/on_painted(obj/machinery/door/airlock/source, mob/user, obj/item/toy/crayon/spraycan/spraycan, is_dark_color)
	SIGNAL_HANDLER
	if(!spraycan.actually_paints)
		return

	spraycan_color = spraycan.paint_color

/obj/machinery/door/airlock/proc/toggle_polarization()
	electrochromed = !electrochromed
	if(operating || !density)
		return // It's toggled, but don't try to animate the effect.

	var/animate_color
	var/list/polarized_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file, src, em_block = TRUE)
	var/image/polarized_image = polarized_overlay[1]

	var/default_color = generate_glass_matrix(src)
	var/tinted_color = generate_glass_matrix(src, TINTED_ALPHA)
	if(!electrochromed)
		polarized_image.color = tinted_color
		animate_color = default_color
		set_opacity(FALSE)
		if(multi_tile)
			filler.set_opacity(FALSE)
	else
		polarized_image.color = default_color
		animate_color = tinted_color
		set_opacity(TRUE)
		if(multi_tile)
			filler.set_opacity(TRUE)

	cut_overlay(polarized_overlay)

	// Animate() does not work on overlays, so a temporary effect is used
	new /obj/effect/temp_visual/polarized_airlock(get_turf(src), polarized_image, animate_color)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), TINT_DURATION)

/obj/effect/temp_visual/polarized_airlock
	layer = OPEN_DOOR_LAYER
	duration = TINT_DURATION
	randomdir = FALSE

/obj/effect/temp_visual/polarized_airlock/Initialize(mapload, image/airlock_overlay, animate_color)
	. = ..()
	if(!airlock_overlay)
		return

	icon = airlock_overlay.icon
	icon_state = airlock_overlay.icon_state
	color = airlock_overlay.color
	dir = airlock_overlay.dir
	animate(src, color = animate_color, time = TINT_DURATION)
