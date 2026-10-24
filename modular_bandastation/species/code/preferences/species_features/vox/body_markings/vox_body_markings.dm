/datum/preference/choiced/species_feature/vox_body_markings
	savefile_key = "feature_vox_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vox_body

/datum/preference/choiced/species_feature/vox_body_markings/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_VOX_BODY_MARKINGS]

/datum/preference/choiced/species_feature/vox_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VOX_BODY_MARKINGS] = value

/datum/preference/choiced/species_feature/vox_body_markings/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/vox_body_markings_color::savefile_key
	return data
