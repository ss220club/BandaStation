/datum/preference/choiced/vulpkanin_tail_markings
	savefile_key = "feature_vulpkanin_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/choiced/vulpkanin_tail_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.vulpkanin_tail_markings_list)

/datum/preference/choiced/vulpkanin_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VULPKANIN_TAIL_MARKINGS] = value

/datum/preference/choiced/vulpkanin_tail_markings/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/vulpkanin_tail_markings_color::savefile_key
	return data

/datum/preference/choiced/vulpkanin_tail_markings/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_vulpkanin)
	return pref == "Default" || pref == "Bushy" || pref == "Straight Bushy"
