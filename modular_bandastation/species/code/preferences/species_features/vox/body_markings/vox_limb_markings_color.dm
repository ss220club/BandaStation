/datum/preference/color/vox_limb_markings_color
	savefile_key = "vox_limb_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vox_limb

/datum/preference/color/vox_limb_markings_color/create_default_value()
	return "#8a6036"

/datum/preference/color/vox_limb_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VOX_LIMB_MARKINGS_COLOR] = value
