/**
 * ## Golden
 *
 * Small gunner of the Golden-Gardren pair, the head of the combined mech. Faster than a Gygax, Marauder-grade armor and an energy shield.
 * Alone it is a regular single-pilot exosuit; it climbs onto the Gardren to form the combined mech.
 * Event-only: spawned by admins, not buildable.
 */
/obj/vehicle/sealed/mecha/golden
	name = "\improper Golden"
	desc = "Маленький быстрый экзокостюм-стрелок с округлой кабиной, широким визором и спаренными стволами."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden"
	base_icon_state = "golden"
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	// About a tenth faster than a Gygax: with the server's speed scale this is the step that lands on a 4 decisecond move.
	movedelay = 2.7
	max_integrity = 200
	armor_type = /datum/armor/mecha_marauder
	max_temperature = 30000
	force = 15
	destruction_sleep_duration = 40
	exit_delay = 30
	wreckage = /obj/structure/mecha_wreckage/golden
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
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
	/// Energy shield, the same one the Golden operates as the gunner of the combined mech.
	var/datum/golden_gardren_shield/shield

/obj/vehicle/sealed/mecha/golden/Initialize(mapload, built_manually)
	. = ..()
	shield = new(src)
	AddComponent(/datum/component/golden_gardren_ejection)

/obj/vehicle/sealed/mecha/golden/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module(src)
	capacitor = new /obj/item/stock_parts/capacitor(src)
	servo = new /obj/item/stock_parts/servo(src)
	update_part_values()

/obj/vehicle/sealed/mecha/golden/Destroy()
	QDEL_NULL(shield)
	return ..()

/obj/vehicle/sealed/mecha/golden/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_combine)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_shield, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/golden/remove_occupant(mob/driver)
	. = ..()
	shield?.drop_if_unmanned()
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.clear_landing_choice(driver)

/// While the ejection countdown runs, the pilot's click picks the landing turf instead of shooting.
/obj/vehicle/sealed/mecha/golden/on_mouseclick(mob/user, atom/target, list/modifiers)
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	if(ejection?.handle_click(user, target))
		return COMSIG_MOB_CANCEL_CLICKON
	return ..()

/// Fires the pilot clear of the wreck in a capsule before the base destruction handles what is left.
/obj/vehicle/sealed/mecha/golden/atom_destruction(damage_flag)
	var/datum/component/golden_gardren_ejection/ejection = GetComponent(/datum/component/golden_gardren_ejection)
	ejection?.eject()
	return ..()

/obj/vehicle/sealed/mecha/golden/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(shield?.active && damage_amount > 0)
		damage_amount = shield.absorb(damage_amount, damage_type)
		if(damage_amount <= 0)
			return 0
	return ..()

/obj/vehicle/sealed/mecha/golden/update_overlays()
	. = ..()
	var/shield_overlay = shield?.get_overlay()
	if(shield_overlay)
		. += shield_overlay

/obj/structure/mecha_wreckage/golden
	name = "\improper Golden wreckage"
	desc = "Расколотая кабина Голдена с погасшим визором. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden-broken"
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
