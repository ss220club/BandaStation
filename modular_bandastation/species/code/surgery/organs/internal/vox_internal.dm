/obj/item/organ/brain/cybernetic/vox
	name = "Vox cortical stack"
	desc = "A brain which has been in some part mechanized. The components are seamlessly integrated into the flesh."
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'
	icon_state = "cortical-stack"

/obj/item/organ/eyes/vox
	name = "vox eyeballs"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

	eye_icon = 'icons/bandastation/mob/species/vox/vox_eyes.dmi'

/obj/item/organ/heart/vox
	name = "vox heart"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

/obj/item/organ/stomach/vox
	name = "vox stomach"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

/obj/item/organ/liver/vox
	name = "vox liver"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 1.6

/obj/item/organ/lungs/vox
	name = "vox lungs"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

	safe_oxygen_min = 0
	safe_oxygen_max = 2
	oxy_damage_type = TOX
	oxy_breath_dam_min = 10

	safe_nitro_min = 10

/obj/item/organ/tongue/vox
	name = "vox tongue"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'
	languages_native = list(/datum/language/vox)
	liked_foodtypes = BUGS | TECH
	disliked_foodtypes = NONE
	modifies_speech = TRUE
	var/static/list/speech_replacements = list(
		new /regex("к+", "g") = "кик",
		new /regex("К+", "g") = "КИК",
		new /regex("ч+", "g") = "чич",
		new /regex("Ч+", "g") = "ЧИЧ",
	)

/obj/item/organ/tongue/vox/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/speechmod,\
		replacements = speech_replacements,\
		should_modify_speech = CALLBACK(src, PROC_REF(should_modify_speech))\
	)
