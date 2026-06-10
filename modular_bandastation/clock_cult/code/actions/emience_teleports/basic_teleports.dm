/datum/action/innate/clockcult/teleport_to_station
	name = "Teleport to Station"
	desc = "Teleport to a random location on the station."
	button_icon_state = "warp_down"

/datum/action/innate/clockcult/teleport_to_station/Activate()
	do_teleport(usr, pick(GLOB.station_turfs), 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	usr.playsound_local(get_turf(usr), 'sound/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)

/datum/action/innate/clockcult/eminence_abscond
	name = "Return to Reebe"
	desc = "Teleport back to reebe."
	button_icon_state = "Abscond"

/datum/action/innate/clockcult/eminence_abscond/Activate()
	if(!length(GLOB.abscond_markers))
		to_chat(usr, span_warning("Ratvar's pathways are not yet open!"))
		return
	do_teleport(usr, get_turf(pick(GLOB.abscond_markers)), 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	usr.playsound_local(get_turf(usr), 'sound/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)

