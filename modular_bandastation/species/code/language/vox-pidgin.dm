/datum/language/vox
	name = "Вокс-пиджин"
	desc = "Общий язык различных кораблей Воксов. Он звучит как хаотичный визг."
	key = "V"
	flags = LANGUAGE_TONGUELESS_SPEECH
	space_chance = 60
	syllables = list("ти","тхи","тчи","хи","кхи","кки","кик","хки","ки","я","та","тцча","ка","йа","йу","тчи","тча","кха", \
		"скри","ахк","ехк","рхак","кра","аркх","хках","хкик","укх","утц","итц")
	always_use_default_namelist = TRUE
	icon = 'icons/bandastation/mob/species/vox/lang.dmi'
	icon_state = "vox-pidgin"
	default_priority = 90

/datum/language/vox/default_name()
	return pick(GLOB.vox_names)

/datum/language_holder/vox
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/vox = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/vox = list(LANGUAGE_ATOM),
	)
