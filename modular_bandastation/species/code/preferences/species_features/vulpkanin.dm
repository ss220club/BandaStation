/// VULPKANIN BODY MARKINGS

/datum/preference/choiced/vulpkanin_body_markings
	savefile_key = "feature_vulpkanin_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Раскраска тела"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin

/datum/preference/choiced/vulpkanin_body_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_body_markings_list)

/datum/preference/choiced/vulpkanin_body_markings/create_default_value()
	var/datum/sprite_accessory/vulpkanin_body_markings/markings = /datum/sprite_accessory/vulpkanin_body_markings
	return initial(markings.name)

/datum/preference/choiced/vulpkanin_body_markings/icon_for(value)
	var/static/icon/body
	if (isnull(body))
		body = icon('icons/blanks/32x32.dmi', "nothing")
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_chest_m"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_leg"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_leg"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_arm"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_arm"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_hand"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_hand"), ICON_OVERLAY)
		body.Blend(COLOR_ORANGE, ICON_MULTIPLY)

	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_body_markings_list[value]
	var/icon/icon_with_markings = new(body)

	if (value != "None")
		var/icon/body_part_icon = icon(markings.icon, "[markings.icon_state]")
		body_part_icon.Crop(1, 1, 32, 32)
		body_part_icon.Blend(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		icon_with_markings.Blend(body_part_icon, ICON_OVERLAY)

	icon_with_markings.Scale(64, 64)
	icon_with_markings.Crop(15, 38, 15 + 31, 7)

	return icon_with_markings

/datum/preference/choiced/vulpkanin_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_body_markings"] = value

// VULPKANIN TAIL

/datum/preference/choiced/tail_vulpkanin
	savefile_key = "feature_vulpkanin_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/choiced/tail_vulpkanin/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_vulpkanin)

/datum/preference/choiced/tail_vulpkanin/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_vulpkanin"] = value

/datum/preference/choiced/tail_vulpkanin/create_default_value()
	return /datum/sprite_accessory/tails/vulpkanin/fluffy::name

/datum/preference/choiced/vulpkanin_body_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_body_markings_color"

	return data

/datum/preference/color/vulpkanin_body_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin

/datum/preference/color/vulpkanin_body_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["furcolor_first"] = value

/// VULPKANIN HEAD MARKINGS

/datum/preference/choiced/vulpkanin_head_markings
	savefile_key = "feature_vulpkanin_head_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Раскраска головы"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/choiced/vulpkanin_head_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_head_markings_list)

/datum/preference/choiced/vulpkanin_head_markings/icon_for(value)
	var/static/icon/body
	if (isnull(body))
		body = icon('icons/blanks/32x32.dmi', "nothing")
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_chest_m"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_leg"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_leg"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_arm"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_arm"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_hand"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_hand"), ICON_OVERLAY)
		body.Blend(COLOR_ORANGE, ICON_MULTIPLY)

	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_head_markings_list[value]
	var/icon/icon_with_markings = new(body)

	if (value != "None")
		var/icon/body_part_icon = icon(markings.icon, "m_vulpkanin_head_markings_[markings.icon_state]_ADJ")
		body_part_icon.Crop(1, 1, 32, 32)
		body_part_icon.Blend(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		icon_with_markings.Blend(body_part_icon, ICON_OVERLAY)

	icon_with_markings.Scale(64, 64)
	icon_with_markings.Crop(15, 64, 15 + 31, 64 - 31)

	return icon_with_markings

/datum/preference/choiced/vulpkanin_head_markings/create_default_value()
	var/datum/sprite_accessory/vulpkanin_head_markings/markings = /datum/sprite_accessory/vulpkanin_head_markings
	return initial(markings.name)

/datum/preference/choiced/vulpkanin_head_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_markings"] = value

/datum/preference/choiced/vulpkanin_head_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_head_markings_color"

	return data

/datum/preference/color/vulpkanin_head_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_head_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/color/vulpkanin_head_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_head_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["furcolor_third"] = value

/// VULPKANIN HEAD ACCESSORIES

/datum/preference/choiced/vulpkanin_head_accessories
	savefile_key = "feature_vulpkanin_head_accessories"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Кастомизация головы"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/choiced/vulpkanin_head_accessories/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_head_accessories_list)

/datum/preference/choiced/vulpkanin_head_accessories/icon_for(value)
	var/static/icon/body
	if (isnull(body))
		body = icon('icons/blanks/32x32.dmi', "nothing")
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_chest_m"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_arm"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_arm"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_l_hand"), ICON_OVERLAY)
		body.Blend(icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_r_hand"), ICON_OVERLAY)
		body.Blend(COLOR_ORANGE, ICON_MULTIPLY)

	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_head_accessories_list[value]
	var/icon/icon_with_markings = new(body)

	if (value != "None")
		var/icon/body_part_icon = icon(markings.icon, "m_vulpkanin_head_accessories_[markings.icon_state]_ADJ")
		body_part_icon.Crop(1, 1, 32, 32)
		body_part_icon.Blend(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		icon_with_markings.Blend(body_part_icon, ICON_OVERLAY)

	icon_with_markings.Scale(64, 64)
	icon_with_markings.Crop(15, 64, 15 + 31, 64 - 31)

	return icon_with_markings

/datum/preference/choiced/vulpkanin_head_accessories/create_default_value()
	var/datum/sprite_accessory/vulpkanin_head_accessories/markings = /datum/sprite_accessory/vulpkanin_head_accessories
	return initial(markings.name)

/datum/preference/choiced/vulpkanin_head_accessories/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_accessories"] = value

/datum/preference/choiced/vulpkanin_head_accessories/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_head_accessories_color"

	return data

/datum/preference/color/vulpkanin_head_accessories_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_head_accessories_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/color/vulpkanin_head_accessories_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_head_accessories_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["furcolor_fourth"] = value

/// VULPKANIN FACIAL HAIR

/datum/preference/choiced/vulpkanin_facial_hair
	savefile_key = "feature_vulpkanin_facial_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Волосы на лице"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/choiced/vulpkanin_facial_hair/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_facial_hair_list)

/datum/preference/choiced/vulpkanin_facial_hair/icon_for(value)
	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_facial_hair_list[value]
	var/static/icon/head_icon
	if (isnull(head_icon))
		head_icon = icon('modular_bandastation/species/icons/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m")
		head_icon.Blend(COLOR_ORANGE, ICON_MULTIPLY)

	var/icon/final_icon = new(head_icon)
	if (!isnull(markings))
		ASSERT(istype(markings))

		var/icon/head_accessory_icon = icon(markings.icon, "m_vulpkanin_facial_hair_[markings.icon_state]_ADJ")
		head_accessory_icon.Blend(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.Blend(head_accessory_icon, ICON_OVERLAY)

	final_icon.Crop(10, 19, 22, 31)
	final_icon.Scale(32, 32)

	return final_icon

/datum/preference/choiced/vulpkanin_facial_hair/create_default_value()
	var/datum/sprite_accessory/vulpkanin_facial_hair/markings = /datum/sprite_accessory/vulpkanin_facial_hair
	return initial(markings.name)

/datum/preference/choiced/vulpkanin_facial_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_facial_hair"] = value

/datum/preference/choiced/vulpkanin_facial_hair/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_facial_hair_color"

	return data

/datum/preference/color/vulpkanin_facial_hair_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_facial_hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/color/vulpkanin_facial_hair_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["furcolor_fifth"] = value

/// VULPKANIN TAIL MARKINGS

/datum/preference/choiced/vulpkanin_tail_markings
	savefile_key = "feature_vulpkanin_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/choiced/vulpkanin_tail_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_tail_markings_list)

/datum/preference/choiced/vulpkanin_tail_markings/create_default_value()
	var/datum/sprite_accessory/vulpkanin_tail_markings/markings = /datum/sprite_accessory/vulpkanin_tail_markings
	return initial(markings.name)

/datum/preference/choiced/vulpkanin_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_markings"] = value

/datum/preference/choiced/vulpkanin_tail_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_tail_markings_color"

	return data

/datum/preference/choiced/vulpkanin_tail_markings/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_vulpkanin)
	return pref == "Default" || pref == "Bushy" || pref == "Straight Bushy"

/datum/preference/color/vulpkanin_tail_markings_color
	savefile_key = "vulpkanin_tail_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/color/vulpkanin_tail_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_tail_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["furcolor_second"] = value

/datum/preference/color/vulpkanin_tail_markings_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_vulpkanin)
	return (pref == "Default" || pref == "Bushy" || pref == "Straight Bushy") && preferences.read_preference(/datum/preference/choiced/vulpkanin_tail_markings) != "None"
