/// The shipped catalogue must resolve to native language and name resources without hidden languages.
/datum/unit_test/sierra_background_culture_profiles
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_culture_profiles/Run()
	var/list/catalog = get_sierra_background_catalog()
	var/list/cultures = catalog["culture"]
	var/list/permitted_languages = list(
		/datum/language/common,
		/datum/language/gutter,
		/datum/language/spinwarder,
		/datum/language/qurvolious,
		/datum/language/siiktajr,
		/datum/language/canilunzt,
		/datum/language/draconic,
		/datum/language/moffic,
		/datum/language/nekomimetic,
		/datum/language/voltaic,
	)
	for(var/culture_id in cultures)
		var/list/profile = get_sierra_background_culture_profile(culture_id)
		TEST_ASSERT(islist(profile), "Culture [culture_id] has no gameplay profile.")
		var/list/languages = profile["languages"]
		TEST_ASSERT(/datum/language/common in languages, "Culture [culture_id] lacks the existing station language.")
		var/list/unique_languages = list()
		unique_languages |= languages
		TEST_ASSERT_EQUAL(length(unique_languages), length(languages), "Culture [culture_id] duplicates a language.")
		for(var/language_type in languages)
			TEST_ASSERT(language_type in permitted_languages, "Culture [culture_id] grants an unrelated or restricted language.")
			TEST_ASSERT_NOTNULL(GLOB.language_datum_instances[language_type], "Culture [culture_id] references a missing language.")
		var/name_language = profile["name_language"]
		if(!isnull(name_language))
			TEST_ASSERT_NOTNULL(GLOB.language_datum_instances[name_language], "Culture [culture_id] references a missing name generator.")
	var/list/plasmaman = get_sierra_background_culture_profile("plasmaman_technocrat")
	var/list/plasmaman_languages = plasmaman["languages"]
	TEST_ASSERT(!(/datum/language/calcic in plasmaman_languages), "The approved Plasmaman lore does not grant their lost language.")
	TEST_ASSERT_EQUAL(plasmaman["name_language"], /datum/language/calcic, "Plasmaman chemical naming must remain independent of language knowledge.")
	var/list/unknown = get_sierra_background_culture_profile("invalid-culture")
	TEST_ASSERT_EQUAL(json_encode(unknown), json_encode(get_sierra_background_culture_profile("other")), "An unknown culture does not use the neutral profile.")

/// UI effects derive from the current slot and selected culture, never from a second saved selection.
/datum/unit_test/sierra_background_culture_effects_ui
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_culture_effects_ui/Run()
	var/datum/preferences/preferences = make_preferences()
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human
	var/datum/preference_middleware/sierra_background/middleware = background_middleware(preferences)
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	for(var/culture_id in list("tsf_solar", "kssp", "skrell_imperial", "elysian", "other"))
		TEST_ASSERT(preferences.update_preference(culture, culture_id), "Could not select [culture_id] for the effects preview.")
		var/list/ui_data = middleware.get_ui_data(null)
		var/list/rows = ui_data["sierra_background"]
		var/list/row = rows[1]
		TEST_ASSERT_EQUAL(row["category"], "culture", "Effects were attached to the wrong category.")
		TEST_ASSERT_EQUAL(json_encode(row["language_names"]), json_encode(get_sierra_background_language_names(culture_id)), "The UI language preview is stale for [culture_id].")
		TEST_ASSERT_EQUAL(row["name_generation"], get_sierra_background_name_generation_label(preferences), "The UI name preview is stale for [culture_id].")
		for(var/index in 2 to length(rows))
			var/list/other_row = rows[index]
			TEST_ASSERT(!("language_names" in other_row), "Residence, faction or religion must not assign upbringing languages.")

/// Citizenship and residence do not automatically prove language knowledge or replace a manual name.
/datum/unit_test/sierra_background_affiliation_language_independence
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_affiliation_language_independence/Run()
	var/datum/preferences/preferences = make_preferences()
	preferences.value_cache[/datum/preference/choiced/species] = /datum/species/human
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Culture Tester"), "Could not prepare a manual name.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture], "tsf_solar"), "Could not prepare Solar upbringing.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/sierra_background/faction], "CUSP"), "Could not prepare Soviet affiliation.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/sierra_background/homeworld], "Magnitka"), "Could not prepare Soviet residence.")
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	preferences.apply_prefs_to(character)
	TEST_ASSERT(!character.has_language(/datum/language/spinwarder), "Faction or residence granted a language without the corresponding upbringing.")
	TEST_ASSERT_EQUAL(character.real_name, "Culture Tester", "Applying cultural effects replaced a manual character name.")
