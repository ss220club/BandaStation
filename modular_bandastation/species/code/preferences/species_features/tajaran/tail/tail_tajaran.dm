/datum/preference/choiced/tail_tajaran
	savefile_key = "feature_tajaran_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/tajaran

/datum/preference/choiced/tail_tajaran/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_tajaran)

/datum/preference/choiced/tail_tajaran/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_tajaran"] = value
