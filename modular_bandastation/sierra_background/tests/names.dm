/datum/unit_test/sierra_background_fixture/proc/name_matches_background_pool(value, list/first_names, list/last_names)
	for(var/first_name in first_names)
		var/prefix = "[first_name] "
		if(copytext(value, 1, length(prefix) + 1) == prefix)
			if(copytext(value, length(prefix) + 1) in last_names)
				return TRUE
	return FALSE

/// The author's Neo-Latin profile keeps valid two-part names and gendered family-name forms.
/datum/unit_test/sierra_background_name_profiles
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_name_profiles/Run()
	var/list/profiles = get_sierra_background_name_profiles()
	var/list/elysian = profiles["elysian"]
	TEST_ASSERT(islist(elysian), "The Elysian name profile is missing.")
	TEST_ASSERT_EQUAL(elysian["label"], "Элизианские имена", "The Elysian generator lost its stable display label.")
	var/list/data = json_decode(file2text('modular_bandastation/sierra_background/data/name_profiles.json'))
	var/list/source = data["source"]
	TEST_ASSERT(istext(source["author_direction"]) && length(source["author_direction"]), "The locally authored Elysian name extension lacks its approved direction.")
	TEST_ASSERT(length(source["source_refs"]), "The Elysian name profile has no lore source reference.")
	var/datum/preferences/preferences = make_preferences()
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	for(var/pool_key in list("first_male", "first_female", "last_male", "last_female", "last"))
		var/list/pool = elysian[pool_key]
		TEST_ASSERT(length(pool), "The Elysian [pool_key] pool is empty.")
		var/list/unique_names = list()
		unique_names |= pool
		TEST_ASSERT_EQUAL(length(pool), length(unique_names), "The Elysian [pool_key] pool contains duplicates.")
		for(var/name in pool)
			TEST_ASSERT(istext(name) && name_preference.is_valid(name, preferences), "The Elysian [pool_key] pool contains an invalid name part.")
			TEST_ASSERT(!findtext(name, " "), "An Elysian name part contains an unexpected title, prefix or extra component.")
	var/list/family_names = list()
	family_names |= elysian["last_male"]
	family_names |= elysian["last_female"]
	var/list/legacy_family_names = elysian["last"]
	TEST_ASSERT_EQUAL(length(legacy_family_names), length(family_names), "The legacy family-name pool does not contain exactly the gendered forms.")
	for(var/name in family_names)
		TEST_ASSERT(name in legacy_family_names, "The legacy family-name pool omitted a gendered form.")
	for(var/gender in list(MALE, FEMALE))
		var/list/first_names = elysian[gender == MALE ? "first_male" : "first_female"]
		var/list/last_names = elysian[gender == MALE ? "last_male" : "last_female"]
		for(var/attempt in 1 to 20)
			var/candidate = generate_sierra_background_name_candidate(list("name_profile" = "elysian"), gender)
			TEST_ASSERT(name_matches_background_pool(candidate, first_names, last_names), "The Elysian generator mixed the selected gender's name or family-name forms.")
			TEST_ASSERT_EQUAL(name_preference.deserialize(candidate, preferences), candidate, "An Elysian candidate changed during native name normalization.")
			var/list/parts = splittext(candidate, " ")
			TEST_ASSERT_EQUAL(length(parts), 2, "Elysian generation added a title, initial or third name component.")
			TEST_ASSERT_NOTEQUAL(parts[1], parts[2], "Elysian generation repeated the same given and family name.")

/// Every selectable upbringing must produce a name accepted by the existing preference validator.
/datum/unit_test/sierra_background_names_validity
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_names_validity/Run()
	var/datum/preferences/preferences = make_preferences()
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	preferences.value_cache[/datum/preference/choiced/gender] = PLURAL
	for(var/species_id in GLOB.species_list)
		var/species_type = GLOB.species_list[species_id]
		preferences.value_cache[/datum/preference/choiced/species] = species_type
		for(var/culture in get_sierra_background_choices("culture", species_type))
			preferences.value_cache[/datum/preference/choiced/sierra_background/culture] = culture
			var/generated_name = generate_sierra_background_name(preferences, unique = FALSE)
			TEST_ASSERT(name_preference.is_valid(generated_name, preferences), "[species_id] with [culture] generated an invalid name: [generated_name].")
			TEST_ASSERT_EQUAL(name_preference.deserialize(generated_name, preferences), generated_name, "[species_id] with [culture] returned a raw name that changes again on native deserialization.")
			var/label = get_sierra_background_name_generation_label(preferences)
			TEST_ASSERT(istext(label) && length(label), "[species_id] with [culture] has no name generation label.")

/// Reuse native sanitization rather than weakening the real-name policy for synthetic names.
/datum/unit_test/sierra_background_names_normalization
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_names_normalization/Run()
	var/datum/preferences/preferences = make_preferences()
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/android
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	for(var/candidate in list("B-4", "12345", "Легион-123", "  клАвДия   пиКарД  ", "Жюли-Поль XXIX", repeat_string(50, "Ж")))
		var/expected = name_preference.deserialize(candidate, preferences)
		TEST_ASSERT_EQUAL(normalize_sierra_background_generated_name(candidate, preferences), expected, "A generated name was normalized differently from the existing real-name preference.")
	TEST_ASSERT_NULL(normalize_sierra_background_generated_name("B-4", preferences), "A synthetic name with only one surviving letter bypassed the real-name validator.")
	TEST_ASSERT_NULL(normalize_sierra_background_generated_name("12345", preferences), "A numeric synthetic name bypassed the real-name validator.")
	TEST_ASSERT_EQUAL(normalize_sierra_background_generated_name("Легион-123", preferences), "Легион-", "Generated synthetic names no longer use the existing numeric-character policy.")
	preferences.value_cache[/datum/preference/choiced/sierra_background/culture] = "other"
	for(var/attempt in 1 to 50)
		var/generated_name = generate_sierra_background_name(preferences)
		TEST_ASSERT(name_preference.is_valid(generated_name, preferences), "The native synthetic generator returned an unusable normalized name: [generated_name].")
		TEST_ASSERT_EQUAL(name_preference.deserialize(generated_name, preferences), generated_name, "Synthetic name normalization was not stable through the normal preference path.")

/// Cultural generators and source-defined naming conventions are independent from biological language grants.
/datum/unit_test/sierra_background_names_culture
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_names_culture/Run()
	var/datum/preferences/preferences = make_preferences()
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human
	preferences.value_cache[/datum/preference/choiced/sierra_background/culture] = "kssp"
	var/list/generator = get_sierra_background_name_generator(preferences)
	TEST_ASSERT_EQUAL(generator["name_language"], /datum/language/spinwarder, "Soviet upbringing did not use the existing Neorussian generator.")
	for(var/gender in list(MALE, FEMALE))
		preferences.value_cache[/datum/preference/choiced/gender] = gender
		var/list/first_names = gender == MALE ? GLOB.first_names_male_spinwarder : GLOB.first_names_female_spinwarder
		var/list/last_names = gender == MALE ? GLOB.last_names_male_spinwarder : GLOB.last_names_female_spinwarder
		for(var/attempt in 1 to 10)
			TEST_ASSERT(name_matches_background_pool(generate_sierra_background_name(preferences), first_names, last_names), "Soviet upbringing generated a name outside the native gendered Neorussian pools.")
	preferences.value_cache[/datum/preference/choiced/sierra_background/culture] = "elysian"
	generator = get_sierra_background_name_generator(preferences)
	TEST_ASSERT_EQUAL(generator["name_profile"], "elysian", "Elysian upbringing did not use the existing Latin name subset.")
	var/list/profiles = get_sierra_background_name_profiles()
	var/list/elysian = profiles["elysian"]
	TEST_ASSERT_EQUAL(get_sierra_background_name_generation_label(preferences), elysian["label"], "The UI label does not describe the Elysian generator.")
	for(var/gender in list(MALE, FEMALE))
		preferences.value_cache[/datum/preference/choiced/gender] = gender
		var/list/first_names = elysian[gender == MALE ? "first_male" : "first_female"]
		for(var/attempt in 1 to 10)
			TEST_ASSERT(name_matches_background_pool(generate_sierra_background_name(preferences), first_names, elysian["last"]), "Elysian upbringing generated a name outside its existing name subset.")

	var/list/required_generators = list(
		/datum/species/skrell = /datum/language/qurvolious,
		/datum/species/ethereal = /datum/language/voltaic,
		/datum/species/plasmaman = /datum/language/calcic,
	)
	for(var/species_type in required_generators)
		preferences.value_cache[/datum/preference/choiced/species] = species_type
		for(var/culture in list("nanotrasen", "kssp", "other"))
			preferences.value_cache[/datum/preference/choiced/sierra_background/culture] = culture
			generator = get_sierra_background_name_generator(preferences)
			TEST_ASSERT_EQUAL(generator["name_language"], required_generators[species_type], "[species_type] with [culture] lost its source-defined naming convention.")
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human/cerulean
	preferences.value_cache[/datum/preference/choiced/sierra_background/culture] = "other"
	generator = get_sierra_background_name_generator(preferences)
	TEST_ASSERT_EQUAL(generator["species_type"], /datum/species/human/cerulean, "An unspecified upbringing silently selected a human name generator for Ceruleans.")
	TEST_ASSERT(!generator["name_language"] && !generator["name_profile"], "Unspecified upbringing did not preserve the native species fallback.")

/// Explicit native actions change names; merely changing upbringing must preserve authored names.
/datum/unit_test/sierra_background_names_actions
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_names_actions/Run()
	var/datum/preferences/preferences = make_preferences()
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	var/datum/preference/culture_preference = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/gender], FEMALE), "Could not select a known gender for the native name action.")
	TEST_ASSERT(preferences.update_preference(name_preference, "Личное Имя"), "Could not set an authored character name.")
	TEST_ASSERT(preferences.update_preference(culture_preference, "kssp"), "Could not change upbringing for the name independence check.")
	var/datum/preference_middleware/sierra_background/background = background_middleware(preferences)
	background.post_set_preference(null, "sierra_culture", "kssp")
	TEST_ASSERT_EQUAL(preferences.read_preference(name_preference.type), "Личное Имя", "Changing upbringing overwrote an authored character name.")
	var/datum/preference_middleware/names/names_middleware
	for(var/datum/preference_middleware/names/candidate in preferences.middleware)
		names_middleware = candidate
		break
	TEST_ASSERT_NOTNULL(names_middleware, "The native name middleware is missing.")
	TEST_ASSERT(names_middleware.randomize_name(list("preference" = "real_name"), null), "The existing randomize-name action rejected cultural name generation.")
	var/randomized_name = preferences.read_preference(name_preference.type)
	TEST_ASSERT(randomized_name != "Личное Имя", "The native randomize-name action retained the old authored name.")
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	var/list/first_names = gender == MALE ? GLOB.first_names_male_spinwarder : GLOB.first_names_female_spinwarder
	var/list/last_names = gender == MALE ? GLOB.last_names_male_spinwarder : GLOB.last_names_female_spinwarder
	TEST_ASSERT(name_matches_background_pool(randomized_name, first_names, last_names), "The existing UI action ignored the current upbringing.")
	TEST_ASSERT(names_middleware.randomize_name(list("preference" = "clown_name"), null), "The existing clown-name action stopped working.")
	TEST_ASSERT_EQUAL(preferences.read_preference(name_preference.type), randomized_name, "Randomizing a special name changed the real name.")

	TEST_ASSERT(preferences.update_preference(name_preference, "Личное Имя"), "Could not restore an authored character name.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/random_body], RANDOM_ENABLED), "Could not enable native round-start randomization.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/random_name], RANDOM_DISABLED), "Could not disable native name randomization.")
	preferences.randomise = list()
	preferences.apply_character_randomization_prefs()
	TEST_ASSERT_EQUAL(preferences.read_preference(name_preference.type), "Личное Имя", "Round-start randomization ignored the disabled name setting.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/random_name], RANDOM_ENABLED), "Could not enable native name randomization.")
	preferences.apply_character_randomization_prefs()
	TEST_ASSERT(name_matches_background_pool(preferences.read_preference(name_preference.type), first_names, last_names), "Round-start randomization ignored the current culture's generator.")

/// Use actual JSON constructors and slot switching to preserve both authored and generated names.
/datum/unit_test/sierra_background_names_slots
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_names_slots/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = make_preferences(mock_client)
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	var/datum/preference/culture_preference = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare slot one's human species.")
	TEST_ASSERT(preferences.update_preference(culture_preference, "kssp"), "Could not prepare slot one's upbringing.")
	TEST_ASSERT(preferences.update_preference(name_preference, "Первый Персонаж"), "Could not prepare slot one's authored name.")
	TEST_ASSERT(preferences.save_character(), "Could not save slot one's authored name.")
	preferences.switch_to_slot(2)
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare slot two's human species.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/gender], FEMALE), "Could not prepare slot two's name gender.")
	TEST_ASSERT(preferences.update_preference(culture_preference, "elysian"), "Could not prepare slot two's upbringing.")
	TEST_ASSERT(preferences.save_character(), "Could not save slot two's culture before generating a missing name.")
	var/list/save_data = preferences.savefile.get_entry("character2")
	save_data -= "real_name"
	preferences.value_cache -= name_preference.type
	var/generated_name = preferences.read_preference(name_preference.type)
	var/list/profiles = get_sierra_background_name_profiles()
	var/list/elysian = profiles["elysian"]
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	var/list/first_names = elysian[gender == MALE ? "first_male" : "first_female"]
	TEST_ASSERT(name_matches_background_pool(generated_name, first_names, elysian["last"]), "A missing slot name did not use its informed cultural default.")
	TEST_ASSERT(preferences.save_character(), "Could not save slot two's generated name.")
	preferences.switch_to_slot(1)
	TEST_ASSERT_EQUAL(preferences.read_preference(name_preference.type), "Первый Персонаж", "Switching slots replaced slot one's authored name.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture_preference.type), "kssp", "Switching slots replaced slot one's upbringing.")
	preferences.switch_to_slot(2)
	TEST_ASSERT_EQUAL(preferences.read_preference(name_preference.type), generated_name, "Switching slots regenerated slot two's name.")
	TEST_ASSERT(preferences.save_preferences(), "Could not flush names and cultures to the native JSON file.")
	var/datum/preferences/reloaded = make_preferences(mock_client)
	TEST_ASSERT_EQUAL(reloaded.read_preference(name_preference.type), generated_name, "JSON reload regenerated the saved name.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(culture_preference.type), "elysian", "JSON reload lost the name's current upbringing.")
	reloaded.switch_to_slot(1)
	TEST_ASSERT_EQUAL(reloaded.read_preference(name_preference.type), "Первый Персонаж", "JSON reload replaced the authored name in the other slot.")

/// An existing slot's missing name must never use another slot's still-cached upbringing.
/datum/unit_test/sierra_background_names_slot_cache
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_names_slot_cache/Run()
	var/datum/preference/name/real_name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	var/datum/preference/culture_preference = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	var/list/profiles = get_sierra_background_name_profiles()
	var/list/elysian = profiles["elysian"]
	for(var/name_state in list("missing", "invalid"))
		var/datum/client_interface/mock_client = allocate(/datum/client_interface)
		var/datum/preferences/preferences = make_preferences(mock_client)
		preferences.switch_to_slot(1)
		TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare the source slot for the [name_state] name regression.")
		TEST_ASSERT(preferences.update_preference(culture_preference, "kssp"), "Could not prepare the source slot's distinct cached upbringing.")
		TEST_ASSERT(preferences.update_preference(name_preference, "Первый Персонаж"), "Could not prepare the source slot's authored name.")
		TEST_ASSERT(preferences.save_character(), "Could not save the source character slot.")
		preferences.switch_to_slot(2)
		TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare the destination slot's species.")
		TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/gender], FEMALE), "Could not prepare the destination slot's name gender.")
		TEST_ASSERT(preferences.update_preference(culture_preference, "elysian"), "Could not prepare the destination slot's different upbringing.")
		TEST_ASSERT(preferences.update_preference(name_preference, "Второй Персонаж"), "Could not prepare the destination slot's initial name.")
		TEST_ASSERT(preferences.save_character(), "Could not save the existing destination slot.")
		preferences.switch_to_slot(1)
		TEST_ASSERT_EQUAL(preferences.read_preference(culture_preference.type), "kssp", "The source slot did not have the expected cached upbringing.")
		var/list/destination_data = preferences.savefile.get_entry("character2")
		if(name_state == "missing")
			destination_data -= "real_name"
		else
			destination_data["real_name"] = "!"
		// Save the current source slot as the UI does, without restoring the destination's old name.
		TEST_ASSERT(preferences.save_character(), "Could not save the source slot before switching.")
		TEST_ASSERT(preferences.save_preferences(), "Could not flush the destination's [name_state] name to JSON.")
		preferences.switch_to_slot(2)
		var/generated_name = preferences.read_preference(name_preference.type)
		TEST_ASSERT_EQUAL(preferences.read_preference(culture_preference.type), "elysian", "The destination's saved upbringing was not restored.")
		TEST_ASSERT(name_matches_background_pool(generated_name, elysian["first_female"], elysian["last"]), "Loading an existing slot with a [name_state] name reused the previous slot's naming culture.")
		TEST_ASSERT(preferences.save_character(), "Could not save the newly generated destination name.")
		TEST_ASSERT(preferences.save_preferences(), "Could not persist the destination's culturally generated name.")
		var/datum/preferences/reloaded = make_preferences(mock_client)
		TEST_ASSERT_EQUAL(reloaded.read_preference(name_preference.type), generated_name, "Reopening JSON regenerated or lost the destination's name.")
		TEST_ASSERT_EQUAL(reloaded.read_preference(culture_preference.type), "elysian", "Reopening JSON lost the destination's culture.")
		reloaded.switch_to_slot(1)
		TEST_ASSERT_EQUAL(reloaded.read_preference(name_preference.type), "Первый Персонаж", "The regression recovery overwrote the source slot's authored name.")
