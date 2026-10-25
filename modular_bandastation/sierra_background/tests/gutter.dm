/// Elysian upbringing teaches Gutter; residence and affiliation alone do not.
/datum/unit_test/sierra_background_gutter_upbringing
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_gutter_upbringing/Run()
	var/datum/preferences/preferences = make_preferences()
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not select a human for the Elysian upbringing test.")
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	var/list/elysian_cultures = list("elysian", "tellurus_upbringing", "asteria_upbringing")
	for(var/culture_id in elysian_cultures)
		TEST_ASSERT(preferences.update_preference(culture, culture_id), "Could not select Elysian culture [culture_id].")
		preferences.apply_prefs_to(character)
		TEST_ASSERT(character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "[culture_id] removed Galactic Common.")
		TEST_ASSERT(character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "[culture_id] did not teach Gutter.")
		TEST_ASSERT(character.can_speak_language(/datum/language/gutter), "A human from [culture_id] cannot speak Gutter.")
		TEST_ASSERT(!character.get_language_holder().omnitongue, "Elysian upbringing enabled omnitongue.")
	for(var/species_id in GLOB.species_list)
		var/species_type = GLOB.species_list[species_id]
		var/list/choices = get_sierra_background_choices("culture", species_type)
		for(var/culture_id in elysian_cultures)
			TEST_ASSERT_EQUAL((culture_id in choices), species_type == /datum/species/human, "[species_type] has incorrect access to human-only Elysian culture [culture_id].")
	TEST_ASSERT(preferences.update_preference(culture, "tsf_solar"), "Could not select a non-Elysian upbringing.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/sierra_background/faction], "Elysium"), "Could not prepare Elysian affiliation.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/sierra_background/homeworld], "Tellurus"), "Could not prepare Elysian residence.")
	preferences.apply_prefs_to(character)
	TEST_ASSERT(!character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "Affiliation or residence taught Gutter without Elysian upbringing.")
	character.grant_language(/datum/language/gutter, ALL, LANGUAGE_QUIRK)
	preferences.apply_prefs_to(character)
	TEST_ASSERT(character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "Reapplying non-Elysian upbringing erased independently learned Gutter.")
	var/datum/language_holder/holder = character.get_language_holder()
	TEST_ASSERT(LANGUAGE_QUIRK in holder.understood_languages[/datum/language/gutter], "Independent Gutter knowledge changed its source.")

/// The ordinary language menu and Bilingual choice expose Gutter without changing the random pool.
/datum/unit_test/sierra_background_gutter_menu_and_bilingual
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_gutter_menu_and_bilingual/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = make_preferences(mock_client)
	mock_client.prefs = preferences
	preferences.all_quirks |= /datum/quirk/bilingual::name
	var/datum/preference/choiced/language/language_preference = GLOB.preference_entries[/datum/preference/choiced/language]
	var/list/choices = language_preference.get_choices()
	for(var/value in list("Random", /datum/language/uncommon::name, /datum/language/spinwarder::name, /datum/language/gutter::name))
		TEST_ASSERT(value in choices, "Adding Gutter removed or omitted the Bilingual choice [value].")
	for(var/datum/language/language_type as anything in GLOB.uncommon_roundstart_languages)
		TEST_ASSERT(initial(language_type.name) in choices, "Adding Gutter removed native Bilingual language [language_type].")
	TEST_ASSERT(!(/datum/language/gutter in GLOB.uncommon_roundstart_languages), "Manual Gutter selection changed the existing random language pool.")
	TEST_ASSERT(preferences.update_preference(language_preference, /datum/language/gutter::name), "The native Bilingual language preference rejected Gutter.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/toggle/language_speakable], TRUE), "Could not prepare spoken Bilingual knowledge.")
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	character.set_species(/datum/species/skrell)
	character.apply_sierra_background_languages("other")
	TEST_ASSERT(character.add_quirk(/datum/quirk/bilingual, mock_client), "The actual Bilingual quirk could not be added.")
	TEST_ASSERT(character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "Bilingual did not teach Gutter outside human Elysian upbringing.")
	TEST_ASSERT(character.can_speak_language(/datum/language/gutter), "Bilingual Gutter knowledge cannot use ordinary vocal anatomy.")
	var/datum/language_menu/menu = allocate(/datum/language_menu, character.get_language_holder())
	var/list/menu_data = menu.ui_data(character)
	var/list/languages = menu_data["languages"]
	var/list/gutter_row
	for(var/list/row as anything in languages)
		if(row["name"] == /datum/language/gutter::name)
			gutter_row = row
			break
	TEST_ASSERT(islist(gutter_row), "The native language menu omitted Gutter.")
	TEST_ASSERT_EQUAL(gutter_row["key"], "3", "The Gutter language menu does not expose language key 3.")
	TEST_ASSERT(gutter_row["can_understand"] && gutter_row["can_speak"] && gutter_row["could_speak"], "The Gutter menu row disagrees with the learned and physical language capabilities.")
	var/list/states = icon_states(gutter_row["icon"], 1)
	TEST_ASSERT(gutter_row["icon_state"] in states, "The Gutter language menu references a missing icon state.")
	var/list/known_mods = list()
	TEST_ASSERT_EQUAL(character.get_message_mods(",3 Привет", known_mods), "Привет", "The native speech parser did not strip the Gutter prefix.")
	TEST_ASSERT_EQUAL(known_mods[LANGUAGE_EXTENSION], /datum/language/gutter, "The native ,3 prefix did not select Gutter.")
	character.remove_quirk(/datum/quirk/bilingual)
	TEST_ASSERT(!character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "Removing Bilingual retained its independently selected Gutter knowledge.")
	var/list/unknown_mods = list()
	TEST_ASSERT_EQUAL(character.get_message_mods(",3 Привет", unknown_mods), ",3 Привет", "Knowing the Gutter prefix bypassed the character's language knowledge.")
	TEST_ASSERT_NULL(unknown_mods[LANGUAGE_EXTENSION], "The parser selected Gutter for a character who never learned it.")

/// Gutter and all three Elysian cultures use the same approved Romance name pools.
/datum/unit_test/sierra_background_gutter_names
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_gutter_names/Run()
	var/datum/language/gutter/language = GLOB.language_datum_instances[/datum/language/gutter]
	TEST_ASSERT_NOTNULL(language, "The Gutter language prototype is missing.")
	var/list/profiles = get_sierra_background_name_profiles()
	var/list/elysian = profiles["elysian"]
	var/datum/preferences/preferences = make_preferences()
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare a human for cultural Gutter names.")
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Ручное Имя"), "Could not prepare a manual name.")
	for(var/gender in list(MALE, FEMALE))
		var/list/first_names = elysian[gender == MALE ? "first_male" : "first_female"]
		for(var/attempt in 1 to 5)
			TEST_ASSERT(name_matches_background_pool(language.get_random_name(gender), first_names, elysian["last"]), "Gutter's language generator ignored the Elysian name pool.")
		TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/gender], gender), "Could not select a name gender.")
		for(var/culture_id in list("elysian", "tellurus_upbringing", "asteria_upbringing"))
			TEST_ASSERT(preferences.update_preference(culture, culture_id), "Could not select [culture_id] for name generation.")
			TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/name/real_name), "Ручное Имя", "Selecting [culture_id] replaced the authored name.")
			for(var/attempt in 1 to 5)
				TEST_ASSERT(name_matches_background_pool(generate_sierra_background_name(preferences), first_names, elysian["last"]), "[culture_id] generated a name outside the approved Elysian pool.")

/// Gutter derives from the saved slot and follows its speaker through the existing mind transfer API.
/datum/unit_test/sierra_background_gutter_reload_and_transfer
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_gutter_reload_and_transfer/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = make_preferences(mock_client)
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare the non-Elysian first slot.")
	TEST_ASSERT(preferences.update_preference(culture, "tsf_solar"), "Could not set the first slot's upbringing.")
	TEST_ASSERT(preferences.save_character(), "Could not save the first slot.")
	preferences.switch_to_slot(2)
	TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], "human"), "Could not prepare the Elysian second slot.")
	TEST_ASSERT(preferences.update_preference(culture, "asteria_upbringing"), "Could not set the Elysian second slot's upbringing.")
	TEST_ASSERT(preferences.save_character(), "Could not save the Elysian slot.")
	TEST_ASSERT(preferences.save_preferences(), "Could not flush the Gutter test's native JSON save.")
	var/datum/preferences/reloaded = make_preferences(mock_client)
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	reloaded.apply_prefs_to(character)
	TEST_ASSERT(character.can_speak_language(/datum/language/gutter), "Reloading the Elysian slot did not restore Gutter.")
	reloaded.switch_to_slot(1)
	reloaded.apply_prefs_to(character)
	TEST_ASSERT(!character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "The non-Elysian slot inherited the other character's Gutter.")
	reloaded.switch_to_slot(2)
	reloaded.apply_prefs_to(character)
	character.mind_initialize()
	var/mob/living/carbon/human/recipient = allocate(/mob/living/carbon/human/consistent)
	character.mind.transfer_to(recipient)
	TEST_ASSERT(recipient.can_speak_language(/datum/language/gutter), "A mind transfer lost the speaker's learned Gutter.")
	TEST_ASSERT(!character.has_language(/datum/language/gutter, UNDERSTOOD_LANGUAGE), "The vacated body retained learned Gutter.")
