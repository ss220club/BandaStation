/mob/dead/new_player
	var/character_creation_in_progress = FALSE

/// Per-call ownership survives deletion/replacement of the lobby's assigned profile.
/// This snapshot never owns or deletes the captured mind, job or assignment.
/datum/job_character_creation
	var/datum/mind/character_mind
	var/datum/job/job
	var/datum/job_character_selection/assignment

/datum/job_character_creation/New(mob/dead/new_player/player)
	. = ..()
	character_mind = player.mind
	job = character_mind?.assigned_role
	assignment = player.assigned_character

/// The job frame survives lobby deletion; the native constructor still runs exactly once.
/datum/job/get_spawn_mob(client/player_client, atom/destination)
	var/mob/dead/new_player/player = isnewplayer(player_client?.mob) ? player_client.mob : null
	var/datum/job_character_creation/creation = player?.character_creation_in_progress ? new(player) : null
	. = ..()
	if(creation && !creation.validate_character(., player))
		return null

/// Before native mind/history changes, reject a stale request and dispose only of its own body.
/datum/job_character_creation/proc/validate_character(mob/living/body, mob/dead/new_player/player)
	var/datum/mind/spawning_mind = character_mind
	var/datum/job/spawning_job = job
	var/datum/job_character_selection/character_context = assignment
	qdel(src)
	if(!QDELETED(player) && !QDELETED(spawning_mind) && !QDELETED(character_context) && spawning_job)
		var/client/requester = player.client || body?.client
		var/datum/mind/current_mind = player.mind || body?.mind
		var/owns_assignment = current_mind == spawning_mind && (!body?.mind || body.mind == spawning_mind) && spawning_mind.assigned_role == spawning_job && player.assigned_character == character_context && spawning_job.type == character_context.job_type && !player.new_character
		var/owns_profile = requester && requester.prefs == character_context.preferences && requester.prefs.default_slot == character_context.slot
		if(!QDELETED(body) && owns_assignment && owns_profile)
			character_context.spawn_rejection = spawning_job.get_join_lock_reason(requester) || character_context.actual_body_error(spawning_job, body)
			if(!character_context.spawn_rejection)
				return TRUE
		else if(!owns_assignment || !owns_profile)
			character_context.spawn_rejection = "Контекст создания персонажа изменился."
	if(QDELETED(body))
		return FALSE
	// Another mind may have taken the body during a yield; never destroy that mind's body.
	if(body.mind && body.mind != spawning_mind)
		return FALSE
	spawning_job?.rollback_spawn_character(body, player, spawning_mind)
	qdel(body)
	return FALSE

/datum/job_character_selection
	/// The body and history entry belong to this construction, until native handover succeeds.
	var/mob/living/created_body
	var/datum/mind/created_mind
	var/spawn_rejection
	var/spawn_handed_over = FALSE
	var/datum/persistent_client/history_connection
	var/history_index

/mob/dead/new_player/Destroy()
	QDEL_NULL(assigned_character)
	QDEL_NULL(latejoin_request)
	return ..()

/mob/dead/new_player/Logout()
	if(!spawning && assigned_character && mind?.assigned_role)
		SSjob.free_job_position(mind.assigned_role.title)
	return ..()

/// Commit the selected profile, then let the original constructor and mind transfer run once.
/mob/dead/new_player/create_character(atom/destination, forced_slot)
	if(character_creation_in_progress || new_character)
		return null
	// Native latejoin supplies the editing slot; the committed assignment owns the actual slot.
	if(mind?.late_joiner && assigned_character)
		forced_slot = assigned_character.slot
	var/datum/job_character_selection/selection = prepare_character_profile(destination, forced_slot)
	if(!selection)
		return null
	var/datum/persistent_client/connection = client.persistent_client
	var/previous_history_length = length(connection?.joined_as_slots)
	selection.created_mind = mind
	character_creation_in_progress = TRUE
	. = ..(destination, selection.slot)
	if(QDELETED(src))
		return null
	character_creation_in_progress = FALSE
	if(.)
		selection.created_body = .
		// Native LAZYADD is immediately followed by non-yielding init_verbs and return.
		if(connection && length(connection.joined_as_slots) > previous_history_length && connection.joined_as_slots[length(connection.joined_as_slots)] == "[selection.slot]")
			selection.history_connection = connection
			selection.history_index = length(connection.joined_as_slots)

/mob/dead/new_player/proc/prepare_character_profile(atom/destination, forced_slot)
	if(!mind?.assigned_role || !destination)
		return null
	if(!client)
		if(assigned_character)
			assigned_character.spawn_rejection = "Клиент отключился во время входа."
		return null
	var/datum/job/job = mind.assigned_role
	var/datum/job_character_selection/selection = resolve_assigned_job_character(job, mind.late_joiner, forced_slot)
	if(latejoin_request)
		latejoin_request.assignment = selection
	selection.spawn_rejection = selection.character_error(job, client, mind.late_joiner) || job.get_join_lock_reason(client)
	if(selection.spawn_rejection)
		return null
	if(!load_assigned_job_character())
		selection.spawn_rejection = "Не удалось загрузить назначенный профиль."
		return null
	return selection

/mob/dead/new_player/proc/can_transfer_job_character()
	var/datum/job_character_selection/selection = assigned_character
	var/mob/living/body = new_character
	return body && (!selection || (body == selection.created_body && body.mind == selection.created_mind && body.mind?.current == body && body.mind?.assigned_role?.type == selection.job_type))

/mob/dead/new_player/transfer_character()
	if(!can_transfer_job_character())
		return null
	var/datum/job_character_selection/selection = assigned_character
	. = ..()
	if(. && selection)
		selection.spawn_handed_over = TRUE

/// Remove one native append, never pre-existing history or another attempt's entry.
/datum/job_character_selection/proc/rollback_spawn_history()
	if(spawn_handed_over || !history_index)
		return
	var/list/history = history_connection?.joined_as_slots
	if(islist(history) && history_index <= length(history) && history[history_index] == "[slot]")
		history.Cut(history_index, history_index + 1)
	history_index = null

/// Release only the captured assignment/body; a newer or foreign assignment is never rollback state.
/mob/dead/new_player/proc/cancel_character_spawn(datum/job_character_selection/expected_character = assigned_character, datum/mind/expected_mind = mind || new_character?.mind, mob/living/expected_body = new_character)
	if(QDELETED(expected_character) || assigned_character != expected_character || QDELETED(expected_mind))
		return FALSE
	if(expected_character.created_mind && expected_character.created_mind != expected_mind)
		return FALSE
	if(new_character != expected_body || (mind && mind != expected_mind))
		return FALSE
	if(expected_body)
		if(QDELETED(expected_body) || expected_body.key || expected_body != expected_character.created_body || expected_body.mind != expected_mind || expected_mind.current != expected_body)
			return FALSE
	else if(mind != expected_mind || expected_mind.current != src)
		return FALSE
	if(expected_mind.assigned_role?.type != expected_character.job_type)
		return FALSE
	if(expected_body)
		expected_mind.transfer_to(src)
		QDEL_NULL(new_character)
	var/datum/job/assigned_job = expected_mind.assigned_role
	if(assigned_job && !is_unassigned_job(assigned_job))
		SSjob.free_job_position(assigned_job.title)
	expected_character.rollback_spawn_history()
	expected_mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
	QDEL_NULL(assigned_character)
	ready = PLAYER_NOT_READY
	spawning = FALSE
	return TRUE
