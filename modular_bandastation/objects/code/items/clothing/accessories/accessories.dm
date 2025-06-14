/obj/item/clothing/accessory/stealth

/obj/item/clothing/accessory/stealth/on_uniform_equipped(obj/item/clothing/under/source, mob/living/user, slot)
	src.alpha = 0
	. = ..()
	source.attached_accessories -= src

/obj/item/clothing/accessory/stealth/on_uniform_dropped(obj/item/clothing/under/source, mob/living/user)
	src.alpha = initial(src.alpha)
	source.attached_accessories += src
	. = ..()

/obj/item/clothing/suit/apron/chef/red
	name = "красный фартук"
	icon = 'modular_bandastation/objects/icons/obj/clothing/accessories.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/accessories.dmi'
	icon_state = "apron_red"
	worn_icon_state = "apron_red"

/obj/item/clothing/under/create_accessory_overlay()
	if(attached_accessories.len == 0 || istype(attached_accessories[1], /obj/item/clothing/accessory/stealth))
		return
	. = ..()
