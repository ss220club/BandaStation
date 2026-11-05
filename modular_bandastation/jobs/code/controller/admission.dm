/// Final admission fixes the selected profile before native role assignment occupies the vacancy.
/datum/controller/subsystem/job/proc/prepare_job_assignment(mob/dead/new_player/player, datum/job/job, latejoin)
	if(QDELETED(player) || !player.mind || !job)
		return FALSE
	var/client/requester = GET_CLIENT(player)
	if(!requester || requester.mob != player || job.get_join_lock_reason(requester))
		return FALSE
	if(!latejoin && !is_random_job_preference_allowed(player, job))
		return FALSE
	if(latejoin && player.latejoin_request && !player.validate_latejoin_request(job.title, check_queue = FALSE))
		return FALSE
	var/datum/job_character_selection/selection = requester.prefs.select_job_character(job, latejoin)
	if(selection.character_error(job, requester, latejoin) || (latejoin && (player.IsJobUnavailable(job.title, latejoin = TRUE, capacity_only = TRUE) != JOB_AVAILABLE || (!(ckey(player.key) in GLOB.admin_datums) && is_latejoin_population_full()))))
		qdel(selection)
		return FALSE
	QDEL_NULL(player.assigned_character)
	player.assigned_character = selection
	if(player.latejoin_request)
		player.latejoin_request.assignment = selection
	return TRUE

/// Preserve every native account/ban check; only the final age result belongs to the selected profile.
/datum/controller/subsystem/job/check_job_eligibility(mob/dead/new_player/player, datum/job/job, debug_prefix = "", add_job_to_log = FALSE, latejoin)
	var/client/requester = player ? GET_CLIENT(player) : null
	var/datum/mind/candidate_mind = player?.mind
	if(QDELETED(player) || !requester || !candidate_mind || !job)
		return JOB_UNAVAILABLE_GENERIC
	// All native occupation distribution happens before PLAYING; the live lobby menu is latejoin.
	if(isnull(latejoin))
		latejoin = !!player.latejoin_request || SSticker.IsRoundInProgress()
	. = ..()
	if(. != JOB_AVAILABLE && . != JOB_UNAVAILABLE_AGE)
		return
	if(QDELETED(player) || !requester || GET_CLIENT(player) != requester || requester.mob != player || player.mind != candidate_mind)
		return JOB_UNAVAILABLE_GENERIC
	if(!latejoin && !is_random_job_preference_allowed(player, job))
		return JOB_UNAVAILABLE_GENERIC
	return check_character_eligibility(player, job, latejoin)

/datum/controller/subsystem/job/proc/check_character_eligibility(mob/dead/new_player/player, datum/job/job, latejoin = FALSE)
	var/client/requester = GET_CLIENT(player)
	if(QDELETED(player) || !requester || !player.mind)
		return JOB_UNAVAILABLE_GENERIC
	if(job.get_join_lock_reason(requester))
		return JOB_UNAVAILABLE_JOB_LOCK
	var/datum/job_character_selection/selection = requester.prefs.select_job_character(job, latejoin)
	var/too_young = selection.is_too_young_for_job(job)
	var/profile_error = selection.character_error(job, requester, latejoin)
	qdel(selection)
	if(too_young)
		return JOB_UNAVAILABLE_AGE
	return profile_error ? JOB_UNAVAILABLE_CHARACTER_PROFILE : JOB_AVAILABLE

/// An assigned lobby character occupies capacity until native handover makes it a living player.
/datum/controller/subsystem/job/proc/is_latejoin_population_full()
	var/hard_cap = CONFIG_GET(number/hard_popcap)
	var/extreme_cap = CONFIG_GET(number/extreme_popcap)
	var/popcap = hard_cap && extreme_cap ? min(hard_cap, extreme_cap) : max(hard_cap, extreme_cap)
	if(!popcap)
		return FALSE
	var/occupants = living_player_count()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player.spawning || !player.assigned_character || isliving(player.client?.mob) || player.new_character?.client)
			continue
		var/datum/job/assigned_job = player.mind?.assigned_role || player.new_character?.mind?.assigned_role
		if(assigned_job && !is_unassigned_job(assigned_job))
			occupants++
	return occupants >= popcap

/// Return the actual eligible job so host-profile consumers need not repeat admission policy.
/mob/dead/new_player/proc/get_eligible_crew_job(list/blacklisted_roles)
	var/client/requester = GET_CLIENT(src)
	var/datum/mind/candidate_mind = mind
	if(!requester || QDELETED(candidate_mind))
		return FALSE
	var/random_fallback = requester.prefs.read_preference(/datum/preference/choiced/jobless_role) != RETURNTOLOBBY
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(QDELETED(src) || !requester || GET_CLIENT(src) != requester || QDELETED(candidate_mind) || mind != candidate_mind)
			return FALSE
		if((job.title in blacklisted_roles) || !job.spawn_positions || (job.job_flags & JOB_LATEJOIN_ONLY))
			continue
		if(!requester.prefs.job_preferences[job.title] && (!random_fallback || job.requires_explicit_preference()))
			continue
		var/availability = SSjob.check_job_eligibility(src, job, "Candidate admission")
		if(QDELETED(src) || !requester || GET_CLIENT(src) != requester || QDELETED(candidate_mind) || mind != candidate_mind)
			return FALSE
		if(availability != JOB_AVAILABLE)
			continue
		return job
	return null

/// Admission can wait for bans; cancellation must still belong to the original lobby and ruleset.
/datum/roundstart_job_admission
	var/mob/dead/new_player/player
	var/client/requester
	var/datum/mind/mind
	var/datum/job_character_selection/selection
	var/datum/roundstart_job_changes/pending_assignment
	var/forced_job
	var/ready

/datum/roundstart_job_admission/New(mob/dead/new_player/player)
	. = ..()
	src.player = player
	requester = GET_CLIENT(player)
	mind = player.mind
	selection = player.assigned_character
	pending_assignment = SSdynamic.get_roundstart_job_changes(mind)
	forced_job = LAZYACCESS(SSjob.forced_occupations, mind)
	ready = player.ready

/datum/roundstart_job_admission/proc/is_current(check_ready = TRUE)
	return !QDELETED(player) && requester && GET_CLIENT(player) == requester && requester.mob == player \
		&& !QDELETED(mind) && player.mind == mind && is_unassigned_job(mind.assigned_role) \
		&& player.assigned_character == selection && (!check_ready || player.ready == ready) \
		&& LAZYACCESS(SSjob.forced_occupations, mind) == forced_job \
		&& SSdynamic.get_roundstart_job_changes(mind) == pending_assignment

/datum/roundstart_job_admission/proc/reject(warn = TRUE, check_ready = TRUE)
	if(!is_current(check_ready))
		return
	if(warn)
		to_chat(player, span_warning("Ни одна выбранная профессия сейчас недоступна. Проверьте профиль и подписку."))
	if(pending_assignment)
		SSdynamic.cancel_roundstart_assignment(mind, pending_assignment)
	SSjob.unassigned -= player
	player.ready = PLAYER_NOT_READY

/// Only a queued invader may join without crew preferences; all crew keep the native checks.
/mob/dead/new_player/check_job_preferences(warn = TRUE)
	var/datum/roundstart_job_admission/admission = new(src)
	var/queued_invader = admission.pending_assignment?.invader && admission.forced_job && admission.forced_job == admission.pending_assignment.forced_job
	var/native_allowed = queued_invader ? TRUE : ..()
	. = native_allowed
	if(.)
		var/datum/job/forced_job = SSjob.get_job_type(admission.forced_job)
		if(forced_job)
			. = SSjob.check_job_eligibility(src, forced_job, "Forced admission") == JOB_AVAILABLE
		else if(client.prefs.read_preference(/datum/preference/choiced/jobless_role) == RETURNTOLOBBY)
			. = !!get_eligible_crew_job(null)
	if(!admission.is_current(check_ready = native_allowed))
		. = FALSE
	else if(!.)
		admission.reject(warn && native_allowed, check_ready = native_allowed)
	qdel(admission)
	return .
