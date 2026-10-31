/// Block conflicting or repeated job assignments for players selected by admins.
/// Players outside the admin list use normal assignment rules.
/// Dynamic's forced occupations run after apply_assignments and can attempt to assign the same player again.
/// Reject that second assignment before assign_role increments current_positions again.
/datum/modpack/roundstart_roster/proc/validate_assignment(datum/source, mob/dead/new_player/player, datum/job/job, reject_already_assigned = TRUE)
	SIGNAL_HANDLER
	var/selected_job_type = assignments[player?.ckey]
	if(!selected_job_type)
		return
	if(selected_job_type != job.type)
		return BLOCK_JOB_ASSIGNMENT
	if(reject_already_assigned && !is_unassigned_job(player.mind.assigned_role))
		return BLOCK_JOB_ASSIGNMENT

/// Allow empty job preferences for admin-selected players. Players must still ready up themselves.
/datum/modpack/roundstart_roster/proc/allow_empty_job_preferences(datum/source, mob/dead/new_player/player)
	SIGNAL_HANDLER
	if(assignments[player.ckey])
		return BYPASS_JOB_PREFERENCES

/// Block antagonist selection that conflicts with a player's admin-selected job.
/// Before roundstart, block invader rulesets and rulesets that blacklist the assigned job.
/datum/modpack/roundstart_roster/proc/validate_antag_candidate(datum/source, datum/dynamic_ruleset/roundstart/ruleset, mob/candidate)
	SIGNAL_HANDLER
	var/datum/job/candidate_job = SSjob.get_job_type(assignments[candidate.ckey])
	if(!candidate_job)
		return
	if(ruleset.ruleset_flags & RULESET_INVADER)
		return BLOCK_ROUNDSTART_ANTAG_CANDIDATE
	if(candidate_job.title in ruleset.get_blacklisted_roles())
		return BLOCK_ROUNDSTART_ANTAG_CANDIDATE

/// since apply_assignments may sleep in some branches, we must process it outside SIGNAL_HANDLER
/datum/modpack/roundstart_roster/proc/collect_assignment_callbacks(datum/source, list/assignment_callbacks)
	SIGNAL_HANDLER
	assignment_callbacks += CALLBACK(src, PROC_REF(apply_assignments))

/// Assign jobs selected by admins to ready players before standard job distribution.
/// Only connected players in SSjob.unassigned receive their jobs.
/// Runs independently in Dynamic's dry run and each real setup attempt.
/datum/modpack/roundstart_roster/proc/apply_assignments()
	for(var/player_ckey in assignments)
		var/job_type = assignments[player_ckey]
		if(!job_type)
			continue
		var/client/player_client = GLOB.directory[player_ckey]
		var/mob/dead/new_player/player = player_client?.mob
		if(!istype(player) || !(player in SSjob.unassigned) || !player.mind || player.ready != PLAYER_READY_TO_PLAY)
			continue
		var/datum/job/selected_job = SSjob.get_job_type(job_type)
		// Admin-selected jobs bypass experience, age and job-ban requirements.
		if(!SSjob.assign_role(player, selected_job, do_eligibility_checks = FALSE))
			continue
		if(!SSjob.run_divide_occupation_pure)
			log_admin("Admin roundstart job assigned [player_ckey] to [selected_job.title].")
