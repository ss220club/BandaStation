/datum/preference/color/vulpkanin_facial_hair_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "vulpkanin_facial_hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/vulpkanin_facial_hair

/datum/preference/color/vulpkanin_facial_hair_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vulpkanin_facial_hair_color"] = value
