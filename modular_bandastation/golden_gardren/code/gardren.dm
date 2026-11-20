/**
 * ## Gardren
 *
 * Big melee body of the Golden-Gardren pair and the base of the combined mech: its pilot takes the main seat.
 * Faster than a Gygax, Marauder-grade armor, a phase shift and a Titanfall-style fist.
 * Alone it is a regular single-pilot exosuit; the Golden climbs into its hatch to form the combined mech.
 * Event-only: spawned by admins, not buildable.
 */
/obj/vehicle/sealed/mecha/gardren
	parent_type = /obj/vehicle/sealed/mecha/golden_gardren_base
	name = "\improper Gardren"
	desc = "Экзокостюм ближнего боя с усиленными кулаками, массивными наплечниками и стыковочным узлом."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren"
	base_icon_state = "gardren"
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	// About a fifth faster than a Gygax: with the server's speed scale this is the step that lands on a 3.5 decisecond move.
	movedelay = 2.35
	max_integrity = 250
	armor_type = /datum/armor/mecha_marauder
	max_temperature = 30000
	force = 25
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/gardren
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
		MECHA_UTILITY = 2,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)

/obj/vehicle/sealed/mecha/gardren/Initialize(mapload, built_manually)
	. = ..()
	AddComponent(/datum/component/golden_gardren_phasing)
	AddComponent(/datum/component/golden_gardren_fist)

/obj/vehicle/sealed/mecha/gardren/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module(src)
	capacitor = new /obj/item/stock_parts/capacitor(src)
	servo = new /obj/item/stock_parts/servo(src)
	update_part_values()

/obj/vehicle/sealed/mecha/gardren/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_combine)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_phasing, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist, VEHICLE_CONTROL_MELEE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze, VEHICLE_CONTROL_MELEE)

/obj/vehicle/sealed/mecha/gardren/remove_occupant(mob/driver)
	. = ..()
	// Nobody left at the controls to hold the fist shut.
	if(!return_amount_of_controllers_with_flag(VEHICLE_CONTROL_MELEE))
		golden_gardren_release_fist(src)

/obj/vehicle/sealed/mecha/gardren/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(golden_gardren_fist_intercept_unbuckle(src, buckled_mob, user))
		return null
	return ..()

/obj/structure/mecha_wreckage/gardren
	name = "\improper Gardren wreckage"
	desc = "Смятый золочёный корпус Гардрена. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren-broken"
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
