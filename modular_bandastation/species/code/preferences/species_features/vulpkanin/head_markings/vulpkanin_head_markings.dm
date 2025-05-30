/datum/preference/choiced/vulpkanin_head_markings
	savefile_key = "feature_vulpkanin_head_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Раскраска головы"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin_head

/datum/preference/choiced/vulpkanin_head_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_head_markings_list)

/datum/preference/choiced/vulpkanin_head_markings/icon_for(value)
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/bodyparts.dmi', "vulpkanin_head")
	final_icon.blend_color(COLOR_ORANGE, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/head_marking = SSaccessories.vulpkanin_head_markings_list[value]
		var/datum/universal_icon/marking_icon = uni_icon(head_marking.icon, "[head_marking.icon_state]_head")
		marking_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(marking_icon, ICON_OVERLAY)

	final_icon.crop(11, 22, 21, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/vulpkanin_head_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_head_markings"] = value

/datum/preference/choiced/vulpkanin_head_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/vulpkanin_head_markings_color::savefile_key

	return data
