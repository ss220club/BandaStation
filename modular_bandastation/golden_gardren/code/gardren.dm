/**
 * ## Gardren
 *
 * Light gunner half of the Golden-Gardren pair.
 * Alone it is a regular single-pilot exosuit; it docks into the Golden to form the combined mech.
 * Event-only: spawned by admins, not buildable.
 */
/obj/vehicle/sealed/mecha/gardren
	name = "\improper Gardren"
	desc = "Компактный экзокостюм-стрелок с округлой кабиной, широким визором и спаренными стволами."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren"
	base_icon_state = "gardren"
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE
	// Reuses the Savannah-Ivanov module bit so combat equipment fits without a new exosuit define.
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 2
	max_integrity = 250
	armor_type = /datum/armor/mecha_gardren
	max_temperature = 30000
	force = 15
	destruction_sleep_duration = 40
	exit_delay = 30
	wreckage = /obj/structure/mecha_wreckage/gardren
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)

/datum/armor/mecha_gardren
	melee = 25
	bullet = 30
	laser = 40
	energy = 40
	bomb = 30
	fire = 100
	acid = 100

/obj/structure/mecha_wreckage/gardren
	name = "\improper Gardren wreckage"
	desc = "Расколотая кабина Гардрена с погасшим визором. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren-broken"
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
