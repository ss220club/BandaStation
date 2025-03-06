/// VULPKANIN BODY MARKINGS

/datum/preference/choiced/vulpkanin_body_markings
	savefile_key = "feature_vulpkanin_body_markings"
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Раскраска тела"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin

/datum/preference/choiced/vulpkanin_body_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_body_markings_list)

/datum/preference/choiced/vulpkanin_body_markings/create_default_value()
	var/datum/sprite_accessory/vulpkanin_body_markings/markings = /datum/sprite_accessory/vulpkanin_body_markings
	return markings::name

/datum/preference/choiced/vulpkanin_body_markings/icon_for(value)
	var/static/list/body_part_icon_states = list(
		"vulpkanin_head_m",
		"vulpkanin_chest_m",
		"groin_m",
		"vulpkanin_r_arm",
		"vulpkanin_l_arm",
		"vulpkanin_r_hand",
		"vulpkanin_l_hand"
	)

	var/static/datum/universal_icon/vulpkanin_body
	if(isnull(vulpkanin_body))
		vulpkanin_body = uni_icon('icons/blanks/32x32.dmi', "nothing")
		for(var/icon_state as anything in body_part_icon_states)
			vulpkanin_body.blend_icon(uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', icon_state), ICON_OVERLAY)

	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_body_markings_list[value]
	var/datum/universal_icon/final_icon = vulpkanin_body.copy()

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/marking_icon = uni_icon(markings.icon, "[markings.icon_state]")
		marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(marking_icon, ICON_OVERLAY)

	final_icon.scale(64, 64)

	return final_icon

/datum/preference/choiced/vulpkanin_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_body_markings"] = value

// MARK: Tail
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

// MARK: Body markings color
/datum/preference/color/vulpkanin_body_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin

/datum/preference/color/vulpkanin_body_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_body_markings_color"] = value

// MARK: Head markings
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
	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_head_markings_list[value]
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m")

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_vulpkanin_head_markings_[markings.icon_state]_ADJ")
		body_part_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(body_part_icon, ICON_OVERLAY)

	final_icon.scale(64, 64)

	return final_icon

/datum/preference/choiced/vulpkanin_head_markings/create_default_value()
	var/datum/sprite_accessory/vulpkanin_head_markings/markings = /datum/sprite_accessory/vulpkanin_head_markings
	return markings::name

/datum/preference/choiced/vulpkanin_head_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_markings"] = value

/datum/preference/choiced/vulpkanin_head_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_head_markings_color"

	return data

// MARK: Head markings color
/datum/preference/color/vulpkanin_head_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_head_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/color/vulpkanin_head_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_head_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_markings_color"] = value

// MARK: Head Accessories
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
	var/datum/sprite_accessory/markings = SSaccessories.vulpkanin_head_accessories_list[value]
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m")

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_vulpkanin_head_accessories_[markings.icon_state]_ADJ")
		body_part_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(body_part_icon, ICON_OVERLAY)

	final_icon.scale(64, 64)

	return final_icon

/datum/preference/choiced/vulpkanin_head_accessories/create_default_value()
	var/datum/sprite_accessory/vulpkanin_head_accessories/markings = /datum/sprite_accessory/vulpkanin_head_accessories
	return markings::name

/datum/preference/choiced/vulpkanin_head_accessories/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_accessories"] = value

/datum/preference/choiced/vulpkanin_head_accessories/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "vulpkanin_head_accessories_color"

	return data

// MARK: Head accessories color
/datum/preference/color/vulpkanin_head_accessories_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_head_accessories_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_VULPKANIN

/datum/preference/color/vulpkanin_head_accessories_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_head_accessories_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_accessories_color"] = value

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
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m")

	if(!isnull(markings))
		var/datum/universal_icon/head_accessory_icon = uni_icon(markings.icon, "m_vulpkanin_facial_hair_[markings.icon_state]_ADJ")
		head_accessory_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(head_accessory_icon, ICON_OVERLAY)

	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/vulpkanin_facial_hair/create_default_value()
	var/datum/sprite_accessory/vulpkanin_facial_hair/markings = /datum/sprite_accessory/vulpkanin_facial_hair
	return markings::name

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
	target.dna.features["vulpkanin_facial_hair_color"] = value

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
	return markings::name

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
	target.dna.features["vulpkanin_tail_markings_color"] = value

/datum/preference/color/vulpkanin_tail_markings_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_vulpkanin)
	return (pref == "Default" || pref == "Bushy" || pref == "Straight Bushy") && preferences.read_preference(/datum/preference/choiced/vulpkanin_tail_markings) != "None"
