/area
	/// Determies whether a new windows/airlocks will be tinted or not.
	/// May be incorrect if there is 2 buttons on the same area.
	var/tinted = FALSE

// MARK: Button
/obj/machinery/button/electrochromic
	name = "electrochromic glass button"
	desc = "Переключатель для электрохромного стекла."
	device_type = /obj/item/assembly/control/electrochromic
	can_alter_skin = FALSE
	/// If equals TINT_CONTROL_GROUP_NONE, only windows with 'null-like' id are controlled by this button. Otherwise, windows with corresponding or 'null-like' id are controlled by this button.
	id = TINT_CONTROL_GROUP_NONE
	color = WINDOW_COLOR
	var/range = TINT_CONTROL_RANGE_AREA

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/electrochromic, 24)

/obj/machinery/button/electrochromic/setup_device()
	. = ..()
	if(device && istype(device, /obj/item/assembly/control/electrochromic))
		var/obj/item/assembly/control/electrochromic/electrochromic_device = device
		electrochromic_device.button_area = get_area(src)
		if(range)
			electrochromic_device.range = range

// MARK: Assembly
/obj/item/assembly/control/electrochromic
	name = "electrochromic glass controller"
	desc = "Небольшое электронное устройство, позволяющее управлять электрохромным стеклом."
	/// Allows to disable linked electrochromic glass after detaching/destroying.
	var/active = FALSE
	/// Windows in this range are controlled by this button. If it equals TINT_CONTROL_RANGE_AREA, the button controls only windows at button_area.
	var/range = TINT_CONTROL_RANGE_AREA
	/// The area where the button is located.
	var/area/button_area

/obj/item/assembly/control/electrochromic/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ASSEMBLY_ADDED_TO_BUTTON, PROC_REF(on_attached))
	RegisterSignal(src, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON, PROC_REF(on_detached))

/obj/item/assembly/control/electrochromic/Destroy()
	. = ..()
	disable_tint()
	UnregisterSignal(src, COMSIG_ASSEMBLY_ADDED_TO_BUTTON)
	UnregisterSignal(src, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON)

/obj/item/assembly/control/electrochromic/activate(forced = FALSE)
	if(!forced)
		if(cooldown)
			return

		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), TINT_ANIMATION_DURATION)
	process_controlled_windows(range != TINT_CONTROL_RANGE_AREA ? range(src, range) : button_area)

/obj/item/assembly/control/electrochromic/proc/process_controlled_windows(control_area)
	if(!control_area)
		return

	active = !active
	button_area.tinted = !button_area.tinted
	for(var/obj/structure/window/window in control_area)
		if(window.electrochromic && (window.id_tag == id || !window.id_tag))
			window.toggle_polarization()

	for(var/obj/machinery/door/airlock/door in control_area)
		if(door.glass && (door.id_tag == id || !door.id_tag))
			door.toggle_polarization()

/obj/item/assembly/control/electrochromic/proc/disable_tint()
	if(!button_area)
		return

	if(active)
		activate(TRUE)

/obj/item/assembly/control/electrochromic/proc/on_attached(obj/machinery/button/button)
	SIGNAL_HANDLER
	if(!button)
		return
	button_area = get_area(button)

/obj/item/assembly/control/electrochromic/proc/on_detached(obj/machinery/button/button)
	SIGNAL_HANDLER
	disable_tint()

/datum/design/electrochromic_control
	name = "Electrochromic Glass Controller"
	id = "electrochromic"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.5)
	build_path = /obj/item/assembly/control/electrochromic
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
