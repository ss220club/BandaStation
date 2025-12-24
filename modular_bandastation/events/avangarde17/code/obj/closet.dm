// MARK: Closet
// Шкафоуни

/obj/structure/closet/secure_closet/armory4
	name = "шкафчик со спецсредствами"
	icon_state = "armory"
	req_access = list(ACCESS_CENT_GENERAL)

/obj/structure/closet/secure_closet/armory4/PopulateContents()
	..()
	new /obj/item/gun/ballistic/automatic/sabel/auto(src)
	for(var/i in 1 to 4)
		new /obj/item/ammo_box/magazine/c762x39mm/small(src)

/obj/structure/closet/secure_closet/omon
	name = "шкафчик со снаряжением"
	icon_state = "secure"
	req_access = list(ACCESS_CENT_GENERAL)

/obj/structure/closet/secure_closet/omon/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/riot/ussp_riot(src)
	new /obj/item/storage/backpack/ussp(src)
	new /obj/item/grenade/chem_grenade/teargas(src)
	new /obj/item/clothing/head/helmet/toggleable/riot/ussp_riot(src)
	new /obj/item/clothing/mask/balaclava/breath(src)
	new /obj/item/storage/belt/military/army/ussp(src)
	for(var/i in 1 to 3)
		new /obj/item/restraints/handcuffs(src)
