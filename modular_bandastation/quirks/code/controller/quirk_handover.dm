/// Native handover can lose its client before the caller assigns quirks.
/datum/controller/subsystem/processing/quirks/AssignQuirks(mob/living/user, client/applied_client)
	if(!applied_client)
		return
	return ..()
