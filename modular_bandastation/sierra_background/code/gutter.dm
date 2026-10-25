/// Elysian lore and naming are independent of Paradise's criminal Gutter.
/// Speech syllables: Paradise-SS220 Tradeband, code/modules/mob/language.dm,
/// commit 0fffca1f1f29a63aff49d9b56524813eedf82c6d (Paradise contributors, AGPL-3.0).
/datum/language/gutter
	name = "Гаттер"
	desc = "Государственный язык Элизиума. Сложился из смешения преимущественно итальянского и испанского, а также французского и португальского языков."
	key = "3"
	flags = LANGUAGE_TONGUELESS_SPEECH
	default_priority = 90
	icon_state = "galuncom"
	space_chance = 100
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	always_use_default_namelist = TRUE
	syllables = list(
		"lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
		"sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
		"magna", "aliqua", "ut", "enim", "ad", "minim", "veniam", "quis", "nostrud",
		"exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo",
		"consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in",
		"voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla",
		"pariatur", "excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt",
		"in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum",
	)

/datum/language/gutter/default_name(gender)
	return generate_sierra_background_name_candidate(list("name_profile" = "elysian"), gender)

/// Regional languages remain selectable through the build's existing Bilingual feature.
/datum/preference/choiced/language/init_possible_values()
	var/list/values = ..()
	values |= /datum/language/gutter::name
	return values
