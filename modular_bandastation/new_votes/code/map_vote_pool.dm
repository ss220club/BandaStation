#define POOL_CONFIG_FILE "config/map_pool.txt"
#define POOL_STATE_FILE "data/map_pool_state.json"

/datum/controller/subsystem/map_vote
	/// Full pool composition from config: map_name -> copy count.
	var/list/initial_pool = list()
	/// Read-only mirror of initial_pool as loaded from config file. Never modified by UI.
	var/list/config_pool = list()
	/// Current remaining pool: flat list of map_names (duplicates = multiple copies).
	var/list/remaining_pool = list()
	/// Last played map name, used to enforce the no-repeat rule.
	var/last_played_map
	/// Snapshot before finalize, restored on revert.
	var/list/previous_remaining_pool
	var/previous_last_played_map

/// Replaces old tally-based Initialize.
/datum/controller/subsystem/map_vote/Initialize()
	load_pool_config()
	load_pool_state()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/map_vote/proc/load_pool_config()
	initial_pool = list()
	config_pool = list()
	if(!rustg_file_exists(POOL_CONFIG_FILE))
		log_world("WARNING: [POOL_CONFIG_FILE] not found. Map pool will be empty.")
		return
	for(var/line in splittext(rustg_file_read(POOL_CONFIG_FILE), "\n"))
		line = trim(line)
		if(!line || copytext(line, 1, 3) == "##")
			continue
		var/last_space = findlasttext(line, " ")
		if(!last_space)
			continue
		var/map_name = trim(copytext(line, 1, last_space))
		var/count = text2num(copytext(line, last_space + 1))
		if(!count || count <= 0)
			continue
		if(!(map_name in config.maplist))
			log_world("WARNING: Bag config: unknown map '[map_name]', skipping.")
			continue
		initial_pool[map_name] = count
		config_pool[map_name] = count

/datum/controller/subsystem/map_vote/proc/load_pool_state()
	if(rustg_file_exists(POOL_STATE_FILE))
		var/list/state = json_decode(rustg_file_read(POOL_STATE_FILE))
		if(!islist(state))
			refill_pool()
			return
		remaining_pool = state["remaining"] || list()
		last_played_map = state["last_played"]
		var/list/clean = list()
		for(var/map_name in remaining_pool)
			if(map_name in initial_pool)
				clean += map_name
		remaining_pool = clean
		if(!length(remaining_pool))
			refill_pool()
	else
		refill_pool()
	save_pool_state()

/datum/controller/subsystem/map_vote/proc/save_pool_state()
	rustg_file_write(json_encode(list(
		"remaining" = remaining_pool,
		"last_played" = last_played_map,
	)), POOL_STATE_FILE)

/datum/controller/subsystem/map_vote/proc/refill_pool()
	remaining_pool = list()
	for(var/map_name in initial_pool)
		for(var/i in 1 to initial_pool[map_name])
			remaining_pool += map_name

/// Returns deduplicated list of unique map names currently in remaining_pool.
/datum/controller/subsystem/map_vote/proc/get_pool_options()
	return unique_list(remaining_pool)

/datum/controller/subsystem/map_vote/proc/get_population_threshold()
	if(SSticker.HasRoundStarted())
		return get_active_player_count(alive_check = FALSE, afk_check = TRUE, human_check = FALSE)
	return length(GLOB.clients)

/// Returns unique map names currently in remaining_pool that match current population limits.
/datum/controller/subsystem/map_vote/proc/get_pop_valid_pool_options()
	var/filter_threshold = get_population_threshold()
	var/list/options = get_pool_options()
	var/list/out = list()
	for(var/map_name in options)
		var/datum/map_config/mc = config.maplist[map_name]
		if(!mc?.votable || (mc.map_name in SSpersistence.blocked_maps))
			continue
		if(mc.config_min_users > 0 && filter_threshold < mc.config_min_users)
			continue
		if(mc.config_max_users > 0 && filter_threshold > mc.config_max_users)
			continue
		out += map_name
	return out

/datum/controller/subsystem/map_vote/proc/get_pool_refill_reason()
	var/list/pop_options = get_pop_valid_pool_options()

	if(!length(pop_options))
		return "no maps match the current pop. Refilling now."

	if(length(pop_options) == 1 && pop_options[1] == last_played_map)
		return "the only map left doesn't match the pop. Refilling now."

	var/list/no_repeat = pop_options.Copy()
	if(last_played_map && (last_played_map in no_repeat))
		no_repeat -= last_played_map
	if(!length(no_repeat))
		return "no variants left. Refilling now."

	return null

/// Replaces old tally/pop-filter logic.
/datum/controller/subsystem/map_vote/get_valid_map_vote_choices()
	var/list/options = get_pop_valid_pool_options()
	if(last_played_map && (last_played_map in options))
		options -= last_played_map
	return options

/datum/controller/subsystem/map_vote/proc/check_pool_before_vote()
	var/list/pop_options = get_pop_valid_pool_options()

	if(!length(pop_options))
		return "REFILL"

	if(length(pop_options) == 1)
		if(pop_options[1] == last_played_map)
			return "REFILL"
		return pop_options[1]

	var/list/options = pop_options.Copy()
	if(last_played_map && (last_played_map in options))
		options -= last_played_map

	if(!length(options))
		return "REFILL"

	if(length(options) <= 3 && last_played_map)
		var/repeat_count = 0
		for(var/map_name in remaining_pool)
			if(map_name == last_played_map)
				repeat_count++
		if(repeat_count > length(remaining_pool) / 2)
			for(var/map_name in options)
				if(map_name != last_played_map)
					return map_name

	return null

/// Replaces old tally-accumulation finalize.
/datum/controller/subsystem/map_vote/finalize_map_vote(datum/vote/map_vote/map_vote)
	if(already_voted)
		message_admins("Attempted to finalize a map vote after a map vote has already been finalized.")
		return
	already_voted = TRUE

	if(admin_override)
		send_map_vote_notice("Admin Override is in effect. Map will not be changed.")
		return

	previous_remaining_pool = remaining_pool.Copy()
	previous_last_played_map = last_played_map

	var/winner
	var/winner_votes = 0
	for(var/map_name in map_vote.choices)
		if(map_vote.choices[map_name] > winner_votes)
			winner = map_name
			winner_votes = map_vote.choices[map_name]

	var/total_votes = 0
	for(var/map_name in map_vote.choices)
		total_votes += map_vote.choices[map_name]

	if(!winner || winner_votes == 0)
		var/list/options = SSmap_vote.remaining_pool?.Copy() || list()
		if(last_played_map)
			options -= last_played_map
		if(!length(options))
			options = SSmap_vote.remaining_pool?.Copy() || list()
		winner = length(options) ? pick(options) : null

	if(!winner)
		message_admins("Map vote: пул пустой! Наполните пул для голосования.")
		already_voted = FALSE
		return

	remove_from_pool(winner)
	last_played_map = winner

	save_pool_state()
	set_next_map(config.maplist[winner])

	if(length(map_vote.choices) > 1)
		var/list/messages = list()
		if(total_votes > 0)
			var/winner_pct = round(winner_votes / total_votes * 100, 1)
			messages += "Победитель: [span_bold(next_map_config.map_name)] — [winner_votes] голос. ([winner_pct]%)"
			messages += "Итоги голосования:"
			for(var/map_name in map_vote.choices)
				var/votes = map_vote.choices[map_name]
				var/pct = round(votes / total_votes * 100, 1)
				var/datum/map_config/mc = config.maplist[map_name]
				messages += "- [mc.map_name]: [votes] ([pct]%)"
		else
			messages += "Никто не проголосовал — карта выбрана случайно."
		send_map_vote_notice(arglist(messages))

/// Remove one copy of map_name from remaining_pool.
/datum/controller/subsystem/map_vote/proc/remove_from_pool(map_name)
	var/idx = remaining_pool.Find(map_name)
	if(idx)
		remaining_pool.Cut(idx, idx + 1)

/// Automatically select next map when only one unique map is available.
/datum/controller/subsystem/map_vote/proc/auto_select_single_map(map_name)
	previous_remaining_pool = remaining_pool.Copy()
	previous_last_played_map = last_played_map
	var/datum/map_config/display_map_datum = config.maplist[map_name]
	set_next_map(display_map_datum)
	remove_from_pool(map_name)
	if(!length(remaining_pool))
		refill_pool()
	last_played_map = map_name
	var/display_name = display_map_datum?.map_name || map_name
	for(var/client/C in GLOB.clients)
		SEND_SOUND(C, sound('sound/misc/bloop.ogg'))
	send_map_vote_notice("Следующая карта — [span_bold(display_name)].")
	save_pool_state()

/// Replaces old cache-restore revert.
/datum/controller/subsystem/map_vote/revert_next_map(client/user)
	if(!next_map_config)
		return
	if(previous_remaining_pool)
		remaining_pool = previous_remaining_pool
		previous_remaining_pool = null
	last_played_map = previous_last_played_map
	previous_last_played_map = null
	already_voted = FALSE
	admin_override = FALSE
	next_map_config = null
	save_pool_state()
	if(!isnull(user))
		message_admins("[key_name_admin(user)] has reverted the next map selection. Voting re-enabled.")
		log_admin("[key_name_admin(user)] reverted the next map selection.")
	send_map_vote_notice("Следующая карта отменена. Голосование снова доступно.")

#undef POOL_CONFIG_FILE
#undef POOL_STATE_FILE
