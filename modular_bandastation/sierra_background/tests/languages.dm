/// A species supplies physiology, while upbringing supplies learned languages for every roundstart kind.
/datum/unit_test/sierra_background_language_upbringing
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_upbringing/Run()
	var/list/species_types = list(
		/datum/species/human,
		/datum/species/human/felinid,
		/datum/species/human/cerulean,
		/datum/species/lizard,
		/datum/species/skrell,
		/datum/species/plasmaman,
		/datum/species/moth,
		/datum/species/ethereal,
		/datum/species/tajaran,
		/datum/species/vulpkanin,
	)
	for(var/species_type in species_types)
		var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
		character.set_species(species_type)
		character.apply_sierra_background_languages("other")
		TEST_ASSERT(character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "[species_type] lost the crew's shared language.")
		TEST_ASSERT(character.get_language_holder().has_sierra_background_languages(), "[species_type] has no authoritative upbringing marker.")
		var/datum/language_holder/species_holder = GLOB.prototype_language_holders[character.dna.species.species_language_holder]
		for(var/language in species_holder.understood_languages)
			if(language == /datum/language/common)
				continue
			TEST_ASSERT(!character.has_language(language, UNDERSTOOD_LANGUAGE), "[species_type] knew [language] solely through biology after another upbringing.")
		var/culture = get_sierra_background_default("culture", species_type)
		character.apply_sierra_background_languages(culture)
		var/list/profile = get_sierra_background_culture_profile(culture)
		for(var/language in profile["languages"])
			TEST_ASSERT(character.has_language(language, UNDERSTOOD_LANGUAGE), "[species_type] did not learn [language] from [culture].")
		if(species_type == /datum/species/plasmaman)
			TEST_ASSERT(!character.has_language(/datum/language/calcic, UNDERSTOOD_LANGUAGE), "Plasmaman upbringing invented Calcic knowledge against the approved wiki.")

/// Repeated application must remove only upbringing sources, retaining independently acquired knowledge and blocks.
/datum/unit_test/sierra_background_language_sources
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_sources/Run()
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	character.set_species(/datum/species/skrell)
	character.grant_language(/datum/language/spinwarder, ALL, LANGUAGE_QUIRK)
	character.grant_language(/datum/language/codespeak, ALL, LANGUAGE_MIND)
	character.grant_language(/datum/language/terrum, ALL, "independent_training")
	character.add_blocked_language(/datum/language/qurvolious, SPOKEN_LANGUAGE, LANGUAGE_QUIRK)
	character.apply_sierra_background_languages("skrell_imperial")
	character.apply_sierra_background_languages("skrell_imperial")
	TEST_ASSERT(character.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "Imperial upbringing did not teach its language.")
	TEST_ASSERT(!character.can_speak_language(/datum/language/qurvolious), "Upbringing bypassed an independent speech block.")
	var/datum/language_holder/holder = character.get_language_holder()
	var/list/common_sources = holder.understood_languages[/datum/language/common]
	TEST_ASSERT_EQUAL(length(common_sources & list(LANGUAGE_BACKGROUND)), 1, "Repeated application duplicated the background source.")
	character.apply_sierra_background_languages("other")
	TEST_ASSERT(!character.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "Changing upbringing retained its former learned language.")
	TEST_ASSERT(LANGUAGE_QUIRK in holder.blocked_speaking[/datum/language/qurvolious], "Changing upbringing removed another source's speech block.")
	TEST_ASSERT(character.has_language(/datum/language/spinwarder, ALL), "Changing upbringing removed a bilingual quirk language.")
	TEST_ASSERT(character.has_language(/datum/language/codespeak, ALL), "Changing upbringing removed a mind or antagonist language.")
	TEST_ASSERT(character.has_language(/datum/language/terrum, ALL), "Changing upbringing removed an independently learned language.")
	character.apply_sierra_background_languages("kssp")
	character.apply_sierra_background_languages("other")
	TEST_ASSERT(character.has_language(/datum/language/spinwarder, ALL), "Removing a shared background grant also removed the same independently learned language.")

/// Knowing a language does not bypass the vocal organs or grant omnitongue.
/datum/unit_test/sierra_background_language_physiology
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_physiology/Run()
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	character.apply_sierra_background_languages("ethereal_sprout")
	TEST_ASSERT(character.has_language(/datum/language/voltaic, UNDERSTOOD_LANGUAGE), "An adopted upbringing could not supply language understanding.")
	TEST_ASSERT(!character.can_speak_language(/datum/language/voltaic), "A human upbringing grant bypassed Voltaic's tongue restriction.")
	TEST_ASSERT(!character.get_language_holder().omnitongue, "Upbringing enabled omnitongue.")
	character.set_species(/datum/species/ethereal)
	TEST_ASSERT(character.can_speak_language(/datum/language/voltaic), "Compatible physiology could not use the already learned language.")
	character.apply_sierra_background_languages("other")
	TEST_ASSERT(!character.has_language(/datum/language/voltaic, UNDERSTOOD_LANGUAGE), "Ethereal biology restored a language that was never learned.")

/// In-round species transformations must preserve upbringing without teaching a new native language.
/datum/unit_test/sierra_background_language_species_change
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_species_change/Run()
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	character.apply_sierra_background_languages("kssp")
	character.grant_language(/datum/language/canilunzt, ALL, LANGUAGE_QUIRK)
	for(var/species_type in list(/datum/species/skrell, /datum/species/lizard, /datum/species/moth, /datum/species/human))
		character.set_species(species_type)
		TEST_ASSERT(character.has_language(/datum/language/spinwarder, UNDERSTOOD_LANGUAGE), "[species_type] transformation erased the character's upbringing.")
		TEST_ASSERT(character.has_language(/datum/language/canilunzt, UNDERSTOOD_LANGUAGE), "[species_type] transformation erased independently learned knowledge.")
		var/datum/language_holder/species_holder = GLOB.prototype_language_holders[character.dna.species.species_language_holder]
		for(var/language in species_holder.understood_languages)
			if(language == /datum/language/common || language == /datum/language/canilunzt)
				continue
			TEST_ASSERT(!character.has_language(language, UNDERSTOOD_LANGUAGE), "Transformation into [species_type] spontaneously taught [language].")
		TEST_ASSERT(character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "A transformation removed the crew's shared language.")

/// Upbringing follows the mind, keeps its removable source, and suppresses inherited knowledge in the recipient body.
/datum/unit_test/sierra_background_language_mind_transfer
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_mind_transfer/Run()
	var/mob/living/carbon/human/original = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/recipient = allocate(/mob/living/carbon/human/consistent)
	original.set_species(/datum/species/skrell)
	original.apply_sierra_background_languages("skrell_imperial")
	original.mind_initialize()
	recipient.set_species(/datum/species/moth)
	recipient.grant_language(/datum/language/spinwarder, ALL, LANGUAGE_QUIRK)
	original.mind.transfer_to(recipient)
	TEST_ASSERT(!original.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "The vacated body retained learned upbringing knowledge.")
	TEST_ASSERT(recipient.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "The mind lost its learned language in the new body.")
	TEST_ASSERT(!recipient.has_language(/datum/language/moffic, UNDERSTOOD_LANGUAGE), "A recipient body supplied unlearned species knowledge.")
	TEST_ASSERT(recipient.has_language(/datum/language/spinwarder, UNDERSTOOD_LANGUAGE), "Background transfer removed an independent recipient grant.")
	recipient.apply_sierra_background_languages("other")
	TEST_ASSERT(!recipient.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "Transferred background knowledge lost its removable source.")

	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human/consistent)
	first.set_species(/datum/species/skrell)
	second.set_species(/datum/species/moth)
	first.apply_sierra_background_languages("skrell_imperial")
	second.apply_sierra_background_languages("nian_caravan")
	first.mind_initialize()
	second.mind_initialize()
	var/datum/mind/first_mind = first.mind
	var/datum/mind/second_mind = second.mind
	first_mind.transfer_to(second)
	second_mind.transfer_to(first)
	TEST_ASSERT(first.has_language(/datum/language/moffic, UNDERSTOOD_LANGUAGE), "A mind swap lost the second character's upbringing.")
	TEST_ASSERT(!first.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "A mind swap merged both characters' learned languages.")
	TEST_ASSERT(second.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "A mind swap lost the first character's upbringing.")
	TEST_ASSERT(!second.has_language(/datum/language/moffic, UNDERSTOOD_LANGUAGE), "A mind swap retained the previous character's upbringing.")

/// Languages are derived from the native saved culture, without their own duplicated save data.
/datum/unit_test/sierra_background_language_slots
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_slots/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/preferences/preferences = make_preferences(mock_client)
	var/datum/preference/species = GLOB.preference_entries[/datum/preference/choiced/species]
	var/datum/preference/culture = GLOB.preference_entries[/datum/preference/choiced/sierra_background/culture]
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not prepare the language test's first slot.")
	TEST_ASSERT(preferences.update_preference(culture, "kssp"), "Could not save a Skrell's independently learned upbringing.")
	TEST_ASSERT(preferences.save_character(), "Could not save the first language slot.")
	preferences.switch_to_slot(2)
	TEST_ASSERT(preferences.update_preference(species, "skrell"), "Could not prepare the language test's second slot.")
	TEST_ASSERT(preferences.update_preference(culture, "skrell_imperial"), "Could not save the second slot's imperial upbringing.")
	TEST_ASSERT(preferences.save_character(), "Could not save the second language slot.")
	TEST_ASSERT(preferences.save_preferences(), "Could not flush language slots through native JSON.")
	var/datum/preferences/reloaded = make_preferences(mock_client)
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
	reloaded.apply_prefs_to(character)
	TEST_ASSERT(character.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "Reloading the imperial slot did not derive its learned language.")
	TEST_ASSERT(!character.has_language(/datum/language/spinwarder, UNDERSTOOD_LANGUAGE), "Reloading a slot inherited the other slot's language.")
	reloaded.switch_to_slot(1)
	reloaded.apply_prefs_to(character)
	TEST_ASSERT(character.has_language(/datum/language/spinwarder, UNDERSTOOD_LANGUAGE), "Reloading the Soviet slot did not derive its learned language.")
	TEST_ASSERT(!character.has_language(/datum/language/qurvolious, UNDERSTOOD_LANGUAGE), "Reapplying the first slot retained native Skrell or second-slot language knowledge.")

/// Common Second Language retains its configured partial understanding across upbringing and body changes.
/datum/unit_test/sierra_background_language_csl
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_csl/Run()
	for(var/strength in list(75, 50, 90))
		var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/consistent)
		var/datum/client_interface/mock_client
		if(strength != 90)
			mock_client = allocate(/datum/client_interface)
			var/datum/preferences/preferences = make_preferences(mock_client)
			mock_client.prefs = preferences
			preferences.all_quirks |= /datum/quirk/csl::name
			TEST_ASSERT(preferences.update_preference(GLOB.preference_entries[/datum/preference/choiced/csl_strength], "[strength]%"), "Could not set the native CSL partial understanding preference.")
		character.apply_sierra_background_languages("kssp")
		TEST_ASSERT(character.add_quirk(/datum/quirk/csl, mock_client), "Could not add the real CSL quirk.")
		TEST_ASSERT(!character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "Background Common bypassed CSL at [strength]%.")
		TEST_ASSERT_EQUAL(character.has_partial_language(/datum/language/common), strength, "CSL lost its configured partial understanding or null-client fallback.")
		TEST_ASSERT(character.get_language_holder().has_sierra_background_languages(), "CSL removed the upbringing marker together with Common understanding.")
		TEST_ASSERT(character.has_language(/datum/language/common, SPOKEN_LANGUAGE), "CSL incorrectly removed the ability to speak Common.")
		character.apply_sierra_background_languages("skrell_imperial")
		TEST_ASSERT(!character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "Reapplying upbringing restored full Common despite CSL.")
		TEST_ASSERT_EQUAL(character.has_partial_language(/datum/language/common), strength, "Reapplying upbringing changed the selected CSL strength.")
		var/datum/quirk/csl/quirk = character.get_quirk(/datum/quirk/csl)
		if(character.mob_mood)
			character.mob_mood.sanity = 50
		var/list/say_args = list()
		say_args.len = SPEECH_MODS
		say_args[SPEECH_MESSAGE] = "Background language test"
		say_args[SPEECH_FORCED] = FALSE
		say_args[SPEECH_MODS] = list()
		say_args[SPEECH_LANGUAGE] = /datum/language/common
		quirk.translate_parts(character, say_args)
		TEST_ASSERT_EQUAL(say_args[SPEECH_LANGUAGE], /datum/language/qurvolious, "CSL kept the former upbringing cached as its native language.")
		character.set_species(/datum/species/moth)
		TEST_ASSERT(!character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "Species change bypassed CSL's understanding limit.")
		TEST_ASSERT_EQUAL(character.has_partial_language(/datum/language/common), strength, "Species change changed CSL partial understanding.")
		TEST_ASSERT(!character.has_language(/datum/language/moffic, UNDERSTOOD_LANGUAGE), "A CSL character learned a species language because its understanding marker was absent.")
		character.remove_quirk(/datum/quirk/csl)
		TEST_ASSERT(character.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "Removing CSL did not restore full Common understanding.")
		var/datum/language_holder/holder = character.get_language_holder()
		TEST_ASSERT(LANGUAGE_BACKGROUND in holder.understood_languages[/datum/language/common], "Removing CSL did not restore the background's own source.")

	var/mob/living/carbon/human/independent = allocate(/mob/living/carbon/human/consistent)
	independent.apply_sierra_background_languages("kssp")
	independent.grant_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_MIND)
	TEST_ASSERT(independent.add_quirk(/datum/quirk/csl), "Could not prepare CSL alongside an independent mind grant.")
	independent.apply_sierra_background_languages("other")
	TEST_ASSERT(independent.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), "CSL integration removed an independent mind source that native CSL preserves.")
	var/datum/language_holder/independent_holder = independent.get_language_holder()
	TEST_ASSERT(LANGUAGE_MIND in independent_holder.understood_languages[/datum/language/common], "Reapplying upbringing changed the source of independent knowledge.")

/// Native Cerulean organs supply articulation; an acquired fish infusion keeps its existing language bonus.
/datum/unit_test/sierra_background_language_fish_organs
	parent_type = /datum/unit_test/sierra_background_fixture

/datum/unit_test/sierra_background_language_fish_organs/Run()
	var/mob/living/carbon/human/cerulean = allocate(/mob/living/carbon/human/consistent)
	cerulean.set_species(/datum/species/human/cerulean)
	cerulean.apply_sierra_background_languages("other")
	TEST_ASSERT(!cerulean.has_language(/datum/language/carptongue, UNDERSTOOD_LANGUAGE), "Cerulean fish anatomy supplied unlearned Carptongue.")
	TEST_ASSERT(cerulean.could_speak_language(/datum/language/carptongue), "Removing unlearned Carptongue also removed its physical articulation.")
	var/list/organs = list(
		cerulean.get_organ_by_type(/obj/item/organ/tongue/fish),
		cerulean.get_organ_by_type(/obj/item/organ/liver/fish),
		cerulean.get_organ_by_type(/obj/item/organ/stomach/fish),
	)
	for(var/obj/item/organ/organ as anything in organs)
		TEST_ASSERT_NOTNULL(organ, "Cerulean is missing a native fish organ used by this regression.")
		organ.Remove(cerulean, special = TRUE)
	var/datum/status_effect/organ_set_bonus/fish/fish_bonus = cerulean.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
	TEST_ASSERT(!fish_bonus?.bonus_active, "Removing three native fish organs did not deactivate the set bonus.")
	for(var/obj/item/organ/organ as anything in organs)
		organ.Insert(cerulean, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	fish_bonus = cerulean.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
	TEST_ASSERT(fish_bonus?.bonus_active, "Reinserting native fish organs did not reactivate the set bonus.")
	TEST_ASSERT(!cerulean.has_language(/datum/language/carptongue, UNDERSTOOD_LANGUAGE), "Reactivating native fish anatomy taught Carptongue without upbringing.")
	TEST_ASSERT(cerulean.could_speak_language(/datum/language/carptongue), "Reinserted Cerulean organs lost their articulation.")
	cerulean.grant_language(/datum/language/carptongue, ALL, LANGUAGE_QUIRK)
	cerulean.apply_sierra_background_languages("other")
	TEST_ASSERT(cerulean.has_language(/datum/language/carptongue, UNDERSTOOD_LANGUAGE), "Suppressing a biological fish grant also removed independent learning.")

	var/mob/living/carbon/human/infused = allocate(/mob/living/carbon/human/consistent)
	infused.apply_sierra_background_languages("other")
	for(var/organ_type in list(/obj/item/organ/tongue/fish, /obj/item/organ/liver/fish, /obj/item/organ/stomach/fish))
		var/obj/item/organ/organ = allocate(organ_type)
		organ.Insert(infused, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	TEST_ASSERT(infused.has_language(/datum/language/carptongue, UNDERSTOOD_LANGUAGE), "An acquired fish infusion lost its native language bonus.")
	infused.apply_sierra_background_languages("other")
	TEST_ASSERT(infused.has_language(/datum/language/carptongue, UNDERSTOOD_LANGUAGE), "Reapplying upbringing removed an acquired non-Cerulean fish infusion's grant.")
