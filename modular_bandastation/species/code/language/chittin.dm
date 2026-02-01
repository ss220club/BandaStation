/datum/language/chittin
	name = "Хиттин"
	desc = "Хитин — родной язык киданов, используемый выходцами планеты Аурум,\
		Он не является исключительно звуковым: полноценная передача информации осуществляется одновременно через щелчки челюстей, дрожь конечностей.\
		Большая часть смыслов языка недоступна другим расам, поскольку требует восприятия химических и тактильных компонентов физиологически невозможных для нечленов киданской расы."
	key = "3"
	syllables = list(
)

	icon = 'icons/bandastation/mob/species/kidan/lang.dmi'
	icon_state = "kidan_face"
	default_priority = 90
	syllables = list(
		"зз","зр","зрр","зх","жз","жр","жж",
		"кш","кшр","кшк","крш","кх","кхр","кхк",
		"тр","трр","тз","тж","тк","тх",
		"шк","шкр","шх","шр","шш",
		"хр","хш","хк","хз","хж",
		"вр","вз","вж","вв","взв",
		"цз","цр","цх","цк",
		"рз","рж","рш","рк","рр",
		"зик","зак","зук","зэк",
		"кзар","кзик","кзур",
		"шаз","шез","шуз",
		"хиз","хаз","хуз",
		"зза","ззу","ззи",
	)

/datum/language/chittin/get_random_name(gender, name_count = 2, force_use_syllables = FALSE)
	if(gender == MALE)
		return "[pick(GLOB.first_names_male_kidan)][random_name_spacer][pick(GLOB.last_names_kidan)]"
	else
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
