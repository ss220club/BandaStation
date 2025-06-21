/obj/item/clothing/mask/breath/red_gas
	name = "prs-1"
	desc = "Стильная дыхательная маска в виде противогаза, не скрывает лицо."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "red_gas"

/obj/item/clothing/mask/breath/breathscarf
	name = "breathscarf system"
	desc = "Стильный и инновационный шарф, который служит дыхательной маской в экстремальных ситуациях."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "breathscarf"
	greyscale_colors = COLOR_PRISONER_BLACK
	greyscale_config = /datum/greyscale_config/breathscarf
	greyscale_config_worn = /datum/greyscale_config/breathscarf/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/datum/greyscale_config/breathscarf
	name = "Breathscarf"
	icon_file = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	json_config = 'code/datums/greyscale/json_configs/bandastation/breathscarf.json'

/datum/greyscale_config/breathscarf/worn
	name = "Breathscarf (Worn)"
	icon_file = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'

/obj/item/clothing/mask/drunkard_mask
	name = "drunkard mask"
	desc = "Простая, но выразительная маска с удивлённо-глуповатым лицом: круглые глаза, полуоткрытый рот и налёт деревенской наивности."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "drunkard_mask"

/obj/item/clothing/mask/sailor_mask
	name = "sailor mask"
	desc = "Маска в морской тельняшке, с хитрой ухмылкой и безумными глазами."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "sailor_mask"
