///how many storytellers can be voted for along with always_votable ones
#define DEFAULT_STORYTELLER_VOTE_OPTIONS 4
///amount of players we can have before no longer running votes for storyteller
#define MAX_POP_FOR_STORYTELLER_VOTE 25
///the duration into the round for which roundstart events are still valid to run
#define ROUNDSTART_VALID_TIMEFRAME 3 MINUTES
#define STATION_REPORT_TEMPLATE_PATH "modular_bandastation/storyteller/templates/station_report.md"

SUBSYSTEM_DEF(gamemode)
	name = "Gamemode"
	runlevels = RUNLEVEL_GAME
	flags = SS_BACKGROUND | SS_KEEP_TIMING
	priority = 20
	wait = 2 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping
	)

	/// List of our event tracks for fast access during for loops.
	var/list/event_tracks = EVENT_TRACKS
	/// Our storyteller. They progresses our trackboards and picks out events
	var/datum/storyteller/current_storyteller
	/// Result of the storyteller vote/pick. Defaults to the guide.
	var/selected_storyteller = /datum/storyteller/default
	/// List of all the storytellers. Populated at init. Associative from type
	var/list/storytellers = list()
	/// Next process for our storyteller. The wait time is STORYTELLER_WAIT_TIME
	var/next_storyteller_process = 0
	/// Associative list of even track points.
	var/list/event_track_points = list(
		EVENT_TRACK_MUNDANE = 0,
		EVENT_TRACK_MODERATE = 0,
		EVENT_TRACK_MAJOR = 0,
		EVENT_TRACK_ROLESET = 0,
		EVENT_TRACK_OBJECTIVES = 0
		)
	/// Last point amount gained of each track. Those are recorded for purposes of estimating how long until next event.
	var/list/last_point_gains = list(
		EVENT_TRACK_MUNDANE = 0,
		EVENT_TRACK_MODERATE = 0,
		EVENT_TRACK_MAJOR = 0,
		EVENT_TRACK_ROLESET = 0,
		EVENT_TRACK_OBJECTIVES = 0
		)
	/// Point thresholds at which the events are supposed to be rolled, it is also the base cost for events.
	var/list/point_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POINT_THRESHOLD,
		EVENT_TRACK_MODERATE = MODERATE_POINT_THRESHOLD,
		EVENT_TRACK_MAJOR = MAJOR_POINT_THRESHOLD,
		EVENT_TRACK_ROLESET = ROLESET_POINT_THRESHOLD,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_POINT_THRESHOLD
		)

	/// Minimum population thresholds for the tracks to fire off events.
	var/list/min_pop_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_MIN_POP,
		EVENT_TRACK_MODERATE = MODERATE_MIN_POP,
		EVENT_TRACK_MAJOR = MAJOR_MIN_POP,
		EVENT_TRACK_ROLESET = ROLESET_MIN_POP,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_MIN_POP
		)

	/// Configurable multipliers for point gain over time.
	var/list/point_gain_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	/// Whether we allow pop scaling. This is configured by config, or the storyteller UI
	var/allow_pop_scaling = TRUE

	/// Associative list of pop scale thresholds.
	var/list/pop_scale_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POP_SCALE_THRESHOLD,
		EVENT_TRACK_MODERATE = MODERATE_POP_SCALE_THRESHOLD,
		EVENT_TRACK_MAJOR = MAJOR_POP_SCALE_THRESHOLD,
		EVENT_TRACK_ROLESET = ROLESET_POP_SCALE_THRESHOLD,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_POP_SCALE_THRESHOLD
		)

	/// Associative list of pop scale penalties.
	var/list/pop_scale_penalties = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POP_SCALE_PENALTY,
		EVENT_TRACK_MODERATE = MODERATE_POP_SCALE_PENALTY,
		EVENT_TRACK_MAJOR = MAJOR_POP_SCALE_PENALTY,
		EVENT_TRACK_ROLESET = ROLESET_POP_SCALE_PENALTY,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_POP_SCALE_PENALTY
		)

	/// Associative list of active multipliers from pop scale penalty.
	var/list/current_pop_scale_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1,
		)

	/// List of all valid event by their name
	var/list/events_by_name = list()

	/// Associative list of control events by their track category. Compiled in Init
	var/list/event_pools = list()

	/// Events that we have scheduled to run in the nearby future
	var/list/scheduled_events = list()

	/// Associative list of tracks to forced event controls. For admins to force events (though they can still invoke them freely outside of the track system)
	var/list/forced_next_events = list(
		EVENT_TRACK_MUNDANE =  list(),
		EVENT_TRACK_MODERATE =  list(),
		EVENT_TRACK_MAJOR =  list(),
		EVENT_TRACK_ROLESET =  list(),
		EVENT_TRACK_OBJECTIVES =  list(),
	)

	var/list/control = list() //list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/running = list() //list of all existing /datum/round_event
	var/list/round_end_data = list() //list of all reports that need to add round end reports

	/// List of all uncategorized events, because they were wizard or holiday events
	var/list/uncategorized = list()

	/// Event frequency multiplier, it exists because wizard, eugh.
	var/event_frequency_multiplier = 1

	/// Current preview page for the statistics UI.
	var/statistics_track_page = EVENT_TRACK_MUNDANE
	/// Page of the UI panel.
	var/panel_page = GAMEMODE_PANEL_MAIN
	/// Whether we are viewing the roundstart events or not
	var/roundstart_event_view = TRUE

	/// Whether the storyteller has been halted
	var/halted_storyteller = FALSE

	/// Ready players for roundstart events.
	var/ready_players = 0
	var/active_players = 0
	///Минимальная сила отдела
	var/min_depart_power = 20
	///Максимальная сила отдела
	var/max_depart_power = 100
	var/list/full_department_roles = list(STS_HEAD = list(), STS_SEC = list(), STS_ENG = list(), STS_MED = list(), STS_RND = list())
	var/list/department_crew_count = list(STS_HEAD = list(), STS_SEC = list(), STS_ENG = list(), STS_MED = list(), STS_RND = list())
	var/list/department_crew_power = list(STS_HEAD = 0, STS_SEC = 0, STS_ENG = 0,  STS_MED = 0, STS_RND = 0)
	var/list/departments_to_calculate = list(STS_SEC, STS_ENG, STS_MED, STS_RND, STS_HEAD)

	/// Is storyteller secret or not
	var/secret_storyteller = FALSE

	/// List of new player minds we currently want to give our roundstart antag to
	var/list/roundstart_antag_minds = list()

	var/wizardmode = FALSE //refactor this into just being a unique storyteller

	var/list/last_round_events = list()
	/// Has a roundstart event been run
	var/ran_roundstart = FALSE
	/// Are we able to run roundstart events
	var/can_run_roundstart = TRUE
	var/list/triggered_round_events = list()
	var/runned_events = list()
	/// Список ролей перед их сбросом в начале раунда
	var/list/presetuped_ocupations = list()
	var/empty_event_chance = 0
	var/roundstart_budget = 0
	var/roundstart_budget_set = -1

/datum/controller/subsystem/gamemode/Initialize(time, zlevel)
	// Populate event pools
	for(var/track in event_tracks)
		event_pools[track] = list()

	// Populate storytellers
	for(var/type in subtypesof(/datum/storyteller))
		storytellers[type] = new type()

	for(var/datum/round_event_control/event_type as anything in typesof(/datum/round_event_control))
		var/datum/round_event_control/event = new event_type
		if(!event_type.name || !event.typepath || !event.valid_for_map())
			continue // event isn't good for this map no point in trying to add it to the list

		control += event //add it to the list of all events (controls)
		events_by_name[name] = event

	load_config_vars()
	load_event_config_vars()

	///Seeding events into track event pools needs to happen after event config vars are loaded
	for(var/datum/round_event_control/event as anything in control)
		if(event.holidayID || event.wizardevent)
			uncategorized += event
			continue
		event_pools[event.track] += event //Add it to the categorized event pools

	load_roundstart_data()
	if(CONFIG_GET(flag/disable_storyteller)) // we're just gonna disable firing but still initialize, so we don't have any weird runtimes
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED

	return SS_INIT_SUCCESS

/datum/controller/subsystem/gamemode/fire(resumed = FALSE)
	if(SSticker.round_start_time && (world.time - SSticker.round_start_time) >= ROUNDSTART_VALID_TIMEFRAME)
		can_run_roundstart = FALSE
		roundstart_event_view = FALSE

	///Handle scheduled events
	for(var/datum/scheduled_event/sch_event in scheduled_events)
		if(world.time >= sch_event.start_time)
			sch_event.try_fire()
		else if(!sch_event.alerted_admins && world.time >= sch_event.start_time - 1 MINUTES)
			///Alert admins 1 minute before running and allow them to cancel or refund the event, once again.
			sch_event.alerted_admins = TRUE
			message_admins("Scheduled Event: [sch_event.event] will run in [(sch_event.start_time - world.time) / 10] seconds. (<a href='byond://?src=[REF(sch_event)];action=cancel'>CANCEL</a>) (<a href='byond://?src=[REF(sch_event)];action=refund'>REFUND</a>)")
	if(!halted_storyteller && next_storyteller_process <= world.time && current_storyteller)
		// We update crew information here to adjust population scalling and event thresholds for the storyteller.
		update_crew_infos()
		next_storyteller_process = world.time + STORYTELLER_WAIT_TIME
		current_storyteller.process(STORYTELLER_WAIT_TIME * 0.1)

/// Gets the number of antagonists the antagonist injection events will stop rolling after.
/datum/controller/subsystem/gamemode/proc/get_antag_cap(forced = FALSE)
	var/pop_count = get_correct_popcount()
	if(pop_count < current_storyteller.min_antag_popcount && !forced)
		return 0
	var/total_number = pop_count + (length(department_crew_count[STS_SEC]) * current_storyteller.sec_antag_modifier)
	var/cap = FLOOR((total_number / current_storyteller.antag_denominator) * current_storyteller.roundstart_cap_multiplier, 1) + current_storyteller.antag_flat_cap
	return cap

/datum/controller/subsystem/gamemode/proc/get_antag_count()
	var/count = 0
	var/list/already_counted = list() // Never count the same mind twice
	if(SSticker.HasRoundStarted())
		for(var/datum/antagonist/antag as anything in GLOB.antagonists)
			if(QDELETED(antag) || QDELETED(antag.owner) || already_counted[antag.owner])
				continue
			if(!antag.count_against_dynamic_roll_chance || (antag.antag_flags & (FLAG_FAKE_ANTAG | FLAG_ANTAG_CAP_IGNORE)))
				continue
			if(antag.antag_flags & FLAG_ANTAG_CAP_TEAM)
				var/datum/team/antag_team = antag.get_team()
				if(antag_team)
					if(already_counted[antag_team])
						continue
					already_counted[antag_team] = TRUE
			var/mob/antag_mob = antag.owner.current
			if(QDELETED(antag_mob) || !antag_mob.key || antag_mob.stat == DEAD || antag_mob.client?.is_afk())
				continue
			already_counted[antag.owner] = TRUE
			count++
	else
		for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
			if(player.ready != PLAYER_READY_TO_PLAY)
				continue
			var/client/client_source = player.client
			if(QDELETED(client_source) || !client_source.ckey)
				continue
			if(player.mind.picking)
				if(!(player.mind in GLOB.pre_setup_antags))
					GLOB.pre_setup_antags += player.mind
				count++
	return count

/// Whether events can inject more antagonists into the round
/datum/controller/subsystem/gamemode/proc/can_inject_antags()
	return (get_antag_cap() > get_antag_count())

/// Gets candidates for antagonist roles.
/datum/controller/subsystem/gamemode/proc/get_candidates(be_special, job_ban, observers, ready_newplayers, living_players, required_time, inherit_required_time = TRUE, midround_antag_pref, no_antags = TRUE, list/restricted_roles, list/required_roles)
	var/list/candidates = list()
	var/list/candidate_candidates = list() //lol

	for(var/mob/player as anything in GLOB.player_list)
		if(QDELETED(player) || player.mind?.picking)
			continue
		if(ready_newplayers && isnewplayer(player))
			var/mob/dead/new_player/new_player = player
			if(new_player.ready == PLAYER_READY_TO_PLAY && new_player.mind && new_player.check_preferences())
				candidate_candidates += player
		else if(observers && isobserver(player))
			candidate_candidates += player
		else if(living_players && isliving(player))
			if(!ishuman(player) && !isAI(player))
				continue
			// I split these checks up to make the code more readable
			var/is_on_station = is_station_level(player.z)
			if(!is_on_station && !is_late_arrival(player))
				continue
			candidate_candidates += player

	for(var/mob/candidate as anything in candidate_candidates)
		if(QDELETED(candidate) || !candidate.key || !candidate.client || (!observers && !candidate.mind))
			continue
		if(!observers)
			if(!ready_players && !isliving(candidate))
				continue
			if(no_antags && !isnull(candidate.mind.antag_datums))
				var/real = FALSE
				for(var/datum/antagonist/antag_datum as anything in candidate.mind.antag_datums)
					if(antag_datum.count_against_dynamic_roll_chance && !(antag_datum.antag_flags & FLAG_FAKE_ANTAG))
						real = TRUE
						break
				if(real)
					continue
			if(restricted_roles && (candidate.mind.assigned_role.title in restricted_roles))
				continue
			if(length(required_roles) && !(candidate.mind.assigned_role.title in required_roles))
				continue

		if(be_special)
			if(!(candidate.client.prefs) || !(be_special in candidate.client.prefs.be_special))
				continue

			var/time_to_check
			if(required_time)
				time_to_check = required_time
			else if(inherit_required_time)
				time_to_check = GLOB.special_roles[be_special]

			if(time_to_check && candidate.client.get_remaining_days(time_to_check) > 0)
				continue

		if(job_ban && is_banned_from(candidate.ckey, list(job_ban, ROLE_SYNDICATE)))
			continue
		candidates += candidate

	return candidates

/// Gets the correct popcount, returning READY people if roundstart, and active people if not.
/datum/controller/subsystem/gamemode/proc/get_correct_popcount()
	if(SSticker.HasRoundStarted())
		update_crew_infos()
		return active_players
	else
		recalculate_ready_pop()
		return ready_players

/// Refunds and removes a scheduled event.
/datum/controller/subsystem/gamemode/proc/refund_scheduled_event(datum/scheduled_event/refunded)
	if(refunded.cost)
		var/track_type = refunded.event.track
		event_track_points[track_type] += refunded.cost
	remove_scheduled_event(refunded)

/// Removes a scheduled event.
/datum/controller/subsystem/gamemode/proc/remove_scheduled_event(datum/scheduled_event/removed)
	scheduled_events -= removed
	qdel(removed)

/// We roll points to be spent for roundstart events, including antagonists.
/datum/controller/subsystem/gamemode/proc/roll_pre_setup_points()
	if(current_storyteller.disable_distribution || halted_storyteller)
		return
	/// Distribute points
	for(var/track in event_track_points)
		var/base_amt
		var/gain_amt
		switch(track)
			if(EVENT_TRACK_MUNDANE)
				base_amt = ROUNDSTART_MUNDANE_BASE
				gain_amt = ROUNDSTART_MUNDANE_GAIN
			if(EVENT_TRACK_MODERATE)
				base_amt = ROUNDSTART_MODERATE_BASE
				gain_amt = ROUNDSTART_MODERATE_GAIN
			if(EVENT_TRACK_MAJOR)
				base_amt = ROUNDSTART_MAJOR_BASE
				gain_amt = ROUNDSTART_MAJOR_GAIN
			if(EVENT_TRACK_ROLESET)
				base_amt = ROUNDSTART_ROLESET_BASE
				gain_amt = ROUNDSTART_ROLESET_GAIN
			if(EVENT_TRACK_OBJECTIVES)
				base_amt = ROUNDSTART_OBJECTIVES_BASE
				gain_amt = ROUNDSTART_OBJECTIVES_GAIN
		var/calc_value = base_amt + (gain_amt * ready_players)
		calc_value *= current_storyteller.roundstart_point_multipliers[track]
		calc_value *= current_storyteller.starting_point_multipliers[track]
		calc_value *= (rand(100 - current_storyteller.roundstart_points_variance,100 + current_storyteller.roundstart_points_variance)/100)
		event_track_points[track] = round(calc_value)

	/// If the storyteller guarantees an antagonist roll, add points to make it so.
	if(current_storyteller.guarantees_roundstart_roleset && event_track_points[EVENT_TRACK_ROLESET] < point_thresholds[EVENT_TRACK_ROLESET] && current_storyteller.min_antag_popcount <= get_correct_popcount())
		event_track_points[EVENT_TRACK_ROLESET] = point_thresholds[EVENT_TRACK_ROLESET]

	/// If we have any forced events, ensure we get enough points for them
	for(var/track in event_tracks)
		if(length(forced_next_events[track]) && event_track_points[track] < point_thresholds[track])
			event_track_points[track] = point_thresholds[track]

/// At this point we've rolled roundstart events and antags and we handle leftover points here.
/datum/controller/subsystem/gamemode/proc/handle_post_setup_points()
//	for(var/track in event_track_points) //Just halve the points for now.
//		event_track_points[track] *= 0.5 TESTING HOW THINGS GO WITHOUT THIS HALVING OF POINTS
	return

/// Because roundstart events need 2 steps of firing for purposes of antags, here is the first step handled, happening before occupation division.
/datum/controller/subsystem/gamemode/proc/handle_pre_setup_roundstart_events()
	if(current_storyteller.disable_distribution)
		return
	if(halted_storyteller)
		message_admins("WARNING: Didn't roll roundstart events (including antagonists) due to the storyteller being halted.")
		return
	handle_pre_setup_occupations()
	SSjob.reset_occupations()
	while(TRUE)
		if(!current_storyteller.handle_tracks())
			break

/// Прок который сохраняет список ролей перед их сбросом. Важно, так позволяет более тонко настраивать количество СБ/Антагов
/datum/controller/subsystem/gamemode/proc/handle_pre_setup_occupations()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player?.mind)
			continue
		var/datum/job/job_datum = get_preferenced_job(player)
		var/client/client_source = player.client
		presetuped_ocupations[client_source.ckey] = job_datum

/// Прок, который пытается получить предпочтительную роль для игрока (и назначить в дальнейшем вес для нее)
/datum/controller/subsystem/gamemode/proc/get_preferenced_job(mob/dead/new_player/check_player)
	var/list/available_occupations = SSjob.joinable_occupations
	for(var/level in SSjob.level_order)
		for(var/datum/job/job in available_occupations)
			// Filter any job that doesn't fit the current level.
			var/player_job_level = check_player.client?.prefs.job_preferences[job.title]
			if(isnull(player_job_level))
				continue
			if(player_job_level != level)
				continue
			return job

/// Second step of handlind roundstart events, happening after people spawn.
/datum/controller/subsystem/gamemode/proc/handle_post_setup_roundstart_events()
	/// Start all roundstart events on post_setup immediately
	for(var/datum/round_event/event as anything in running)
		if(!event.control.roundstart)
			continue
		ASYNC
			event.try_start()
		INVOKE_ASYNC(event, TYPE_PROC_REF(/datum/round_event, try_start))

/// Для восполнения очков ролсета
/datum/controller/subsystem/gamemode/proc/refill_roleset()
	event_track_points[EVENT_TRACK_ROLESET] = point_thresholds[EVENT_TRACK_ROLESET]

/// Schedules an event to run later.
/datum/controller/subsystem/gamemode/proc/schedule_event(datum/round_event_control/passed_event, passed_time, passed_cost, passed_ignore, passed_announce, _forced = FALSE)
	if(_forced)
		passed_ignore = TRUE
	var/datum/scheduled_event/scheduled = new (passed_event, world.time + passed_time, passed_cost, passed_ignore, passed_announce)
	var/round_started = SSticker.HasRoundStarted()
	if(round_started)
		message_admins("Event: [passed_event] has been scheduled to run in [passed_time / 10] seconds. (<a href='byond://?src=[REF(scheduled)];action=cancel'>CANCEL</a>) (<a href='byond://?src=[REF(scheduled)];action=refund'>REFUND</a>)")
	else //Only roundstart events can be scheduled before round start
		message_admins("Event: [passed_event] has been scheduled to run on roundstart. (<a href='byond://?src=[REF(scheduled)];action=cancel'>CANCEL</a>)")
	scheduled_events += scheduled

/datum/controller/subsystem/gamemode/proc/update_crew_infos()
	// Very similar logic to `get_active_player_count()`
	active_players = 0
	department_crew_count = list(STS_HEAD = list(), STS_SEC = list(), STS_ENG = list(), STS_MED = list(), STS_RND = list())
	for(var/mob/player_mob as anything in GLOB.player_list)
		if(!player_mob.client)
			continue
		if(player_mob.stat) //If they're alive
			continue
		if(player_mob.client.is_afk()) //If afk
			continue
		if(!ishuman(player_mob))
			continue
		active_players++
		if(player_mob.mind?.assigned_role)
			fill_count(player_mob)
	if(SSticker.HasRoundStarted())
		depart_power()
	else
		recalculate_ready_pop()
	update_pop_scaling()

/datum/controller/subsystem/gamemode/proc/depart_power()
	var/intern_threshold = (CONFIG_GET(number/use_low_living_hour_intern_hours) * 60) || (CONFIG_GET(number/use_exp_restrictions_heads_hours) * 60)
	department_crew_power = list(STS_HEAD = 0, STS_SEC = 0, STS_ENG = 0,  STS_MED = 0, STS_RND = 0)
	for(var/department in departments_to_calculate)
		var/department_max_crew = length(full_department_roles[department])
		var/crew_power = 0
		for(var/mob/player_mob as anything in department_crew_count[department])
			var/playtime = player_mob.client.get_exp_living(pure_numeric = TRUE)
			var/is_intern = (intern_threshold > playtime) && (player_mob.mind?.assigned_role.job_flags & JOB_CAN_BE_INTERN)
			var/depart_power = is_intern ? 0 : clamp(playtime, min_depart_power, max_depart_power)
			crew_power += depart_power
		if(length(department_crew_count[department]))
			var/max_power = department_max_crew * max_depart_power
			var/department_power = round((crew_power / max_power) * 100, 0.1)
			department_crew_power[department] = department_power

/datum/controller/subsystem/gamemode/proc/fill_count(mob/player_mob)
	var/datum/job/player_role = player_mob.mind.assigned_role
	var/department
	if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		department = STS_HEAD
	if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)
		department = STS_ENG
	if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
		department = STS_MED
	if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_SCIENCE)
		department = STS_RND
	if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
		department = STS_SEC
	if(department)
		department_crew_count[department] += player_mob

/datum/controller/subsystem/gamemode/proc/check_event_power(datum/round_event_control/event)
	var/can_run = TRUE
	if(length(event.req_departments_power))
		for(var/department in departments_to_calculate)
			if(department_crew_power[department] < event.req_departments_power[department])
				can_run = FALSE
				break

	return can_run

/datum/controller/subsystem/gamemode/proc/get_sec_mult()
	var/antag_cap = get_antag_cap()
	return antag_cap > 0 ? (2 - (get_antag_count() / antag_cap)) : 0

/datum/controller/subsystem/gamemode/proc/update_pop_scaling()
	for(var/track in event_tracks)
		var/low_pop_bound = min_pop_thresholds[track]
		var/high_pop_bound = pop_scale_thresholds[track]
		var/scale_penalty = pop_scale_penalties[track]

		var/perceived_pop = min(max(low_pop_bound, active_players), high_pop_bound)

		var/divisor = high_pop_bound - low_pop_bound
		/// If the bounds are equal, we'd be dividing by zero or worse, if upper is smaller than lower, we'd be increasing the factor, just make it 1 and continue.
		/// this is only a problem for bad configs
		if(divisor <= 0)
			current_pop_scale_multipliers[track] = 1
			continue
		var/scalar = (perceived_pop - low_pop_bound) / divisor
		var/penalty = scale_penalty - (scale_penalty * scalar)
		var/calculated_multiplier = 1 - (penalty / 100)

		current_pop_scale_multipliers[track] = calculated_multiplier

/datum/controller/subsystem/gamemode/proc/TriggerEvent(datum/round_event_control/event, forced = FALSE, from_schedule = FALSE)
	. = event.preRunEvent(forced, scheduled = from_schedule)
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		event.max_occurrences = 0
	else if(. == EVENT_READY)
		event.run_event(random = TRUE, admin_forced = forced) // fallback to dynamic
		triggered_round_events |= event.name

///Resets frequency multiplier.
/datum/controller/subsystem/gamemode/proc/resetFrequency()
	event_frequency_multiplier = 1

/client/proc/forceEvent()
	set name = "Trigger Event"
	set category = "Admin.Events"
	if(!holder ||!check_rights(R_FUN))
		return
	holder.forceEvent(usr)

/datum/admins/forceEvent()
	if(!check_rights(R_FUN))
		return

	SSgamemode.event_panel(usr)

/client/proc/forceGamemode()
	set name = "Open Gamemode Panel"
	set category = "Admin.Events"
	if(!holder ||!check_rights(R_FUN))
		return
	holder.forceGamemode(usr)

/datum/admins/proc/forceGamemode(mob/user)
	SSgamemode.admin_panel(user)

/datum/controller/subsystem/gamemode/proc/toggleWizardmode()
	wizardmode = !wizardmode //TODO: decide what to do with wiz events
	message_admins("Summon Events has been [wizardmode ? "enabled, events will occur [SSgamemode.event_frequency_multiplier] times as fast" : "disabled"]!")
	log_game("Summon Events was [wizardmode ? "enabled" : "disabled"]!")

///Attempts to select players for special roles the mode might have.
/datum/controller/subsystem/gamemode/proc/pre_setup()
	recalculate_ready_pop()
	roll_pre_setup_points()
	handle_pre_setup_roundstart_events()
	return TRUE

///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/controller/subsystem/gamemode/proc/post_setup(report) //Gamemodes can override the intercept report. Passing TRUE as the argument will force a report.
	if(!report)
		report = !CONFIG_GET(flag/no_intercept_report)

	if (!CONFIG_GET(flag/no_intercept_report))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(display_roundstart_logout_report)), ROUNDSTART_LOGOUT_REPORT_TIME)

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles))
		var/delay = CONFIG_GET(number/reopen_roundstart_suicide_roles_delay)
		if(delay)
			delay = (delay SECONDS)
		else
			delay = (4 MINUTES) //default to 4 minutes if the delay isn't defined.
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reopen_roundstart_suicide_roles)), delay)

	if(SSdbcore.Connect())
		var/list/to_set = list()
		var/arguments = list()
		if(current_storyteller)
			to_set += "game_mode = :game_mode"
			arguments["game_mode"] = current_storyteller.name
		if(GLOB.revdata.originmastercommit)
			to_set += "commit_hash = :commit_hash"
			arguments["commit_hash"] = GLOB.revdata.originmastercommit
		if(to_set.len)
			arguments["round_id"] = GLOB.round_id
			var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery(
				"UPDATE [format_table_name("round")] SET [to_set.Join(", ")] WHERE id = :round_id",
				arguments
			)
			query_round_game_mode.Execute()
			qdel(query_round_game_mode)
	SSstation.generate_station_goals(CONFIG_GET(number/station_goal_budget))
	if(report)
		generate_station_goal_report()
	handle_post_setup_roundstart_events()
	handle_post_setup_points()
	return TRUE


///Handles late-join antag assignments
/datum/controller/subsystem/gamemode/proc/make_antag_chance(mob/living/carbon/human/character)
	return

/datum/controller/subsystem/gamemode/proc/check_finished(force_ending) //to be called by SSticker
	if(!SSticker.setup_done)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE

/*
 * Generate a list of station goals available to purchase to report to the crew.
 *
 * Returns a formatted string all station goals that are available to the station.
 */
/datum/controller/subsystem/gamemode/proc/generate_station_goal_report()
	if(GLOB.communications_controller.block_command_report) //If we don't want the report to be printed just yet, we put it off until it's ready
		addtimer(CALLBACK(src, PROC_REF(generate_station_goal_report)), 10 SECONDS)
		return

	if(!fexists(STATION_REPORT_TEMPLATE_PATH))
		stack_trace("station report template doesn't exist at path: [STATION_REPORT_TEMPLATE_PATH]")
		return

	var/station_report_template = file2text(STATION_REPORT_TEMPLATE_PATH)
	if(!station_report_template)
		stack_trace("station report template doesn't is empty at path: [STATION_REPORT_TEMPLATE_PATH]")
		return

	var/list/datum/station_goal/goals = SSstation.get_station_goals()
	var/station_goals_section = ""
	if(length(goals))
		var/list/station_goal_reports = list()
		for(var/datum/station_goal/station_goal as anything in goals)
			station_goal.on_report()
			station_goal_reports += station_goal.get_report()

		station_goals_section = list(
			"# === Цели на смену ===\n",
			station_goal_reports.Join("\n\n---\n\n"),
		).Join()

	station_report_template = replacetext(station_report_template, "%STATION_GOALS", station_goals_section);

	var/list/trait_reports = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue

		trait_reports += "- [station_trait.get_report()]"

	var/trait_reports_sections = ""
	if(length(trait_reports))
		trait_reports_sections = list(
			"\n\n---\n\n",
			"# === Обнаруженные отклонения ===\n",
			trait_reports.Join("\n")
		).Join()

	station_report_template = replacetext(station_report_template, "%TRAIT_REPORTS", trait_reports_sections);

	var/footnote_section = ""
	if(length(GLOB.communications_controller.command_report_footnotes))
		var/list/footnotes = list()
		for(var/datum/command_footnote/footnote in GLOB.communications_controller.command_report_footnotes)
			footnotes += "[footnote.message]<BR>"
			footnotes += "<i>[footnote.signature]</i><BR>"
			footnotes += "<BR>"

		footnote_section = list(
			"\n\n---\n\n",
			"# === Дополнительная информация ===\n",
			footnotes.Join()
		).Join()

	station_report_template = replacetext(station_report_template, "%FOOTNOTES", footnote_section);
	station_report_template = replacetext(station_report_template, "%SIGNING_OFFICER", "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]");

	station_report_template = replace_text_keys(station_report_template)

#ifndef MAP_TEST
	print_command_report(station_report_template, "[command_name()] Status Summary", announce=FALSE)
	priority_announce("Отчет был скопирован и распечатан на всех консолях связи.", "Отчет о безопасности", SSstation.announcer.get_rand_report_sound())
#endif

/datum/controller/subsystem/gamemode/proc/recalculate_ready_pop()
	ready_players = 0
	department_crew_count = list(STS_HEAD = list(), STS_SEC = list(), STS_ENG = list(), STS_MED = list(), STS_RND = list())
	handle_pre_setup_occupations()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY)
			ready_players++
		var/client/client_source = player.client
		if(QDELETED(client_source) || !client_source.ckey)
			continue
		var/datum/job/player_role = presetuped_ocupations[client_source.ckey]
		var/department
		if(player_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND && !player.mind.special_role)
			department = STS_HEAD
		if(player_role?.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING && !player.mind.special_role)
			department = STS_ENG
		if(player_role?.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL && !player.mind.special_role)
			department = STS_MED
		if(player_role?.departments_bitflags & DEPARTMENT_BITFLAG_SCIENCE && !player.mind.special_role)
			department = STS_RND
		if(player_role?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY && !player.mind.special_role)
			department = STS_SEC
		if(department)
			department_crew_count[department] += player

/datum/controller/subsystem/gamemode/proc/round_start_handle()
	recalculate_ready_pop()
	recalculate_roundstart_budget()
	message_admins("Storyteller begin to get roundstart events with budget [roundstart_budget].")

	var/track = EVENT_TRACK_ROLESET
	if(forced_next_events[track])
		for(var/datum/round_event_control/forced_event in forced_next_events[track])
			if(forced_event.exclusive_roundstart_event)
				forced_event = exclusives_add_antags(forced_event, forced = TRUE)
			message_admins("Storyteller purchased and triggered forced roundstart event [forced_event].")
			TriggerEvent(forced_event, forced = TRUE)
			runned_events += "Runned forced roundstart: [forced_event.name]"
		forced_next_events[track] = list()


	event_track_points[track] = 0
	var/pop_count = ready_players + (length(department_crew_count[STS_SEC]) * current_storyteller.sec_antag_modifier)
	if(pop_count < current_storyteller.min_antag_popcount)
		message_admins("Not enough ready players to run general and scheduled roundstart events.")
		message_admins("Storyteller finished to get roundstart events.")
		return

	var/list/valid_events = recalculate_roundstart_costs(track)

	valid_events = rountstart_scheduled_events_run(valid_events)

	rountstart_general_events_run(valid_events, track)

	message_admins("Storyteller finished to get roundstart events with points left - [roundstart_budget].")
	current_storyteller.roundstart_cap_multiplier = 1

/datum/controller/subsystem/gamemode/proc/recalculate_roundstart_budget()
	var/pop_count = ready_players + (length(department_crew_count[STS_SEC]) * current_storyteller.sec_antag_modifier)
	var/calculated_roundstart_budget = pop_count
	roundstart_budget = roundstart_budget_set == -1 ? calculated_roundstart_budget : roundstart_budget_set

/datum/controller/subsystem/gamemode/proc/rountstart_general_events_run(valid_events, track)

	if(!length(valid_events))
		message_admins("Storyteller failed to pick an events for roundstart.")
		event_track_points[track] *= TRACK_FAIL_POINT_PENALTY_MULTIPLIER
		return

	while(length(valid_events))
		recalculate_ready_pop()
		recalculate_roundstart_costs(track)

		var/datum/round_event_control/picked_event = pick_weight(valid_events)
		if(picked_event.can_spawn_event(ready_players) && (roundstart_budget >= picked_event.get_pre_cost()))
			roundstart_budget -= picked_event.get_pre_cost()
			message_admins("Storyteller purchased and triggered [picked_event] event for [picked_event.get_pre_cost()]. Left balance: [roundstart_budget].")
			if(picked_event.exclusive_roundstart_event)
				valid_events = list()
				picked_event = exclusives_add_antags(picked_event, forced = FALSE)
			else
			// Если первое событие не-эксклюзивное, то удаляем из списка все эксклюзивные
				for(var/datum/round_event_control/exclude_event as anything in valid_events)
					if(exclude_event.exclusive_roundstart_event)
						valid_events -= exclude_event
			TriggerEvent(picked_event, forced = FALSE)
			runned_events += "Runned roundstart: [picked_event.name]"
			// Если первое событие эксклюзивное, то отчищаем список

		else
			valid_events -= picked_event

/datum/controller/subsystem/gamemode/proc/rountstart_scheduled_events_run(valid_events)
	var/list/scheduled_events_roleset = list()
	for(var/datum/scheduled_event/scheduled_pre_event in scheduled_events)
		scheduled_events_roleset += scheduled_pre_event.event
		scheduled_events_roleset[scheduled_pre_event.event] = scheduled_pre_event.event.weight
		scheduled_events -= scheduled_pre_event

	var/list/dynamic_roundstart_rules = SSdynamic.init_rulesets(/datum/dynamic_ruleset/roundstart)
	if(length(scheduled_events_roleset))
		var/datum/round_event_control/antagonist/solo/scheduled_event = pick_weight(scheduled_events_roleset)
		for(var/datum/dynamic_ruleset/ruleset as anything in dynamic_roundstart_rules)
			if(ruleset.antag_datum == scheduled_event.antag_datum)
				scheduled_event.roundstart_cost = scheduled_event.get_pre_cost() ? scheduled_event.get_pre_cost() : ruleset.cost
				break

	while(length(scheduled_events_roleset))
		var/datum/round_event_control/scheduled_event = pick_weight(scheduled_events_roleset)
		if(scheduled_event.can_spawn_event(ready_players) && (roundstart_budget >= scheduled_event.get_pre_cost()))
			roundstart_budget -= scheduled_event.get_pre_cost()
			message_admins("Storyteller purchased and triggered scheduled event [scheduled_event] for [scheduled_event.get_pre_cost()]. Left balance: [roundstart_budget].")
			if(scheduled_event.exclusive_roundstart_event)
				valid_events = list()
				scheduled_event = exclusives_add_antags(scheduled_event, forced = FALSE)
			else
			// Если первое событие не-эксклюзивное, то удаляем из списка все эксклюзивные
				for(var/datum/round_event_control/exclude_event as anything in scheduled_events_roleset)
					if(exclude_event.exclusive_roundstart_event)
						scheduled_events_roleset -= exclude_event
				for(var/datum/round_event_control/exclude_event as anything in valid_events)
					if(exclude_event.exclusive_roundstart_event)
						valid_events -= exclude_event
			TriggerEvent(scheduled_event, forced = FALSE)
			runned_events += "Runned scheduled roundstart: [scheduled_event.name]"
			scheduled_events_roleset -= scheduled_event

		else
			message_admins("Storyteller failed to purchase scheduled event [scheduled_event] for [scheduled_event.roundstart_cost]. Left balance: [roundstart_budget].")
			scheduled_events_roleset -= scheduled_event

	return valid_events

/datum/controller/subsystem/gamemode/proc/exclusives_add_antags(datum/round_event_control/antagonist/solo/exclusive_event, forced = FALSE)
	//Получить бюджет
	var/addition_antags = 0
	if(forced)
		addition_antags = exclusive_event.forced_antags_count
	else
		while(exclusive_event.price_to_buy_adds <= roundstart_budget)
			roundstart_budget -= exclusive_event.price_to_buy_adds
			addition_antags++
			message_admins("Storyteller purchased and triggered [exclusive_event] and buy additional antag. Left balance: [roundstart_budget].")
	//Расчитать новый максимум и минимум антагов
	exclusive_event.base_antags += addition_antags
	exclusive_event.maximum_antags += addition_antags
	roundstart_budget = 0
	return exclusive_event

/datum/controller/subsystem/gamemode/proc/recalculate_roundstart_costs(track)
	full_department_roles[STS_SEC] = list()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			for(var/i = 0; i < job.total_positions; i++)
				full_department_roles[STS_SEC] += job.title

	/// Получить количество доступных раундстартом событий
	current_storyteller.calculate_weights(track)
	var/list/valid_events = list()
	// Determine which events are valid to pick
	for(var/datum/round_event_control/event as anything in event_pools[track])
		if(event.can_spawn_event(ready_players))
			if(QDELETED(event))
				message_admins("[event.name] was deleted!")
				continue
			valid_events[event] = round(event.calculated_weight * 10)
	if(!length(valid_events))
		return

	var/list/dynamic_roundstart_rules = SSdynamic.init_rulesets(/datum/dynamic_ruleset/roundstart)
	for(var/datum/round_event_control/antagonist/solo/event as anything in valid_events)
		for(var/datum/dynamic_ruleset/ruleset as anything in dynamic_roundstart_rules)
			if(ruleset.antag_datum == event.antag_datum)
				event.roundstart_cost = event.get_pre_cost() ? event.get_pre_cost() : ruleset.cost
				break

	return valid_events

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/list/msg = list("[span_boldnotice("Roundstart logout report")]\n\n")
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/mob/living/carbon/C = L
		if (istype(C) && !C.last_mind)
			continue  // never had a client

		if(L.ckey && !GLOB.directory[L.ckey])
			msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			var/failed = FALSE
			if(L.client.inactivity >= ROUNDSTART_LOGOUT_AFK_THRESHOLD) //Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				failed = TRUE //AFK client
			if(!failed && L.stat)
				if(HAS_TRAIT(L, TRAIT_SUICIDED)) //Suicider
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] ([span_boldannounce("Suicide")])\n"
					failed = TRUE //Disconnected client
				if(!failed && (L.stat == UNCONSCIOUS || L.stat == HARD_CRIT))
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dying)\n"
					failed = TRUE //Unconscious
				if(!failed && L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dead)\n"
					failed = TRUE //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(HAS_TRAIT(L, TRAIT_SUICIDED)) //Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_boldannounce("Suicide")])\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_boldannounce("Ghosted")])\n"
						continue //Ghosted while alive

	var/concatenated_message = msg.Join()
	log_admin(concatenated_message)
	to_chat(GLOB.admins, concatenated_message)

//Set result and news report here
/datum/controller/subsystem/gamemode/proc/set_round_result()
	SSticker.mode_result = "undefined"
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_DESTROYED_NUKE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		SSticker.news_report = STATION_EVACUATED
		if(SSshuttle.emergency.is_hijacked())
			SSticker.news_report = SHUTTLE_HIJACK

/// Loads json event config values from events.txt
/datum/controller/subsystem/gamemode/proc/load_event_config_vars()
	var/json_file = file("[global.config.directory]/events.json")
	if(!fexists(json_file))
		return
	var/list/decoded = json_decode(file2text(json_file))
	for(var/event_text_path in decoded)
		var/event_path = text2path(event_text_path)
		var/datum/round_event_control/event
		for(var/datum/round_event_control/iterated_event as anything in control)
			if(iterated_event.type == event_path)
				event = iterated_event
				break
		if(!event)
			continue
		var/list/var_list = decoded[event_text_path]
		for(var/variable in var_list)
			var/value = var_list[variable]
			switch(variable)
				if("weight")
					event.weight = value
				if("min_players")
					event.min_players = value
				if("max_occurrences")
					event.max_occurrences = value
				if("earliest_start")
					event.earliest_start = value * (1 MINUTES)
				if("track")
					if(value in event_tracks)
						event.track = value
				if("cost")
					event.cost = value
				if("reoccurence_penalty_multiplier")
					event.reoccurence_penalty_multiplier = value
				if("shared_occurence_type")
					if(!isnull(value))
						value = "[value]"
					event.shared_occurence_type = value

/// Loads config values from game_options.txt
/datum/controller/subsystem/gamemode/proc/load_config_vars()
	point_gain_multipliers[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_OBJECTIVES] = CONFIG_GET(number/objectives_point_gain_multiplier)

	min_pop_thresholds[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_min_pop)
	min_pop_thresholds[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_min_pop)
	min_pop_thresholds[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_min_pop)
	min_pop_thresholds[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_min_pop)
	min_pop_thresholds[EVENT_TRACK_OBJECTIVES] = CONFIG_GET(number/objectives_min_pop)

	if(!CONFIG_GET(flag/events_config_enabled))
		return

	var/file_path = "[global.config.directory]/bandastation/events.toml"
	if(!fexists(file_path))
		return

	var/list/configuration = rustg_read_toml_file(file_path)
	for(var/variable in configuration)
		var/datum/round_event_control/event = events_by_name[variable]
		if(!event)
			stack_trace("Invalid event [event] attempting to be configured.")
			continue
		for(var/event_variable in configuration[variable])
			if(!(event.vars.Find(event_variable)))
				stack_trace("Invalid event configuration variable [event_variable] in variable changes for [variable].")
				continue
			event.vars[event_variable] = configuration[variable][event_variable]


/datum/controller/subsystem/gamemode/proc/handle_picking_storyteller()
	if(CONFIG_GET(flag/disable_storyteller))
		return
	if(length(GLOB.clients) > MAX_POP_FOR_STORYTELLER_VOTE)
		secret_storyteller = FALSE
		//selected_storyteller = pick_weight(get_valid_storytellers(TRUE))
		return
	//SSvote.initiate_vote(/datum/vote/storyteller, "pick round storyteller", forced = TRUE)

/datum/controller/subsystem/gamemode/proc/storyteller_vote_choices()
	var/list/final_choices = list()
	var/list/pick_from = list()
	for(var/datum/storyteller/storyboy in get_valid_storytellers())
		if(storyboy.always_votable)
			final_choices[storyboy.name] = 0
		else
			pick_from[storyboy.name] = storyboy.weight //might be able to refactor this to be slightly better due to get_valid_storytellers returning a weighted list

	var/added_storytellers = 0
	while(added_storytellers < DEFAULT_STORYTELLER_VOTE_OPTIONS && length(pick_from))
		added_storytellers++
		var/picked_storyteller = pick_weight(pick_from)
		final_choices[picked_storyteller] = 0
		pick_from -= picked_storyteller
	return final_choices

/datum/controller/subsystem/gamemode/proc/storyteller_desc(storyteller_name)
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.name != storyteller_name)
			continue
		return storyboy.desc


/datum/controller/subsystem/gamemode/proc/storyteller_vote_result(winner_name)
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.name == winner_name)
			selected_storyteller = storyteller_type
			break

///return a weighted list of all storytellers that are currently valid to roll, if return_types is set then we will return types instead of instances
/datum/controller/subsystem/gamemode/proc/get_valid_storytellers(return_types = FALSE)
	var/client_amount = length(GLOB.clients)
	var/list/valid_storytellers = list()
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.restricted || (storyboy.population_min && storyboy.population_min > client_amount) || (storyboy.population_max && storyboy.population_max < client_amount))
			continue

		valid_storytellers[return_types ? storyboy.type : storyboy] = storyboy.weight
	return valid_storytellers

/datum/controller/subsystem/gamemode/proc/init_storyteller()
	if(!current_storyteller)
		set_storyteller(selected_storyteller)

/datum/controller/subsystem/gamemode/proc/set_storyteller(passed_type)
	if(!storytellers[passed_type])
		message_admins("Attempted to set an invalid storyteller type: [passed_type], force setting to guide instead.")
		current_storyteller = /datum/storyteller/default //if we dont have any then we brick, lets not do that
		CRASH("Attempted to set an invalid storyteller type: [passed_type].")
	var/passed_state = FALSE
	var/passed_multiplayer
	if (current_storyteller)
		passed_state = current_storyteller.round_started
		passed_multiplayer = current_storyteller.roundstart_cap_multiplier
		current_storyteller.round_started = FALSE
	current_storyteller = storytellers[passed_type]
	current_storyteller.round_started = passed_state
	current_storyteller.round_started = passed_multiplayer
	if(!secret_storyteller)
		send_to_playing_players(span_notice("<b>Storyteller is [current_storyteller.name]!</b>"))
		send_to_playing_players(span_notice("[current_storyteller.welcome_text]"))
	else
		send_to_observers(span_boldbig("<b>Storyteller is [current_storyteller.name]!</b>")) //observers still get to know

/// Panel containing information, variables and controls about the gamemode and scheduled event
/datum/controller/subsystem/gamemode/proc/admin_panel(mob/user)
	if(!current_storyteller)
		set_storyteller(selected_storyteller)
	update_crew_infos()
	var/round_started = SSticker.HasRoundStarted()
	var/list/dat = list()
	dat += "Storyteller: [current_storyteller ? "[current_storyteller.name]" : "None"] "
	dat += " <a href='byond://?src=[REF(src)];panel=main;action=halt_storyteller' [halted_storyteller ? "class='linkOn'" : ""]>HALT Storyteller</a> <a href='byond://?src=[REF(src)];panel=main;action=open_stats'>Event Panel</a> <a href='byond://?src=[REF(src)];panel=main;action=set_storyteller'>Set Storyteller</a> <a href='byond://?src=[REF(src)];panel=main'>Refresh</a>"
	dat += "<BR><font color='#888888'><i>Storyteller determines points gained, event chances, and is the entity responsible for rolling events.</i></font>"
	dat += "<BR>Active Players: [active_players]   (Head: [length(department_crew_count[STS_HEAD])]/[department_crew_power[STS_HEAD]], Sec: [length(department_crew_count[STS_SEC])]/[department_crew_power[STS_SEC]], Eng: [length(department_crew_count[STS_ENG])]/[department_crew_power[STS_HEAD]], Med: [length(department_crew_count[STS_MED])]/[department_crew_power[STS_MED]], RnD: [length(department_crew_count[STS_RND])]/[department_crew_power[STS_RND]])"
	dat += "<BR>Antagonist Count vs Maximum: [get_antag_count()] / [get_antag_cap()]"
	dat += "<HR>"
	dat += "<a href='byond://?src=[REF(src)];panel=main;action=tab;tab=[GAMEMODE_PANEL_MAIN]' [panel_page == GAMEMODE_PANEL_MAIN ? "class='linkOn'" : ""]>Main</a>"
	dat += " <a href='byond://?src=[REF(src)];panel=main;action=tab;tab=[GAMEMODE_PANEL_VARIABLES]' [panel_page == GAMEMODE_PANEL_VARIABLES ? "class='linkOn'" : ""]>Variables</a>"
	dat += "<HR>"
	switch(panel_page)
		if(GAMEMODE_PANEL_VARIABLES)
			dat += "<a href='byond://?src=[REF(src)];panel=main;action=reload_config_vars'>Reload Config Vars</a> <font color='#888888'><i>Configs located in game_options.txt.</i></font>"
			dat += "<HR>"

			dat += "<BR><b>Storyteller Basic Variables:</b>"
			dat += "<BR>Storyteller Antag Low pop:<a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_lowpop;'>[current_storyteller.min_antag_popcount]</a>"
			dat += "<BR><font color='#888888'><i>Это значение устанавливает то, сколько игроков считается минимально-необходимым для спавна антагонистов</i></font>"
			dat += "<BR>Guarantees Roundstart Roleset: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_guarante_roundstart;'>[current_storyteller.guarantees_roundstart_roleset ? "TRUE" : "FALSE" ]</a>"
			dat += "<BR>Storyteller Antag Cap Formula: floor((pop_count + secs * sec_antag_modifier) / denominator)[!SSticker.HasRoundStarted() ? " *  roundstart cap multiplier" : ""] + addiction"
			dat += "<BR>Storyteller Antag Cap Result: floor(([get_correct_popcount()] + [length(department_crew_count[STS_SEC])] * [current_storyteller.sec_antag_modifier]) / [current_storyteller.antag_denominator])[!SSticker.HasRoundStarted() ? " * [current_storyteller.roundstart_cap_multiplier]" : ""]  + [current_storyteller.antag_flat_cap]"
			dat += "<BR>Sec antag modifier: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_sec_antag;'>[current_storyteller.sec_antag_modifier]</a>"
			dat += "<BR>Antag addiction: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_addiction;'>[current_storyteller.antag_flat_cap]</a>"
			if(!SSticker.HasRoundStarted())
				dat += "<BR>Antag roundstart cap multiplier: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_cap_mult;'>[current_storyteller.roundstart_cap_multiplier]</a>"
			dat += "<BR>Antag denominator: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_denominator;'>[current_storyteller.antag_denominator]</a>"
			dat += "<BR><font color='#888888'><i>Эта настройка влияет на то, сколько антагонистов может заспавниться максимум на 1 члена экипажа.</i></font>"
			dat += "<HR>"

			if(!SSticker.HasRoundStarted())
				handle_pre_setup_occupations()
				recalculate_ready_pop()
				recalculate_roundstart_costs(EVENT_TRACK_ROLESET)
				recalculate_roundstart_budget()
				dat += "<BR><b>Storyteller Roundstart Values:</b>"

				dat += "<BR>Sec info: Full sec crew = [length(full_department_roles[STS_SEC])], Players with High Sec = [length(department_crew_count[STS_SEC])]"
				dat += "<BR><font color='#888888'><i>Отображает максимальное количество ролей с пометкой СБ, у скольких игроков эти должности в высоком приоритете и сколько нехватка.</i></font>"
				dat += "<BR>Roundstart info: Roundstart budget = ready_players([ready_players]) + (sec_crew([length(department_crew_count[STS_SEC])]) * current_storyteller.sec_antag_modifier([current_storyteller.sec_antag_modifier])) = [roundstart_budget]"
				dat += "<BR><font color='#888888'><i>Раундстартовый бюджет для событий, расчитанный с помощью формулы выше.</i></font>"
				dat += "<BR>Roundstart info: Forced Roundstart budget = <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_roundstart_budget;'>[roundstart_budget_set]</a>"
				dat += "<BR><font color='#888888'><i>Зафоршенный андминами раундстарт бюджет. Установите -1 для автоматического расчета.</i></font>"
				dat += "<HR>"

			dat += "<BR><b>Point Gains Multipliers (only over time):</b>"
			dat += "<BR>Basic all tracks multiplayer: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_basemult;'>[current_storyteller.point_gain_base_mult]</a>"
			dat += "<BR><font color='#888888'><i>This affects points gained over time towards scheduling new events of the tracks.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=pts_multiplier;track=[track]'>[point_gain_multipliers[track]]</a>"
			dat += "<HR>"

			dat += "<b>Roundstart Points Multipliers:</b>"
			dat += "<BR><font color='#888888'><i>This affects points generated for roundstart events and antagonists.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=roundstart_pts;track=[track]'>[current_storyteller.roundstart_point_multipliers[track]]</a>"
			dat += "<HR>"

			dat += "<b>Minimum Population for Tracks:</b>"
			dat += "<BR><font color='#888888'><i>This are the minimum population caps for events to be able to run.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=min_pop;track=[track]'>[min_pop_thresholds[track]]</a>"
			dat += "<HR>"

			dat += "<b>Point Thresholds:</b>"
			dat += "<BR><font color='#888888'><i>Those are thresholds the tracks require to reach with points to make an event.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=pts_threshold;track=[track]'>[point_thresholds[track]]</a>"

		if(GAMEMODE_PANEL_MAIN)
			var/even = TRUE
			dat += "<h2>Event Tracks:</h2>"
			dat += "<font color='#888888'><i>Every track represents progression towards scheduling an event of it's severity</i></font>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=25%><b>Track</b></td>"
			dat += "<td width=20%><b>Progress</b></td>"
			dat += "<td width=10%><b>Next</b></td>"
			dat += "<td width=10%><b>Forced</b></td>"
			dat += "<td width=35%><b>Actions</b></td>"
			dat += "</tr>"
			for(var/track in event_tracks)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				var/lower = event_track_points[track]
				var/upper = point_thresholds[track]
				var/percent = round((lower/upper)*100)
				var/next = 0
				var/last_points = last_point_gains[track] != 0 ? last_point_gains[track] : 1
				if(last_points)
					next = round(((upper - lower) / last_points / STORYTELLER_WAIT_TIME))
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[track] - [last_points] per process.</td>" //Track
				dat += "<td>[percent]% ([lower]/[upper])</td>" //Progress
				dat += "<td>~[next] seconds</td>" //Next
				var/list/forced_events = forced_next_events[track]
				var/forced = ""
				for(var/datum/round_event_control/forced_event in forced_events)
					var/event_data = "[forced_event.name] <a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=remove_forced;track=[track];forced_event_to_remove=[forced_event]'>X</a></BR>"
					if(ispath(forced_event.type, /datum/round_event_control/antagonist))
						var/datum/round_event_control/antagonist/forced_antag_event = forced_event
						event_data = "[forced_antag_event.name][forced_antag_event?.forced_antags_count > 0 ? "([forced_antag_event?.forced_antags_count])": ""] <a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=remove_forced;track=[track];forced_event_to_remove=[forced_event]'>X</a></BR>"
					forced = forced + event_data
				dat += "<td>[forced]</td>" //Forced
				dat += "<td><a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=set_pts;track=[track]'>Set Pts.</a> <a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=next_event;track=[track]'>Next Event</a></td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Scheduled Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "<td width=17%><b>Severity</b></td>"
			dat += "<td width=12%><b>Time</b></td>"
			dat += "<td width=41%><b>Actions</b></td>"
			dat += "</tr>"
			var/sorted_scheduled = list()
			for(var/datum/scheduled_event/scheduled as anything in scheduled_events)
				sorted_scheduled[scheduled] = scheduled.start_time
			sortTim(sorted_scheduled, cmp=/proc/cmp_numeric_asc, associative = TRUE)
			even = TRUE
			for(var/datum/scheduled_event/scheduled as anything in sorted_scheduled)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[scheduled.event.name]</td>" //Name
				dat += "<td>[scheduled.event.track]</td>" //Severity
				var/time = (scheduled.event.roundstart && !round_started) ? "ROUNDSTART" : "[(scheduled.start_time - world.time) / (1 SECONDS)] s."
				dat += "<td>[time]</td>" //Time
				dat += "<td>[scheduled.get_href_actions()]</td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Running Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "<td width=70%><b>Actions</b></td>"
			dat += "</tr>"
			even = TRUE
			for(var/datum/round_event/event as anything in running)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[event.control.name]</td>" //Name
				dat += "<td>-TBA-</td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Runned Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "</tr>"
			even = TRUE
			for(var/event as anything in runned_events)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[event]</td>" //Name
				dat += "</tr>"
			dat += "</table>"

	var/datum/browser/popup = new(user, "gamemode_admin_panel", "Gamemode Panel", 670, 650)
	popup.set_content(dat.Join())
	popup.open()

 /// Panel containing information and actions regarding events
/datum/controller/subsystem/gamemode/proc/event_panel(mob/user)
	var/list/dat = list()
	if(!SSticker.HasRoundStarted())
		handle_pre_setup_occupations()
		recalculate_ready_pop()
		recalculate_roundstart_costs(EVENT_TRACK_ROLESET)
		recalculate_roundstart_budget()

	if(current_storyteller)
		dat += "Storyteller: [current_storyteller.name]"
		dat += "<BR>Repetition penalty multiplier: [current_storyteller.event_repetition_multiplier]"
		dat += "<BR>Cost variance: [current_storyteller.cost_variance][SSticker.HasRoundStarted() ? "" : ", roundstart_budget = <a href='byond://?src=[REF(src)];panel=main;action=vars;var=vars_roundstart_budget;'>[roundstart_budget]</a>"]"
		if(current_storyteller.tag_multipliers)
			dat += "<BR>Tag multipliers:"
			for(var/tag in current_storyteller.tag_multipliers)
				dat += "[tag]:[current_storyteller.tag_multipliers[tag]] | "
		current_storyteller.calculate_weights(statistics_track_page)
	else
		dat += "Storyteller: None<BR>Weight and chance statistics will be inaccurate due to the present lack of a storyteller."

	dat += "<BR><a href='byond://?src=[REF(src)];panel=stats;action=set_roundstart'[roundstart_event_view ? "class='linkOn'" : ""]>Roundstart Events</a> Forced Roundstart events will use rolled points, and are guaranteed to trigger (even if the used points are not enough)"
	dat += "<BR>Avg. event intervals: "
	for(var/track in event_tracks)
		if(last_point_gains[track])
			var/lower = event_track_points[track]
			var/upper = point_thresholds[track]
			var/last_points = last_point_gains[track] != 0 ? last_point_gains[track] : 1
			var/est_time = round(((upper - lower) / last_points / STORYTELLER_WAIT_TIME))
			dat += "[track]: ~[est_time] secs. | "
	dat += "<HR>"
	for(var/track in EVENT_PANEL_TRACKS)
		dat += "<a href='byond://?src=[REF(src)];panel=stats;action=set_cat;cat=[track]'[(statistics_track_page == track) ? "class='linkOn'" : ""]>[track]</a>"
	dat += "<HR>"
	/// Create event info and stats table
	dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
	dat += "<tr style='vertical-align:top'>"
	dat += "<td width=17%><b>Name</b></td>"
	dat += "<td width=16%><b>Tags</b></td>"
	dat += "<td width=8%><b>Occurences</b></td>"
	dat += "<td width=8%><b>Max Occurences</b></td>"
	dat += "<td width=5%><b>M.Pop</b></td>"
	dat += "<td width=5%><b>M.Time</b></td>"
	dat += "<td width=7%><b>Can Occur</b></td>"
	dat += "<td width=7%><b>Failure Reason</b></td>"
	dat += "<td width=16%><b>[!SSticker.HasRoundStarted() ? "Cost/" : ""]Weight</b></td>"
	dat += "<td width=26%><b>Actions</b></td>"
	dat += "</tr>"
	var/even = TRUE
	var/total_weight = 0
	var/list/event_lookup
	switch(statistics_track_page)
		if(ALL_EVENTS)
			event_lookup = control
		if(UNCATEGORIZED_EVENTS)
			event_lookup = uncategorized
		else
			event_lookup = event_pools[statistics_track_page]
	var/list/assoc_spawn_weight = list()
	for(var/datum/round_event_control/event as anything in event_lookup)
		var/players_amt = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
		if(event.roundstart != roundstart_event_view)
			continue
		if(event.can_spawn_event(players_amt))
			total_weight += event.calculated_weight
			assoc_spawn_weight[event] = event.calculated_weight
		else
			assoc_spawn_weight[event] = 0
	sortTim(assoc_spawn_weight, cmp=/proc/cmp_numeric_dsc, associative = TRUE)
	for(var/datum/round_event_control/event as anything in assoc_spawn_weight)
		even = !even
		var/background_cl = even ? "#17191C" : "#23273C"
		dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
		dat += "<td>[event.name]</td>" //Name
		dat += "<td>" //Tags
		for(var/tag in event.tags)
			dat += "[tag] "
		dat += "</td>"
		var/occurence_string = "[event.occurrences]"
		if(event.shared_occurence_type)
			occurence_string += " (shared: [event.get_occurences()])"
		var/max_occurence_string = "[event.max_occurrences]"
		dat += "<td>[occurence_string]</td>" //Occurences
		dat += "<td>[max_occurence_string]</td>" //Max Occurences
		dat += "<td>[event.min_players]</td>" //Minimum pop
		dat += "<td>[event.earliest_start / (1 MINUTES)] m.</td>" //Minimum time
		dat += "<td>[assoc_spawn_weight[event] ? "Yes" : "No"]</td>" //Can happen?
		dat += "<td>[event.return_failure_string(active_players)]</td>" //Why can't happen?
		var/weight_string = "(new.[event.calculated_weight] /raw.[event.weight])"
		if(assoc_spawn_weight[event])
			var/percent = round((event.calculated_weight / total_weight) * 100)
			weight_string = "[event.calculated_on_track_weight]% - [percent]% - [weight_string]"
		dat += "<td>[SSticker.HasRoundStarted() && !event.get_pre_cost() ? weight_string : "[event.get_pre_cost()]/[weight_string]"]</td>" //Weight
		dat += "<td>[event.get_href_actions()]</td>" //Actions
		dat += "</tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "gamemode_event_panel", "Event Panel", 1100, 600)
	popup.set_content(dat.Join())
	popup.open()

/datum/controller/subsystem/gamemode/Topic(href, href_list)
	. = ..()
	var/mob/user = usr
	if(!check_rights(R_ADMIN))
		return
	switch(href_list["panel"])
		if("main")
			switch(href_list["action"])
				if("set_storyteller")
					message_admins("[key_name_admin(usr)] is picking a new Storyteller.")
					var/list/name_list = list()
					for(var/storyteller_type in storytellers)
						var/datum/storyteller/storyboy = storytellers[storyteller_type]
						name_list[storyboy.name] = storyboy.type
					var/new_storyteller_name = input(usr, "Choose new storyteller (circumvents voted one):", "Storyteller")  as null|anything in name_list
					if(!new_storyteller_name)
						message_admins("[key_name_admin(usr)] has cancelled picking a Storyteller.")
						return
					message_admins("[key_name_admin(usr)] has chosen [new_storyteller_name] as the new Storyteller.")
					var/new_storyteller_type = name_list[new_storyteller_name]
					set_storyteller(new_storyteller_type)
				if("halt_storyteller")
					halted_storyteller = !halted_storyteller
					message_admins("[key_name_admin(usr)] has [halted_storyteller ? "HALTED" : "un-halted"] the Storyteller.")
				if("vars")
					var/track = href_list["track"]
					switch(href_list["var"])
						if("pts_multiplier")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set point gain multiplier for [track] track to [new_value].")
							point_gain_multipliers[track] = new_value
						if("roundstart_pts")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set roundstart pts multiplier for [track] track to [new_value].")
							current_storyteller.roundstart_point_multipliers[track] = new_value
						if("min_pop")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set minimum population for [track] track to [new_value].")
							min_pop_thresholds[track] = new_value
						if("pts_threshold")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set point threshold of [track] track to [new_value].")
							point_thresholds[track] = new_value
						if("vars_addiction")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set addictive antags to [new_value].")
							current_storyteller.antag_flat_cap = new_value
						if("vars_sec_antag")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set sec antag modifier to [new_value].")
							current_storyteller.sec_antag_modifier = new_value
						if("vars_denominator")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set antags denominator to [new_value].")
							current_storyteller.antag_denominator = new_value
						if("vars_lowpop")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set low pop count to [new_value].")
							current_storyteller.min_antag_popcount = new_value
						if("vars_basemult")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set basic storyteller multiplier to [new_value].")
							current_storyteller.point_gain_base_mult = new_value
						if("vars_cap_mult")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set basic storyteller cap multiplier to [new_value].")
							current_storyteller.roundstart_cap_multiplier = new_value
						if("vars_guarante_roundstart")
							var/new_value = !current_storyteller.guarantees_roundstart_roleset
							message_admins("[key_name_admin(usr)] set basic storyteller multiplier to [new_value].")
							current_storyteller.guarantees_roundstart_roleset = new_value
						if("vars_roundstart_budget")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set forced roundstart budget to [new_value].")
							roundstart_budget_set = new_value
						if("vars_storyteller_basic_modifier")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set storyteller basic cost modifier to [new_value].")
							current_storyteller.storyteller_basic_modifier = new_value
				if("reload_config_vars")
					message_admins("[key_name_admin(usr)] reloaded gamemode config vars.")
					load_config_vars()
				if("tab")
					var/tab = href_list["tab"]
					panel_page = tab
				if("open_stats")
					event_panel(user)
					return
				if("track_action")
					var/track = href_list["track"]
					if(!(track in event_tracks))
						return
					switch(href_list["track_action"])
						if("remove_forced")
							if(forced_next_events[track])
								var/datum/round_event_control/forced_event_to_remove
								for(var/datum/round_event_control/forced_event_to_check in forced_next_events[track])
									if(forced_event_to_check.name == href_list["forced_event_to_remove"])
										forced_event_to_remove = forced_event_to_check
								if(!forced_event_to_remove)
									return
								message_admins("[key_name_admin(usr)] removed forced event [forced_event_to_remove.name] from track [forced_event_to_remove.track].")
								forced_next_events[track] -= forced_event_to_remove
						if("set_pts")
							var/set_pts = input(usr, "New point amount ([point_thresholds[track]]+ invokes event):", "Set points for [track]") as num|null
							if(isnull(set_pts))
								return
							event_track_points[track] = set_pts
							message_admins("[key_name_admin(usr)] set points of [track] track to [set_pts].")
							log_admin_private("[key_name(usr)] set points of [track] track to [set_pts].")
						if("next_event")
							message_admins("[key_name_admin(usr)] invoked next event for [track] track.")
							log_admin_private("[key_name(usr)] invoked next event for [track] track.")
							event_track_points[track] = point_thresholds[track]
							if(current_storyteller)
								current_storyteller.handle_tracks()
			admin_panel(user)
		if("stats")
			switch(href_list["action"])
				if("set_roundstart")
					roundstart_event_view = !roundstart_event_view
				if("set_cat")
					var/new_category = href_list["cat"]
					if(new_category in EVENT_PANEL_TRACKS)
						statistics_track_page = new_category
			event_panel(user)

/datum/controller/subsystem/gamemode/proc/round_end_report()
	if(!length(round_end_data))
		return
	for(var/datum/round_event/event as anything in round_end_data)
		if(!istype(event))
			continue
		event.round_end_report()

/datum/controller/subsystem/gamemode/proc/store_roundend_data()
	var/congealed_string = ""
	for(var/event_name as anything in triggered_round_events)
		congealed_string += event_name
		congealed_string += ","
	text2file(congealed_string, "data/last_round_events.txt")

/datum/controller/subsystem/gamemode/proc/load_roundstart_data()
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, lazy_load_template), LAZY_TEMPLATE_KEY_NUKIEBASE)
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, lazy_load_template), LAZY_TEMPLATE_KEY_WIZARDDEN)

	var/department
	for(var/datum/job/check_role in SSjob.all_occupations)
		if(check_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			department = STS_HEAD
		if(check_role.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)
			department = STS_ENG
		if(check_role.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
			department = STS_MED
		if(check_role.departments_bitflags & DEPARTMENT_BITFLAG_SCIENCE)
			department = STS_RND
		if(check_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			department = STS_SEC
		if(department)
			for(var/i = 0; i < check_role.total_positions; i++)
				full_department_roles[department] += check_role.title

	var/massive_string = trim(file2text("data/last_round_events.txt"))
	if(fexists("data/last_round_events.txt"))
		fdel("data/last_round_events.txt")
	if(!massive_string)
		return
	last_round_events = splittext(massive_string, ",")

	if(!length(last_round_events))
		return
	for(var/event_name as anything in last_round_events)
		for(var/datum/round_event_control/listed as anything in control)
			if(listed.name != event_name)
				continue
			listed.occurrences++
			listed.occurrences++

/datum/controller/subsystem/gamemode/proc/get_antag_count_by_type(type)
	var/count = 0
	if(!type)
		return count

	for(var/datum/antagonist/antag_datum_element in GLOB.antagonists)
		if(antag_datum_element.type == type)
			count++

	return count

/datum/controller/subsystem/gamemode/proc/left_antag_count_by_type(control)
	var/datum/round_event_control/antagonist/solo/cast_control = control
	var/left = cast_control.maximum_antags_per_round - get_antag_count_by_type(cast_control.antag_datum)
	return left

/datum/controller/subsystem/gamemode/proc/create_roundend_score()
	var/list/parts = list()
	parts += "<div class='panel stationborder'><span class='header'>[("Storyteller: [SSgamemode.current_storyteller ? SSgamemode.current_storyteller.name : "N/A"]")]</span><br><br>"
	parts += "Spawned durning this round events:<br>"
	for(var/i in SSgamemode.runned_events)
		parts += "<span class='info ml-1'>[i]</span><br>"

	parts += "</div>"
	return parts

#undef DEFAULT_STORYTELLER_VOTE_OPTIONS
#undef MAX_POP_FOR_STORYTELLER_VOTE
#undef ROUNDSTART_VALID_TIMEFRAME
#undef STATION_REPORT_TEMPLATE_PATH
