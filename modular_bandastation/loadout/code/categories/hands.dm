/datum/loadout_category/gloves
	category_name = "Руки"
	category_ui_icon = FA_ICON_HANDS
	type_to_generate = /datum/loadout_item/gloves
	tab_order = /datum/loadout_category/head::tab_order + 1

/datum/loadout_item/gloves
	abstract_type = /datum/loadout_item/gloves

/datum/loadout_item/glasses/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.gloves)
		LAZYADD(outfit.backpack_contents, outfit.gloves)
	outfit.gloves = item_path

///Т0
/datum/loadout_item/gloves/gloves_black
	name = "Черные перчатки"
	item_path = /obj/item/clothing/gloves/color/black

///Т0
/datum/loadout_item/gloves/gloves_orange
	name = "Оранжевые перчатки"
	item_path = /obj/item/clothing/gloves/color/orange

///Т0
/datum/loadout_item/gloves/gloves_red
	name = "Красные перчатки"
	item_path = /obj/item/clothing/gloves/color/red

///Т0
/datum/loadout_item/gloves/gloves_rainbow
	name = "Радужные перчатки"
	item_path = /obj/item/clothing/gloves/color/rainbow

///Т0
/datum/loadout_item/gloves/gloves_blue
	name = "Синие перчатки"
	item_path = /obj/item/clothing/gloves/color/blue

///Т0
/datum/loadout_item/gloves/gloves_purple
	name = "Фиолетовые перчатки"
	item_path = /obj/item/clothing/gloves/color/purple

///Т0
/datum/loadout_item/gloves/gloves_green
	name = "Зеленые перчатки"
	item_path = /obj/item/clothing/gloves/color/green

///Т0
/datum/loadout_item/gloves/gloves_grey
	name = "Серые перчатки"
	item_path = /obj/item/clothing/gloves/color/grey

///Т0
/datum/loadout_item/gloves/gloves_light_brown
	name = "Светло-коричневые перчатки"
	item_path = /obj/item/clothing/gloves/color/light_brown

///Т0
/datum/loadout_item/gloves/gloves_brown
	name = "Коричневые перчатки"
	item_path = /obj/item/clothing/gloves/color/brown

///Т0
/datum/loadout_item/gloves/gloves_white
	name = "Белые перчатки"
	item_path = /obj/item/clothing/gloves/color/white

///Т0
/datum/loadout_item/gloves/gloves_maid
	name = "Перчатки горничной"
	item_path = /obj/item/clothing/gloves/maid

///Т0
/datum/loadout_item/gloves/gloves_fingerless
	name = "Перчатки без пальцев"
	item_path = /obj/item/clothing/gloves/fingerless

///Т1
/datum/loadout_item/gloves/biker_gloves
	name = "Байкерские перчатки"
	item_path = /obj/item/clothing/gloves/fingerless/biker_gloves
