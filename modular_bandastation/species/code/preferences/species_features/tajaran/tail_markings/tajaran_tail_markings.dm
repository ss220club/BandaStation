/datum/preference/choiced/tajaran_tail_markings
	savefile_key = "feature_tajaran_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/tajaran

/datum/preference/choiced/tajaran_tail_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tajaran_tail_markings_list)

/datum/preference/choiced/tajaran_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_tail_markings"] = value

/datum/preference/choiced/tajaran_tail_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/tajaran_tail_markings_color::savefile_key

	return data

/datum/preference/choiced/tajaran_tail_markings/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_tajaran)
	return pref == "Long tail" || pref == "Huge tail"
