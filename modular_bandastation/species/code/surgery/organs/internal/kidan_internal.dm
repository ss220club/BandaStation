/obj/item/organ/brain/kidan
	parent_type = /obj/item/organ/brain
	name = "kidan brain"
	desc = "Специфический мозг киданов, адаптированный к их фермерской биологии."
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/heart/kidan
	name = "kidan heart"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/lungs/kidan
	name = "kidan lungs"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/eyes/kidan
	name = "kidan eyes"
	desc = "Многогранные фасеточные глаза, отражающие свет и обеспечивающие широкий угол обзора."
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	synchronized_blinking = FALSE
	eye_icon_state = null

/obj/item/organ/tongue/kidan
	name = "kidan tongue"
	desc = "Короткий, но чувствительный язык киданов."
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	modifies_speech = FALSE
	languages_native = list(/datum/language/chittin)
	liked_foodtypes = FRUIT | GRAIN
	disliked_foodtypes = MEAT | SEAFOOD | GROSS

/obj/item/organ/tongue/kidan/get_possible_languages()
	return ..() + /datum/language/chittin

/obj/item/organ/liver/kidan
	name = "kidan liver"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 6

/obj/item/organ/stomach/kidan
	name = "kidan stomach"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
