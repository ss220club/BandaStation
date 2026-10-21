/obj/item/choice_beacon/weapon
	name = "sidearm weapon beacon"
	desc = "Одноразовый маяк для доставки оружия по вашему выбору. Пожалуйста, используйте его только в своем офисе."
	var/static/list/selectable_gun_types = list()

/obj/item/choice_beacon/weapon/security_pistol/generate_display_names()
	selectable_gun_types = list(
		"GP-9 9x25mm Pistol" = /obj/item/storage/toolbox/guncase/ntcase/pistol/gp9/sec,
		"Disabler Energy Pistol" = /obj/item/gun/energy/disabler,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/blueshield
	name = "blueshield sidearm weapon beacon"

/obj/item/choice_beacon/weapon/blueshield/generate_display_names()
	selectable_gun_types = list(
		"EG-14 Energy Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/eg_14,
		"TNG-3 Thermal-Nanite pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/tng_3,
		"GP-38 .38 cal Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/gp38,
		"PDH-A1-M 'Ladon'" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/ladon,
	)
	return selectable_gun_types

/obj/item/choice_beacon/weapon/hos
	name = "HoS sidearm weapon beacon"

/obj/item/choice_beacon/weapon/hos/generate_display_names()
	selectable_gun_types = list(
		"X-01 MultiPhase Energy Gun" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_laser,
		"X-02 Laser Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_laser2,
		"GP-45 .45 cal Pistol" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_gp45,
		"PDH-A2-NR 'Osprey'" = /obj/item/storage/toolbox/guncase/ntspecial/pistol/hos_pdh,
	)
	return selectable_gun_types

/obj/structure/closet/secure_closet/hos/PopulateContents()
	. = ..()
	new /obj/item/clothing/accessory/holster(src)

/datum/outfit/job/security
	suit_store = null
	backpack_contents = list(
		/obj/item/choice_beacon/weapon/security_pistol = 1,
	)

/datum/objective_item/steal/hoslaser
	targetitem = /obj/item/choice_beacon/weapon/hos
	exists_on_map = FALSE
	altitems = list(/obj/item/gun/ballistic/automatic/pistol/pdh/hos, /obj/item/gun/ballistic/automatic/pistol/cm70/hos, /obj/item/gun/ballistic/automatic/laser/pistol, /obj/item/gun/energy/e_gun/hos)
