/obj/effect/spawner/xeno_egg_delivery
	name = "xeno egg delivery"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	icon_state = "egg_growing"

/obj/effect/spawner/xeno_egg_delivery/Initialize(mapload)
	. = ..()
	var/turf/spawn_turf = get_turf(src)
	new /obj/structure/alien/egg/delivery(spawn_turf)
	new /obj/effect/temp_visual/gravpush(spawn_turf)
	playsound(spawn_turf, 'sound/items/party_horn.ogg', 50, TRUE, -1)
	if(SSticker.HasRoundStarted())
		return

	message_admins("An alien egg has been delivered to [ADMIN_VERBOSEJMP(spawn_turf)].")
	log_game("An alien egg has been delivered to [AREACOORD(spawn_turf)]")

	var/datum/command_footnote/footnote = new()
	footnote.message = "Мы доверили вашей команде исследовательский образец в [get_area(src)]. \
		Не забывайте соблюдать все меры предосторожности при работе с образцом."
	footnote.signature = "Центральное Командование"

	GLOB.communications_controller.command_report_footnotes += footnote

/obj/structure/alien/egg/delivery
	name = "xenobiological specimen egg"
	desc = "Большое пёстрое яйцо, присланное руководством в рамках инициативы по ксенобиологическим исследованиям. Обращайтесь с ним осторожно!"
	max_integrity = 300

/obj/structure/alien/egg/delivery/Initialize(mapload)
	. = ..()

	GLOB.communications_controller.xenomorph_egg_delivered = TRUE
	GLOB.communications_controller.captivity_area = get_area(src)
