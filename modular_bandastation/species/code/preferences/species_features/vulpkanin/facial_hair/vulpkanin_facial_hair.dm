/datum/preference/choiced/vulpkanin_facial_hair
	savefile_key = "feature_vulpkanin_facial_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Волосы на лице"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin_facial_hair

/datum/preference/choiced/vulpkanin_facial_hair/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_facial_hair_list)

/datum/preference/choiced/vulpkanin_facial_hair/icon_for(value)
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vulpkanin/bodyparts.dmi', "vulpkanin_head")
	final_icon.blend_color(COLOR_ORANGE, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/facial_hair = SSaccessories.vulpkanin_facial_hair_list[value]
		var/datum/universal_icon/facial_hair_icon = uni_icon(facial_hair.icon, "[facial_hair.icon_state]_head")
		facial_hair_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)
		final_icon.blend_icon(facial_hair_icon, ICON_OVERLAY)

	final_icon.crop(11, 22, 21, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/vulpkanin_facial_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_facial_hair"] = value

/datum/preference/choiced/vulpkanin_facial_hair/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/vulpkanin_facial_hair_color::savefile_key
	return data
