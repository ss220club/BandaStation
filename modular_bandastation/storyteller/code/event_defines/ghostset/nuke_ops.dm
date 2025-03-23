/datum/round_event_control/antagonist/solo/from_ghosts/nuclear_operative
	name = "Nuclear Assault"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_OPERATIVE_MIDROUND
	antag_datum = /datum/antagonist/nukeop
	typepath = /datum/round_event/antagonist/solo/ghost/nuclear_operative
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	base_antags = 3
	maximum_antags = 4
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_enemies = 5
	// I give up, just there should be enough heads with 35 players...
	min_players = 35
	earliest_start = 45 MINUTES
	weight = 4
	max_occurrences = 1
	prompted_picking = TRUE
	can_change_count = TRUE

/datum/round_event/antagonist/solo/ghost/nuclear_operative
	excute_round_end_reports = TRUE
	end_when = 60000 /// we will end on our own when revs win
	var/static/datum/team/nuclear/nuke_team
	var/set_leader = FALSE
	var/required_role = ROLE_NUCLEAR_OPERATIVE
	var/job_type = /datum/job/nuclear_operative

/datum/round_event/antagonist/solo/ghost/nuclear_operative/add_datum_to_mind(datum/mind/antag_mind)
	var/mob/living/current_mob = antag_mind.current
	var/list/items = current_mob.get_equipped_items(TRUE)
	current_mob.unequip_everything()
	for(var/obj/item/item as anything in items)
		qdel(item)

	var/datum/mind/most_experienced = get_most_experienced(setup_minds, required_role)
	antag_mind.set_assigned_role(SSjob.get_job_type(/datum/job/nuclear_operative))
	antag_mind.special_role = ROLE_NUCLEAR_OPERATIVE

	if(!most_experienced)
		most_experienced = antag_mind

	if(!set_leader)
		set_leader = TRUE
		var/datum/antagonist/nukeop/leader/leader_antag_datum = new()
		nuke_team = leader_antag_datum.nuke_team
		most_experienced.add_antag_datum(leader_antag_datum)

	if(antag_mind == most_experienced)
		return

	var/datum/antagonist/nukeop/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)

//this might be able to be kept as just calling parent
/datum/round_event/antagonist/solo/ghost/nuclear_operative/round_end_report()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/round_event/antagonist/solo/ghost/nuclear_operative/setup()
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = forced && cast_control.forced_antags_count > 0 ? cast_control.forced_antags_count : cast_control.get_antag_count_to_spawn(forced)
	if(!antag_count)
		return

	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client

	if(prompted_picking)
		candidates = SSpolling.poll_ghost_candidates(check_jobban = antag_flag, role = antag_flag, alert_pic = /obj/structure/sign/poster/contraband/syndicate_recruitment, role_name_text = lowertext(cast_control.name))

	var/list/weighted_candidates = return_antag_weight(candidates)
	var/spawned_count = 0
	var/failed_retries = 0
	while(length(weighted_candidates) && spawned_count < antag_count && failed_retries < STORYTELLER_MAXIMUM_RETRIES)
		var/candidate_ckey = pick_n_take_weighted(weighted_candidates)
		var/client/candidate_client = GLOB.directory[candidate_ckey]
		if(QDELETED(candidate_client) || QDELETED(candidate_client.mob))
			failed_retries++
			continue
		var/mob/candidate = candidate_client.mob

		spawned_count++
		if(spawned_count > SSgamemode.get_antag_cap(forced) || spawned_count > SSgamemode.left_antag_count_by_type(cast_control))
			break

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)
		var/mob/living/carbon/human/new_human = make_body(candidate)
		new_human.mind.special_role = antag_flag
		new_human.mind.restricted_roles = restricted_roles
		setup_minds += new_human.mind

	setup = TRUE
