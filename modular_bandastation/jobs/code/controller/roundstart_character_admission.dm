/// Ownership of one native roundstart construction and its joined-list append.
/datum/roundstart_character_attempt
	var/datum/job_character_selection/selection
	var/datum/mind/mind
	var/mob/living/previous_body
	var/player_ckey
	var/list/joined_players
	var/joined_index

/datum/controller/subsystem/ticker/proc/capture_roundstart_character(mob/dead/new_player/player)
	SHOULD_NOT_SLEEP(TRUE)
	var/datum/roundstart_character_attempt/attempt = new
	if(!player.assigned_character && player.mind?.assigned_role && GET_CLIENT(player))
		player.resolve_assigned_job_character(player.mind.assigned_role)
	attempt.selection = player.assigned_character
	attempt.mind = player.mind
	attempt.previous_body = player.new_character
	attempt.player_ckey = player.ckey
	attempt.joined_players = GLOB.joined_player_list
	attempt.joined_index = length(attempt.joined_players) + 1
	return attempt

/datum/roundstart_character_attempt/proc/rollback_joined_player()
	if(joined_index <= length(joined_players) && joined_players[joined_index] == player_ckey)
		joined_players.Cut(joined_index, joined_index + 1)

/datum/roundstart_character_attempt/proc/owns_assignment(mob/dead/new_player/player, mob/living/character)
	return !QDELETED(player) && !QDELETED(mind) && !QDELETED(selection) && player.assigned_character == selection && (player.mind || character?.mind) == mind

/datum/roundstart_character_attempt/proc/owns_body(mob/dead/new_player/player, mob/living/character)
	return !QDELETED(character) && character != previous_body && selection?.created_body == character && character.mind == mind && player?.new_character == character

/// Runs immediately after the native constructor, before collect/equip/handover.
/datum/controller/subsystem/ticker/proc/validate_roundstart_character(mob/dead/new_player/player, mob/living/character, datum/roundstart_character_attempt/attempt)
	var/cancelled = FALSE
	if(attempt.owns_assignment(player, character) && attempt.owns_body(player, character))
		cancelled = SEND_SIGNAL(attempt.mind, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, character) & COMPONENT_CANCEL_CHARACTER_SPAWN
	// Signal listeners can replace or cancel the attempt; re-read ownership before any effect.
	var/owns_assignment = attempt.owns_assignment(player, character)
	var/owns_body = attempt.owns_body(player, character)
	if(owns_assignment && owns_body && !cancelled)
		qdel(attempt)
		return TRUE
	if(owns_assignment)
		SSdynamic.cancel_roundstart_assignment(attempt.mind)
		player.cancel_character_spawn(attempt.selection, attempt.mind, owns_body ? character : null)
	attempt.rollback_joined_player()
	qdel(attempt)
	return FALSE
