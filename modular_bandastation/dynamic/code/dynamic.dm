/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * recent_episodes - The number of recent antagonist episodes
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/proc/calculate_candidate_weight(recent_episodes)
	if(!recent_episodes)
		return CONFIG_GET(number/antag_base_weight)

	var/base_weight = CONFIG_GET(number/antag_base_weight)
	var/penalty_per_episode = CONFIG_GET(number/antag_weight_penalty)
	var/min_weight = CONFIG_GET(number/antag_min_weight)

	return max(base_weight - (recent_episodes * penalty_per_episode), min_weight)

/proc/get_antag_test_random(maximum)
	if(maximum <= 0)
		return

	var/const/random_range = 268435456
	if(maximum > random_range)
		CRASH("Antag test random maximum exceeds its supported range: [maximum]")

	var/static/last_round_id
	var/static/roll_number
	if(last_round_id != GLOB.round_id || isnull(roll_number))
		last_round_id = GLOB.round_id
		roll_number = 0

	var/usable_range = random_range - (random_range % maximum)
	while(TRUE)
		var/roll_id = roll_number++
		var/roll = hex2num(copytext(md5("[GLOB.round_id]:[roll_id]"), 1, 8))
		if(roll < usable_range)
			return roll % maximum + 1

/proc/pick_antag_test_weight(list/list_to_pick)
	if(!length(list_to_pick))
		return

	var/total_weight = 0
	for(var/item in list_to_pick)
		total_weight += list_to_pick[item]
	if(total_weight <= 0)
		return

	var/roll = get_antag_test_random(total_weight)
	for(var/item in list_to_pick)
		roll -= list_to_pick[item]
		if(roll <= 0)
			return item

/proc/antag_test_prob(chance)
	return get_antag_test_random(10000) <= clamp(round(chance * 100), 0, 10000)

/proc/log_antag_test_selection(selection_target, selection_phase, slots_required, list/mob/candidates, list/mob/candidate_weights, list/mob/actual_random_result, list/mob/hypothetical_weighted_result)
	var/list/weights_by_ckey = list()
	for(var/mob/candidate as anything in candidates)
		weights_by_ckey[candidate.ckey] = candidate_weights[candidate]

	var/list/actual_ckeys = list()
	for(var/mob/candidate as anything in actual_random_result)
		actual_ckeys += candidate.ckey

	var/list/hypothetical_ckeys = list()
	for(var/mob/candidate as anything in hypothetical_weighted_result)
		hypothetical_ckeys += candidate.ckey

	log_dynamic("Antag test selection", list(
		"round_id" = GLOB.round_id,
		"selection_target" = selection_target,
		"selection_phase" = selection_phase,
		"slots_required" = slots_required,
		"candidate_count" = length(candidates),
		"candidate_weights" = weights_by_ckey,
		"actual_random_result" = length(actual_ckeys) ? actual_ckeys : null,
		"hypothetical_weighted_result" = length(hypothetical_ckeys) ? hypothetical_ckeys : null,
	))

/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * candidate_ckey - The ckey of the player
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/datum/dynamic_ruleset/proc/get_candidate_weight(candidate_ckey)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!candidate_ckey)
		return CONFIG_GET(number/antag_base_weight)

	var/recent_episodes = count_player_antag_episodes(candidate_ckey)
	var/weight = calculate_candidate_weight(recent_episodes)

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("[config_tag]: Candidate weight for [candidate_ckey]: recent=[recent_episodes], final=[weight]")

	return weight

/**
 * Counts the number of antagonist episodes for a player in the known time window.
 *
 * * ckey - The ckey of the player
 *
 * Returns the number of antagonist episodes
 */
/datum/dynamic_ruleset/proc/count_player_antag_episodes(ckey)
	return 0

/datum/dynamic_ruleset/roundstart/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_roundstart)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)

/datum/dynamic_ruleset/midround/from_ghosts/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_midround)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)

/datum/dynamic_ruleset/latejoin/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_latejoin)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)

/datum/dynamic_ruleset/latejoin/is_valid_candidate(mob/candidate, client/candidate_client)
	if(!..())
		return FALSE

	return TRUE

/datum/dynamic_ruleset/latejoin/proc/passes_weight_check(candidate_ckey, current_weight = null)
	if(isnull(current_weight))
		current_weight = get_candidate_weight(candidate_ckey)

	var/base_weight = CONFIG_GET(number/antag_base_weight)
	var/selection_chance = 100 * current_weight / base_weight

	if(antag_test_prob(selection_chance))
		return TRUE

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("[config_tag]: Candidate [candidate_client.ckey] failed latejoin weight check ([selection_chance]%)")

	return FALSE

/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * candidate_ckey - The ckey of the player
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/datum/round_event/ghost_role/proc/get_candidate_weight(candidate_ckey)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!candidate_ckey)
		return CONFIG_GET(number/antag_base_weight)

	var/recent_episodes = count_player_antag_episodes(candidate_ckey)
	var/weight = calculate_candidate_weight(recent_episodes)

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("[role_name]: Candidate weight for [candidate_ckey]: recent=[recent_episodes], final=[weight]")

	return weight

/**
 * Counts the number of antagonist episodes for a player in the known time window.
 *
 * * ckey - The ckey of the player
 *
 * Returns the number of antagonist episodes
 */
/datum/round_event/ghost_role/proc/count_player_antag_episodes(ckey)
	var/days_back = CONFIG_GET(number/antag_history_window_days)
	var/list/tracked_antagonists = CONFIG_GET(str_list/tracked_antagonists_midround)
	return select_player_antag_episodes(ckey, days_back, tracked_antagonists)
