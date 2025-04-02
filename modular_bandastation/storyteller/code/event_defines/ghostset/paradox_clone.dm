/datum/round_event_control/antagonist/solo/from_ghosts/paradox_clone
	name = "Paradox Clone"
	tags = list(TAG_OUTSIDER_ANTAG, TAG_SPOOKY, TAG_TARGETED)
	typepath = /datum/round_event/antagonist/solo/ghost/paradox_clone
	antag_flag = ROLE_PARADOX_CLONE
	track = EVENT_TRACK_MODERATE
	antag_datum = /datum/antagonist/paradox_clone
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
	)
	maximum_antags = 1
	required_enemies = 2
	weight = 6
	max_occurrences = 2
	prompted_picking = TRUE

/datum/round_event/antagonist/solo/ghost/paradox_clone
	var/list/possible_spawns = list() ///places the antag can spawn
	var/mob/living/carbon/human/clone_victim
	var/mob/living/carbon/human/new_human

/datum/round_event/antagonist/solo/ghost/paradox_clone/setup()
	possible_spawns += find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE)
	if(!possible_spawns.len)
		return

	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = forced && cast_control.forced_antags_count > 0 ? cast_control.forced_antags_count : cast_control.get_antag_count_to_spawn(forced)
	if(!antag_count)
		return

	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client

	if(prompted_picking)
		candidates = SSpolling.poll_ghost_candidates(
			"Would you like to be a paradox clone?",
			check_jobban = ROLE_PARADOX_CLONE,
			poll_time = 20 SECONDS,
			alert_pic = /mob/living/carbon/human,
			role_name_text = "paradox clone",
			chat_text_border_icon = /datum/antagonist/paradox_clone,
		)

	var/list/weighted_candidates = return_antag_weight(candidates)
	var/spawned_count = 0
	var/failed_retries = 0
	while(length(weighted_candidates) && spawned_count < antag_count && failed_retries < STORYTELLER_MAXIMUM_RETRIES)
		var/client/candidate_ckey = pick_n_take_weighted(weighted_candidates)
		var/client/candidate_client = GLOB.directory[candidate_ckey]
		if(QDELETED(candidate_client) || QDELETED(candidate_client.mob))
			failed_retries++
			continue

		spawned_count++
		if(spawned_count > SSgamemode.get_antag_cap(forced) || spawned_count > SSgamemode.left_antag_count_by_type(cast_control))
			break

		var/mob/candidate = candidate_client.mob
		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		clone_victim = find_original()
		new_human = duplicate_object(clone_victim, pick(possible_spawns))
		if(!candidate_ckey)
			continue
		new_human.ckey = candidate_ckey
		new_human.mind.special_role = antag_flag
		new_human.mind.restricted_roles = restricted_roles
		setup_minds += new_human.mind


	setup = TRUE


/datum/round_event/antagonist/solo/ghost/paradox_clone/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/paradox_clone/new_datum = antag_mind.add_antag_datum(/datum/antagonist/paradox_clone)
	new_datum.original_ref = WEAKREF(clone_victim.mind)
	new_datum.setup_clone()
	new /obj/item/storage/toolbox/mechanical(new_human.loc) //so they dont get stuck in maints

	message_admins("[ADMIN_LOOKUPFLW(new_human)] has been made into a Paradox Clone by the midround ruleset.")
	new_human.log_message("was spawned as a Paradox Clone of [key_name(new_human)] by the midround ruleset.", LOG_GAME)
	GLOB.pre_setup_antags -= antag_mind


/**
 * Trims through GLOB.player_list and finds a target
 * Returns a single human victim, if none is possible then returns null.
 */
/datum/round_event/antagonist/solo/ghost/paradox_clone/proc/find_original()
	var/list/possible_targets = list()

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		possible_targets += player

	if(possible_targets.len)
		return pick(possible_targets)
	return FALSE
