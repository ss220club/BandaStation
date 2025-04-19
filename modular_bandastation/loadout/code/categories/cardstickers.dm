/datum/loadout_category/id_sticker
	category_name = "Наклейки"
	category_ui_icon = FA_ICON_ID_CARD
	type_to_generate = /datum/loadout_item/id_sticker
	tab_order = /datum/loadout_category/head::tab_order + 1

/datum/loadout_item/id_sticker
	abstract_type = /datum/loadout_item/id_sticker

/datum/loadout_item/glasses/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	LAZYADD(outfit.backpack_contents, item_path)

// ID Skins
///Т0

/datum/loadout_item/id_sticker/id_decal_colored
	name = "Наклейка на карту (Голографическая)"
	item_path = /obj/item/id_sticker/colored

/datum/loadout_item/id_sticker/id_decal_donut
	name = "Пончиковая наклейка на карту"
	item_path = /obj/item/id_sticker/donut

/datum/loadout_item/id_sticker/id_decal_business
	name = "Бизнесменская наклейка на карту"
	item_path = /obj/item/id_sticker/business

/datum/loadout_item/id_sticker/id_decal_ussp
	name = "Коммунистическая наклейка на карту"
	item_path = /obj/item/id_sticker/ussp

///Т3
/datum/loadout_item/id_sticker/id_decal_silver_colored
	name = "Серебрянная наклейка на карту (Голографическая)"
	item_path = /obj/item/id_sticker/colored/silver

/datum/loadout_item/id_sticker/id_decal_silver
	name = "Серебрянная наклейка на карту"
	item_path = /obj/item/id_sticker/silver

/datum/loadout_item/id_sticker/id_decal_gold_skin
	name = "Золотая наклейка на карту"
	item_path = /obj/item/id_sticker/gold

/datum/loadout_item/id_sticker/id_decal_lifetime
	name = "Стильная наклейка на карту"
	item_path = /obj/item/id_sticker/lifetime

/datum/loadout_item/id_sticker/id_decal_clown
	name = "Клоунская наклейка на карту"
	item_path = /obj/item/id_sticker/clown

/datum/loadout_item/id_sticker/id_decal_neon
	name = "Неоновая наклейка на карту"
	item_path = /obj/item/id_sticker/neon

/datum/loadout_item/id_sticker/id_decal_neon_colored
	name = "Неоновая наклейка на карту (Голографическая)"
	item_path = /obj/item/id_sticker/colored/neon

/datum/loadout_item/id_sticker/id_decal_missing
	name = "Чёрно-розовая наклейка на карту"
	item_path = /obj/item/id_sticker/missing

/datum/loadout_item/id_sticker/id_decal_paradise
	name = "Paradise наклейка на карту"
	item_path = /obj/item/id_sticker/paradise

/datum/loadout_item/id_sticker/id_decal_ouija
	name = "Уиджи наклейка на карту"
	item_path = /obj/item/id_sticker/ouija

/datum/loadout_item/id_sticker/id_decal_kitty
	name = "Кото-клейка на карту"
	item_path = /obj/item/id_sticker/kitty

/datum/loadout_item/id_sticker/id_decal_kitty_colored
	name = "Кото-клейка на карту (Голографическая)"
	item_path = /obj/item/id_sticker/colored/kitty

/datum/loadout_item/id_sticker/id_decal_anime
	name = "Анимешная наклейка на карту"
	item_path = /obj/item/id_sticker/cursedmiku

/datum/loadout_item/id_sticker/id_decal_jokerge
	name = "Джокерге наклейка на карту"
	item_path = /obj/item/id_sticker/jokerge

///Т4
/datum/loadout_item/id_sticker/id_decal_rainbow
	name = "Радужная наклейка на карту"
	item_path = /obj/item/id_sticker/rainbow

/datum/loadout_item/id_sticker/id_decal_space
	name = "КОСМИЧЕСКАЯ наклейка на карту"
	item_path = /obj/item/id_sticker/space

/datum/loadout_item/id_sticker/id_decal_snake
	name = "Бегущая наклейка на карту"
	item_path = /obj/item/id_sticker/colored/snake

/datum/loadout_item/id_sticker/id_decal_magic
	name = "Магическая наклейка на карту"
	item_path = /obj/item/id_sticker/magic

/datum/loadout_item/id_sticker/id_decal_terminal
	name = "Наклейка на карту в виде терминала"
	item_path = /obj/item/id_sticker/terminal

/datum/loadout_item/id_sticker/id_decal_boykisser
	name = "BoyKisser наклейка на карту"
	item_path = /obj/item/id_sticker/boykisser
