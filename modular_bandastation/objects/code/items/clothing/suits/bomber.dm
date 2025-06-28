/obj/item/clothing/suit/jacket/bomber
	inhand_icon_state =  null

/obj/item/clothing/suit/jacket/bomber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

// Science
/obj/item/clothing/suit/jacket/bomber/science
	name = "science bomber"
	desc = "Стильная черная куртка-бомбер, украшенная красной полосой слева."
	icon_state = "bombersci"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/bomber.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/bomber.dmi'

// Roboticist
/obj/item/clothing/suit/jacket/bomber/roboticist
	name = "roboticist bomber"
	desc = "Стильная белая куртка-бомбер, украшенная Фиолетовой полосой слева."
	icon_state = "bomberrobo"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/bomber.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/bomber.dmi'
