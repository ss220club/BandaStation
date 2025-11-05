/datum/language/chittin
	name = "Хитин"
	desc = "Щелчки и вибрации хитина — родной язык киданов."
	key = "k"
	flags = TONGUELESS_SPEECH
	space_chance = 60
	syllables = list("клик", "зрик", "кчак", "зрк", "ззр")
	always_use_default_namelist = TRUE
	icon = 'icons/bandastation/mob/species/kidan/lang.dmi'
	icon_state = "kidanmark"
	default_priority = 80

/datum/language/chittin/default_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.first_names_male_kidan)][random_name_spacer][pick(GLOB.last_names_kidan)]"
	return "[pick(GLOB.first_names_female_kidan)][random_name_spacer][pick(GLOB.last_names_kidan)]"

/datum/language_holder/kidan
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/chittin = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/chittin = list(LANGUAGE_ATOM),
	)
