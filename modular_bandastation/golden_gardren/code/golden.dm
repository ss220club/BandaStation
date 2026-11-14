/**
 * ## Golden
 *
 * Small fast gunner of the Golden-Gardren pair, the head of the combined mech.
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
	movedelay = 2
	max_integrity = 200
	armor_type = /datum/armor/mecha_gygax
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

/obj/vehicle/sealed/mecha/golden/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_combine)

/obj/structure/mecha_wreckage/golden
	name = "\improper Golden wreckage"
	desc = "Расколотая кабина Голдена с погасшим визором. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden-broken"
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
