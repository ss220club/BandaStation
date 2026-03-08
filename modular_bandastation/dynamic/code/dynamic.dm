/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * candidate_ckey - The ckey of the player
 *
 * Returns a weight value (higher = more likely to be selected)
 */
/datum/dynamic_ruleset/proc/calculate_candidate_weight(candidate_ckey)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	if(!candidate_ckey)
		return CONFIG_GET(number/antag_base_weight)

	var/time_window = CONFIG_GET(number/antag_history_window_days)
	var/base_weight = CONFIG_GET(number/antag_base_weight)
	var/penalty_per_episode = CONFIG_GET(number/antag_weight_penalty)
	var/min_weight = CONFIG_GET(number/antag_min_weight)
	var/list/ignored_antagonists = CONFIG_GET(str_list/ignored_antagonists)

	var/recent_episodes = count_player_antag_episodes(candidate_ckey, time_window, ignored_antagonists)
	var/weight = max(base_weight - (recent_episodes * penalty_per_episode), min_weight)

	if(CONFIG_GET(flag/log_antag_candidate_weight))
		log_dynamic("Weight calculation for [candidate_ckey]: base=[base_weight], recent=[recent_episodes], penalty=[penalty_per_episode], final=[weight]")

	return weight
