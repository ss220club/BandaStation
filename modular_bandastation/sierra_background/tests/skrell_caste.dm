/// Full character UI compilation also asks the client about playtime-gated preferences.
/datum/client_interface/sierra_background_character_ui/proc/is_veteran()
	return FALSE

/datum/client_interface/sierra_background_character_ui/proc/get_exp_living(pure_numeric = FALSE)
	return 0

/// Birth caste uses its own native preference and never replaces upbringing.
/datum/unit_test/sierra_background_skrell_caste_validation
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_skrell_caste_validation/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface/sierra_background_character_ui)
	var/datum/preferences/preferences = make_preferences(mock_client)
	var/datum/preference/choiced/skrell_caste/caste = GLOB.preference_entries[/datum/preference/choiced/skrell_caste]
	var/datum/preference/species = GLOB.preference_entries[/datum/preference/choiced/species]
	var/list/castes = get_skrell_castes()
	var/list/expected_castes = list("Qerr-Katish", "Malish-Katish", "Kanin-Katish", "Talum-Katish", "Raskinta-Katish")
	TEST_ASSERT_EQUAL(length(castes), length(expected_castes), "The birth caste choices must contain all five castes.")
	TEST_ASSERT_EQUAL(caste.savefile_identifier, PREFERENCE_CHARACTER, "Birth caste must be saved per character.")
	TEST_ASSERT(!caste.can_randomize, "Random appearance must not rewrite birth caste.")
	TEST_ASSERT(caste.priority > species.priority, "Caste must apply after species.")
	for(var/caste_id in expected_castes)
		TEST_ASSERT(caste_id in castes, "The caste catalog is missing [caste_id].")
		var/list/definition = castes[caste_id]
		TEST_ASSERT(istext(definition["name"]) && length(definition["name"]), "A caste is missing its display name.")
		TEST_ASSERT(istext(definition["description"]) && length(definition["description"]), "A caste is missing its description.")
		TEST_ASSERT(caste.is_valid(caste_id), "A valid caste must validate without a preferences datum.")
		TEST_ASSERT_EQUAL(caste.deserialize(caste.serialize(caste_id), preferences), caste_id, "A valid caste changed during serialization.")
	var/list/invalid_values = list(null, 0, 123, list("forged"), "nanotrasen", "unknown-caste", "<script>forged</script>")
	for(var/invalid_value in invalid_values)
		TEST_ASSERT(!caste.is_valid(invalid_value), "Birth caste accepted malformed input or an upbringing ID.")
		TEST_ASSERT_EQUAL(caste.deserialize(invalid_value, preferences), "Qerr-Katish", "Malformed caste input did not use the native default.")
	TEST_ASSERT(preferences.update_preference(species, "human"), "Could not select human for caste access validation.")
	TEST_ASSERT(!caste.is_accessible(preferences), "Human must not expose the Skrell caste preference.")
	TEST_ASSERT(!preferences.update_preference(caste, "Talum-Katish"), "Human accepted a forged Skrell caste update.")
	var/list/character_preferences = preferences.compile_character_preferences(null)
	var/list/caste_category = character_preferences[caste.category]
	TEST_ASSERT(!caste_category || !(caste.savefile_key in caste_category), "Human character UI data contains the Skrell caste preference.")
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not select Skrell for caste access validation.")
	var/datum/preference_middleware/sierra_background/middleware = background_middleware(preferences)
	middleware.post_set_preference(null, "species", "skrell")
	TEST_ASSERT(caste.is_accessible(preferences), "Skrell must expose the birth caste preference.")
	character_preferences = preferences.compile_character_preferences(null)
	caste_category = character_preferences[caste.category]
	TEST_ASSERT(caste_category && (caste.savefile_key in caste_category), "Skrell character UI data omitted its caste preference.")
	var/list/upbringing_choices = get_sierra_background_choices("culture", /datum/species/skrell)
	TEST_ASSERT("skrell_imperial" in upbringing_choices, "Skrell upbringing is missing its native culture.")
	TEST_ASSERT("nanotrasen" in upbringing_choices, "A Skrell raised by Nanotrasen must be able to choose corporate upbringing.")
	TEST_ASSERT("other" in upbringing_choices, "Skrell upbringing must allow another culture.")
	for(var/caste_id in expected_castes)
		TEST_ASSERT(!(caste_id in upbringing_choices), "Birth caste [caste_id] remains an upbringing choice.")

/// Seed the native JSON tree so the real constructor exercises legacy migration.
/datum/unit_test/sierra_background_skrell_caste_migration
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_skrell_caste_migration/Run()
	var/list/legacy_castes = list("Qerr-Katish", "Malish-Katish", "Kanin-Katish", "Talum-Katish", "Raskinta-Katish")
	for(var/legacy_caste in legacy_castes)
		var/datum/client_interface/mock_client = allocate(/datum/client_interface)
		var/datum/preferences/preferences = make_preferences(mock_client)
		TEST_ASSERT(preferences.save_character(), "Could not create the legacy character tree.")
		var/list/save_data = preferences.savefile.get_entry("character1")
		save_data["species"] = "skrell"
		save_data["sierra_culture"] = legacy_caste
		save_data["sierra_culture_notes"] = "Моя история воспитания: [legacy_caste]"
		save_data -= "skrell_caste"
		TEST_ASSERT(preferences.save_preferences(), "Could not write the legacy JSON file.")
		var/datum/preferences/reloaded = make_preferences(mock_client)
		TEST_ASSERT_EQUAL(reloaded.read_preference(/datum/preference/choiced/skrell_caste), legacy_caste, "Loading legacy culture [legacy_caste] lost its birth caste.")
		TEST_ASSERT_EQUAL(reloaded.read_preference(/datum/preference/choiced/sierra_background/culture), "skrell_imperial", "Legacy caste did not become the default independent upbringing.")
		TEST_ASSERT_EQUAL(reloaded.read_preference(/datum/preference/text/sierra_background_notes/culture), "Моя история воспитания: [legacy_caste]", "Caste migration changed personal upbringing notes.")
		TEST_ASSERT(reloaded.save_character(), "Could not save the migrated character.")
		TEST_ASSERT(reloaded.save_preferences(), "Could not flush migrated JSON.")
		var/datum/preferences/reopened = make_preferences(mock_client)
		var/list/migrated_data = reopened.savefile.get_entry("character1")
		TEST_ASSERT_EQUAL(migrated_data["skrell_caste"], legacy_caste, "Migrated caste was not persisted to JSON.")
		TEST_ASSERT_EQUAL(migrated_data["sierra_culture"], "skrell_imperial", "The old caste remained serialized as upbringing.")
		TEST_ASSERT_EQUAL(reopened.read_preference(/datum/preference/choiced/skrell_caste), legacy_caste, "Reopening migrated JSON changed its caste.")
	var/list/saved_castes = list("Talum-Katish", "invalid-saved-caste")
	for(var/saved_caste in saved_castes)
		var/datum/client_interface/mock_client = allocate(/datum/client_interface)
		var/datum/preferences/preferences = make_preferences(mock_client)
		TEST_ASSERT(preferences.save_character(), "Could not prepare the explicit caste character tree.")
		var/list/save_data = preferences.savefile.get_entry("character1")
		save_data["species"] = "skrell"
		save_data["sierra_culture"] = "Raskinta-Katish"
		save_data["skrell_caste"] = saved_caste
		TEST_ASSERT(preferences.save_preferences(), "Could not flush an explicit saved caste.")
		var/datum/preferences/reloaded = make_preferences(mock_client)
		var/expected_caste = saved_caste == "Talum-Katish" ? saved_caste : "Qerr-Katish"
		TEST_ASSERT_EQUAL(reloaded.read_preference(/datum/preference/choiced/skrell_caste), expected_caste, "Legacy culture overrode an explicit caste or resurrected an invalid saved caste.")
		TEST_ASSERT_EQUAL(reloaded.read_preference(/datum/preference/choiced/sierra_background/culture), "skrell_imperial", "Explicit caste prevented normalization of legacy upbringing.")

/// Residence never rewrites upbringing, affiliation or genetic caste.
/datum/unit_test/sierra_background_skrell_caste_independence
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_skrell_caste_independence/Run()
	var/datum/preferences/preferences = make_preferences()
	var/datum/preference/species = GLOB.preference_entries[/datum/preference/choiced/species]
	var/datum/preference/caste = GLOB.preference_entries[/datum/preference/choiced/skrell_caste]
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	var/datum/preference/homeworld = GLOB.preference_entries[/datum/preference/choiced/sierra_background/homeworld]
	var/datum/preference/faction = GLOB.preference_entries[/datum/preference/choiced/sierra_background/faction]
	var/datum/preference_middleware/sierra_background/middleware = background_middleware(preferences)
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not prepare a Skrell character.")
	middleware.post_set_preference(null, "species", "skrell")
	TEST_ASSERT(preferences.update_preference(culture, "nanotrasen"), "A Skrell could not select corporate upbringing.")
	TEST_ASSERT(preferences.update_preference(caste, "Malish-Katish"), "Could not set a Skrell birth caste.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture.type), "nanotrasen", "Changing caste overwrote independent upbringing.")
	TEST_ASSERT(preferences.update_preference(caste, "Kanin-Katish"), "Could not change birth caste.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture.type), "nanotrasen", "Changing caste reset corporate upbringing.")
	TEST_ASSERT(preferences.update_preference(culture, "other"), "Could not select another upbringing.")
	TEST_ASSERT_EQUAL(preferences.read_preference(caste.type), "Kanin-Katish", "Changing upbringing changed birth caste.")
	TEST_ASSERT(preferences.update_preference(faction, "Nanotrasen"), "Could not select independent corporate affiliation.")
	var/list/homeworld_choices = get_sierra_background_choices("homeworld", /datum/species/skrell)
	for(var/homeworld_id in homeworld_choices)
		TEST_ASSERT(preferences.update_preference(homeworld, homeworld_id), "Could not select an offered Skrell residence.")
		middleware.post_set_preference(null, "sierra_homeworld", homeworld_id)
		TEST_ASSERT_EQUAL(preferences.read_preference(caste.type), "Kanin-Katish", "Residence [homeworld_id] changed birth caste.")
		TEST_ASSERT_EQUAL(preferences.read_preference(culture.type), "other", "Residence [homeworld_id] changed independent upbringing.")
		TEST_ASSERT_EQUAL(preferences.read_preference(faction.type), "Nanotrasen", "Residence [homeworld_id] changed independent main affiliation.")
	TEST_ASSERT(preferences.update_preference(culture, "nanotrasen"), "Could not restore corporate upbringing.")
	TEST_ASSERT(preferences.update_preference(caste, "forged-caste"), "The native choiced preference did not normalize an invalid caste.")
	TEST_ASSERT_EQUAL(preferences.read_preference(caste.type), "Qerr-Katish", "An unknown caste remained in the preference cache.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture.type), "nanotrasen", "Invalid caste input changed upbringing.")
	TEST_ASSERT(preferences.update_preference(species, "human"), "Could not change species to human.")
	middleware.post_set_preference(null, "species", "human")
	TEST_ASSERT(!preferences.update_preference(caste, "Raskinta-Katish"), "Hidden caste accepted an update after changing species.")
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not restore Skrell species.")
	middleware.post_set_preference(null, "species", "skrell")
	TEST_ASSERT_EQUAL(preferences.read_preference(caste.type), "Qerr-Katish", "Changing species lost the character's caste.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture.type), "nanotrasen", "Changing species reset valid shared upbringing.")

/// Both independent values must reach the mob through the normal application order.
/datum/unit_test/sierra_background_skrell_caste_apply
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_skrell_caste_apply/Run()
	var/datum/preferences/preferences = make_preferences()
	var/datum/preference/species = GLOB.preference_entries[/datum/preference/choiced/species]
	var/datum/preference/caste = GLOB.preference_entries[/datum/preference/choiced/skrell_caste]
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	var/datum/preference_middleware/sierra_background/middleware = background_middleware(preferences)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(preferences.update_preference(species, "human"), "Could not select human before applying preferences.")
	middleware.post_set_preference(null, "species", "human")
	caste.apply_to_human(human, "Talum-Katish", preferences)
	TEST_ASSERT(!("skrell_caste" in human.dna.features), "Applying the caste preference wrote Skrell caste onto a human.")
	preferences.apply_prefs_to(human)
	TEST_ASSERT(!("skrell_caste" in human.dna.features), "Full preference application wrote Skrell caste onto a human.")
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not select Skrell before applying preferences.")
	middleware.post_set_preference(null, "species", "skrell")
	TEST_ASSERT(preferences.update_preference(caste, "Raskinta-Katish"), "Could not prepare the applied birth caste.")
	TEST_ASSERT(preferences.update_preference(culture, "nanotrasen"), "Could not prepare the applied upbringing.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Caste Tester"), "Could not prepare the normal name preference.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/numeric/age], 35), "Could not prepare the normal age preference.")
	preferences.apply_prefs_to(human)
	TEST_ASSERT_EQUAL(human.dna.species.type, /datum/species/skrell, "Full preference application did not set Skrell species first.")
	TEST_ASSERT_EQUAL(human.dna.features["skrell_caste"], "Raskinta-Katish", "Full preference application lost the birth caste.")
	TEST_ASSERT_EQUAL(human.dna.features["sierra_culture"], "nanotrasen", "Full preference application conflated caste with upbringing.")
	TEST_ASSERT_EQUAL(human.real_name, "Caste Tester", "Caste application damaged the normal name preference.")
	TEST_ASSERT_EQUAL(human.age, 35, "Caste application damaged the normal age preference.")
	TEST_ASSERT(preferences.update_preference(species, "human"), "Could not restore human before reapplying preferences.")
	middleware.post_set_preference(null, "species", "human")
	preferences.apply_prefs_to(human)
	TEST_ASSERT(!("skrell_caste" in human.dna.features), "Reapplying human preferences retained the former Skrell caste.")

/// Exercise real slot switching and JSON reload with two Skrell of different upbringing.
/datum/unit_test/sierra_background_skrell_caste_slots
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_skrell_caste_slots/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = make_preferences(mock_client)
	var/datum/preference/species = GLOB.preference_entries[/datum/preference/choiced/species]
	var/datum/preference/caste = GLOB.preference_entries[/datum/preference/choiced/skrell_caste]
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	var/datum/preference/culture_notes = GLOB.preference_entries[/datum/preference/text/sierra_background_notes/culture]
	var/datum/preference_middleware/sierra_background/middleware = background_middleware(preferences)
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not select slot one's Skrell species.")
	middleware.post_set_preference(null, "species", "skrell")
	TEST_ASSERT(preferences.update_preference(caste, "Malish-Katish"), "Could not set slot one's birth caste.")
	TEST_ASSERT(preferences.update_preference(culture, "nanotrasen"), "Could not set slot one's corporate upbringing.")
	TEST_ASSERT(preferences.update_preference(culture_notes, "Первый слот: корпоративное воспитание."), "Could not set slot one's upbringing notes.")
	TEST_ASSERT(preferences.save_character(), "Could not save slot one.")
	preferences.switch_to_slot(2)
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not select slot two's Skrell species.")
	middleware.post_set_preference(null, "species", "skrell")
	TEST_ASSERT_EQUAL(preferences.read_preference(caste.type), "Qerr-Katish", "A new slot inherited slot one's caste.")
	TEST_ASSERT(preferences.update_preference(caste, "Talum-Katish"), "Could not set slot two's birth caste.")
	TEST_ASSERT(preferences.update_preference(culture, "skrell_imperial"), "Could not set slot two's imperial upbringing.")
	TEST_ASSERT(preferences.update_preference(culture_notes, "Второй слот: имперское воспитание."), "Could not set slot two's upbringing notes.")
	TEST_ASSERT(preferences.save_character(), "Could not save slot two.")
	preferences.switch_to_slot(1)
	TEST_ASSERT_EQUAL(preferences.read_preference(caste.type), "Malish-Katish", "Switching slots lost slot one's caste.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture.type), "nanotrasen", "Switching slots lost slot one's upbringing.")
	TEST_ASSERT_EQUAL(preferences.read_preference(culture_notes.type), "Первый слот: корпоративное воспитание.", "Switching slots lost slot one's upbringing notes.")
	preferences.switch_to_slot(2)
	TEST_ASSERT(preferences.save_preferences(), "Could not flush the two character slots to JSON.")
	TEST_ASSERT(fexists(preferences.path), "The native preferences JSON was not created.")
	var/datum/preferences/reloaded = make_preferences(mock_client)
	TEST_ASSERT_EQUAL(reloaded.default_slot, 2, "Reload did not restore the active slot.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(species.type), /datum/species/skrell, "Reload lost slot two's species.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(caste.type), "Talum-Katish", "Reload lost slot two's caste.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(culture.type), "skrell_imperial", "Reload lost slot two's upbringing.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(culture_notes.type), "Второй слот: имперское воспитание.", "Reload lost slot two's upbringing notes.")
	reloaded.switch_to_slot(1)
	TEST_ASSERT_EQUAL(reloaded.read_preference(species.type), /datum/species/skrell, "Reload lost slot one's species.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(caste.type), "Malish-Katish", "Reload lost slot one's caste.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(culture.type), "nanotrasen", "Reload lost slot one's upbringing.")
	TEST_ASSERT_EQUAL(reloaded.read_preference(culture_notes.type), "Первый слот: корпоративное воспитание.", "Reload lost slot one's upbringing notes.")
