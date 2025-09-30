/datum/preference/color/tajaran_tail_markings_color
	savefile_key = "tajaran_tail_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/tail/tajaran

/datum/preference/color/tajaran_tail_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/tajaran_tail_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAJARAN_TAIL_MARKINGS_COLOR] = value

/datum/preference/color/tajaran_tail_markings_color/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/tail_tajaran)
	return (pref == "Long tail" || pref == "Huge tail") && preferences.read_preference(/datum/preference/choiced/tajaran_tail_markings) != SPRITE_ACCESSORY_NONE
