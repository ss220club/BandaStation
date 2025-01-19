/datum/loadout_category/cardstickers
	category_name = "Наклейки"
	category_ui_icon = FA_ICON_ID_CARD
	type_to_generate = /datum/loadout_item/cardstickers
	tab_order = /datum/loadout_category/head::tab_order + 1

/datum/loadout_item/cardstickers
	abstract_type = /datum/loadout_item/cardstickers

/datum/loadout_item/glasses/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	LAZYADD(outfit.backpack_contents, item_path)

/*
// ID Skins
///Т0

/datum/loadout_item/cardstickers/id_decal_colored
	name = "Наклейка на карту (Голографическая)"
	item_path = /obj/item/id_skin/colored

/datum/loadout_item/cardstickers/id_decal_donut
	name = "Пончиковая наклейка на карту"
	item_path = /obj/item/id_skin/donut

/datum/loadout_item/cardstickers/id_decal_business
	name = "Бизнесменская наклейка на карту"
	item_path = /obj/item/id_skin/business

/datum/loadout_item/cardstickers/id_decal_ussp
	name = "Коммунистическая наклейка на карту"
	item_path = /obj/item/id_skin/ussp

///Т3
/datum/loadout_item/cardstickers/id_decal_silver_colored
	name = "Серебрянная наклейка на карту (Голографическая)"
	item_path = /obj/item/id_skin/colored/silver

/datum/loadout_item/cardstickers/id_decal_silver
	name = "Серебрянная наклейка на карту"
	item_path = /obj/item/id_skin/silver

/datum/loadout_item/cardstickers/id_decal_gold_skin
	name = "Золотая наклейка на карту"
	item_path = /obj/item/id_skin/gold

/datum/loadout_item/cardstickers/id_decal_lifetime
	name = "Стильная наклейка на карту"
	item_path = /obj/item/id_skin/lifetime

/datum/loadout_item/cardstickers/id_decal_clown
	name = "Клоунская наклейка на карту"
	item_path = /obj/item/id_skin/clown

/datum/loadout_item/cardstickers/id_decal_neon
	name = "Неоновая наклейка на карту"
	item_path = /obj/item/id_skin/neon

/datum/loadout_item/cardstickers/id_decal_neon_colored
	name = "Неоновая наклейка на карту (Голографическая)"
	item_path = /obj/item/id_skin/colored/neon

/datum/loadout_item/cardstickers/id_decal_missing
	name = "Чёрно-розовая наклейка на карту"
	item_path = /obj/item/id_skin/missing

/datum/loadout_item/cardstickers/id_decal_paradise
	name = "Paradise наклейка на карту"
	item_path = /obj/item/id_skin/paradise

/datum/loadout_item/cardstickers/id_decal_ouija
	name = "Уиджи наклейка на карту"
	item_path = /obj/item/id_skin/ouija

/datum/loadout_item/cardstickers/id_decal_kitty
	name = "Кото-клейка на карту"
	item_path = /obj/item/id_skin/kitty

/datum/loadout_item/cardstickers/id_decal_kitty_colored
	name = "Кото-клейка на карту (Голографическая)"
	item_path = /obj/item/id_skin/colored/kitty

/datum/loadout_item/cardstickers/id_decal_anime
	name = "Анимешная наклейка на карту"
	item_path = /obj/item/id_skin/cursedmiku

/datum/loadout_item/cardstickers/id_decal_jokerge
	name = "Джокерге наклейка на карту"
	item_path = /obj/item/id_skin/jokerge

///Т4
/datum/loadout_item/cardstickers/id_decal_rainbow
	name = "Радужная наклейка на карту"
	item_path = /obj/item/id_skin/rainbow

/datum/loadout_item/cardstickers/id_decal_space
	name = "КОСМИЧЕСКАЯ наклейка на карту"
	item_path = /obj/item/id_skin/space

/datum/loadout_item/cardstickers/id_decal_snake
	name = "Бегущая наклейка на карту"
	item_path = /obj/item/id_skin/colored/snake

/datum/loadout_item/cardstickers/id_decal_magic
	name = "Магическая наклейка на карту"
	item_path = /obj/item/id_skin/magic

/datum/loadout_item/cardstickers/id_decal_terminal
	name = "Наклейка на карту в виде терминала"
	item_path = /obj/item/id_skin/terminal

/datum/loadout_item/cardstickers/id_decal_boykisser
	name = "BoyKisser наклейка на карту"
	item_path = /obj/item/id_skin/boykisser
*/
