/datum/preference/color/vox_snout_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vox_snout_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/snout/vox

/datum/preference/color/vox_snout_color/create_default_value()
	return "#FFB906"

/datum/preference/color/vox_snout_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VOX_SNOUT_COLOR] = value
