/// The serialization interface has no preferences argument; contextual validation happens before saving.
/datum/preference/name/real_name/serialize(input)
	return reject_bad_name(input, allow_numbers = TRUE)

/datum/preference/name/real_name/is_valid(value, datum/preferences/preferences)
	return istext(value) && value == reject_bad_name(value, allow_numbers_for_species(preferences))

/datum/preference/name/real_name/proc/allow_numbers_for_species(datum/preferences/preferences)
	return ispath(preferences?.read_preference(/datum/preference/choiced/species), /datum/species/ipc)

/// Revalidate an unsaved model name when changing species, before it can reach a human preview or spawn.
/datum/preference/choiced/species/post_write(value, datum/preferences/preferences)
	. = ..()
	if(!(type in preferences.value_cache) || preferences.value_cache[type] == value || !(/datum/preference/name/real_name in preferences.value_cache))
		return
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	var/current_name = preferences.value_cache[/datum/preference/name/real_name]
	// post_write runs before the generic preference writer updates this cache entry.
	preferences.value_cache[type] = value
	if(!preferences.update_preference(name_preference, current_name))
		preferences.update_preference(name_preference, name_preference.create_informed_default_value(preferences))
