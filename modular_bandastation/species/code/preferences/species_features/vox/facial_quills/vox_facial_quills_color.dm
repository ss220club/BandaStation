/datum/preference/color/vox_facial_quills_color
	priority = PREFERENCE_PRORITY_LATE_BODY_TYPE
	savefile_key = "vox_facial_quills_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_organ = /obj/item/organ/facial_quills/vox

/datum/preference/color/vox_facial_quills_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vox_facial_quills_color/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features[FEATURE_VOX_FACIAL_QUILLS_COLOR] = value
