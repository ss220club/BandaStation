/proc/get_skrell_caste_data()
	var/static/list/data
	if(isnull(data))
		data = json_decode(file2text('modular_bandastation/sierra_background/data/skrell.json'))
	return data

/proc/get_skrell_castes()
	var/list/data = get_skrell_caste_data()
	return data["castes"]

/// An inherited species characteristic, independent of upbringing and political affiliation.
/datum/preference/choiced/skrell_caste
	savefile_key = "skrell_caste"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/skrell_caste/init_possible_values()
	var/list/choices = list()
	for(var/caste in get_skrell_castes())
		choices += caste
	return choices

/datum/preference/choiced/skrell_caste/create_default_value()
	return "Qerr-Katish"

/datum/preference/choiced/skrell_caste/create_informed_default_value(datum/preferences/preferences)
	if(preferences && ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/skrell))
		// Read the slot itself: culture may already have been deserialized as upbringing.
		var/list/save_data = preferences.get_save_data_for_savefile_identifier(PREFERENCE_CHARACTER)
		var/legacy_caste = save_data?["sierra_culture"]
		if(legacy_caste in get_choices())
			return legacy_caste
	return create_default_value()

/datum/preference/choiced/skrell_caste/is_accessible(datum/preferences/preferences)
	if(!preferences || !..())
		return FALSE
	return ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/skrell)

/datum/preference/choiced/skrell_caste/compile_constant_data()
	var/list/data = ..()
	var/list/names = list()
	var/list/descriptions = list()
	var/list/castes = get_skrell_castes()
	for(var/caste in castes)
		var/list/entry = castes[caste]
		names[caste] = entry["name"]
		descriptions[caste] = entry["description"]
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = names
	data["descriptions"] = descriptions
	return data

/datum/preference/choiced/skrell_caste/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	// The native apply loop also visits preferences hidden for the current species.
	if(ispath(target.dna.species.type, /datum/species/skrell))
		target.dna.features[savefile_key] = value

/datum/preference/choiced/sierra_background/culture/deserialize(input, datum/preferences/preferences)
	if(preferences && ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/skrell) && (input in get_skrell_castes()))
		// Materialize the genetic choice before replacing the legacy culture in this slot.
		preferences.read_preference(/datum/preference/choiced/skrell_caste)
		preferences.recently_updated_keys |= type
	return ..()
