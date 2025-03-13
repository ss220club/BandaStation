// MARK: Tajaran body markings
/datum/preference/choiced/tajaran_body_markings
	savefile_key = "feature_tajaran_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Узор меха"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/tajaran

/datum/preference/choiced/tajaran_body_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tajaran_body_markings_list)

/datum/preference/choiced/tajaran_body_markings/icon_for(value)
	var/static/list/body_part_icon_states = list(
		"tajaran_chest_m",
		"tajaran_l_leg",
		"tajaran_r_leg",
		"tajaran_l_arm",
		"tajaran_r_arm",
		"tajaran_l_hand",
		"tajaran_r_hand"
	)

	var/static/datum/universal_icon/body
	if(isnull(body))
		body = uni_icon('icons/blanks/32x32.dmi', "nothing")
		for(var/body_part_icon_state in body_part_icon_states)
			body.blend_icon(uni_icon('icons/bandastation/mob/species/tajaran/sprite_accessories/body.dmi', body_part_icon_state), ICON_OVERLAY)

		body.blend_color(COLOR_ASSISTANT_GRAY, ICON_MULTIPLY)

	var/datum/universal_icon/final_icon = body.copy()

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/body_marking = SSaccessories.tajaran_body_markings_list[value]
		var/datum/universal_icon/body_marking_icon = uni_icon(body_marking.icon, "[body_marking.icon_state]")
		body_marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(body_marking_icon, ICON_OVERLAY)

	final_icon.crop(8, 1, 24, 22)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/tajaran_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_body_markings"] = value

/datum/preference/choiced/tajaran_body_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "tajaran_body_markings_color"

	return data

/datum/preference/color/tajaran_body_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "tajaran_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/tajaran

/datum/preference/color/tajaran_body_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/tajaran_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_body_markings_color"] = value

// MARK: Tajaran tail
/datum/preference/choiced/tail_tajaran
	savefile_key = "feature_tajaran_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/tajaran

/datum/preference/choiced/tail_tajaran/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_tajaran)

/datum/preference/choiced/tail_tajaran/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_tajaran"] = value

// MARK: Tajaran head markings
/datum/preference/choiced/tajaran_head_markings
	savefile_key = "feature_tajaran_head_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Узор меха головы"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_TAJARAN

/datum/preference/choiced/tajaran_head_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tajaran_head_markings_list)

/datum/preference/choiced/tajaran_head_markings/icon_for(value)
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/tajaran/sprite_accessories/body.dmi', "tajaran_head_m")
	final_icon.blend_color(COLOR_ASSISTANT_GRAY, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/head_marking = SSaccessories.tajaran_head_markings_list[value]
		var/datum/universal_icon/head_marking_icon = uni_icon(head_marking.icon, "m_tajaran_head_markings_[head_marking.icon_state]_ADJ")
		head_marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(head_marking_icon, ICON_OVERLAY)

	final_icon.crop(12, 22, 20, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/tajaran_head_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_head_markings"] = value

/datum/preference/choiced/tajaran_head_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "tajaran_head_markings_color"

	return data

/datum/preference/color/tajaran_head_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "tajaran_head_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_TAJARAN

/datum/preference/color/tajaran_head_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/tajaran_head_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_head_markings_color"] = value

// MARK: Tajaran facial hair
/datum/preference/choiced/tajaran_facial_hair
	savefile_key = "feature_tajaran_facial_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Растительность на лице"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_TAJARAN

/datum/preference/choiced/tajaran_facial_hair/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tajaran_facial_hair_list)

/datum/preference/choiced/tajaran_facial_hair/icon_for(value)
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/tajaran/sprite_accessories/body.dmi', "tajaran_head_m")
	final_icon.blend_color(COLOR_ASSISTANT_GRAY, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/facial_hair = SSaccessories.tajaran_facial_hair_list[value]
		var/datum/universal_icon/facial_hair_icon = uni_icon(facial_hair.icon, "m_tajaran_facial_hair_[facial_hair.icon_state]_ADJ")
		facial_hair_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(facial_hair_icon, ICON_OVERLAY)

	final_icon.crop(12, 21, 20, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/tajaran_facial_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_facial_hair"] = value

/datum/preference/choiced/tajaran_facial_hair/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "tajaran_facial_hair_color"

	return data

/datum/preference/color/tajaran_facial_hair_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "tajaran_facial_hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_TAJARAN

/datum/preference/color/tajaran_facial_hair_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/tajaran_facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_facial_hair_color"] = value

// MARK: Tajaran tail markings
/datum/preference/choiced/tajaran_tail_markings
	savefile_key = "feature_tajaran_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/tajaran

/datum/preference/choiced/tajaran_tail_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tajaran_tail_markings_list)

/datum/preference/choiced/tajaran_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_tail_markings"] = value

/datum/preference/choiced/tajaran_tail_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "tajaran_tail_markings_color"

	return data

/datum/preference/choiced/tajaran_tail_markings/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_tajaran)
	return pref == "Long tail" || pref == "Huge tail"

/datum/preference/color/tajaran_tail_markings_color
	savefile_key = "tajaran_tail_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/tajaran

/datum/preference/color/tajaran_tail_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/tajaran_tail_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_tail_markings_color"] = value

/datum/preference/color/tajaran_tail_markings_color/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_tajaran)
	return (pref == "Long tail" || pref == "Huge tail") && preferences.read_preference(/datum/preference/choiced/tajaran_tail_markings) != "None"
