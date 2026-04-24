//MARK: Обычная кобура, пустая
/obj/item/clothing/accessory/holster
	name = "кобура под пистолет"
	desc = "Обычная, ничем не примечательная кобура под одно небольшое оружие."
	icon = 'modular_bandastation/objects/icons/obj/clothing/holsters.dmi'
	icon_state = "holster"
	worn_icon = 'modular_bandastation/objects/icons/onbody/holsters.dmi'
	worn_icon_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER
	w_class = WEIGHT_CLASS_BULKY
	above_suit = FALSE

/datum/storage/pockets/holst
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holst/New()
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
	create_storage(storage_type = /datum/storage/pockets/holst)

/obj/item/clothing/accessory/holst/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	var/result = ..()
	if(!result)
		return

	if(!isnull(attach_to.atom_storage))
		if(user)
			attach_to.balloon_alert(user, "Этот предмет не помещается!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/holster/Entered(atom/movable/I)
	. = ..()

	if(istype(I, /obj/item/gun))
		playsound(src, 'modular_bandastation/weapon/sound/ranged/holster_getting.ogg', 50, TRUE)

/obj/item/clothing/accessory/holster/Exited(atom/movable/I)
	. = ..()

	if(istype(I, /obj/item/gun))
		playsound(src, 'modular_bandastation/weapon/sound/ranged/holster_putting.ogg', 50, TRUE)

//MARK: Пустая энергетическая кобура
/obj/item/clothing/accessory/holster/energy
	name = "кобура под энергетические пистолеты"
	desc = "Обычная, ничем не примечательная кобура под несколько энергетических пистолетов."

/datum/storage/pockets/holst/energy
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holst/energy/New()
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
	create_storage(storage_type = /datum/storage/pockets/holst/energy)

//MARK: Заполненная энергетическая кобура с одним дизейблером
/obj/item/clothing/accessory/holster/energy/disabler

/obj/item/clothing/accessory/holster/energy/disabler/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/energy)
	new /obj/item/gun/energy/disabler(src)

//MARK: Заполненная энергетическая кобура с двумя нано-пистолетами
/obj/item/clothing/accessory/holster/energy/thermal

/obj/item/clothing/accessory/holster/energy/thermal/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/energy)
	new /obj/item/gun/energy/laser/thermal/cryo(src)
	new /obj/item/gun/energy/laser/thermal/inferno(src)

//MARK: Кобура детектива, пустая
/obj/item/clothing/accessory/holster/detective
	name = "кобура детектива"
	desc = "Улучшенная кобура, специально для проведения самых громких и выдающихся расследований. Есть дополнительные кармашки под магазины."

/datum/storage/pockets/holst/dec
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holst/dec/New()
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
	create_storage(storage_type = /datum/storage/pockets/holst/dec)

//MARK: Проверка на то, чтобы была возможность помещать только один вид оружия
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

//MARK: Полная кобура детектива
/obj/item/clothing/accessory/holster/detective/full

/obj/item/clothing/accessory/holster/detective/full/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/dec)
	new /obj/item/gun/ballistic/revolver/c38/detective(src)
	new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/ammo_box/speedloader/c38(src)

//MARK: Трейторская хамелеон-кобура, пустая
/obj/item/clothing/accessory/holster/chameleon
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	worn_icon_state = "pocketprotector"
	w_class = WEIGHT_CLASS_SMALL
	above_suit = TRUE

/datum/storage/pockets/holst/trait
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holst/trait/New()
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
	create_storage(storage_type = /datum/storage/pockets/holst/trait)

//MARK: Разные виды тактической кобуры (2 свободных слота)
/obj/item/clothing/accessory/holster/tacticool
	name = "тактическая кобура"
	desc = "Темная, тактическая кобура с двумя карманами, предназначенная для выполнения специальных задач. Особые крепления позволяют её надеть поверх униформы"
	icon_state = "operative_holster"
	worn_icon = 'modular_bandastation/objects/icons/onbody/holsters.dmi'
	worn_icon_state = "holster"

/datum/storage/pockets/holst/tac
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/pockets/holst/tac/New()
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
	create_storage(storage_type = /datum/storage/pockets/holst/tac)

/obj/item/clothing/accessory/holster/tacticool/cowboy

/obj/item/clothing/accessory/holster/tacticool/cowboy/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/tac)
	new /obj/item/gun/ballistic/revolver/cowboy/nuclear(src)
	new /obj/item/ammo_box/speedloader/c357(src)

/obj/item/clothing/accessory/holster/tacticool/ert_gp93r

/obj/item/clothing/accessory/holster/tacticool/ert_gp93r/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/tac)
	new /obj/item/gun/ballistic/automatic/pistol/gp9/spec(src)
	new /obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap(src)

/obj/item/clothing/accessory/holster/tacticool/ert_gammacom

/obj/item/clothing/accessory/holster/tacticool/ert_gammacom/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/tac)
	new /obj/item/gun/ballistic/automatic/cm5/compact(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm357(src)

/obj/item/clothing/accessory/holster/tacticool/tsf_commander

/obj/item/clothing/accessory/holster/tacticool/tsf_commander/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/tac)
	new /obj/item/gun/ballistic/automatic/pistol/deagle/regal(src)
	new /obj/item/ammo_box/magazine/r10mm(src)

/obj/item/clothing/accessory/holster/tacticool/ussp_commander
	icon_state = "holster"
	desc = "Коричневая, тактическая кобура с двумя карманами, предназначенная для выполнения специальных задач. Особые крепления позволяют её надеть поверх униформы"

/obj/item/clothing/accessory/holster/tacticool/ussp_commander/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holst/tac)
	new /obj/item/gun/ballistic/revolver/nagant(src)
	new /obj/item/ammo_box/speedloader/n762_cylinder(src)
