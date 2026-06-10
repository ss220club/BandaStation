//operating computer that starts with all surgeries excluding a few like necrotic revival
/obj/machinery/computer/operating/clockwork
	name = "Clockwork Operating Computer"
	desc = "A device containing (most) of the surgery secrets of the universe."
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer"
	clockwork = TRUE
/obj/machinery/computer/operating/clockwork/Initialize(mapload)
	. = ..()
	// Add all available surgeries; Monkestation-specific surgery types removed as they don't exist in BandaStation
	for(var/datum/surgery_operation/surgery_type as anything in subtypesof(/datum/surgery_operation))
		advanced_surgeries |= surgery_type
