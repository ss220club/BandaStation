/datum/preference/color/skrell_head_tentacle_color
	savefile_key = "skrell_head_tentacle_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/head_tentacle

/datum/preference/color/skrell_head_tentacle_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["skrell_head_tentacle_color"] = value
