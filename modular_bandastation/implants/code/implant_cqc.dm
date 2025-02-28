/obj/item/implant/cqc
	name = "cqc implant"
	desc = "Teaches you the arts of Close Quarters Combat in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/scrolls.dmi'
	icon_state ="scroll2"
	var/datum/martial_art/cqc/style

/obj/item/implant/cqc/get_data()
	var/dat = {"
		<b>Implant Specifications:</b><BR>
		<b>Name:</b> CQC Implant<BR>
		<b>Life:</b> 4 hours after death of host<BR>
		<b>Implant Details:</b> <BR>
		<b>Function:</b> Teaches even the clumsiest host the arts of Close Quarters Combat.
	"}
	return dat

/obj/item/implant/cqc/Initialize(mapload)
	. = ..()
	style = new()
	style.allow_temp_override = FALSE

/obj/item/implant/cqc/Destroy()
	QDEL_NULL(style)
	return ..()

/obj/item/implant/cqc/activate()
	. = ..()
	if(isnull(imp_in.mind))
		return
	if(style.fully_remove(imp_in))
		return

	style.teach(imp_in, TRUE)

/obj/item/implanter/cqc
	name = "implanter (cqc)"
	imp_type = /obj/item/implant/cqc

/obj/item/implantcase/cqc
	name = "implant case - 'Close Quarters Combat'"
	desc = "A glass case containing an implant that can teach the user the arts of Close Quarters Combat."
	imp_type = /obj/item/implant/cqc
