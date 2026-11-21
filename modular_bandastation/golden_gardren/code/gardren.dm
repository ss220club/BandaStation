/obj/vehicle/sealed/mecha/gardren
	parent_type = /obj/vehicle/sealed/mecha/golden_gardren_base
	name = "\improper Gardren"
	desc = "Экзокостюм ближнего боя с усиленными кулаками, массивными наплечниками и стыковочным узлом."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren"
	base_icon_state = "gardren"
	SET_BASE_PIXEL(-4, 0)
	movedelay = 2.35
	max_integrity = 250
	armor_type = /datum/armor/mecha_marauder
	force = 25
	wreckage = /obj/structure/mecha_wreckage/gardren

/obj/vehicle/sealed/mecha/gardren/Initialize(mapload, built_manually)
	max_equip_by_category[MECHA_UTILITY] = 2
	. = ..()
	AddComponent(/datum/component/golden_gardren_phasing)
	AddComponent(/datum/component/golden_gardren_fist, 20)

/obj/vehicle/sealed/mecha/gardren/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_combine)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_phasing, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist, VEHICLE_CONTROL_MELEE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_fist_squeeze, VEHICLE_CONTROL_MELEE)

/obj/structure/mecha_wreckage/gardren
	name = "\improper Gardren wreckage"
	desc = "Смятый золочёный корпус Гардрена. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/gardren.dmi'
	icon_state = "gardren-broken"
	SET_BASE_PIXEL(-4, 0)
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
