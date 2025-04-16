/datum/round_event_control
	/// The typepath to the event group this event is a part of.
	var/datum/event_group/event_group = null
	var/roundstart = FALSE
	var/cost = 1
	var/reoccurence_penalty_multiplier = 0.75
	var/shared_occurence_type
	var/track = EVENT_TRACK_MODERATE
	/// Last calculated weight that the storyteller assigned this event
	var/calculated_weight = 0
	var/calculated_on_track_weight = 0
	var/tags = list() 	/// Tags of the event
	/// List of the shared occurence types.
	var/static/list/shared_occurences = list()
	/// Whether a roundstart event can happen post roundstart. Very important for events which override job assignments.
	var/can_run_post_roundstart = TRUE
	/// If set then the type or list of types of storytellers we are restricted to being trigged by
	var/list/allowed_storytellers
	///do we check against the antag cap before attempting a spawn?
	var/checks_antag_cap = FALSE
	/// List of enemy roles, will check if x amount of these exist exist
	var/list/enemy_roles
	///required number of enemies in roles to exist
	var/required_enemies = 0
	///required power of department to start event
	var/list/req_departments_crew = list()
	var/list/req_departments_power = list()
	/// Является ли событие эксклюзивным (не допускающим другие) в случае раундстарта
	var/exclusive_roundstart_event = FALSE
	/// Значение, которое используется при расчете стоимости покупки из раундстарт бюджета. Считается если значение 0.
	var/roundstart_cost = 0

/datum/round_event_control/proc/get_pre_cost()
	return roundstart_cost

/datum/round_event_control/proc/return_failure_string(players_amt)
	var/string
	if(SSgamemode.current_storyteller?.disable_distribution || SSgamemode.halted_storyteller)
		string += "Storyteller halted"
	if(event_group && !GLOB.event_groups[event_group].can_run())
		if(string)
			string += ","
		string += "Group runing"
	if(roundstart && (!SSgamemode.can_run_roundstart))
		if(string)
			string += ","
		string += "Roundstart only"
	if(!roundstart && (SSgamemode.can_run_roundstart))
		if(string)
			string += ","
		string += "Not roundstart"
	// BANDASTATION EDIT END - STORYTELLER
	if(occurrences >= max_occurrences)
		if(string)
			string += ","
		string += "Cap Reached"
	if(earliest_start >= (world.time - SSticker.round_start_time))
		if(string)
			string += ","
		string +="Too Soon"
	if(players_amt < min_players)
		if(string)
			string += ","
		string += "Lack of players"
	if(holidayID && !check_holidays(holidayID))
		if(string)
			string += ","
		string += "Holiday Event"
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		if(string)
			string += ","
		string += "Round End"
	if(ispath(typepath, /datum/round_event/ghost_role) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		if(string)
			string += ","
		string += "No ghost candidates"
	if(checks_antag_cap && !SSgamemode.can_inject_antags())
		if(string)
			string += ","
		string += "Too Many Antags"
	if(allowed_storytellers && SSgamemode.current_storyteller && ((islist(allowed_storytellers) && !is_type_in_list(SSgamemode.current_storyteller, allowed_storytellers)) || SSgamemode.current_storyteller.type != allowed_storytellers))
		if(string)
			string += ","
		string += "Wrong Storyteller"
	if(!SSgamemode.check_event_power(src))
		if(string)
			string += ","
		var/departs
		for(var/depart in req_departments_power)
			if(departs)
				departs += ", "
			departs += depart
		string += "Too low department power ([departs])"
	if(!weight)
		if(string)
			string += ","
		string += "Can't be selected"
	if (dynamic_should_hijack && SSdynamic.random_event_hijacked != HIJACKED_NOTHING)
		if(string)
			string += ","
		string += "Hijack mission"
	if (type in SSgamemode.current_storyteller.exclude_events)
		if(string)
			string += ","
		string += "Disabled by choosen storyteller"
	return string

/datum/round_event_control/antagonist/return_failure_string(players_amt)
	. =..()
	if(!check_enemies())
		if(.)
			. += ", "
		. += "No Enemies"
	if(!check_required())
		if(.)
			. += ", "
		. += "No Required"
	return .

/datum/round_event_control/roundstart
	roundstart = TRUE
	earliest_start = 0

/datum/round_event_control/antagonist
	checks_antag_cap = TRUE
	track = EVENT_TRACK_ROLESET
	///list of required roles, needed for this to form
	var/list/exclusive_roles
	/// Protected roles from the antag roll. People will not get those roles if a config is enabled
	var/list/protected_roles
	/// Restricted roles from the antag roll
	var/list/restricted_roles
	var/event_icon_state
	//The number of forced antags to spawn with the event if it forced
	var/forced_antags_count = 0
	var/can_change_count = FALSE

/datum/round_event_control/antagonist/solo
	typepath = /datum/round_event/antagonist/solo
	/// How many baseline antags do we spawn
	var/base_antags = 1
	/// How many maximum antags can we spawn
	var/maximum_antags = 3
	var/maximum_antags_per_round = 10
	/// For this many players we'll add 1 up to the maximum antag amount
	var/denominator = 20
	/// The antag flag to be used
	var/antag_flag
	/// The antag datum to be applied
	var/antag_datum
	/// Prompt players for consent to turn them into antags before doing so. Dont allow this for roundstart.
	var/prompted_picking = FALSE
	/// A list of extra events to force whenever this one is chosen by the storyteller.
	/// Can either be normal list or a weighted list.
	var/list/extra_spawned_events
	/// Similar to extra_spawned_events however these are only used by roundstart events and will only try and run if we have the points to do so
	var/list/preferred_events

	var/price_to_buy_adds = 20

/datum/round_event_control/antagonist/solo/return_failure_string(players_amt)
	. =..()
	var/list/candidates = get_candidates() //we should optimize this
	var/ghost_event = ispath(typepath, /datum/round_event/antagonist/solo/ghost) || ispath(typepath, /datum/round_event/ghost_role)
	if((length(candidates) < base_antags))
		if(.)
			. += ", "
		. += get_antag_count_to_spawn() ? "Not Enough [ghost_event ? "ghost" : ""] candidates!" : "No empty antag-slots"

	return .

/datum/round_event_control/proc/generate_image(list/mobs)
	return

/* Для титров
/datum/round_event_control/antagonist/generate_image(list/mobs)
	SScredits.generate_major_icon(mobs, event_icon_state)
*/

/// Check if our enemy_roles requirement is met, if return_players is set then we will return the list of enemy players instead
/datum/round_event_control/proc/check_enemies(return_players = FALSE)
	if(!length(enemy_roles))
		return return_players ? list() : TRUE

	var/job_check = 0
	var/list/enemy_players = list()
	if(roundstart)
		for(var/enemy in enemy_roles)
			var/datum/job/enemy_job = SSjob.get_job(enemy)
			if(enemy_job && SSjob.assigned_players_by_job[enemy_job.type])
				job_check += length(SSjob.assigned_players_by_job[enemy_job.type])
				enemy_players += SSjob.assigned_players_by_job[enemy_job.type]

	else
		for(var/mob/M in GLOB.alive_player_list)
			if (M.stat == DEAD)
				continue // Dead players cannot count as opponents
			if (M.mind && (M.mind.assigned_role.title in enemy_roles))
				job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that
				enemy_players += M

	if(job_check >= required_enemies)
		return return_players ? enemy_players : TRUE
	return return_players ? enemy_players : FALSE

/datum/round_event_control/antagonist/New()
	. = ..()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_roles |= protected_roles

/datum/round_event_control/antagonist/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!check_required())
		return FALSE

	if(!.)
		return

/datum/round_event_control/antagonist/proc/check_required()
	if(!length(exclusive_roles))
		return TRUE
	for (var/mob/M in GLOB.alive_player_list)
		if (M.stat == DEAD)
			continue // Dead players cannot count as passing requirements
		if(M.mind && (M.mind.assigned_role.title in exclusive_roles))
			return TRUE

/datum/round_event_control/antagonist/proc/trim_candidates(list/candidates)
	if(!roundstart)
		for(var/mob/candidate in candidates)
			//Если событие призраков, то проверить. что кандидат - призрак
			if((ispath(typepath, /datum/round_event/ghost_role) || ispath(typepath, /datum/round_event/antagonist/solo/ghost/))  && candidate.stat != DEAD)
				candidates -= candidate
			//Если событие живых, то проверить. что кандидат - жив или без сознания (не мертв, не в софт крите и не в хард крите)
			if(!(ispath(typepath, /datum/round_event/ghost_role) || ispath(typepath, /datum/round_event/antagonist/solo/ghost/)) && !(candidate.stat == CONSCIOUS || candidate.stat == UNCONSCIOUS))
				candidates -= candidate
	return candidates

/datum/round_event_control/antagonist/solo/from_ghosts/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, observers = TRUE, midround_antag_pref = midround_antag_pref_arg, restricted_roles = restricted_roles)
	candidates = trim_candidates(candidates)
	return candidates

/datum/round_event_control/antagonist/solo/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return
	var/antag_amt = get_antag_count_to_spawn()
	var/list/candidates = get_candidates()
	if((length(candidates) < antag_amt) || !antag_amt)
		return FALSE

/datum/round_event_control/antagonist/solo/proc/get_antag_count_to_spawn(forced_event = FALSE)
	var/decided_count = rand(base_antags, maximum_antags)
	var/current_cap = SSgamemode.get_antag_cap(forced_event)
	var/gamemode_antags_left = current_cap - SSgamemode.get_antag_count()
	var/maximum_to_spawn_on_calculation = min(gamemode_antags_left, maximum_antags)
	var/maximum_to_spawn_on_population = FLOOR(SSgamemode.get_correct_popcount() / denominator, 1)
	var/maximum_to_spawn = min(maximum_to_spawn_on_calculation, maximum_to_spawn_on_population)
	var/clamped_value = clamp(decided_count, 0, maximum_to_spawn)
	//Maximum antags per round left to spawn
	//Получить уже количество антагов в раунде
	var/typed_antags_in_round = SSgamemode.get_antag_count_by_type(antag_datum)
	var/left_to_spawn = maximum_antags_per_round - typed_antags_in_round
	var/final_value = clamp(clamped_value, 0, left_to_spawn)
	//double check
	var/predicted_count = final_value + SSgamemode.get_antag_count()
	while(predicted_count > current_cap && final_value > 0)
		final_value--

	return final_value

/datum/round_event_control/antagonist/solo/proc/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/new_players_arg = round_started ? FALSE : TRUE
	var/living_players_arg = round_started ? TRUE : FALSE
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, FALSE, new_players_arg, living_players_arg, midround_antag_pref = midround_antag_pref_arg, \
													restricted_roles = restricted_roles, required_roles = exclusive_roles)
	candidates = trim_candidates(candidates)
	return candidates

///Adds an occurence. Has to use the setter to properly handle shared occurences
/datum/round_event_control/proc/add_occurence()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		shared_occurences[shared_occurence_type]++
	occurrences++

///Subtracts an occurence. Has to use the setter to properly handle shared occurences
/datum/round_event_control/proc/subtract_occurence()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		shared_occurences[shared_occurence_type]--
	occurrences--

///Gets occurences. Has to use the getter to properly handle shared occurences
/datum/round_event_control/proc/get_occurences()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		return shared_occurences[shared_occurence_type]
	return occurrences

/// Prints the action buttons for this event.
/datum/round_event_control/proc/get_href_actions()
	var/button_code
	if(SSticker.HasRoundStarted())
		if(roundstart)
			if(!can_run_post_roundstart)
				button_code += "<a class='linkOff'>Fire</a><a class='linkOff'>Schedule</a>"
			button_code += "<a href='byond://?src=[REF(src)];action=fire'>Fire</a><a href='byond://?src=[REF(src)];action=schedule'>Schedule</a>"
		else
			button_code += "<a href='byond://?src=[REF(src)];action=fire'>Fire</a><a href='byond://?src=[REF(src)];action=schedule'>Schedule</a> <a href='byond://?src=[REF(src)];action=force_next'>Force Next</a>"
	else
		if(roundstart)
			button_code += "<a href='byond://?src=[REF(src)];action=schedule'>Add Roundstart</a><a href='byond://?src=[REF(src)];action=force_next'>Force Roundstart</a>"
		else
			button_code += "<a class='linkOff'>Fire</a><a class='linkOff'>Schedule</a><a class='linkOff'>Force Next</a>"
	button_code += "<a href='byond://?src=[REF(src)];action=set_weight'>Set Weight</a>"
	return button_code


/datum/round_event_control/Topic(href, href_list)
	. = ..()
	if(QDELETED(src))
		return
	switch(href_list["action"])
		if("schedule")
			var/new_schedule = roundstart ? 0 : input(usr, "New schedule time (in seconds):", "Reschedule Event") as num|null
			if(isnull(new_schedule) || QDELETED(src))
				return
			message_admins("[key_name_admin(usr)] scheduled event [src.name] in [new_schedule] seconds.")
			log_admin_private("[key_name(usr)] scheduled [src.name] in [new_schedule] seconds.")
			SSgamemode.schedule_event(src, new_schedule SECONDS, 0, _forced = FALSE)
		if("set_weight")
			var/new_weight = input(usr, "New schedule time (in seconds):", "Reschedule Event") as num|null
			if(isnull(new_weight) || QDELETED(src))
				return
			message_admins("[key_name_admin(usr)] set weight of event [src.name] to [new_weight].")
			log_admin_private("[key_name(usr)] set weight of event [src.name] to [new_weight].")
			src.weight = new_weight
		if("force_next")
			if(length(src.admin_setup))
				for(var/datum/event_admin_setup/admin_setup_datum in src.admin_setup)
					if(admin_setup_datum.prompt_admins() == ADMIN_CANCEL_EVENT)
						return
			if(ispath(type, /datum/round_event_control/antagonist))
				var/new_value = input(usr, "How many players affected:", "Set value") as num|null
				if(isnull(new_value) || new_value < 1)
					return
				message_admins("[key_name_admin(usr)] forced scheduled event [src.name] with count [new_value].")
				log_admin_private("[key_name(usr)] forced scheduled event [src.name] with count [new_value].")
				var/datum/round_event_control/antagonist/forced_antag_event = new type()
				forced_antag_event.forced_antags_count = new_value
				SSgamemode.forced_next_events[forced_antag_event.track] += forced_antag_event
			else
				message_admins("[key_name_admin(usr)] forced scheduled event [src.name].")
				log_admin_private("[key_name(usr)] forced scheduled event [src.name].")
				SSgamemode.forced_next_events[src.track] += src
		if("fire")
			if(length(src.admin_setup))
				for(var/datum/event_admin_setup/admin_setup_datum in src.admin_setup)
					if(admin_setup_datum.prompt_admins() == ADMIN_CANCEL_EVENT)
						return
			message_admins("[key_name_admin(usr)] fired event [src.name].")
			log_admin_private("[key_name(usr)] fired event [src.name].")
			if(ispath(type, /datum/round_event_control/antagonist))
				var/datum/round_event_control/antagonist/forced_antag_event = src
				if(forced_antag_event.can_change_count)
					var/new_value = input(usr, "How many players affected:", "Set value") as num|null
					if(isnull(new_value) || new_value < 1)
						return
					forced_antag_event.forced_antags_count = new_value
				forced_antag_event.run_event(random = FALSE, admin_forced = TRUE)
			else
				run_event(random = FALSE, admin_forced = TRUE)
