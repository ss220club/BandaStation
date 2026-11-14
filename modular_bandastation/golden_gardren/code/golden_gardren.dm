/**
 * ## Golden-Gardren
 *
 * The combined two-pilot mech. Occupies a single tile so it fits through airlocks, but is drawn twice as large.
 * When formed from the pair, the Golden and the Gardren are kept docked inside and the frame runs on the Golden's parts.
 * Event-only: spawned by admins or formed from the pair, not buildable.
 */
/obj/vehicle/sealed/mecha/golden_gardren
	name = "\improper Golden-Gardren"
	desc = "Громадная боевая машина: Гардрен сидит в люке Голдена, как голова на плечах. Управляется двумя пилотами."
	icon = 'modular_bandastation/golden_gardren/icons/golden_gardren.dmi'
	icon_state = "golden_gardren"
	base_icon_state = "golden_gardren"
	SET_BASE_PIXEL(-16, 0)
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 650
	armor_type = /datum/armor/mecha_golden_gardren
	max_temperature = 30000
	force = 45
	destruction_sleep_duration = 40
	exit_delay = 40
	max_occupants = 2
	wreckage = /obj/structure/mecha_wreckage/golden_gardren
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	/// The Golden docked inside while combined. Null for an admin-spawned frame.
	var/obj/vehicle/sealed/mecha/golden/docked_golden
	/// The Gardren docked inside while combined. Null for an admin-spawned frame.
	var/obj/vehicle/sealed/mecha/gardren/docked_gardren

/datum/armor/mecha_golden_gardren
	melee = 50
	bullet = 40
	laser = 40
	energy = 35
	bomb = 45
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/golden_gardren/Destroy()
	// The halves exist only as a part of this frame now, so they go down with it.
	QDEL_NULL(docked_golden)
	QDEL_NULL(docked_gardren)
	return ..()

/// The first pilot in takes the main seat (movement and hands), the second one the weapons seat.
/obj/vehicle/sealed/mecha/golden_gardren/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers)
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_SETTINGS)
	else
		add_control_flags(new_occupant, VEHICLE_CONTROL_EQUIPMENT)

/**
 * Forms the frame from the pair: moves both pilots in, takes over the Golden's parts and docks both halves.
 * Every check must already have passed. Returns FALSE and leaves the pair untouched if a pilot could not be moved.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/assemble(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot)
	// The Golden pilot goes first so they get the main seat.
	if(!take_pilot_from(golden, golden_pilot))
		return FALSE
	if(!take_pilot_from(gardren, gardren_pilot))
		return_pilot_to(golden, golden_pilot)
		return FALSE

	for(var/obj/item/stock_parts/part in list(golden.cell, golden.scanmod, golden.capacitor, golden.servo))
		part.forceMove(src)
	golden.locate_parts()
	locate_parts()

	max_integrity = golden.max_integrity + gardren.max_integrity
	update_integrity(golden.get_integrity() + gardren.get_integrity())

	dock_component(golden)
	dock_component(gardren)
	docked_golden = golden
	docked_gardren = gardren
	diag_hud_set_mechhealth()
	update_appearance()
	log_message("Combined from [golden] ([key_name(golden_pilot)]) and [gardren] ([key_name(gardren_pilot)]).", LOG_MECHA)
	return TRUE

/// Moves a pilot from one of the halves into this frame without dropping them on the floor in between.
/obj/vehicle/sealed/mecha/golden_gardren/proc/take_pilot_from(obj/vehicle/sealed/mecha/source, mob/living/pilot)
	if(!source.is_occupant(pilot) || pilot.loc != source)
		return FALSE
	SStgui.close_user_uis(pilot, source)
	// Leaving the source makes its Exited() remove the occupant there.
	if(!mob_enter(pilot, silent = TRUE))
		return FALSE
	pilot.update_mouse_pointer()
	set_mouse_pointer()
	return TRUE

/// Puts a pilot back into the half they came from. Used to roll back a failed assembly.
/obj/vehicle/sealed/mecha/golden_gardren/proc/return_pilot_to(obj/vehicle/sealed/mecha/destination, mob/living/pilot)
	if(!is_occupant(pilot))
		return
	SStgui.close_user_uis(pilot, src)
	destination.mob_enter(pilot, silent = TRUE)
	pilot.update_mouse_pointer()

/// Stores a half inside the frame: hidden, switched off and not processing until the frame separates.
/obj/vehicle/sealed/mecha/golden_gardren/proc/dock_component(obj/vehicle/sealed/mecha/component)
	if(component.mecha_flags & LIGHTS_ON)
		component.toggle_lights()
	component.forceMove(src)
	component.completely_disabled = TRUE
	STOP_PROCESSING(SSobj, component)
	RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_docked_component_deleted))

/obj/vehicle/sealed/mecha/golden_gardren/proc/on_docked_component_deleted(datum/source)
	SIGNAL_HANDLER
	if(source == docked_golden)
		docked_golden = null
	else if(source == docked_gardren)
		docked_gardren = null

/obj/structure/mecha_wreckage/golden_gardren
	name = "\improper Golden-Gardren wreckage"
	desc = "Груда искорёженного золочёного металла — всё, что осталось от Голден-Гардрена. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/golden_gardren.dmi'
	icon_state = "golden_gardren-broken"
	SET_BASE_PIXEL(-16, 0)
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
	salvage_num = 8
