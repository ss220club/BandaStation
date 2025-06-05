// TSF
// Marine belt
/obj/item/storage/belt/military/army/tsf
	storage_type = /datum/storage/military_belt/tsf

/obj/item/storage/belt/military/army/tsf/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/knife/combat(src)

/datum/storage/military_belt/tsf
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 8

// Infiltrator belt
/obj/item/storage/belt/military/army/tsf_infiltrator
	name = "infiltrator belt"
	desc = "A belt used by special forces."
	storage_type = /datum/storage/military_belt/tsf

/obj/item/storage/belt/military/army/tsf_infiltrator/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe/suppressed(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo/ripper(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo/ap(src)
	new /obj/item/ammo_box/magazine/smgm45/ap(src)
	new /obj/item/ammo_box/magazine/smgm45/ap(src)
	new /obj/item/ammo_box/magazine/smgm45/ap(src)
	new /obj/item/ammo_box/magazine/smgm45/ap(src)

//USSP
/obj/item/storage/belt/military/army/ussp
//	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
//	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt.dmi'
//	icon_state = "ussp_belt"
//	inhand_icon_state = "utility"
//	worn_icon_state = "ussp_belt"
	storage_type = /datum/storage/military_belt/ussp

/datum/storage/military_belt/ussp
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 8

/obj/item/storage/belt/military/army/ussp/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_rifle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)

/obj/item/storage/belt/military/army/ussp/full_engineer/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/knife/combat(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/stack/sheet/mineral/sandbags/thirty(src)

/obj/item/stack/sheet/mineral/sandbags/thirty
	amount = 30
