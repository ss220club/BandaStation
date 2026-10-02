/datum/preference/color/vox_body_markings_color
	savefile_key = "vox_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vox_body

/datum/preference/color/vox_body_markings_color/create_default_value()
	return "#8a6036"

/datum/preference/color/vox_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VOX_BODY_MARKINGS_COLOR] = value

/datum/preference/color/vox_body_markings_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/species_feature/vox_body_markings) != SPRITE_ACCESSORY_NONE
