/datum/loadout_category/suits
	category_name = "Верхняя одежда"
	category_ui_icon = FA_ICON_VEST
	type_to_generate = /datum/loadout_item/suits
	tab_order = /datum/loadout_category/head::tab_order + 1

/datum/loadout_item/suits
	abstract_type = /datum/loadout_item/suits

/datum/loadout_item/glasses/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.suit)
		LAZYADD(outfit.backpack_contents, outfit.suit)
	outfit.suit = item_path
///Т0
/datum/loadout_item/suits/wintercoat
	name = "Зимняя куртка"
	item_path = /obj/item/clothing/suit/hooded/wintercoat

/datum/loadout_item/suits/jacket_letterman
	name = "Куртка курьера"
	item_path = /obj/item/clothing/suit/jacket/letterman

/datum/loadout_item/suits/miljacket
	name = "Военная куртка"
	item_path = /obj/item/clothing/suit/jacket/miljacket

/datum/loadout_item/suits/leather
	name = "Кожаная куртка"
	item_path = /obj/item/clothing/suit/jacket/leather

/datum/loadout_item/suits/leather_biker
	name = "Куртка байкера"
	item_path = /obj/item/clothing/suit/jacket/leather/biker

/datum/loadout_item/suits/bomber
	name = "Куртка-бомбер"
	item_path = /obj/item/clothing/suit/jacket/bomber

/datum/loadout_item/suits/oversized
	name = "куртка на вырост"
	item_path = /obj/item/clothing/suit/jacket/oversized

/datum/loadout_item/suits/sweater
	name = "Свитер"
	item_path = /obj/item/clothing/suit/toggle/jacket/sweater

///Т1
/datum/loadout_item/suits/soundhand_black_jacket
	name = "Черная куртка с тэгом группы Саундхэнд"
	item_path = /obj/item/clothing/suit/soundhand_black_jacket/tag

/datum/loadout_item/suits/soundhand_olive_jacket
	name = "Оливковая куртка с тэгом группы Саундхэнд"
	item_path = /obj/item/clothing/suit/soundhand_olive_jacket/tag

/datum/loadout_item/suits/soundhand_brown_jacket
	name = "Коричневая куртка с тэгом группы Саундхэнд"
	item_path = /obj/item/clothing/suit/soundhand_brown_jacket/tag

///Т3
/datum/loadout_item/suits/soundhand_white_jacket
	name = "Черная куртка с тэгом группы Саундхэнд"
	item_path = /obj/item/clothing/suit/soundhand_white_jacket

/datum/loadout_item/suits/shark_suit
	name = "Костюм акулы"
	item_path = /obj/item/clothing/suit/hooded/shark_costume

/datum/loadout_item/suits/shark_light_suit
	name = "Костюм акулы (светло-голубой)"
	item_path = /obj/item/clothing/suit/hooded/shark_costume/light

///Т3
/datum/loadout_item/suits/v_jacket
	name = "Куртка V"
	item_path = /obj/item/clothing/suit/v_jacket

/datum/loadout_item/suits/takemura_jacket
	name = "Куртка Такэмуры"
	item_path = /obj/item/clothing/suit/takemura_jacket

/datum/loadout_item/suits/v_jacket
	name = "Куртка Вай"
	item_path = /obj/item/clothing/suit/hooded/vi_arcane

///Т4
/datum/loadout_item/suits/katarina_jacket
	name = "Куртка Катарины"
	item_path = /obj/item/clothing/suit/katarina_jacket

/datum/loadout_item/suits/katarina_cyberjacket
	name = "Кибер-куртка Катарины"
	item_path = /obj/item/clothing/suit/katarina_cyberjacket

///Т5
/datum/loadout_item/suits/soundhand_white_jacket
	name = "Серебристая куртка Арии"
	item_path = /obj/item/clothing/suit/soundhand_white_jacket/tag

