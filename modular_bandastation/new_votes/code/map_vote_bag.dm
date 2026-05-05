#define BAG_CONFIG_FILE "config/bag.txt"
#define BAG_STATE_FILE "data/bag_state.json"

/datum/controller/subsystem/map_vote
	/// Full bag composition from config: map_name -> copy count.
	var/list/initial_bag = list()
	/// Read-only mirror of initial_bag as loaded from config file. Never modified by UI.
	var/list/config_bag = list()
	/// Current remaining bag: flat list of map_names (duplicates = multiple copies).
	var/list/remaining_bag = list()
	/// Last played map name, used to enforce the no-repeat rule.
	var/last_played_map
	/// Snapshot before finalize, restored on revert.
	var/list/previous_remaining_bag
	var/previous_last_played_map

/// Replaces old tally-based Initialize.
/datum/controller/subsystem/map_vote/Initialize()
	load_bag_config()
	load_bag_state()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/map_vote/proc/load_bag_config()
	initial_bag = list()
	config_bag = list()
	if(!rustg_file_exists(BAG_CONFIG_FILE))
		log_world("WARNING: [BAG_CONFIG_FILE] not found. Map bag will be empty.")
		return
	for(var/line in splittext(rustg_file_read(BAG_CONFIG_FILE), "\n"))
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
		initial_bag[map_name] = count
		config_bag[map_name] = count

/datum/controller/subsystem/map_vote/proc/load_bag_state()
	if(rustg_file_exists(BAG_STATE_FILE))
		var/list/state = json_decode(rustg_file_read(BAG_STATE_FILE))
		if(!islist(state))
			refill_bag()
			return
		remaining_bag = state["remaining"] || list()
		last_played_map = state["last_played"]
		var/list/clean = list()
		for(var/map_name in remaining_bag)
			if(map_name in initial_bag)
				clean += map_name
		remaining_bag = clean
		if(!length(remaining_bag))
			refill_bag()
	else
		refill_bag()
	save_bag_state()

/datum/controller/subsystem/map_vote/proc/save_bag_state()
	rustg_file_write(json_encode(list(
		"remaining" = remaining_bag,
		"last_played" = last_played_map,
	)), BAG_STATE_FILE)

/datum/controller/subsystem/map_vote/proc/refill_bag()
	remaining_bag = list()
	for(var/map_name in initial_bag)
		for(var/i in 1 to initial_bag[map_name])
			remaining_bag += map_name

/// Returns deduplicated list of unique map names currently in remaining_bag.
/datum/controller/subsystem/map_vote/proc/get_bag_options()
	return unique_list(remaining_bag)

/// Replaces old tally/pop-filter logic.
/datum/controller/subsystem/map_vote/get_valid_map_vote_choices()
	var/list/options = get_bag_options()
	if(last_played_map && (last_played_map in options))
		options -= last_played_map
	return options

/datum/controller/subsystem/map_vote/proc/check_bag_before_vote()
	var/list/options = get_valid_map_vote_choices()

	if(!length(options))
		if(!last_played_map || !length(remaining_bag))
			return null
		var/all_repeats = TRUE
		for(var/map_name in remaining_bag)
			if(map_name != last_played_map)
				all_repeats = FALSE
				break
		if(all_repeats)
			return "REFILL"
		return null

	if(length(options) == 1)
		return options[1]

	if(length(options) <= 3 && last_played_map)
		var/repeat_count = 0
		for(var/map_name in remaining_bag)
			if(map_name == last_played_map)
				repeat_count++
		if(repeat_count > length(remaining_bag) / 2)
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

	previous_remaining_bag = remaining_bag.Copy()
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
		var/list/options = SSmap_vote.remaining_bag?.Copy() || list()
		if(last_played_map)
			options -= last_played_map
		if(!length(options))
			options = SSmap_vote.remaining_bag?.Copy() || list()
		winner = length(options) ? pick(options) : null

	if(!winner)
		message_admins("Map vote: пул пустой! Наполните пул для голосования.")
		already_voted = FALSE
		return

	remove_from_bag(winner)
	last_played_map = winner

	save_bag_state()
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

/// Remove one copy of map_name from remaining_bag.
/datum/controller/subsystem/map_vote/proc/remove_from_bag(map_name)
	var/idx = remaining_bag.Find(map_name)
	if(idx)
		remaining_bag.Cut(idx, idx + 1)

/// Automatically select next map when only one unique map is available.
/datum/controller/subsystem/map_vote/proc/auto_select_single_map(map_name)
	previous_remaining_bag = remaining_bag.Copy()
	previous_last_played_map = last_played_map
	var/datum/map_config/display_map_datum = config.maplist[map_name]
	set_next_map(display_map_datum)
	remove_from_bag(map_name)
	if(!length(remaining_bag))
		refill_bag()
	last_played_map = map_name
	var/display_name = display_map_datum?.map_name || map_name
	for(var/client/C in GLOB.clients)
		SEND_SOUND(C, sound('sound/misc/bloop.ogg'))
	send_map_vote_notice("Следующая карта — [span_bold(display_name)].")
	save_bag_state()

/// Replaces old cache-restore revert.
/datum/controller/subsystem/map_vote/revert_next_map(client/user)
	if(!next_map_config)
		return
	if(previous_remaining_bag)
		remaining_bag = previous_remaining_bag
		previous_remaining_bag = null
	last_played_map = previous_last_played_map
	previous_last_played_map = null
	already_voted = FALSE
	admin_override = FALSE
	next_map_config = null
	save_bag_state()
	if(!isnull(user))
		message_admins("[key_name_admin(user)] has reverted the next map selection. Voting re-enabled.")
		log_admin("[key_name_admin(user)] reverted the next map selection.")
	send_map_vote_notice("Следующая карта отменена. Голосование снова доступно.")

#undef BAG_CONFIG_FILE
#undef BAG_STATE_FILE
