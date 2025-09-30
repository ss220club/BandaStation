/datum/loadout_category/suits
	category_name = "Верхняя одежда"
	category_ui_icon = FA_ICON_VEST
	type_to_generate = /datum/loadout_item/suits

/datum/loadout_item/suits
	abstract_type = /datum/loadout_item/suits

/datum/loadout_item/suits/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.suit)
		LAZYADD(outfit.backpack_contents, outfit.suit)
	outfit.suit = item_path

// MARK: Tier 0
/datum/loadout_item/suits/wintercoat
	name = "Зимняя"
	item_path = /obj/item/clothing/suit/hooded/wintercoat

/datum/loadout_item/suits/jacket_letterman
	name = "Курьерская"
	item_path = /obj/item/clothing/suit/jacket/letterman

/datum/loadout_item/suits/miljacket
	name = "Военная"
	item_path = /obj/item/clothing/suit/jacket/miljacket

/datum/loadout_item/suits/leather
	name = "Кожанная"
	item_path = /obj/item/clothing/suit/jacket/leather

/datum/loadout_item/suits/leather_biker
	name = "Байкерская"
	item_path = /obj/item/clothing/suit/jacket/leather/biker

/datum/loadout_item/suits/bomber
	name = "Бомбер"
	item_path = /obj/item/clothing/suit/jacket/bomber

/datum/loadout_item/suits/oversized
	name = "Оверсайз"
	item_path = /obj/item/clothing/suit/jacket/oversized

/datum/loadout_item/suits/sweater
	name = "Свитер"
	item_path = /obj/item/clothing/suit/toggle/jacket/sweater

// MARK: Tier 1
/datum/loadout_item/suits/soundhand_white_jacket
	name = "Саундхэнд (Белая)"
	item_path = /obj/item/clothing/suit/soundhand_white_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/soundhand_black_jacket
	name = "Саундхэнд (Чёрная)"
	item_path = /obj/item/clothing/suit/soundhand_black_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/soundhand_olive_jacket
	name = "Саундхэнд (Оливковая)"
	item_path = /obj/item/clothing/suit/soundhand_olive_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/soundhand_brown_jacket
	name = "Саундхэнд (Коричневая)"
	item_path = /obj/item/clothing/suit/soundhand_brown_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/etamin_jacket
	name = "Кожаная куртка Etamin Industries"
	item_path = /obj/item/clothing/suit/toggle/etamin_jacket
	donator_level = DONATOR_TIER_1

// MARK: Tier 2
/datum/loadout_item/suits/shark_suit
	name = "Костюм акулы"
	item_path = /obj/item/clothing/suit/hooded/shark_costume
	donator_level = DONATOR_TIER_2

/datum/loadout_item/suits/shark_light_suit
	name = "Костюм акулы (светло-голубой)"
	item_path = /obj/item/clothing/suit/hooded/shark_costume/light
	donator_level = DONATOR_TIER_2

// MARK: Tier 3
/datum/loadout_item/suits/v_jacket
	name = "Куртка V"
	item_path = /obj/item/clothing/suit/v_jacket
	donator_level = DONATOR_TIER_3

/datum/loadout_item/suits/takemura_jacket
	name = "Куртка Такэмуры"
	item_path = /obj/item/clothing/suit/takemura_jacket
	donator_level = DONATOR_TIER_3

/datum/loadout_item/suits/v_jacket
	name = "Куртка Вай"
	item_path = /obj/item/clothing/suit/hooded/vi_arcane
	donator_level = DONATOR_TIER_3

/datum/loadout_item/suits/etamin_cloak
	name = "Плащ Etamin Industries"
	item_path = /obj/item/clothing/suit/hooded/etamin_cloak
	donator_level = DONATOR_TIER_3

// MARK: Tier 4
/datum/loadout_item/suits/katarina_jacket
	name = "Куртка Катарины"
	item_path = /obj/item/clothing/suit/katarina_jacket
	donator_level = DONATOR_TIER_4

/datum/loadout_item/suits/katarina_cyberjacket
	name = "Кибер-куртка Катарины"
	item_path = /obj/item/clothing/suit/katarina_cyberjacket
	donator_level = DONATOR_TIER_4

// MARK: Tier 5
/datum/loadout_item/suits/soundhand_white_jacket
	name = "Серебристая куртка Арии"
	item_path = /obj/item/clothing/suit/soundhand_white_jacket/tag
	donator_level = DONATOR_TIER_5

/datum/loadout_item/suits/etamin_coat
	name = "Офицерский плащ Etamin Industries"
	item_path = /obj/item/clothing/suit/etamin_coat
	donator_level = DONATOR_TIER_5

