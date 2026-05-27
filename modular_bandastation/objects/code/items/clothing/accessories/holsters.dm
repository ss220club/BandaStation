//MARK: Standart holster, empty
/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "Обычная, ничем не примечательная кобура под одно небольшое оружие."
	icon = 'modular_bandastation/objects/icons/obj/clothing/holsters.dmi'
	icon_state = "holster"
	worn_icon = 'modular_bandastation/objects/icons/onbody/holsters.dmi'
	worn_icon_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER
	w_class = WEIGHT_CLASS_BULKY
	above_suit = FALSE

/datum/storage/pockets/holster
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holster/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14
	))

/obj/item/clothing/accessory/holster/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster)

/obj/item/clothing/accessory/holster/Entered(atom/movable/I)
	. = ..()

	if(istype(I, /obj/item/gun))
		playsound(src, 'modular_bandastation/weapon/sound/ranged/holster_getting.ogg', 50, TRUE)

/obj/item/clothing/accessory/holster/Exited(atom/movable/I)
	. = ..()

	if(istype(I, /obj/item/gun))
		playsound(src, 'modular_bandastation/weapon/sound/ranged/holster_putting.ogg', 50, TRUE)

/obj/item/clothing/accessory/holster/proc/get_holstered_gun()
	for(var/obj/item/gun/G in atom_storage.real_location.contents)
		return G
	return null

/obj/item/clothing/accessory/holster/attack_hand(mob/user)
	if(user != loc)
		var/mob/living/carbon/human/H = null
		if(ishuman(loc))
			H = loc
		else if(ishuman(loc?.loc))
			H = loc.loc
		if(H)
			H.visible_message(
				span_userdanger("[user] пытается сорвать кобуру с [H]!"),
				span_userdanger("[user] пытается сорвать вашу кобуру!")
			)

	return ..()

/obj/item/clothing/accessory/holster/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	..()
	if(user)
		ADD_CLOTHING_TRAIT(user, TRAIT_GUNFLIP)

/obj/item/clothing/accessory/holster/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	..()
	if(user)
		REMOVE_CLOTHING_TRAIT(user, TRAIT_GUNFLIP)

// Empty energy holster
/obj/item/clothing/accessory/holster/energy
	name = "energy shoulder holsters"
	desc = "Обычная, ничем не примечательная кобура под несколько энергетических пистолетов."

/datum/storage/pockets/holster/energy
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holster/energy/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14
	))

/obj/item/clothing/accessory/holster/energy/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/energy)

/obj/item/clothing/accessory/holster/energy/proc/get_holstered_guns()

	var/list/guns = list()

	for(var/obj/item/gun/energy/G in contents)
		guns += G
	return guns

// Energy holster with one disabler
/obj/item/clothing/accessory/holster/energy/disabler

/obj/item/clothing/accessory/holster/energy/disabler/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/energy)
	new /obj/item/gun/energy/disabler(src)

// Energy holster with one laser pistol
/obj/item/clothing/accessory/holster/energy/laser_pistol

/obj/item/clothing/accessory/holster/energy/laser_pistol/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/energy)
	new /obj/item/gun/energy/laser/pistol(src)

// Energy holster with two smoothborne disablers
/obj/item/clothing/accessory/holster/energy/smoothborne

/obj/item/clothing/accessory/holster/energy/smoothborne/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/energy)
	new /obj/item/gun/energy/disabler/smoothbore(src)
	new /obj/item/gun/energy/disabler/smoothbore(src)

// Energy holster with two nano-pistols
/obj/item/clothing/accessory/holster/energy/thermal

/obj/item/clothing/accessory/holster/energy/thermal/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/energy)
	new /obj/item/gun/energy/laser/thermal/cryo(src)
	new /obj/item/gun/energy/laser/thermal/inferno(src)

// Detective holster
/obj/item/clothing/accessory/holster/detective
	name = "detective's holster"
	desc = "Улучшенная кобура, специально созданная для проведения самых громких и выдающихся расследований. Имеет дополнительные кармашки для магазинов."

/datum/storage/pockets/holster/dec
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holster/dec/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/ammo_box/magazine,
		/obj/item/ammo_box/speedloader
	))

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/dec)

// One gun logic
/obj/item/clothing/accessory/holster/detective/Entered(atom/movable/I)
	. = ..()

	if(!istype(I, /obj/item/gun))
		return

	var/obj/item/gun/new_gun = I
	var/obj/item/gun/existing_gun = null

	for(var/obj/item/gun/G in src)
		if(G != new_gun)
			existing_gun = G
			break

	if(existing_gun)
		var/mob/user = null

		if(ismob(src.loc))
			user = src.loc
		else if(ismob(src.loc?.loc))
			user = src.loc.loc
		new_gun.forceMove(user ? user : get_turf(src))

		if(user)
			user.put_in_hands(new_gun)
			to_chat(user, span_warning("В кобуре уже есть оружие!"))

// Full detective holster
/obj/item/clothing/accessory/holster/detective/full

/obj/item/clothing/accessory/holster/detective/full/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/dec)
	new /obj/item/gun/ballistic/revolver/c38/detective(src)
	new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/ammo_box/speedloader/c38(src)

// Traitor holster
/obj/item/clothing/accessory/holster/chameleon
	name = "pocket protector"
	desc = "Может защитить вашу одежду от чернильных пятен, но вы будете выглядеть как зануда, если будете им пользоваться."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	worn_icon_state = "pocketprotector"
	w_class = WEIGHT_CLASS_SMALL
	above_suit = TRUE

/datum/storage/pockets/holster/traitor
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL
	silent = TRUE

/datum/storage/pockets/holster/traitor/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/e_gun/mini
	))

/obj/item/clothing/accessory/holster/chameleon/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/traitor)

// Tacticool holster
/obj/item/clothing/accessory/holster/tacticool
	name = "tacticool holster"
	desc = "Тёмная тактическая кобура с двумя карманами, предназначенная для выполнения специальных задач. Особые крепления позволяют надеть её поверх униформы."
	icon_state = "operative_holster"
	worn_icon = 'modular_bandastation/objects/icons/onbody/holsters.dmi'
	worn_icon_state = "holster"

/datum/storage/pockets/holster/tac
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/pockets/holster/tac/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/ballistic/shotgun/automatic/combat/compact,
		/obj/item/gun/ballistic/automatic/cm5/compact,
		/obj/item/gun/ballistic/automatic/proto/unrestricted,
		/obj/item/gun/ballistic/automatic/mini_uzi,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/ammo_box/magazine,
		/obj/item/ammo_box/speedloader,
		/obj/item/knife/combat,
		/obj/item/grenade
	))

/obj/item/clothing/accessory/holster/tacticool/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/tac)

/obj/item/clothing/accessory/holster/tacticool/cowboy

/obj/item/clothing/accessory/holster/tacticool/cowboy/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/tac)
	new /obj/item/gun/ballistic/revolver/cowboy/nuclear(src)
	new /obj/item/ammo_box/speedloader/c357(src)

/obj/item/clothing/accessory/holster/tacticool/ert_gp93r

/obj/item/clothing/accessory/holster/tacticool/ert_gp93r/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/tac)
	new /obj/item/gun/ballistic/automatic/pistol/gp9/spec(src)
	new /obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap(src)

/obj/item/clothing/accessory/holster/tacticool/ert_gammacom

/obj/item/clothing/accessory/holster/tacticool/ert_gammacom/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/tac)
	new /obj/item/gun/ballistic/automatic/cm5/compact(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm357(src)

/obj/item/clothing/accessory/holster/tacticool/tsf_commander

/obj/item/clothing/accessory/holster/tacticool/tsf_commander/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/tac)
	new /obj/item/gun/ballistic/automatic/pistol/deagle/regal(src)
	new /obj/item/ammo_box/magazine/r10mm(src)

/obj/item/clothing/accessory/holster/tacticool/ussp_commander
	icon_state = "holster"
	desc = "Коричневая тактическая кобура с двумя карманами, предназначенная для выполнения специальных задач. Особые крепления позволяют надеть её поверх униформы."

/obj/item/clothing/accessory/holster/tacticool/ussp_commander/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/tac)
	new /obj/item/gun/ballistic/revolver/nagant(src)
	new /obj/item/ammo_box/speedloader/n762_cylinder(src)
