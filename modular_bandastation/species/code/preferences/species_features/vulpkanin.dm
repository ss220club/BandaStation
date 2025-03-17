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

/datum/preference/choiced/vulpkanin_body_markings/icon_for(value)
	var/static/list/body_part_icon_states = list(
		"vulpkanin_head_m",
		"vulpkanin_chest_m",
		"vulpkanin_r_arm",
		"vulpkanin_l_arm",
		"vulpkanin_r_hand",
		"vulpkanin_l_hand",
		"groin_m",
		"vulpkanin_l_leg",
		"vulpkanin_r_leg"
	)

	var/static/datum/universal_icon/vulpkanin_body
	if(isnull(vulpkanin_body))
		vulpkanin_body = uni_icon('icons/blanks/32x32.dmi', "nothing")
		for(var/body_part_icon_state as anything in body_part_icon_states)
			vulpkanin_body.blend_icon(uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', body_part_icon_state), ICON_OVERLAY)

		vulpkanin_body.blend_color(COLOR_ORANGE, ICON_MULTIPLY)

	var/datum/universal_icon/final_icon = vulpkanin_body.copy()
	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/body_marking = SSaccessories.vulpkanin_body_markings_list[value]
		var/datum/universal_icon/body_marking_icon = uni_icon(body_marking.icon, "[body_marking.icon_state]")
		body_marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(body_marking_icon, ICON_OVERLAY)

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
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m")
	final_icon.blend_color(COLOR_ORANGE, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/head_marking = SSaccessories.vulpkanin_head_markings_list[value]
		var/datum/universal_icon/marking_icon = uni_icon(head_marking.icon, "m_vulpkanin_head_markings_[head_marking.icon_state]_ADJ")
		marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(marking_icon, ICON_OVERLAY)

	final_icon.crop(11, 22, 21, 32)
	final_icon.scale(32, 32)

	return final_icon

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

/// MARK: Facial hair

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
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/sprite_accessories/body.dmi', "vulpkanin_head_m")
	final_icon.blend_color(COLOR_ORANGE, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/facial_hair = SSaccessories.vulpkanin_facial_hair_list[value]
		var/datum/universal_icon/facial_hair_icon = uni_icon(facial_hair.icon, "m_vulpkanin_facial_hair_[facial_hair.icon_state]_ADJ")
		facial_hair_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(facial_hair_icon, ICON_OVERLAY)

	final_icon.crop(11, 22, 21, 32)
	final_icon.scale(32, 32)

	return final_icon

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

/// MARK: Tail markings

/datum/preference/choiced/vulpkanin_tail_markings
	savefile_key = "feature_vulpkanin_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/choiced/vulpkanin_tail_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_tail_markings_list)

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
