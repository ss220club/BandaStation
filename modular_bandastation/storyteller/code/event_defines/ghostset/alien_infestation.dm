/datum/round_event_control/antagonist/solo/from_ghosts/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/antagonist/solo/ghost/alien_infestation
	weight = 3
	track = EVENT_TRACK_MAJOR

	min_players = 15

	earliest_start = 60 MINUTES

	category = EVENT_CATEGORY_ENTITIES
	description = "A xenomorph larva spawns on a random vent."

	maximum_antags = 1
	antag_flag = ROLE_ALIEN
	enemy_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_enemies = 3
	prompted_picking = TRUE

/datum/round_event/antagonist/solo/ghost/alien_infestation
	announce_when = 400
	fakeable = TRUE

/datum/round_event/antagonist/solo/ghost/alien_infestation/setup()
	announce_when = rand(announce_when, announce_when + 50)
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = forced && cast_control.forced_antags_count > 0 ? cast_control.forced_antags_count : cast_control.get_antag_count_to_spawn(forced)
	if(!antag_count)
		return

	if(prob(50))
		antag_count++

	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client

	candidates = SSpolling.poll_ghost_candidates(check_jobban = antag_flag, role = antag_flag, alert_pic = /mob/living/carbon/alien/larva, role_name_text = lowertext(cast_control.name))

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent

	if(!length(vents))
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return MAP_ERROR

	var/list/weighted_candidates = return_antag_weight(candidates)
	var/spawned_count = 0
	var/failed_retries = 0
	while(length(weighted_candidates) && spawned_count < antag_count && failed_retries <= STORYTELLER_MAXIMUM_RETRIES)
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

		var/obj/vent = pick_n_take(vents)
		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.ckey = candidate_ckey
		new_xeno.move_into_vent(vent)


		message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by an event.")
		new_xeno.log_message("was spawned as an alien by an event.", LOG_GAME)

	setup = TRUE

/datum/round_event/antagonist/solo/ghost/alien_infestation/announce(fake)
	var/living_aliens = FALSE
	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			living_aliens = TRUE

	if(living_aliens || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)
