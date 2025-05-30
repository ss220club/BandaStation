/datum/loadout_category/masks
	category_name = "Лицо"
	category_ui_icon = FA_ICON_MASK
	type_to_generate = /datum/loadout_item/masks

/datum/loadout_item/masks
	abstract_type = /datum/loadout_item/masks

/datum/loadout_item/masks/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.mask)
		LAZYADD(outfit.backpack_contents, outfit.mask)
	outfit.mask = item_path

// MARK: Tier 1
/datum/loadout_item/masks/breathscarf
	name = "Шарф с системой дыхания"
	item_path = /obj/item/clothing/mask/breath/breathscarf
	donator_level = DONATOR_TIER_1

/datum/loadout_item/masks/pig
	name = "Маска свиньи"
	item_path = /obj/item/clothing/mask/animal/pig
	donator_level = DONATOR_TIER_1

/datum/loadout_item/masks/horsehead
	name = "Маска лошади"
	item_path = /obj/item/clothing/mask/animal/horsehead
	donator_level = DONATOR_TIER_1

/datum/loadout_item/masks/raven
	name = "Маска ворона"
	item_path = /obj/item/clothing/mask/animal/small/raven
	donator_level = DONATOR_TIER_1

// MARK: Tier 2
/datum/loadout_item/masks/red_gas
	name = "ПРС-1"
	item_path = /obj/item/clothing/mask/breath/red_gas
	donator_level = DONATOR_TIER_2
