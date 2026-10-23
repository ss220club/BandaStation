/// Resolve one crime for equipment and the initial record.
/mob/living/carbon/human
	var/prisoner_crime
	var/prisoner_record_registered = FALSE
	var/prisoner_tattoos_applied = FALSE
	var/datum/record/crew/prisoner_initial_record

/// Replace only our native global subscription; registration needs the exact initial record.
/datum/job/prisoner/New()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

/// Capture one crime before preference application can yield, alongside the shared variant context.
/datum/job/prisoner/prepare_spawn_character(mob/living/body, datum/preferences/preferences)
	. = ..()
	if(!ishuman(body))
		return
	var/mob/living/carbon/human/new_prisoner = body
	if(GLOB.prisoner_crimes[new_prisoner.prisoner_crime])
		return
	var/crime_name = preferences?.read_preference(/datum/preference/choiced/prisoner_crime)
	new_prisoner.prisoner_crime = GLOB.prisoner_crimes[crime_name] ? crime_name : pick(assoc_to_keys(GLOB.prisoner_crimes))

/// Run the native handler with body-owned inputs, never a name-matched replacement record.
/datum/job/prisoner/proc/register_initial_prisoner_record(mob/living/carbon/human/crewmember, datum/record/crew/target_record)
	if(crewmember.prisoner_record_registered || QDELETED(target_record))
		return FALSE
	if(!GLOB.prisoner_crimes[crewmember.prisoner_crime])
		CRASH("Initial Prisoner record has no selected crime")
	crewmember.prisoner_initial_record = target_record
	handle_prisoner_joining(null, crewmember, title)
	crewmember.prisoner_initial_record = null
	return crewmember.prisoner_record_registered

/datum/job/prisoner/handle_prisoner_joining(datum/source, mob/living/crewmember, rank)
	if(rank != title)
		return ..()
	if(!ishuman(crewmember))
		return
	var/mob/living/carbon/human/body = crewmember
	if(body.prisoner_record_registered || QDELETED(body.prisoner_initial_record))
		return
	body.prisoner_record_registered = TRUE
	. = ..()
	if(!body.client)
		RegisterSignal(body, COMSIG_MOB_LOGIN, PROC_REF(notify_prisoner_crime))

/// Roundstart records precede possession; only the chat notice needs to wait for the client.
/datum/job/prisoner/proc/notify_prisoner_crime(mob/living/carbon/human/body)
	SIGNAL_HANDLER
	UnregisterSignal(body, COMSIG_MOB_LOGIN)
	to_chat(body, span_warning("You are imprisoned for \"[body.prisoner_crime]\"."))

/// Adapt the native local before its Random/fallback handling and effects.
/datum/job/prisoner/proc/get_committed_prisoner_crime_name(mob/living/crewmember, crime_name)
	if(ishuman(crewmember))
		var/mob/living/carbon/human/body = crewmember
		if(GLOB.prisoner_crimes[body.prisoner_crime])
			return body.prisoner_crime
	return crime_name

/// The wrapper guarantees that effects run only during the exact-record callback.
/datum/job/prisoner/proc/get_initial_prisoner_record(mob/living/crewmember, datum/record/crew/target_record)
	if(ishuman(crewmember))
		var/mob/living/carbon/human/body = crewmember
		if(body.prisoner_initial_record)
			return body.prisoner_initial_record
	return target_record

/// Native parent equipment already ran; only the tattoo loop is gated here.
/datum/outfit/job/prisoner/proc/get_prisoner_equipment_crime(mob/living/carbon/human/new_prisoner, datum/prisoner_crime/crime, visuals_only)
	if(visuals_only || new_prisoner.prisoner_tattoos_applied)
		return null
	crime = GLOB.prisoner_crimes[new_prisoner.prisoner_crime] || crime
	if(crime)
		new_prisoner.prisoner_tattoos_applied = TRUE
	return crime
