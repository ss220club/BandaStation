/obj/vehicle/sealed/mecha/golden
	parent_type = /obj/vehicle/sealed/mecha/golden_gardren_base
	name = "\improper Golden"
	desc = "Маленький быстрый экзокостюм-стрелок с широким визором и антенной на плече."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden"
	base_icon_state = "golden"
	SET_BASE_PIXEL(-4, 0)
	movedelay = 2.7
	max_integrity = 200
	armor_type = /datum/armor/mecha_marauder
	force = 15
	exit_delay = 30
	wreckage = /obj/structure/mecha_wreckage/golden

/obj/vehicle/sealed/mecha/golden/Initialize(mapload, built_manually)
	. = ..()
	AddComponent(/datum/component/golden_gardren_shield, 1.25, 4, 8)

/obj/vehicle/sealed/mecha/golden/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_combine)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_emergency_eject)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/golden_gardren_shield, VEHICLE_CONTROL_EQUIPMENT)

/obj/structure/mecha_wreckage/golden
	name = "\improper Golden wreckage"
	desc = "Расколотая кабина Голдена с погасшим визором. Восстановить невозможно, но что-то ещё можно снять."
	icon = 'modular_bandastation/golden_gardren/icons/golden.dmi'
	icon_state = "golden-broken"
	SET_BASE_PIXEL(-4, 0)
	welder_salvage = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/iron, /obj/item/stack/rods)
