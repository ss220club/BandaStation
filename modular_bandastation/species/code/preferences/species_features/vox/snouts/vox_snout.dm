/datum/preference/choiced/species_feature/vox_snout
	savefile_key = "vox_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Морда"
	should_generate_icons = TRUE
	relevant_organ = /obj/item/organ/snout/vox

/datum/preference/choiced/species_feature/vox_snout/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_VOX_SNOUT]

/datum/preference/choiced/species_feature/vox_snout/icon_for(value)
	var/datum/universal_icon/final_icon = uni_icon('icons/bandastation/mob/species/vox/bodyparts.dmi', "_template")
	final_icon.blend_color(COLOR_LIGHT_YELLOW, ICON_MULTIPLY)

	if(value != SPRITE_ACCESSORY_NONE)
		var/datum/sprite_accessory/snout = get_accessory_for_value(value)
		var/datum/universal_icon/snout_icon = uni_icon(snout.icon, "m_vox_snout_[snout.icon_state]_ADJ")
		snout_icon.blend_color(COLOR_VERY_LIGHT_GRAY, ICON_MULTIPLY)

		final_icon.blend_icon(snout_icon, ICON_OVERLAY)

	final_icon.crop(8, 16, 24, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/species_feature/vox_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VOX_SNOUT] = value

/datum/preference/choiced/species_feature/vox_snout/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/vox_snout_color::savefile_key
	return data
