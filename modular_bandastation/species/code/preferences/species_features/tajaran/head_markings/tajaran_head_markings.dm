/datum/preference/choiced/tajaran_head_markings
	savefile_key = "feature_tajaran_head_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Узор меха головы"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/tajaran_head

/datum/preference/choiced/tajaran_head_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tajaran_head_markings_list)

/datum/preference/choiced/tajaran_head_markings/icon_for(value)
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/tajaran/bodyparts.dmi', "tajaran_head")
	final_icon.blend_color(COLOR_ASSISTANT_GRAY, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/head_marking = SSaccessories.tajaran_head_markings_list[value]
		var/datum/universal_icon/head_marking_icon = uni_icon(head_marking.icon, "[head_marking.icon_state]_head")
		head_marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(head_marking_icon, ICON_OVERLAY)

	final_icon.crop(12, 22, 20, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/tajaran_head_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_head_markings"] = value

/datum/preference/choiced/tajaran_head_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/tajaran_head_markings_color::savefile_key

	return data
