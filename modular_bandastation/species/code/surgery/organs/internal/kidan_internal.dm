/obj/item/organ/brain/kidan
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/eyes/kidan
	name = "kidan eyeballs"
	desc = "Глаза оранжево-жёлтого цвета, но по своей структуре - глаза насекомоподобного гуманоида."
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	synchronized_blinking = FALSE
	eye_icon_state = "kidan_eyes"

/obj/item/organ/tongue/kidan
	name = "kidan tongue"
	desc = "Странный язык кидана."
	languages_native = list(/datum/language/chittin)
	liked_foodtypes = VEGETABLES | FRUIT | SUGAR
	toxic_foodtypes = MEAT | SEAFOOD
	var/static/list/speech_replacements = list(
		new /regex("z+", "g") = "zzz",
		new /regex("v+", "g") = "vvv",
		new /regex("Z+", "g") = "ZZZ",
		new /regex("V+", "g") = "VVV",
		new /regex("з+", "g") = "ззз",
		new /regex("в+", "g") = "ввв",
		new /regex("З+", "g") = "ЗЗЗ",
		new /regex("В+", "g") = "ВВВ",
	)

/obj/item/organ/tongue/kidan/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/speechmod,\
		replacements = speech_replacements,\
		should_modify_speech = CALLBACK(src, PROC_REF(should_modify_speech))\
	)


/obj/item/organ/tongue/kidan/get_possible_languages()
	get_possible_languages()
	return ..() + /datum/language/chittin

/obj/item/organ/heart/kidan
	name = "kidan heart"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/lungs/kidan
	name = "kidan lungs"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/stomach/kidan
	name = "kidan stomach"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	hunger_modifier = 1.5

/obj/item/organ/liver/kidan
	name = "kidan liver"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 6
