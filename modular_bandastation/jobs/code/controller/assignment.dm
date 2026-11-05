/// Roles requiring an explicit preference cannot become the automatic overflow assignment.
/datum/controller/subsystem/job/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = ispath(new_overflow_role) ? get_job_type(new_overflow_role) : get_job(new_overflow_role)
	if(new_overflow?.requires_explicit_preference())
		job_debug("SET_OVRFLW: Failed to set new overflow role: [new_overflow_role]")
		CRASH("set_overflow_role failed | new_overflow_role: [isnull(new_overflow_role) ? "null" : new_overflow_role]")
	. = ..()

/// Native priority assignment may reject a forced role after the earlier preferences check.
/datum/controller/subsystem/job/assign_priority_positions()
	var/list/admissions = list()
	for(var/datum/mind/mind as anything in forced_occupations)
		if(!isnewplayer(mind.current) || !SSdynamic.get_roundstart_job_changes(mind))
			continue
		admissions += new /datum/roundstart_job_admission(mind.current)
	. = ..()
	// Wait until native iteration has finished before removing any forced-occupation entries.
	for(var/datum/roundstart_job_admission/admission as anything in admissions)
		admission.reject()
		qdel(admission)

/// Release cancelled selections before native role changes, including lobbies without a mind.
/datum/controller/subsystem/job/reset_occupations()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player?.assigned_character)
			QDEL_NULL(player.assigned_character)
	. = ..()

/// Only explicit-preference roles need an opt-in; this check never runs eligibility or SQL.
/datum/controller/subsystem/job/proc/is_random_job_preference_allowed(mob/dead/new_player/player, datum/job/job)
	var/client/requester = player ? GET_CLIENT(player) : null
	return job && requester?.prefs && (!job.requires_explicit_preference() || requester.prefs.job_preferences[job.title])
