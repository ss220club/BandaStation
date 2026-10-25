/datum/round_event_control/shadow_demon
	name = "Shadow Demon"
	typepath = /datum/round_event/ghost_role/shadow_demon
	weight = 0
	// Native weight zero can still be selected; this role is available only when forced.
	max_occurrences = 0
	category = EVENT_CATEGORY_INVASION
	description = "Призрак становится тенедемоном в тёмном техническом помещении."

/datum/round_event/ghost_role/shadow_demon
	role_name = "тенедемон"

/datum/round_event/ghost_role/shadow_demon/spawn_role()
	if(isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE)))
		return MAP_ERROR
	var/mob/dead/observer/chosen_one = SSpolling.poll_ghost_candidates(
		question = "Хотите стать тенедемоном?",
		check_jobban = ROLE_SENTIENCE,
		role = ROLE_SENTIENCE,
		alert_pic = /mob/living/basic/demon/shadow,
		role_name_text = role_name,
		amount_to_pick = 1,
	)
	if(!isobserver(chosen_one) || !chosen_one.client || !chosen_one.key)
		return NOT_ENOUGH_PLAYERS
	if(is_banned_from(chosen_one.ckey, list(ROLE_SYNDICATE, ROLE_SENTIENCE)))
		return NOT_ENOUGH_PLAYERS
	// Polling yields: both the candidate and the darkness must still be valid.
	var/turf/spawn_turf = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE)
	if(isnull(spawn_turf))
		return MAP_ERROR
	var/mob/living/basic/demon/shadow/demon = new(spawn_turf)
	var/datum/mind/new_mind = new(chosen_one.key)
	new_mind.transfer_to(demon, force_key_move = TRUE)
	if(!new_mind.has_antag_datum(/datum/antagonist/shadow_demon))
		new_mind.add_antag_datum(/datum/antagonist/shadow_demon)
	message_admins("[ADMIN_LOOKUPFLW(demon)] has been made into a shadow demon by an event.")
	demon.log_message("was spawned as a shadow demon by an event.", LOG_GAME)
	spawned_mobs += demon
	return SUCCESSFUL_SPAWN
