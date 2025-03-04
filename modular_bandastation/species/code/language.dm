// MARK: Vulpkanin language
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
	icon = 'modular_bandastation/species/icons/mob/species/vulpkanin/lang.dmi'
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

// MARK: Tajaran language
/datum/language/siiktajr
	name = "Сик'таир"
	desc = "Основной разговорный язык таяр."
	key = "8"
	flags = TONGUELESS_SPEECH
	space_chance = 50
	syllables = list("рр","ррр","тайр","кир","радж","кии","мир","кра","ахк","нал","вах","кхаз","джри","ран","дарр", \
	"ми","джри","дин","манк","рхе","зар","ррхаз","кал","чур","ич","тхаа","дра","джурл","мах","сану","дра","ии'р", \
	"ка","ааси","фар","ва","бак","ара","кара","зар","сам","мак","храр","нджа","рир","хан","джун","дар","рик","ках", \
	"хал","кет","джурл","мах","тул","крещ","азу","рах")
	icon = 'modular_bandastation/species/icons/mob/species/tajaran/lang.dmi'
	icon_state = "taj_face"
	default_priority = 90

/datum/language/siiktajr/get_random_name(
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
		return "[pick(GLOB.first_names_male_tajaran)][random_name_spacer][pick(GLOB.last_names_tajaran)]"
	return "[pick(GLOB.first_names_female_tajaran)][random_name_spacer][pick(GLOB.last_names_tajaran)]"

/datum/language_holder/tajaran
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/siiktajr = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/siiktajr = list(LANGUAGE_ATOM),
	)
