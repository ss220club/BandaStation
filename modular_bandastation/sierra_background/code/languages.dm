/// Spoken Common retains the upbringing marker even when CSL removes full understanding.
/datum/language_holder/proc/has_sierra_background_languages()
	return (LANGUAGE_BACKGROUND in LAZYACCESS(understood_languages, /datum/language/common)) || (LANGUAGE_BACKGROUND in LAZYACCESS(spoken_languages, /datum/language/common))

/// Species still determines the tongue and language blocks, but does not teach its language at birth.
/mob/living/carbon/human/proc/remove_sierra_species_languages()
	var/datum/language_holder/species_holder = GLOB.prototype_language_holders[dna.species.species_language_holder]
	for(var/language in species_holder.understood_languages)
		if(language != /datum/language/common)
			remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in species_holder.spoken_languages)
		if(language != /datum/language/common)
			remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	// Cerulean anatomy also activates the native fish organ bonus, outside the species holder.
	if(is_species(src, /datum/species/human/cerulean))
		remove_language(/datum/language/carptongue, ALL, /datum/status_effect/organ_set_bonus/fish)

/// Reapplying preferences replaces only this background's knowledge, preserving training and other grants.
/mob/living/carbon/human/proc/apply_sierra_background_languages(culture_id)
	var/list/profile = get_sierra_background_culture_profile(culture_id)
	var/list/languages = profile["languages"]
	remove_all_languages(source = LANGUAGE_BACKGROUND)
	grant_language(/datum/language/common, ALL, LANGUAGE_BACKGROUND)
	remove_sierra_species_languages()
	for(var/language in languages)
		grant_language(language, ALL, LANGUAGE_BACKGROUND)
	var/datum/quirk/csl/common_second_language = get_quirk(/datum/quirk/csl)
	common_second_language?.reremove_common()
	get_selected_language()
