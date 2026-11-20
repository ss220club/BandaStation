/// Share of integrity at and below which the pilots are warned that the frame is about to break.
#define GOLDEN_GARDREN_CRITICAL_INTEGRITY 0.3

/obj/vehicle/sealed/mecha/golden_gardren
	parent_type = /obj/vehicle/sealed/mecha/golden_gardren_base
	name = "\improper Golden-Gardren"
	desc = "Громадная боевая машина: Голден сидит в люке Гардрена, как голова на плечах, и возвышается над обычными мехами. Управляется двумя пилотами."
	icon = 'modular_bandastation/golden_gardren/icons/golden_gardren.dmi'
	icon_state = "golden_gardren"
	base_icon_state = "golden_gardren"
	SET_BASE_PIXEL(-8, 0)
	movedelay = 3
	max_integrity = 450
	armor_type = /datum/armor/mecha_golden_gardren
	force = 45
	max_occupants = 2
	wreckage = /obj/structure/mecha_wreckage/golden_gardren
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/golden_gardren,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/golden_gardren,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	/// The Golden docked inside while combined. Null for an admin-spawned frame.
	var/obj/vehicle/sealed/mecha/golden/docked_golden
	/// The Gardren docked inside while combined. Null for an admin-spawned frame.
	var/obj/vehicle/sealed/mecha/gardren/docked_gardren
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
	AddComponent(/datum/component/golden_gardren_shield, 1.5, 8, 12)
	AddComponent(/datum/component/golden_gardren_phasing)
	// The bigger frame holds things further out in front of it.
	AddComponent(/datum/component/golden_gardren_fist, 20)

/obj/vehicle/sealed/mecha/golden_gardren/Destroy()
	QDEL_NULL(cockpit)
	// Put the pilots on free turfs instead of the base drop under the frame.
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.eject(use_capsules = FALSE)
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
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_phasing, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist, VEHICLE_CONTROL_MELEE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze, VEHICLE_CONTROL_MELEE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats, VEHICLE_CONTROL_EQUIPMENT)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_shield, VEHICLE_CONTROL_EQUIPMENT)

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
	drop_unmanned_systems()
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

/// Sound the alarm when the frame crosses the critical integrity threshold.
/obj/vehicle/sealed/mecha/golden_gardren/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	var/critical_integrity = max_integrity * GOLDEN_GARDREN_CRITICAL_INTEGRITY
	var/was_above_critical = get_integrity() > critical_integrity
	. = ..()
	if(was_above_critical && !QDELETED(src) && get_integrity() > 0 && get_integrity() <= critical_integrity)
		log_message("Integrity critical.", LOG_MECHA)
		to_chat(occupants, span_userdanger("КРИТИЧЕСКИЕ ПОВРЕЖДЕНИЯ! Корпус вот-вот разрушится — готовьтесь к аварийному катапультированию."))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 75, FALSE)

/**
 * Forms the frame from the pair: moves the pilots in, takes over the Gardren's parts and docks both halves.
 * Both pilots must still be at the controls of their original mechs.
 * Returns FALSE and leaves the pair untouched if a pilot could not be moved.
 */
/obj/vehicle/sealed/mecha/golden_gardren/proc/assemble(obj/vehicle/sealed/mecha/golden/golden, obj/vehicle/sealed/mecha/gardren/gardren, mob/living/golden_pilot, mob/living/gardren_pilot)
	if(!golden_gardren_pilot_ready(golden, golden_pilot) || !golden_gardren_pilot_ready(gardren, gardren_pilot))
		return FALSE
	if(!gardren.transfer_pilot(src, gardren_pilot))
		return FALSE
	if(!golden.transfer_pilot(src, golden_pilot))
		transfer_pilot(gardren, gardren_pilot)
		return FALSE
	assign_seat(gardren_pilot, main_seat = TRUE)
	assign_seat(golden_pilot, main_seat = FALSE)

	gardren.transfer_stock_parts(src)

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
