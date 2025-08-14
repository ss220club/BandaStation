// MARK: TSF
/obj/item/storage/belt/military/army/tsf
	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	icon_state = "military_holster"
	storage_type = /datum/storage/military_belt/tsf

/datum/storage/military_belt/tsf
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_SMALL * 8
	max_slots = 10

/obj/item/storage/belt/military/army/tsf/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_submachine/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_rifle_short/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/pierce(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_rifle_standart/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard/pierce(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_engineer/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/wespe(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/stendo(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_machinegun/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/box(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/box/pierce(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/tsf/full_infiltrator/PopulateContents()
	new /obj/item/gun/ballistic/automatic/sindano/compact/suppressed(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap(src)
	new /obj/item/ammo_box/magazine/c35sol_pistol/drum/ap(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard(src)
	new /obj/item/ammo_box/magazine/c40sol_rifle/standard/pierce(src)

/obj/item/storage/belt/holster/detective/full/ert/tsf_commander
	name = "TSF commander's holster"
	desc = "Wearing this makes you feel badass."

/obj/item/storage/belt/holster/detective/full/ert/tsf_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/magazine/r10mm = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle/regal = 1,
	),src)

// MARK: USSP
/obj/item/storage/belt/military/army/ussp
	icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/belt.dmi'
	icon_state = "ussp_belt"
	inhand_icon_state = "utility"
	worn_icon_state = "ussp_belt"
	storage_type = /datum/storage/military_belt/ussp

/datum/storage/military_belt/ussp
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_SMALL * 8
	max_slots = 10

/obj/item/storage/belt/military/army/ussp/full/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_rifle_small/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_rifle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_autorifle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/knife/combat(src)

/obj/item/storage/belt/military/army/ussp/full_autorifle_spetsnaz/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/emp(src)

/obj/item/storage/belt/military/army/ussp/full_engineer/PopulateContents()
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/ammo_box/strilka310(src)
	new /obj/item/knife/combat(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/stack/sheet/mineral/sandbags/thirty(src)

/obj/item/storage/belt/military/army/ussp/full_infiltrator/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/suppressed(src)
	new /obj/item/ammo_box/magazine/m9mm/ap(src)
	new /obj/item/ammo_box/magazine/m9mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/ap(src)
	new /obj/item/ammo_box/magazine/c762x39mm/emp(src)
	new /obj/item/knife/combat(src)

/obj/item/stack/sheet/mineral/sandbags/thirty
	amount = 30

/obj/item/storage/belt/holster/detective/full/ert/ussp_commander
	name = "USSP commander's holster"
	desc = "Wearing this makes you feel comrade."
	icon_state = "holster"

/obj/item/storage/belt/holster/detective/full/ert/ussp_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/ammo_box/n762_cylinder = 2,
		/obj/item/gun/ballistic/revolver/nagant = 1,
	),src)
