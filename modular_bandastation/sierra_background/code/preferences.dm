/// The four values use the existing character savefile and slot lifecycle.
/datum/preference/choiced/sierra_background
	abstract_type = /datum/preference/choiced/sierra_background
	savefile_identifier = PREFERENCE_CHARACTER
	category = "sierra_background"
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE
	should_update_preview = FALSE
	/// Catalogue category, independent of the existing savefile key.
	var/background_category
	var/background_label

/datum/preference/choiced/sierra_background/init_possible_values()
	var/list/catalog = get_sierra_background_catalog()
	var/list/entries = catalog[background_category]
	var/list/choices = list()
	for(var/entry in entries)
		choices += entry
	return choices

/datum/preference/choiced/sierra_background/create_default_value()
	return get_sierra_background_default(background_category)

/datum/preference/choiced/sierra_background/create_informed_default_value(datum/preferences/preferences)
	return get_sierra_background_default(background_category, preferences.read_preference(/datum/preference/choiced/species))

/datum/preference/choiced/sierra_background/deserialize(input, datum/preferences/preferences)
	var/species_type = preferences?.read_preference(/datum/preference/choiced/species) || /datum/species/human
	var/value = normalize_sierra_background_value(background_category, input, species_type)
	if(preferences && !isnull(input) && input != value)
		// Native loading caches normalized values; mark migrations for the next ordinary slot save.
		preferences.recently_updated_keys |= type
	return value

/datum/preference/choiced/sierra_background/is_valid(value, datum/preferences/preferences)
	if(!istext(value))
		return FALSE
	var/species_type = preferences?.read_preference(/datum/preference/choiced/species) || /datum/species/human
	return value in get_sierra_background_choices(background_category, species_type)

/datum/preference/choiced/sierra_background/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	var/list/choices = get_sierra_background_choices(background_category, target.dna.species.type)
	target.dna.features[savefile_key] = (value in choices) ? value : choices[1]

/datum/preference/choiced/sierra_background/culture
	savefile_key = "sierra_culture"
	background_category = "culture"
	background_label = "Культура"

/datum/preference/choiced/sierra_background/culture/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	..()
	target.apply_sierra_background_languages(target.dna.features[savefile_key])

/datum/preference/choiced/sierra_background/homeworld
	savefile_key = "sierra_homeworld"
	background_category = "homeworld"
	background_label = "Место жительства"

/datum/preference/choiced/sierra_background/faction
	savefile_key = "sierra_faction"
	background_category = "faction"
	background_label = "Фракция"

/datum/preference/choiced/sierra_background/religion
	savefile_key = "sierra_religion"
	background_category = "religion"
	background_label = "Вера"

/datum/preferences/proc/sanitize_sierra_background()
	for(var/preference_type in subtypesof(/datum/preference/choiced/sierra_background))
		var/datum/preference/choiced/sierra_background/preference = GLOB.preference_entries[preference_type]
		var/value = read_preference(preference_type)
		if(!preference.is_valid(value, src))
			update_preference(preference, preference.deserialize(value, src))

/datum/preference_middleware/sierra_background

/datum/preference_middleware/sierra_background/get_constant_data()
	var/list/catalog = get_sierra_background_catalog()
	var/list/ui_catalog = list()
	for(var/category in catalog)
		var/list/entries = catalog[category]
		var/list/ui_entries = list()
		for(var/id in entries)
			var/list/entry = entries[id]
			// Source notes and unresolved editorial metadata stay outside the player asset.
			ui_entries[id] = list(
				"name" = entry["name"],
				"description" = entry["description"],
				"extra" = entry["extra"],
			)
		ui_catalog[category] = ui_entries
	return ui_catalog

/datum/preference_middleware/sierra_background/pre_set_preference(mob/user, preference, value)
	if(preference == "skrell_caste")
		var/datum/preference/choiced/caste = GLOB.preference_entries[/datum/preference/choiced/skrell_caste]
		return !caste.is_valid(value, preferences)
	var/datum/preference/choiced/sierra_background/entry = GLOB.preference_entries_by_key[preference]
	if(!istype(entry))
		return FALSE
	// Saved invalid values receive defaults; forged UI selections leave the choice intact.
	return !entry.is_valid(value, preferences)

/datum/preference_middleware/sierra_background/post_set_preference(mob/user, preference, value)
	if(preference == "species")
		preferences.sanitize_sierra_background()

/datum/preference_middleware/sierra_background/on_new_character(mob/user)
	preferences.sanitize_sierra_background()

/datum/preference_middleware/sierra_background/get_ui_data(mob/user)
	// Also covers the native randomize-character action, which writes species directly.
	preferences.sanitize_sierra_background()
	var/list/rows = list()
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/list/preference_types = list(
		/datum/preference/choiced/sierra_background/culture,
		/datum/preference/choiced/sierra_background/homeworld,
		/datum/preference/choiced/sierra_background/faction,
		/datum/preference/choiced/sierra_background/religion,
	)
	for(var/preference_type in preference_types)
		var/datum/preference/choiced/sierra_background/preference = GLOB.preference_entries[preference_type]
		var/datum/preference/text/sierra_background_notes/notes_preference = GLOB.preference_entries_by_key["[preference.savefile_key]_notes"]
		var/list/row = list(
			"category" = preference.background_category,
			"preference" = preference.savefile_key,
			"label" = preference.background_label,
			"value" = preferences.read_preference(preference_type),
			"choices" = get_sierra_background_choices(preference.background_category, species_type),
			"notes" = preferences.read_preference(notes_preference.type),
			"notes_preference" = notes_preference.savefile_key,
			"notes_max_length" = notes_preference.maximum_value_length - 1,
			"notes_prompt" = notes_preference.notes_prompt,
		)
		if(preference.background_category == "culture")
			row["language_names"] = get_sierra_background_language_names(row["value"])
			row["name_generation"] = get_sierra_background_name_generation_label(preferences)
		rows += list(row)
	return list("sierra_background" = rows)
