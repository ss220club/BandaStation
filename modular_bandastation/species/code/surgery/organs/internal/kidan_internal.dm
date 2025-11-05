/obj/item/organ/brain/kidan
	parent_type = /obj/item/organ/brain
	name = "kidan brain"
	desc = "The Kidan's unique brain, adapted to their farming biology."
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/heart/kidan
	name = "kidan heart"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/lungs/kidan
	name = "kidan lungs"
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'

/obj/item/organ/eyes/kidan
	name = "kidan eyes"
	desc = "Multifaceted compound eyes that reflect light and provide a wide field of view."
	icon = 'icons/bandastation/mob/species/kidan/organs.dmi'
	synchronized_blinking = FALSE
	eye_icon_state = null

/obj/item/organ/tongue/kidan
	name = "kidan tongue"
	desc = "The short but sensitive language of the Kidans"
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
