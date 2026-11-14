/**
 * ## Gardren
 *
 * Big melee body of the Golden-Gardren pair. Gygax-class frame with Durand-grade armor.
 * Alone it is a regular single-pilot exosuit; the Golden climbs into its hatch to form the combined mech.
 * Event-only: spawned by admins, not buildable.
 */
/obj/vehicle/sealed/mecha/gardren
	name = "\improper Gardren"
	desc = "Массивный экзокостюм ближнего боя с золочёной бронёй и огромными кулаками. Сверху виден стыковочный люк."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren"
	base_icon_state = "gardren"
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 250
	armor_type = /datum/armor/mecha_durand
	max_temperature = 30000
	force = 25
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/gardren
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma,
		MECHA_R_ARM = null,
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

/obj/vehicle/sealed/mecha/gardren/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_combine)

/obj/structure/mecha_wreckage/gardren
	name = "\improper Gardren wreckage"
	desc = "Смятый золочёный корпус Гардрена. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren-broken"
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
