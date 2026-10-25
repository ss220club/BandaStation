/obj/item/implant/kaza_ruk
	name = "kaza ruk implant"
	desc = "Teaches you the Tiziran martial arts of Kaza Ruk in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/scrolls.dmi'
	icon_state ="scroll2"
	/// The martial art style this implant teaches.
	var/datum/martial_art/kaza_ruk/style

	implant_info = "Automatically activates upon implantation. Teaches the Tiziran martial arts of Kaza Ruk."

	implant_lore = "The Kaza Ruk Implant is an integrated training database consisting of five short instructional videos \
		beamed directly into the eyeballs, capable of being replayed on demand in order to review the fundamentals of the Tiziran \
		martial arts of Kaza Ruk, regardless of the host's previous martial arts skills or a distinct lack thereof."

/obj/item/implant/kaza_ruk/Initialize(mapload)
	. = ..()
	style = new(src)

/obj/item/implant/kaza_ruk/Destroy()
	QDEL_NULL(style)
	return ..()

// BANDASTATION ADDITION START - Disconnect learned implant abilities
/obj/item/implant/kaza_ruk/on_remove(mob/living/source, silent = FALSE, special = FALSE)
	if(HAS_TRAIT(source, TRAIT_CYBERNETIC_REJECTION))
		style?.unlearn(source)
	return ..()
// BANDASTATION ADDITION END - Disconnect learned implant abilities

/obj/item/implant/kaza_ruk/on_activate() // BANDASTATION EDIT - Functional implant hook behind rejection gate
	. = ..()
	if(isnull(imp_in.mind))
		return
	if(style.unlearn(imp_in))
		return

	style.teach(imp_in)

/obj/item/implanter/kaza_ruk
	name = "implanter (kaza ruk)"
	imp_type = /obj/item/implant/kaza_ruk

/obj/item/implantcase/kaza_ruk
	name = "implant case - 'Kaza Ruk'"
	desc = "A glass case containing an implant that can teach the user the Tiziran martial arts of Kaza Ruk."
	imp_type = /obj/item/implant/kaza_ruk
