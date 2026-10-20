/mob/dead/new_player
	var/datum/latejoin_profile_snapshot/latejoin_request
	/// Synchronous native capacity phase; reset on every normal entry before any yielding checks.
	var/job_capacity_check_only = FALSE

/datum/latejoin_profile_snapshot
	var/client/requester
	var/datum/mind/character_mind
	var/job_title
	var/datum/job_character_selection/assignment

/// Menu snapshots remain local to the request; the singleton menu never stores a player's state.
/mob/dead/new_player/proc/capture_latejoin_request(job_title = null)
	var/client/requester = GET_CLIENT(src)
	if(!requester || requester.mob != src || !mind)
		return null
	var/datum/latejoin_profile_snapshot/context = requester.prefs.capture_latejoin_profile(job_title)
	context.requester = requester
	context.character_mind = mind
	context.job_title = job_title
	return context

/mob/dead/new_player/proc/is_latejoin_request_current(datum/latejoin_profile_snapshot/context)
	if(QDELETED(src) || !istype(context) || QDELETED(context))
		return FALSE
	var/client/requester = context.requester
	return requester && GET_CLIENT(src) == requester && requester.mob == src && mind == context.character_mind && requester.prefs.is_latejoin_profile_current(context.job_title, context)

/// Keep native capacity, including its early newbie Assistant return, without bypassing admission.
/mob/dead/new_player/IsJobUnavailable(rank, latejoin = FALSE, capacity_only = FALSE)
	job_capacity_check_only = capacity_only
	if(capacity_only)
		// The native injection ends this phase before eligibility/SQL; there is no wait here.
		. = ..(rank, latejoin)
		job_capacity_check_only = FALSE
		return
	var/datum/job/job = istext(rank) ? SSjob.get_job(rank) : null
	var/datum/latejoin_profile_snapshot/context = capture_latejoin_request(rank)
	if(!job || job.title != rank || !context)
		return JOB_UNAVAILABLE_GENERIC
	var/client/requester = context.requester
	var/newbie_capacity_exception = job.current_positions >= job.total_positions && job.total_positions != -1 && is_assistant_job(job) && isnum(requester.player_age) && requester.player_age <= 14
	// The native latejoin caller omits the flag; its active request supplies the context.
	if(latejoin_request && latejoin_request.job_title == rank)
		latejoin = TRUE
	. = ..(rank, latejoin)
	if(. != JOB_AVAILABLE)
		return
	if(!is_latejoin_request_current(context))
		return JOB_UNAVAILABLE_GENERIC
	// This native path returned before eligibility; every other path has already checked it.
	if(newbie_capacity_exception)
		. = SSjob.check_job_eligibility(src, job, "Newbie assistant admission", latejoin = latejoin)
		if(. != JOB_AVAILABLE)
			return
		if(!is_latejoin_request_current(context) || (latejoin && !job.special_check_latejoin(requester)))
			return JOB_UNAVAILABLE_GENERIC
		if(!is_latejoin_request_current(context))
			return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/mob/dead/new_player/AttemptLateSpawn(rank)
	if(spawning || assigned_character || new_character || !SSticker.IsRoundInProgress())
		return FALSE
	var/datum/latejoin_profile_snapshot/context = capture_latejoin_request(rank)
	if(!context)
		return FALSE
	latejoin_request = context
	spawning = TRUE
	. = ..()
	var/handed_over = context.assignment?.spawn_handed_over
	if(!handed_over && !QDELETED(context.assignment))
		cancel_character_spawn(context.assignment, context.character_mind, context.assignment.created_body)
	if(latejoin_request == context)
		latejoin_request = null
		if(!assigned_character && !new_character)
			spawning = FALSE
	qdel(context)
	if(handed_over)
		return TRUE

/// Inspect the requested profile without changing the active preferences.
/mob/dead/new_player/proc/get_latejoin_character_slot(rank)
	var/datum/job/job = SSjob.get_job(rank)
	if(job && assigned_character?.job_type == job.type)
		return assigned_character.slot
	var/client/requester = GET_CLIENT(src)
	if(!job || !requester)
		return null
	var/datum/job_character_selection/selection = requester.prefs.select_job_character(job, TRUE)
	var/character_slot = selection.slot
	qdel(selection)
	return character_slot

/// Run after waits and once more in final assignment, before any vacancy is occupied. No SQL.
/mob/dead/new_player/proc/validate_latejoin_request(rank, check_queue = TRUE)
	if(!latejoin_request || latejoin_request.job_title != rank || !is_latejoin_request_current(latejoin_request))
		return reject_late_spawn("Настройки персонажа изменились; выберите профессию повторно.")
	if(!SSticker.IsRoundInProgress())
		return reject_late_spawn()
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход в раунд временно отключён администрацией.")
	if(!(ckey(key) in GLOB.admin_datums))
		if((check_queue && length(SSticker.queued_players) && SSticker.queued_players[1] != src) || SSjob.is_latejoin_population_full())
			return reject_late_spawn("Сервер заполнен; дождитесь своей очереди.")
	if(SSshuttle.arrivals?.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
		return reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
	return TRUE

/// Native failures keep their original alert/CRASH; only a recorded admission rejection returns FALSE.
/mob/dead/new_player/proc/handle_latejoin_creation_failure()
	var/datum/latejoin_profile_snapshot/context = latejoin_request
	var/datum/job_character_selection/selection = context?.assignment
	var/rejection = selection?.spawn_rejection
	if(!selection || !cancel_character_spawn(selection, context.character_mind, selection.created_body))
		return FALSE
	if(rejection && context.requester)
		to_chat(src, span_warning(rejection))
	return !!rejection

/// Pre-assignment rejection has no right to clear a body or a committed selection.
/mob/dead/new_player/proc/reject_late_spawn(message)
	if(assigned_character || new_character)
		return FALSE
	var/client/requester = GET_CLIENT(src)
	if(message && requester)
		to_chat(src, span_warning(message))
	spawning = FALSE
	if(!requester && !QDELETED(src))
		qdel(src)
	return FALSE

/// Only the additional assigned-profile branch uses this policy; the native current-slot branch remains active.
/mob/dead/new_player/proc/check_assigned_latejoin_history(rank)
	if("[get_latejoin_character_slot(rank)]" in persistent_client.joined_as_slots)
		tgui_alert(usr, "Вы уже играли на данном персонаже в этом раунде!")
		return FALSE
	return TRUE
