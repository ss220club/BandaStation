/area
	/// Is the window tint control in this area on? Controls whether electrochromic windows and doors are tinted or not
	var/window_tint = FALSE

/obj/machinery/button/electrochromic
	name = "electrochromic glass controller"
	desc = "Переключатель для электрохромного стекла."
	icon = 'modular_bandastation/electrochromic_glass/icons/button.dmi'
	icon_state = "polarizer"
	base_icon_state = "polarizer"
	can_alter_skin = FALSE
	/// If equals TINT_CONTROL_GROUP_NONE, only windows with 'null-like' id are controlled by this button. Otherwise, windows with corresponding or 'null-like' id are controlled by this button.
	id = TINT_CONTROL_GROUP_NONE
	/// Windows in this range are controlled by this button. If it equals TINT_CONTROL_RANGE_AREA, the button controls only windows at button_area.
	var/range = TINT_CONTROL_RANGE_AREA
	/// The button toggle state. If range equals TINT_CONTROL_RANGE_AREA and id equals TINT_CONTROL_GROUP_NONE or is same with other button, it is shared between all such buttons in its area.
	var/active = FALSE
	/// The area where the button is located.
	var/area/button_area
	/// Cooldown between toggles
	COOLDOWN_DECLARE(electrochromic_toggle_cooldown)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/electrochromic, 24)

/obj/machinery/button/electrochromic/Initialize(mapload)
	. = ..()
	button_area = get_area(src)

/obj/machinery/button/electrochromic/Destroy()
	. = ..()
	if(active)
		toggle_tint()

/obj/machinery/button/electrochromic/attempt_press(mob/user)
	if(!COOLDOWN_FINISHED(src, electrochromic_toggle_cooldown))
		return

	. = ..()

	active = !active
	toggle_tint()
	COOLDOWN_START(src, electrochromic_toggle_cooldown, TINT_DURATION)

/obj/machinery/button/electrochromic/power_change()
	if(!..())
		return
	if(active && (machine_stat & NOPOWER))
		toggle_tint()

/obj/machinery/button/electrochromic/update_overlays()
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open && active)
		. += "[base_icon_state]_on"

/obj/machinery/button/electrochromic/proc/toggle_tint()
	if(range == TINT_CONTROL_RANGE_AREA)
		button_area.window_tint = !button_area.window_tint
		for(var/obj/machinery/button/electrochromic/button in button_area)
			if(button.range != TINT_CONTROL_RANGE_AREA || (button.id != id && button.id != TINT_CONTROL_GROUP_NONE))
				continue
			button.active = button_area.window_tint
			button.update_icon(UPDATE_OVERLAYS)
	else
		active = !active
		update_icon(UPDATE_OVERLAYS)
	process_controlled_windows(range != TINT_CONTROL_RANGE_AREA ? range(src, range) : button_area)

/obj/machinery/button/electrochromic/proc/process_controlled_windows(control_area)
	for(var/obj/structure/window/window in control_area)
		if(!window.electrochromic && (window.electrochromic_id != id || window.electrochromic_id))
			continue
		window.toggle_polarization()

	for(var/obj/machinery/door/airlock/door in control_area)
		if(!door.glass && (door.electrochromic_id != id || door.electrochromic_id))
			continue
		door.toggle_polarization()
