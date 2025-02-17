/datum/round_event
	/// Whether the event called its start() yet or not.
	var/has_started = FALSE
	///have we finished setup?
	var/setup = FALSE
	///Записывать ли событие в лог СТ для вывода в конце раунда?
	var/excute_round_end_reports = FALSE
	///Ивент считается форшеным?
	var/forced = FALSE

/// This section of event processing is in a proc because roundstart events may get their start invoked.
/datum/round_event/proc/try_start()
	if(has_started)
		return
	has_started = TRUE
	processing = FALSE
	start()
	processing = TRUE

/datum/round_event/proc/round_end_report()
	return

/datum/round_event/setup()
	. = ..()
	if(excute_round_end_reports)
		SSgamemode.round_end_data |= src

/datum/round_event/antagonist
	fakeable = FALSE
	end_when = 6000 //This is so prompted picking events have time to run //TODO: refactor events so they can be the masters of themselves, instead of relying on some weirdly timed vars

/datum/round_event/antagonist/solo
	// ALL of those variables are internal. Check the control event to change them
	/// The antag flag passed from control
	var/antag_flag
	/// The antag datum passed from control
	var/antag_datum
	/// The antag count passed from control
	var/antag_count
	/// The restricted roles (jobs) passed from control
	var/list/restricted_roles
	/// The minds we've setup in setup() and need to finalize in start()
	var/list/setup_minds = list()
	/// Whether we prompt the players before picking them.
	var/prompted_picking = FALSE
	/// DO NOT SET THIS MANUALLY, THIS IS INHERITED FROM THE EVENT CONTROLLER ON NEW
	var/list/extra_spawned_events
	/// Similar to extra_spawned_events however these are only used by roundstart events and will only try and run if we have the points to do so
	var/list/preferred_events

/datum/round_event/antagonist/solo/New(my_processing, datum/round_event_control/event_controller)
	. = ..()
	if(istype(event_controller, /datum/round_event_control/antagonist/solo))
		var/datum/round_event_control/antagonist/solo/antag_event_controller = event_controller
		if(antag_event_controller)
			if(antag_event_controller.extra_spawned_events)
				extra_spawned_events = fill_with_ones(antag_event_controller.extra_spawned_events)
			if(antag_event_controller.preferred_events)
				preferred_events = fill_with_ones(antag_event_controller.preferred_events)

/datum/round_event/antagonist/solo/setup()
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = forced && cast_control.forced_antags_count > 0 ? cast_control.forced_antags_count : cast_control.get_antag_count_to_spawn(forced)
	if(!antag_count)
		return

	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/possible_candidates = cast_control.get_candidates()
	var/list/candidates = list()

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in possible_candidates)
		cliented_list += mob.client

	var/list/weighted_candidates = return_antag_weight(possible_candidates)

	var/valid_to_spawn = TRUE
	var/failed_retries = 0
	while(length(weighted_candidates) && length(candidates) < antag_count && valid_to_spawn && failed_retries < STORYTELLER_MAXIMUM_RETRIES) //both of these pick_n_take from weighted_candidates so this should be fine
		if(prompted_picking)
			var/picked_ckey = pick_n_take_weighted(weighted_candidates)
			var/client/picked_client = GLOB.directory[picked_ckey]
			if(QDELETED(picked_client))
				failed_retries++
				continue
			var/mob/picked_mob = picked_client.mob
			log_storyteller("Prompted antag event mob: [picked_mob], special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
			if(picked_mob)
				candidates |= SSpolling.poll_candidates(
					question = "Would you like to be a [cast_control.name]?",
					check_jobban = antag_flag,
					role = antag_flag,
					poll_time = 20 SECONDS,
					group = list(picked_mob),
					alert_pic = antag_datum,
					role_name_text = lowertext(cast_control.name),
					chat_text_border_icon = antag_datum,
				)
		else
			var/picked_ckey = pick_n_take_weighted(weighted_candidates)
			var/client/picked_client = GLOB.directory[picked_ckey]
			if(QDELETED(picked_client))
				continue
			var/mob/picked_mob = picked_client.mob
			picked_mob?.mind?.picking = TRUE
			log_storyteller("Picked antag event mob: [picked_mob], special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
			candidates |= picked_mob


	var/list/picked_mobs = list()
	var/spawned_count = 0
	while(spawned_count < antag_count)
		if(!length(candidates))
			message_admins("A roleset event got fewer antags then its antag_count and may not function correctly.")
			break

		spawned_count++
		if(spawned_count > SSgamemode.get_antag_cap(forced) || spawned_count > SSgamemode.left_antag_count_by_type(cast_control))
			break

		var/mob/candidate = pick_n_take(candidates)
		log_storyteller("Antag event spawned mob: [candidate], special role: [candidate.mind?.special_role ? candidate.mind.special_role : "none"]")

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		setup_minds += candidate.mind
		candidate.mind.special_role = antag_flag
		candidate.mind.restricted_roles = restricted_roles
		picked_mobs += WEAKREF(candidate.client)

	setup = TRUE
	control.generate_image(picked_mobs)
	if(LAZYLEN(extra_spawned_events))
		var/event_type = pick_weight(extra_spawned_events)
		if(!event_type)
			return
		var/datum/round_event_control/triggered_event = locate(event_type) in SSgamemode.control
		//wait a second to avoid any potential omnitraitor bs
		addtimer(CALLBACK(triggered_event, TYPE_PROC_REF(/datum/round_event_control, run_event), FALSE, null, FALSE, "storyteller"), 1 SECONDS)

/datum/round_event/antagonist/solo/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind, antag_mind.current)

/datum/round_event/antagonist/solo/proc/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.add_antag_datum(antag_datum)
	GLOB.pre_setup_antags -= antag_mind

/datum/round_event/antagonist/solo/proc/spawn_extra_events()
	if(!LAZYLEN(extra_spawned_events))
		return
	var/datum/round_event_control/event = pick_weight(extra_spawned_events)
	event?.run_event(random = FALSE, event_cause = "storyteller")

/datum/round_event/antagonist/solo/proc/create_human_mob_copy(turf/create_at, mob/living/carbon/human/old_mob, qdel_old_mob = TRUE)
	if(!old_mob?.client)
		return

	var/mob/living/carbon/human/new_character = new(create_at)
	if(!create_at)
		SSjob.SendToLateJoin(new_character)

	old_mob.client.prefs.safe_transfer_prefs_to(new_character)
	new_character.dna.update_dna_identity()
	old_mob.mind.transfer_to(new_character)
	if(qdel_old_mob)
		qdel(old_mob)
	return new_character

/datum/round_event/antagonist/solo/ghost/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind)

/datum/round_event/antagonist/solo/ghost/setup()
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
		//candidates = SSpolling.poll_ghost_candidates(check_jobban = antag_flag, role = antag_flag, alert_pic = /mob/living/carbon/alien/larva, role_name_text = lowertext(cast_control.name))
		candidates = SSpolling.poll_candidates(
			question = "Would you like to be a [cast_control.name]?",
			check_jobban = antag_flag,
			role = antag_flag,
			poll_time = 20 SECONDS,
			group = candidates,
			alert_pic = antag_datum,
			role_name_text = lowertext(cast_control.name),
			chat_text_border_icon = antag_datum,
		)

	var/list/weighted_candidates = return_antag_weight(candidates)
	var/spawned_count = 0
	while(length(weighted_candidates) && spawned_count < antag_count)
		var/candidate_ckey = pick_n_take_weighted(weighted_candidates)
		var/client/candidate_client = GLOB.directory[candidate_ckey]
		if(QDELETED(candidate_client) || QDELETED(candidate_client.mob))
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
