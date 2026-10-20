/// Changes made by one unexecuted ruleset, excluding restrictions that already existed.
/datum/roundstart_job_changes
	var/list/previous_blocked_jobs
	var/list/added_blocked_jobs
	var/forced_job
	var/previous_forced_job

/datum/dynamic_ruleset/roundstart
	/// Occupation changes owned by each unexecuted assignment, excluding pre-existing restrictions.
	VAR_PRIVATE/list/prepared_job_changes

/// A crew antagonist also needs an eligible job after the native mind and queued-selection checks.
/datum/dynamic_ruleset/roundstart/is_valid_candidate(mob/candidate, client/candidate_client)
	if(QDELETED(candidate) || !candidate_client || GET_CLIENT(candidate) != candidate_client)
		return FALSE
	. = ..()
	if(QDELETED(candidate) || !candidate_client || GET_CLIENT(candidate) != candidate_client)
		return FALSE
	if(!. || !isnewplayer(candidate) || (ruleset_flags & RULESET_INVADER))
		return
	var/mob/dead/new_player/player = candidate
	. = player.has_eligible_crew_preference(get_blacklisted_roles())
	if(QDELETED(candidate) || !candidate_client || GET_CLIENT(candidate) != candidate_client)
		return FALSE

/// The native caller retains both operations; only their before/after state belongs here.
/datum/dynamic_ruleset/proc/capture_job_constraints(datum/mind/candidate)
	return null

/datum/dynamic_ruleset/proc/commit_job_constraints(datum/mind/candidate, datum/roundstart_job_changes/changes)
	return

/datum/dynamic_ruleset/roundstart/capture_job_constraints(datum/mind/candidate)
	. = ..()
	var/datum/roundstart_job_changes/changes = new
	var/list/blocked_jobs = LAZYACCESS(SSjob.prevented_occupations, candidate)
	changes.previous_blocked_jobs = blocked_jobs ? blocked_jobs.Copy() : list()
	changes.previous_forced_job = LAZYACCESS(SSjob.forced_occupations, candidate)
	return changes

/datum/dynamic_ruleset/roundstart/commit_job_constraints(datum/mind/candidate, datum/roundstart_job_changes/changes)
	. = ..()
	if(!changes)
		return
	var/list/current_blocks = LAZYACCESS(SSjob.prevented_occupations, candidate)
	changes.added_blocked_jobs = (current_blocks || list()) - changes.previous_blocked_jobs
	changes.previous_blocked_jobs = null
	changes.forced_job = LAZYACCESS(SSjob.forced_occupations, candidate)
	LAZYSET(prepared_job_changes, candidate, changes)

/datum/dynamic_ruleset/roundstart/execute()
	. = ..()
	prepared_job_changes = null

/datum/dynamic_ruleset/roundstart/Destroy()
	prepared_job_changes = null
	return ..()

/datum/dynamic_ruleset/roundstart/set_config_value(new_var, new_val)
	if(new_var == NAMEOF(src, prepared_job_changes))
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/proc/cancel_assignment(datum/mind/candidate)
	if(!(candidate in selected_minds))
		return FALSE
	var/datum/roundstart_job_changes/changes = LAZYACCESS(prepared_job_changes, candidate)
	if(changes)
		var/list/blocked_jobs = LAZYACCESS(SSjob.prevented_occupations, candidate)
		blocked_jobs -= changes.added_blocked_jobs
		if(!length(blocked_jobs))
			LAZYREMOVE(SSjob.prevented_occupations, candidate)
		if(LAZYACCESS(SSjob.forced_occupations, candidate) == changes.forced_job)
			if(changes.previous_forced_job)
				LAZYSET(SSjob.forced_occupations, candidate, changes.previous_forced_job)
			else
				LAZYREMOVE(SSjob.forced_occupations, candidate)
	LAZYREMOVE(prepared_job_changes, candidate)
	selected_minds -= candidate
	return TRUE

/// Cancel only queued roundstart selections; active antagonists and other minds are untouched.
/datum/controller/subsystem/dynamic/proc/cancel_roundstart_assignment(datum/mind/candidate)
	var/cancelled = FALSE
	for(var/datum/dynamic_ruleset/roundstart/ruleset in queued_rulesets.Copy())
		if((ruleset in executed_rulesets) || !ruleset.cancel_assignment(candidate))
			continue
		cancelled = TRUE
		if(!length(ruleset.selected_minds))
			unqueue_ruleset(ruleset)
			qdel(ruleset)
	return cancelled
