/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt
	name = "roboticist's winter coat"
	desc = "Пальто, исключительно для разбирающихся в моде. Для крутых и подкрученных перцев. На бирке указано: 'Flameholdeir Industries'. Поможет даже во время самых длинных, холодных и тёмных времен."
	icon_state = "coatrobotics"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/wintercoat.dmi'
	hoodtype = NONE
	inhand_icon_state = null

/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt/click_alt(mob/user)
	return NONE // Restrict user to zip and unzip coat

// Blueshield
/obj/item/clothing/suit/hooded/wintercoat/blueshield
	name = "blueshield's winter coat"
	desc = "Удобное пальто с кевларовой подкладкой и синими вставками, предназначенное для того, чтобы «Синий щит» оставался защищённым и в тепле."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/wintercoat.dmi'
	icon_state = "coat_blueshield"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/blueshield
	armor_type = /datum/armor/suit_armor

/obj/item/clothing/suit/hooded/wintercoat/blueshield/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/blueshield
	desc = "Удобный капюшон на кевларовой подкладке в комплект к удобному пальто на кевларовой подкладке."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/winterhood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/winterhood.dmi'
	icon_state = "hood_blueshield"
	armor_type = /datum/armor/suit_armor

// Nanotrasen Representative
/obj/item/clothing/suit/hooded/wintercoat/nanotrasen_representative
	name = "Nanotrasen representative's winter coat"
	desc = "Удобная и тёплая куртка, сшитая под заказ для самых статусных представителей Нанотрейзен."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/wintercoat.dmi'
	icon_state = "coat_ntrep"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/nanotrasen_representative

/obj/item/clothing/head/hooded/winterhood/nanotrasen_representative
	desc = "Удобный и тёплый капюшон, сшитый под заказ для самых статусных представителей Нанотрейзен."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/winterhood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/winterhood.dmi'
	icon_state = "hood_ntrep"
