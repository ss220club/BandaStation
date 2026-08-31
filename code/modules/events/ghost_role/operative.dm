/datum/round_event_control/operative
	name = "Lone Operative"
	typepath = /datum/round_event/ghost_role/operative
	weight = 0 //its weight is relative to how much stationary and neglected the nuke disk is. See nuclearbomb.dm. Shouldn't be dynamic hijackable.
	max_occurrences = 1
	category = EVENT_CATEGORY_INVASION
	description = "A single nuclear operative assaults the station."

/datum/round_event_control/operative/can_spawn_event(players_amt, allow_magic)
	return ..() && SSdynamic.antag_events_enabled

/datum/round_event/ghost_role/operative
	minimum_required = 1
	role_name = "lone operative"
	fakeable = FALSE

/datum/round_event/ghost_role/operative/spawn_role()
	// BANDASTATION EDIT START - Weighted candidate selection
	var/mob/chosen_one
	var/list/mob/valid_candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_OPERATIVE, role = ROLE_LONE_OPERATIVE, alert_pic = /obj/machinery/nuclearbomb)

	// Build weighted list of candidates
	var/list/mob/weighted_candidates = list()
	for(var/mob/candidate as anything in valid_candidates)
		var/client/candidate_client = GET_CLIENT(candidate)
		if(!candidate_client)
			continue
		var/weight = get_candidate_weight(candidate_client.ckey)
		weighted_candidates[candidate] = weight

	if(!length(weighted_candidates))
		return NOT_ENOUGH_PLAYERS

	// Test mode preserves the old random selection before rolling the virtual weighted result.
	chosen_one = pick(valid_candidates)
	var/mob/hypothetical_weighted_result = pick_antag_test_weight(weighted_candidates)
	log_antag_test_selection(role_name, "midround", 1, valid_candidates, weighted_candidates, list(chosen_one), hypothetical_weighted_result ? list(hypothetical_weighted_result) : list())
	for(var/mob/dead/observer/poll_recipient as anything in GLOB.player_list)
		to_chat(poll_recipient, span_ooc("[FOLLOW_LINK(poll_recipient, chosen_one.client.mob)][span_warning(" [full_capitalize(ROLE_LONE_OPERATIVE)] Poll: ")][key_name(chosen_one.client, include_name = FALSE)] was selected."))
	// BANDASTATION EDIT END
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS
	var/spawn_location = find_space_spawn()
	if(isnull(spawn_location))
		return MAP_ERROR
	var/mob/living/carbon/human/operative = new(spawn_location)
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()
	var/datum/mind/Mind = new /datum/mind(chosen_one.key)
	Mind.set_assigned_role(SSjob.get_job_type(/datum/job/lone_operative))
	Mind.active = TRUE
	Mind.transfer_to(operative)
	if(!operative.client?.prefs.read_preference(/datum/preference/toggle/nuke_ops_species))
		var/species_type = operative.client.prefs.read_preference(/datum/preference/choiced/species)
		operative.set_species(species_type) //Apply the preferred species to our freshly-made body.

	Mind.add_antag_datum(/datum/antagonist/nukeop/lone)

	message_admins("[ADMIN_LOOKUPFLW(operative)] has been made into lone operative by an event.")
	operative.log_message("was spawned as a lone operative by an event.", LOG_GAME)
	spawned_mobs += operative
	return SUCCESSFUL_SPAWN
