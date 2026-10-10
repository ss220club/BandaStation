/obj/item/choice_beacon/weapon
	name = "sidearm weapon beacon"
	desc = "Одноразовый маяк для доставки оружия по вашему выбору. Пожалуйста, используйте его только в своем офисе."

/obj/item/choice_beacon/weapon/security_pistol/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"GP-9 9x25mm Pistol" = /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec,
		"Disabler Energy Pistol" = /obj/item/gun/energy/disabler,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/blueshield/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"EG-14 Energy Pistol" = /obj/item/gun/energy/eg_14,
		"GP-38 .38 cal Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp38,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/hos/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"X-01 MultiPhase Energy Gun" = /obj/item/gun/energy/e_gun/hos,
		"X-02 Laser Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos,
		"GP-45 .45 cal Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp45,
		"PDH-A2 'Osprey'" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/pdh,
	)
	return selectable_gun_types

/datum/outfit/job/security
	suit_store = null
	backpack_contents = list(
		/obj/item/choice_beacon/weapon/security_pistol = 1,
	)

/datum/objective_item/steal/hoslaser
	targetitem = /obj/item/choice_beacon/weapon/hos
	altitems = list(/obj/item/gun/ballistic/automatic/pistol/pdh/hos, /obj/item/gun/ballistic/automatic/pistol/cm70/hos, /obj/item/gun/ballistic/automatic/laser/pistol, /obj/item/gun/energy/e_gun/hos)

/obj/item/choice_beacon/hos/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/choice_beacon/weapon/hos)
