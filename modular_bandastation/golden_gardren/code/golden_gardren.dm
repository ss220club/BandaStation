/// Share of integrity at and below which the pilots are warned that the frame is about to break.
#define GOLDEN_GARDREN_CRITICAL_INTEGRITY 0.3

/**
 * ## Golden-Gardren
 *
 * The combined two-pilot mech. Occupies a single tile so it fits through airlocks, but is drawn one and a half tiles tall.
 * Main seat: movement, the fist (punch, grab, throw, squeeze), the phase shift and the Golden Ram. Weapons seat: arm weapons, the shield and the missile strike.
 * When formed from the pair, the Golden and the Gardren are kept docked inside and the frame runs on the Gardren's parts.
 * Event-only: spawned by admins or formed from the pair, not buildable.
 */
/obj/vehicle/sealed/mecha/golden_gardren
	name = "\improper Golden-Gardren"
	desc = "Громадная боевая машина: Голден сидит в люке Гардрена, как голова на плечах, и возвышается над обычными мехами. Управляется двумя пилотами."
	icon = 'modular_bandastation/golden_gardren/icons/golden_gardren.dmi'
	icon_state = "golden_gardren"
	base_icon_state = "golden_gardren"
	SET_BASE_PIXEL(-8, 0)
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 450
	armor_type = /datum/armor/mecha_golden_gardren
	max_temperature = 30000
	force = 45
	destruction_sleep_duration = 40
	exit_delay = 40
	max_occupants = 2
	wreckage = /obj/structure/mecha_wreckage/golden_gardren
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
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
	/// Energy shield of the weapons seat.
	var/datum/golden_gardren_shield/shield
	/// Per-seat cockpit panel, created the first time a pilot opens it.
	var/datum/golden_gardren_cockpit/cockpit

/// One and a half times the armor of the halves (Marauder grade). Melee would come out at 105, so it is capped below full immunity.
/datum/armor/mecha_golden_gardren
	melee = 90
	bullet = 90
	laser = 90
	energy = 45
	bomb = 75
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/golden_gardren/Initialize(mapload, built_manually)
	. = ..()
	// The shield sprite is drawn for a regular mech, so it is stretched over the 48x48 frame.
	shield = new(src, 1.5, 8, 12)
	AddComponent(/datum/component/golden_gardren_phasing)
	AddComponent(/datum/component/golden_gardren_ejection)
	// The bigger frame holds things further out in front of it.
	AddComponent(/datum/component/golden_gardren_fist, 20)

/obj/vehicle/sealed/mecha/golden_gardren/Destroy()
	QDEL_NULL(cockpit)
	QDEL_NULL(shield)
	// Put the pilots on free turfs instead of the base drop under the frame.
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.eject(use_capsules = FALSE, stun = FALSE)
	// The halves exist only as a part of this frame now, so they go down with it.
	QDEL_NULL(docked_golden)
	QDEL_NULL(docked_gardren)
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_cockpit)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_swap_seat)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_separate)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_ram, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_phasing, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist, VEHICLE_CONTROL_MELEE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze, VEHICLE_CONTROL_MELEE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats, VEHICLE_CONTROL_EQUIPMENT)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_shield, VEHICLE_CONTROL_EQUIPMENT)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike/golden_gardren, VEHICLE_CONTROL_EQUIPMENT)

/// The first pilot in takes the main seat, the second one the weapons seat.
/obj/vehicle/sealed/mecha/golden_gardren/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers)
		add_control_flags(new_occupant, GOLDEN_GARDREN_MAIN_SEAT)
	else
		add_control_flags(new_occupant, GOLDEN_GARDREN_WEAPONS_SEAT)

/// Moves an occupant into the given seat, replacing whatever seat they had.
/obj/vehicle/sealed/mecha/golden_gardren/proc/assign_seat(mob/occupant, main_seat)
	remove_control_flags(occupant, ALL)
	remove_all_equipment_actions(occupant)
	add_control_flags(occupant, main_seat ? GOLDEN_GARDREN_MAIN_SEAT : GOLDEN_GARDREN_WEAPONS_SEAT)
	generate_equipment_actions(occupant)
	update_appearance()

// Equipment buttons belong to the weapons seat, not to the seat with mech settings.
/obj/vehicle/sealed/mecha/golden_gardren/generate_equipment_actions(mob/occupant)
	if(!(occupant in occupants) || !(occupants[occupant] & VEHICLE_CONTROL_EQUIPMENT))
		return
	for(var/obj/item/mecha_parts/mecha_equipment/equipment in flat_equipment)
		if(is_equipment_valid_for_action(equipment))
			grant_equipment_action(occupant, equipment)

/obj/vehicle/sealed/mecha/golden_gardren/on_equipment_attach(obj/item/mecha_parts/mecha_equipment/equipment)
	if(!is_equipment_valid_for_action(equipment))
		return
	for(var/mob/occupant as anything in return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT))
		grant_equipment_action(occupant, equipment)

/obj/vehicle/sealed/mecha/golden_gardren/remove_occupant(mob/driver)
	. = ..()
	// A pilot leaving during the ejection countdown takes no landing choice or marker with them.
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.clear_landing_choice(driver)
	// Without an operator the shield cannot be held.
	shield?.drop_if_unmanned()
	// Nobody left at the controls to hold the fist shut.
	if(!return_amount_of_controllers_with_flag(VEHICLE_CONTROL_MELEE))
		golden_gardren_release_fist(src)

/// Each seat may only use its own part of the mech panel: weapons belong to the weapons seat, settings to the main seat.
/obj/vehicle/sealed/mecha/golden_gardren/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui?.user
	if(user && is_occupant(user))
		var/static/list/weapons_seat_actions = list("select_module", "equip_act", "toggle_safety")
		if(occupants[user] & VEHICLE_CONTROL_SETTINGS)
			if(action == "equip_act")
				return FALSE
		else if(!(action in weapons_seat_actions))
			return FALSE
	return ..()

/// The shield soaks brute and burn damage from its own charge before it reaches the hull. Crossing into critical damage raises the alarm.
/obj/vehicle/sealed/mecha/golden_gardren/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(shield?.active && damage_amount > 0)
		damage_amount = shield.absorb(damage_amount, damage_type)
		if(damage_amount <= 0)
			return 0
	var/critical_integrity = max_integrity * GOLDEN_GARDREN_CRITICAL_INTEGRITY
	var/was_above_critical = get_integrity() > critical_integrity
	. = ..()
	if(was_above_critical && !QDELETED(src) && get_integrity() > 0 && get_integrity() <= critical_integrity)
		log_message("Integrity critical.", LOG_MECHA)
		to_chat(occupants, span_userdanger("КРИТИЧЕСКИЕ ПОВРЕЖДЕНИЯ! Корпус вот-вот разрушится — готовьтесь к аварийному катапультированию."))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 75, FALSE)

/// Throws the pilots clear of the wreck before the base destruction handles what is left.
/obj/vehicle/sealed/mecha/golden_gardren/atom_destruction(damage_flag)
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.eject()
	return ..()

/// While the ejection countdown runs, a pilot's click picks the landing turf instead of punching or shooting.
/obj/vehicle/sealed/mecha/golden_gardren/on_mouseclick(mob/user, atom/target, list/modifiers)
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	if(ejection?.handle_click(user, target))
		return COMSIG_MOB_CANCEL_CLICKON
	return ..()

/obj/vehicle/sealed/mecha/golden_gardren/update_overlays()
	. = ..()
	var/shield_overlay = shield?.get_overlay()
	if(shield_overlay)
		. += shield_overlay

/obj/vehicle/sealed/mecha/golden_gardren/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(golden_gardren_fist_intercept_unbuckle(src, buckled_mob, user))
		return null
	return ..()

/**
 * Forms the frame from the pair: moves the pilots in, takes over the Gardren's parts and docks both halves.
 * Every check must already have passed; either pilot may be missing.
 * Returns FALSE and leaves the pair untouched if a pilot could not be moved.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/assemble(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot)
	if(gardren_pilot && !take_pilot_from(gardren, gardren_pilot))
		return FALSE
	if(golden_pilot && !take_pilot_from(golden, golden_pilot))
		if(gardren_pilot)
			move_pilot_to(gardren, gardren_pilot)
		return FALSE
	// The seat follows the half the pilot came from, whoever entered first.
	if(gardren_pilot)
		assign_seat(gardren_pilot, main_seat = TRUE)
	if(golden_pilot)
		assign_seat(golden_pilot, main_seat = FALSE)

	for(var/obj/item/stock_parts/part in list(gardren.cell, gardren.scanmod, gardren.capacitor, gardren.servo))
		part.forceMove(src)
	gardren.locate_parts()
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

/// Moves a pilot from this frame into one of the halves. Used to roll back a failed assembly and on separation.
/obj/vehicle/sealed/mecha/golden_gardren/proc/move_pilot_to(obj/vehicle/sealed/mecha/destination, mob/living/pilot)
	if(!is_occupant(pilot))
		return
	SStgui.close_user_uis(pilot, src)
	// Leaving this frame makes its Exited() remove the occupant here.
	destination.mob_enter(pilot, silent = TRUE)
	pilot.update_mouse_pointer()
	destination.set_mouse_pointer()

/// Stores a half inside the frame: hidden, switched off and not processing until the frame separates.
/obj/vehicle/sealed/mecha/golden_gardren/proc/dock_component(obj/vehicle/sealed/mecha/component)
	golden_gardren_release_fist(component)
	var/datum/component/golden_gardren_phasing/phasing = component.GetComponent(/datum/component/golden_gardren_phasing)
	phasing?.set_active(FALSE)
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
	SET_BASE_PIXEL(-8, 0)
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
	salvage_num = 8

#undef GOLDEN_GARDREN_CRITICAL_INTEGRITY
