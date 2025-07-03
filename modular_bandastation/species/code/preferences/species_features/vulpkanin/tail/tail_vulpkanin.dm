/datum/preference/choiced/tail_vulpkanin
	savefile_key = "feature_vulpkanin_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/choiced/tail_vulpkanin/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_vulpkanin)

/datum/preference/choiced/tail_vulpkanin/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_vulpkanin"] = value
