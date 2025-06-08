/// Number of top experienced candidates to consider for ERT leadership selection
#define ERT_EXPERIENCED_LEADER_CHOOSE_TOP 3

/datum/emergency_call
	/// Name for admin
	var/name = "Blame coderbus"
	/// Team datum type for the ERT
	var/team = /datum/team/ert
	/// Antag role for the team leader
	var/leader_role = /datum/antagonist/ert/commander
	/// List of non-leader antag roles
	var/roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer)
	/// Custom team name for antag/roundend reporting
	var/rename_team = "Blame coderbus"
	/// Ghost poll description text
	var/polldesc = "Blame coderbus"
	/// Team mission objective (friendly mode)
	var/mission = "Окажите помощь станции."
	/// Team mission objective (hostile mode)
	var/hostile_mission = "Сейте хаос."
	/// Initial dispatch announcement message
	var/dispatch_message = "С ближайшего судна получен зашифрованный сигнал. Ожидайте."
	/// Arrival announcement message
	var/arrival_message = ""
	/// Chance for arrival message to be scrambled (0-100)
	var/chance_hidden = 20
	/// Maximum number of team members
	var/mob_max = 5
	/// Minimum candidates required to activate
	var/mob_min = 1
	/// Whether to generate random last names for team members
	var/random_names = TRUE
	/// Prioritize experienced players for leader role
	var/leader_experience = TRUE
	/// Shuttle template ID for deployment
	var/shuttle_id = "tsf_patrol"
	/// Lazy template ID for ERT base (null for no base)
	var/base_template = null
	/// Mob type for team members (default - human)
	var/mob_type
	/// Activation weight relative to other ERT types
	var/weight = 0
	/// Custom ghost poll image (uses leader preview if null)
	var/alert_pic = null
	/// Hostility chance percentage (0-100)
	var/hostility = 0
	/// Reserved turf area for ERT base
	var/datum/turf_reservation/base
	/// Shuttle docking port reference
	var/obj/docking_port/mobile/shuttle

/proc/test_distress()
	SSemergency_call.activate_random_emergency_call()

/proc/test_distress_pick()
	var/pick = tgui_input_list(usr, "Pick distress", "title", SSemergency_call.emergency_calls)
	if(!pick)
		return
	SSemergency_call.activate(pick)

/datum/emergency_call/New()
	if(prob(hostility))
		hostility = TRUE

/datum/emergency_call/Destroy()
	base = null
	shuttle = null
	. = ..()

/**
 * Activate emergency call
 *
 * Main proc for starting ERT deployment
 * Arguments:
 * * announce_launch - Whether to send station launch announcement
 * * announce_incoming - Whether to send arrival announcement
 * Returns: TRUE on success, FALSE on failure
 */
/datum/emergency_call/proc/activate(announce_launch = TRUE, announce_incoming = TRUE)
	if(announce_launch)
		priority_announce("С борта [station_name()] был запущен маяк бедствия.", "Приоритетное оповещение")

	message_admins("Emergency call: '[name]' activated [hostility? "[span_warning("(THEY ARE HOSTILE)")]":"(they are friendly)"]. Looking for candidates.")
	var/list/candidates = SSpolling.poll_ghost_candidates(
														"Do you wish to be considered for a [rename_team]",
														check_jobban = FALSE,
														poll_time = 5 SECONDS, // MIRA for tests
														alert_pic = alert_pic ? alert_pic : create_leader_preview(),
														role_name_text = rename_team
														)

	if(length(candidates) < mob_min)
		message_admins("Tried to start emergency call but didn't find enough candidates.")

		if(announce_launch)
			priority_announce("Сигнал бедствия не получил ответа, ретранслятор проходит повторную калибровку.", "Сигнал бедствия")

		return FALSE

	// create base
	if(base_template)
		base = SSmapping.lazy_load_template(base_template)
		if(!base)
			stack_trace("Failed to load lazy template for emergency call base!")

	// create shuttle
	var/list/shuttle_turfs = create_shuttle(shuttle_id)

	// ensure shuttle can fly to base
	allow_shuttle_fly_to_base()

	// find spawn turfs in shuttle
	var/list/spawn_turfs = find_spawn_turfs(shuttle_turfs)

	// antag team
	var/datum/team/ert/ert_team = create_antag_team()

	if(announce_launch)
		priority_announce(dispatch_message, "Сигнал бедствия")

	// finalize
	pick_and_spawn_candidates(candidates, spawn_turfs, ert_team)

	if(arrival_message && announce_incoming)
		if(prob(chance_hidden))
			priority_announce(scramble_message_replace_chars(arrival_message, replaceprob = 60), "Перехваченная радиопередача:")
		else
			priority_announce(arrival_message, "Перехваченная радиопередача:")

	return TRUE

/**
 * Create ERT shuttle
 *
 * Loads and positions the shuttle template
 * Arguments:
 * * shuttle_id - Template ID from SSmapping.shuttle_templates
 * Returns: List of affected turfs in shuttle
 */
/datum/emergency_call/proc/create_shuttle(shuttle_id)
	var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]

	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - template.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - template.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/located_turf = locate(x,y,z)

	if(!located_turf)
		CRASH("Failed to locate turf for emergency call shuttle")

	if(!template.load(located_turf))
		CRASH("Failed to load shuttle for emergency call!")

	var/list/shuttle_turfs = template.get_affected_turfs(located_turf)

	// MIRA this is sooooo bad
	for(var/turf/affected_turf as anything in shuttle_turfs)
		for(var/obj/machinery/computer/shuttle/shuttle_computer in affected_turf)
			shuttle_id = shuttle_computer.shuttleId
			break // should be only one, but in case

	shuttle = SSshuttle.getShuttle(shuttle_id)
	shuttle.destination = null
	shuttle.mode = SHUTTLE_IGNITING
	shuttle.setTimer(shuttle.ignitionTime)

	return shuttle_turfs

/**
 * Find valid spawn locations in shuttle
 *
 * Arguments:
 * * shuttle_turfs - List of turfs in the spawned shuttle
 * Returns: List of safe spawn locations
 */
/datum/emergency_call/proc/find_spawn_turfs(list/shuttle_turfs)
	var/list/spawn_turfs = list()
	for(var/turf/affected_turf as anything in shuttle_turfs)
		for(var/obj/effect/landmark/ert_shuttle_spawn/spawner in affected_turf)
			spawn_turfs += get_turf(spawner)

		if(!length(spawn_turfs))
			stack_trace("ERT shuttle loaded but found no spawn points, placing the ERT at wherever inside the shuttle instead.")

		for(var/turf/open/floor/open_turf in shuttle_turfs)
			if(!is_safe_turf(open_turf))
				continue
			spawn_turfs += open_turf

	return spawn_turfs

/**
 * Create antagonist team datum
 *
 * Generates team objectives based on hostility status
 * Returns: New /datum/team/ert
 */
/datum/emergency_call/proc/create_antag_team()
	var/datum/team/ert/ert_team = new team()
	if(rename_team)
		ert_team.name = rename_team

	//Assign team objective
	var/datum/objective/missionobj = new ()
	missionobj.team = ert_team
	missionobj.explanation_text = hostility ? hostile_mission : mission
	missionobj.completed = TRUE
	ert_team.objectives += missionobj
	ert_team.mission = missionobj

	return ert_team

/**
 * Select and spawn candidates
 *
 * Handles player selection and mob creation
 * Arguments:
 * * candidates - List of ghost candidates
 * * spawn_turfs - List of valid spawn locations
 * * ert_team - Team datum for antag assignment
 */
/datum/emergency_call/proc/pick_and_spawn_candidates(list/candidates, list/spawn_turfs, datum/team/ert/ert_team)
	var/numagents = min(mob_max, length(candidates))

	var/mob/dead/observer/leader
	var/leader_spawned = FALSE // just in case the earmarked leader disconnects or becomes unavailable, we can try giving leader to the last guy to get chosen

	var/list/candidate_living_exps = list()
	for(var/i in candidates)
		var/mob/dead/observer/potential_leader = i
		candidate_living_exps[potential_leader] = potential_leader.client?.get_exp_living(TRUE)

	candidate_living_exps = sort_list(candidate_living_exps, cmp=/proc/cmp_numeric_dsc)
	if(candidate_living_exps.len > ERT_EXPERIENCED_LEADER_CHOOSE_TOP)
		candidate_living_exps.Cut(ERT_EXPERIENCED_LEADER_CHOOSE_TOP+1) // pick from the top ERT_EXPERIENCED_LEADER_CHOOSE_TOP contenders in playtime
	leader = pick(candidate_living_exps)

	while(numagents && candidates.len)
		var/turf/spawnloc = pick(spawn_turfs)
		var/mob/dead/observer/chosen_candidate = leader || pick(candidates) // this way we make sure that our leader gets chosen
		candidates -= chosen_candidate

		//Spawn the body
		var/mob/living/carbon/human/ert_operative
		if(mob_type)
			ert_operative = new mob_type(spawnloc)
		else
			ert_operative = new /mob/living/carbon/human(spawnloc)
			chosen_candidate.client.prefs.safe_transfer_prefs_to(ert_operative, is_antag = TRUE)
		ert_operative.PossessByPlayer(chosen_candidate.key)

		//Give antag datum
		var/datum/antagonist/ert/ert_antag

		if((chosen_candidate == leader) || (numagents == 1 && !leader_spawned))
			ert_antag = new leader_role ()
			leader = null
			leader_spawned = TRUE
		else
			ert_antag = roles[WRAP(numagents,1,length(roles) + 1)]
			ert_antag = new ert_antag ()
		ert_antag.random_names = random_names

		ert_operative.mind.add_antag_datum(ert_antag,ert_team)
		ert_operative.mind.set_assigned_role(SSjob.get_job_type(ert_antag.ert_job_path))

		//Logging and cleanup
		ert_operative.log_message("has been selected as \a [ert_antag.name].", LOG_GAME)
		numagents--

/**
 * Configure shuttle navigation
 *
 * Adds ERT base destination to shuttle computer
 */
/datum/emergency_call/proc/allow_shuttle_fly_to_base()
	if(!base || !shuttle)
		return

	var/list/destinations = list()
	for(var/turf/turf as anything in base.reserved_turfs)
		for(var/obj/docking_port/stationary/dock in turf)
			destinations |= dock.shuttle_id

	var/obj/machinery/computer/shuttle/shuttle_computer = shuttle.get_control_console()
	var/list/current_destinations = splittext(shuttle_computer.possible_destinations, ";")
	current_destinations |= destinations
	shuttle_computer.possible_destinations = current_destinations.Join(";")

/**
 * Generate leader preview image
 *
 * Creates appearance for ghost poll
 * Returns: /image of leader outfit
 */
/datum/emergency_call/proc/create_leader_preview()
	var/datum/antagonist/ert/preview = leader_role
	return image(get_dynamic_human_appearance(preview.outfit, r_hand = NO_REPLACE, l_hand = NO_REPLACE))

#undef ERT_EXPERIENCED_LEADER_CHOOSE_TOP
