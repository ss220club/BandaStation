/mob/living/carbon/human
	var/initial_crew_record_pending = FALSE
	var/initial_crew_record_registered = FALSE

/// Called immediately before the two native initial inject() operations; identity changes never mark it.
/mob/living/proc/prepare_initial_crew_record()
	if(!ishuman(src))
		return
	var/mob/living/carbon/human/body = src
	if(!body.initial_crew_record_registered && (mind?.assigned_role.job_flags & JOB_CREW_MANIFEST))
		body.initial_crew_record_pending = TRUE

/// The native constructor registers this exact record and its locked counterpart before the callback.
/datum/record/crew/proc/on_created_crew_record()
	var/datum/record/locked/locked_record = locate(lock_ref)
	var/datum/mind/record_mind = locked_record?.mind_ref?.resolve()
	if(!ishuman(record_mind?.current))
		return
	var/mob/living/carbon/human/body = record_mind.current
	if(!body.initial_crew_record_pending || body.initial_crew_record_registered)
		return
	body.initial_crew_record_pending = FALSE
	body.initial_crew_record_registered = TRUE
	record_mind.assigned_role.on_initial_crew_record(body, src)

/// Called only for the first crew record, never a later identity change.
/datum/job/proc/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(body, COMSIG_HUMAN_INITIAL_CREW_RECORD, src, record)

/// Adapt the exact-record callback to the native Prisoner lifecycle.
/datum/job/prisoner/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	..()
	return register_initial_prisoner_record(body, record)
