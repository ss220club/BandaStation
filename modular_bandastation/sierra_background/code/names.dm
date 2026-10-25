/proc/get_sierra_background_name_profiles()
	var/static/list/data
	if(isnull(data))
		data = json_decode(file2text('modular_bandastation/sierra_background/data/name_profiles.json'))
	return data["profiles"]

/// Resolve both the generator and its UI label without generating or changing a name.
/proc/get_sierra_background_name_generator(datum/preferences/preferences)
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/language_type
	var/name_label
	if(ispath(species_type, /datum/species/skrell))
		language_type = /datum/language/qurvolious
		name_label = "Скреллианские имена"
	else if(ispath(species_type, /datum/species/ethereal))
		language_type = /datum/language/voltaic
		name_label = "Имена эфириалов"
	else if(ispath(species_type, /datum/species/plasmaman))
		// Naming tradition does not grant knowledge of the generator's language.
		language_type = /datum/language/calcic
		name_label = "Имена плазмаменов"
	if(language_type)
		return list("name_language" = language_type, "name_label" = name_label)

	var/culture = preferences.read_preference(/datum/preference/choiced/sierra_background/culture)
	var/list/culture_profile = get_sierra_background_culture_profile(culture)
	var/profile_id = culture_profile?["name_profile"]
	var/list/name_profiles = get_sierra_background_name_profiles()
	var/list/name_profile = name_profiles[profile_id]
	if(islist(name_profile))
		return list("name_profile" = profile_id, "name_label" = culture_profile["name_label"] || name_profile["label"])
	language_type = culture_profile?["name_language"]
	if(ispath(language_type, /datum/language))
		var/datum/language/language = GLOB.language_datum_instances[language_type]
		if(language)
			return list("name_language" = language_type, "name_label" = culture_profile["name_label"] || "Имена по языку «[language.name]»")
	return list("species_type" = species_type, "name_label" = "Имена вида «[initial(species_type.name)]»")

/proc/get_sierra_background_name_generation_label(datum/preferences/preferences)
	var/list/generator = get_sierra_background_name_generator(preferences)
	return generator["name_label"]

/// Keep exactly the existing real-name sanitization, including mandatory human surnames.
/proc/normalize_sierra_background_generated_name(value, datum/preferences/preferences)
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	var/result = name_preference.deserialize(value, preferences)
	return name_preference.is_valid(result, preferences) ? result : null

/// Produce a raw native candidate; the caller checks the actual name after native sanitization.
/proc/generate_sierra_background_name_candidate(list/generator, gender)
	var/profile_id = generator["name_profile"]
	if(profile_id)
		var/list/profiles = get_sierra_background_name_profiles()
		var/list/profile = profiles[profile_id]
		if(gender != MALE && gender != FEMALE)
			gender = pick(MALE, FEMALE)
		var/list/first_names = profile[gender == MALE ? "first_male" : "first_female"]
		var/list/last_names = profile[gender == MALE ? "last_male" : "last_female"] || profile["last"]
		var/first_name = pick(first_names)
		var/list/distinct_last_names = last_names - first_name
		var/last_name = pick(length(distinct_last_names) ? distinct_last_names : last_names)
		return "[first_name] [last_name]"
	var/language_type = generator["name_language"]
	if(language_type)
		var/list/language_weights = list()
		language_weights[language_type] = 1
		return generate_random_name(gender, unique = FALSE, language_weights = language_weights)
	return generate_random_name_species_based(gender, unique = FALSE, species_type = generator["species_type"])

/// The existing name preference calls this for missing values and explicit randomization only.
/proc/generate_sierra_background_name(datum/preferences/preferences, unique = TRUE)
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	var/list/generators = list(
		get_sierra_background_name_generator(preferences),
		list("name_language" = /datum/language/common),
	)
	for(var/list/generator as anything in generators)
		var/last_valid
		for(var/attempt in 1 to 10)
			var/candidate = generate_sierra_background_name_candidate(generator, gender)
			var/result = normalize_sierra_background_generated_name(candidate, preferences)
			if(isnull(result))
				continue
			last_valid = result
			if(!unique || !findname(result))
				return result
		if(last_valid)
			// Native generators also retry uniqueness a bounded number of times.
			return last_valid
		// Some native synthetic names become unusable after the existing no-numbers policy.
		// Only then try the existing Common pool; valid source conventions stay intact.
	CRASH("No generated name passed the existing real-name preference validator.")
