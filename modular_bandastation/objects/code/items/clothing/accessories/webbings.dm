/obj/item/clothing/accessory/ammo_vest
	name = "разгрузка для магазинов"
	desc = "Тактическая разгрузка для хранения магазинов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/webbings.dmi'
	icon_state = "webbing"
	worn_icon = 'modular_bandastation/objects/icons/onbody/webbings.dmi'
	worn_icon_state = "webbing"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/clothing/accessory/ammo_vest/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/ammo_v)

/obj/item/clothing/accessory/ammo_vest/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	var/result = ..()
	if(!result)
		return

	if(!isnull(attach_to.atom_storage))
		if(user)
			attach_to.balloon_alert(user, "Этот предмет не помещается!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/ammo_vest/black
	name = "тёмная разгрузка для магазинов"
	desc = "Тактическая тёмная разгрузка для хранения магазинов."
	icon_state = "webbing_black"
	worn_icon_state = "webbing_black"
