// MARK: Shoes //
/obj/item/clothing/shoes
	digitigrade_worn_icon_state = DIGI_BOOTS_WORN

/obj/item/clothing/shoes/sneakers
	digitigrade_worn_icon_state = DIGI_SNEAKERS_WORN

/obj/item/clothing/shoes/chameleon
	supports_variations_flags = /obj/item/clothing/shoes/sneakers/black::supports_variations_flags
	digitigrade_worn_icon_state = /obj/item/clothing/shoes/sneakers/black::digitigrade_worn_icon_state

/obj/item/clothing/shoes/chameleon/get_general_color(icon/base_icon)
	var/datum/action/item_action/chameleon/change/action = locate() in actions
	var/target_type = action?.active_type
	if(!target_type)
		return ..()
	var/obj/item/target_item = SSwardrobe.provide_type(target_type)
	if(target_item)
		var/result = target_item.get_general_color(base_icon)
		qdel(target_item)
		return result
	return ..()

// MARK: Misc shoes
/obj/item/clothing/shoes/shark
	name = "shark shoes"
	desc = "Эти тапочки сделаны из акульей кожи, или нет?"
	icon = 'modular_bandastation/objects/icons/obj/clothing/shoes.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/shoes.dmi'
	icon_state = "shark"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/shoes/shark/light
	name = "light shark shoes"
	icon_state = "shark_light"

// MARK: CentCom
/obj/item/clothing/shoes/laceup/centcom
	name = "fleet officer's laceup shoes"
	desc = "Деловые флотские вездеходы из натуральной кожи. Пик моды."
	clothing_traits = list(TRAIT_NO_SLIP_ALL)

/obj/item/clothing/shoes/jackboots/centcom
	name = "fleet officer's jackboots"
	desc = "Стандартный вариант тактической обуви, выпускаемой Нанотрейзен."
	clothing_traits = list(TRAIT_NO_SLIP_ALL)

// MARK: Etamin ind.
/obj/item/clothing/shoes/etamin_shoes
	name = "Gold On Black shoes"
	desc = "Черный ботинки в классическом стиле с легким золотым напылением от корпорации Etamin Industries."
	icon = 'modular_bandastation/objects/icons/obj/clothing/shoes.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/shoes.dmi'
	icon_state = "ei_shoes"
