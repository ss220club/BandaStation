/datum/language/canilunzt
	name = "Канилунц"
	desc = "Основной разговорный язык вульпканинов."
	key = "7"
	flags = TONGUELESS_SPEECH
	space_chance = 60
	syllables = list("рур","йа","сен","равр","бар","кук","тек","куат","ук","ву","вух","тах","тч","сжз","ауч", \
		"ист","йеин","ентч","звич","тут","мирr","во","бис","эс","вор","ник","гро","эл","энем","зантх","тзч","ноч", \
		"хел","исчт","фар","ва","барам","йеренг","теч","лач","сам","мак","лич","ген","ор","аг","ект","гек","стаг","онн", \
		"бин","кет","ярл","вульф","эйнеч","кресвз","азунейн","гхчв")
	icon = 'icons/bandastation/mob/species/vulpkanin/lang.dmi'
	icon_state = "vulptail"
	default_priority = 90

/datum/language/canilunzt/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()
	if(gender != MALE)
		gender = pick(MALE, FEMALE)

	if(gender == MALE)
		return "[pick(GLOB.first_names_male_vulp)][random_name_spacer][pick(GLOB.last_names_vulp)]"
	return "[pick(GLOB.first_names_female_vulp)][random_name_spacer][pick(GLOB.last_names_vulp)]"

/datum/language_holder/vulpkanin
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/canilunzt = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/canilunzt = list(LANGUAGE_ATOM),
	)
