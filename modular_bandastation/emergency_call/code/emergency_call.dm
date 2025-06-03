#define ERT_EXPERIENCED_LEADER_CHOOSE_TOP 3

GLOBAL_LIST_INIT_TYPED(emergency_call_weighted_list, /list/datum/emergency_call, generate_emergency_call_weighted_list())

/proc/generate_emergency_call_weighted_list()
	var/list/weighted_list = list()

	for(var/datum/emergency_call/emergency_call_type as anything in typesof(/datum/emergency_call))
		var/weight = emergency_call_type.weight
		if(weight <= 0)
			continue

		LAZYSET(weighted_list, emergency_call_type, weight)

	return weighted_list

/datum/emergency_call
	// name for admins
	var/name = "Blame coderbus name"
	// antag datum
	var/team = /datum/team/ert
	///Alternate antag datum given to the leader of the squad.
	var/leader_role = /datum/antagonist/ert/commander
	///A list of roles distributed to the selected candidates that are not the leader.
	var/roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer)
	///The custom name assigned to this team, for their antag datum/roundend reporting.
	var/rename_team = "Blame coderbus"
	///The "would you like to play as XXX" message used when polling for players.
	var/polldesc = "Blame coderbus"
	///The mission given to this ERT type in their flavor text.
	var/mission = "Assist the station."
	///The mission given to this ERT type if they are hostile.
	///
	var/hostile_mission = "Wreak chaos."
	///
	var/dispatch_message = "С ближайшего судна получен зашифрованный сигнал. Ожидайте."
	///
	var/arrival_message = ""
	///
	var/chance_hidden = 20
	///The max number of players
	var/mob_max = 5
	// min candidates to activate
	var/mob_min = 0
	/// If TRUE, gives the team members "[role] [random last name]" style names
	var/random_names = TRUE
	/// If TRUE, we try and pick one of the most experienced players who volunteered to fill the leader slot
	var/leader_experience = TRUE
	/// A shuttle map template to spawn the ERT at. Must present
	var/shuttle_id = "tsf_patrol"
	/// if null or false - no base
	var/base_template = "generic_ert_base"
	/// Used for spawning bodies for your ERT. Unless customized in the Summon-ERT verb settings, will be overridden and should not be defined at the datum level.
	var/mob_type
	// chance to roll
	var/weight = 0
	// obj to show in ghost poll, or will show leader dummy if null or false
	var/alert_pic = null
	// chance to be hostile from 0 to 100
	var/hostility = 0

/proc/test_distress()
	SSemergency_call.activate()

/datum/emergency_call/New()
	if(prob(hostility))
		hostility = TRUE

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

	// create shuttle
	var/list/shuttle_turfs = create_shuttle(shuttle_id)

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

	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(shuttle_id)
	port.destination = null
	port.mode = SHUTTLE_IGNITING
	port.setTimer(port.ignitionTime)

	return shuttle_turfs

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

/datum/emergency_call/proc/create_leader_preview()
	var/datum/antagonist/ert/preview = leader_role
	var/mob/living/carbon/human/dummy = new /mob/living/carbon/human/dummy/consistent
	dummy.equipOutfit(preview.outfit, visuals_only = TRUE)
	dummy.wear_suit?.update_greyscale()
	alert_pic = dummy
	QDEL_IN(dummy, 1 SECONDS)
	return dummy

#undef ERT_EXPERIENCED_LEADER_CHOOSE_TOP
