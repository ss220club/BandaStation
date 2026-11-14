/**
 * ## Golden
 *
 * Heavy melee half of the Golden-Gardren pair.
 * Alone it is a regular single-pilot exosuit; the gunner half docks into it to form the combined mech.
 * Event-only: spawned by admins, not buildable.
 */
/obj/vehicle/sealed/mecha/golden
	name = "\improper Golden"
	desc = "Массивный экзокостюм ближнего боя с золочёной бронёй и огромными кулаками. Сверху виден стыковочный люк."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden"
	base_icon_state = "golden"
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 400
	armor_type = /datum/armor/mecha_golden
	max_temperature = 30000
	force = 40
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/golden
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 2,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)

/datum/armor/mecha_golden
	melee = 50
	bullet = 35
	laser = 30
	energy = 30
	bomb = 40
	fire = 100
	acid = 100

/obj/structure/mecha_wreckage/golden
	name = "\improper Golden wreckage"
	desc = "Смятый золочёный корпус Голдена. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden-broken"
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
