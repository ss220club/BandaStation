/**
 * Calculates the candidate weight for a player based on their recent antagonist activity.
 *
 * * recent_episodes - The number of recent antagonist episodes
 * * candidate_ckey - The ckey of the player, used to apply Bandastation bonus adjustments
 *
 * Returns a weight value (higher = more likely to be selected)
 */

/proc/get_candidate_antag_hours(candidate_ckey)
	if(!candidate_ckey)
		return 0

	var/client/C = GLOB.persistent_clients_by_ckey[candidate_ckey]?.client
	if(C)
		return C.calc_exp_type(EXP_TYPE_ANTAG)

	if(!SSdbcore.Connect())
		return 0

	var/list/antag_job_titles = list()
	for(var/datum/job/job as anything in SSjob.experience_jobs_map[EXP_TYPE_ANTAG])
		antag_job_titles += job.title
	if(!length(antag_job_titles))
		return 0

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT SUM(minutes) FROM [format_table_name("role_time")]
		WHERE ckey = :ckey
		AND job IN (\"[jointext(antag_job_titles, '\", \"')]\")
	"}, list("ckey" = candidate_ckey))
	if(!query.Execute())
		qdel(query)
		return 0

	var/minutes = 0
	if(query.NextRow())
		minutes = text2num(query.item[1]) || 0
	qdel(query)

	return minutes

/proc/get_candidate_antag_hours_bonus(candidate_ckey)
	var/minutes = get_candidate_antag_hours(candidate_ckey)
	var/hours = floor(minutes / 60)
	var/step = min(5, floor(hours / 10))
	return max(0, 2 - (0.4 * step))

/proc/get_candidate_rounds_since_last_antag(candidate_ckey)
	if(!candidate_ckey)
		return 0
	if(!GLOB.round_id)
		return 0
	if(!SSdbcore.Connect())
		return 0

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT MAX(f.round_id) FROM [format_table_name(\"feedback\")] f
		CROSS JOIN JSON_TABLE(
			f.json,
			'$.data.*' COLUMNS (
				ckey_field VARCHAR(32) PATH '$.key'
			)
		) AS antagonist
		WHERE f.key_name = 'antagonists'
		AND antagonist.ckey_field = :ckey
	"}, list("ckey" = candidate_ckey))
	if(!query.Execute())
		qdel(query)
		return 0

	var/last_antag_round_id = 0
	if(query.NextRow())
		last_antag_round_id = text2num(query.item[1]) || 0
	qdel(query)

	var/rounds = max(0, GLOB.round_id - last_antag_round_id - 1)
	return min(rounds, 25)

/proc/get_candidate_rounds_without_antag_bonus(candidate_ckey)
	return get_candidate_rounds_since_last_antag(candidate_ckey) * 0.2

/proc/get_candidate_days_absent(candidate_ckey)
	if(!candidate_ckey)
		return 0
	var/client/C = GLOB.persistent_clients_by_ckey[candidate_ckey]?.client
	if(C)
		return 0

	if(!SSdbcore.Connect())
		return 0

	// Get days since last played any role (from role_time table)
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT DATEDIFF(Now(), MAX(end_time)) FROM [format_table_name(\"role_time\")] WHERE ckey = :ckey",
		list("ckey" = candidate_ckey)
	)
	if(!query.Execute())
		qdel(query)
		return 0

	var/days = 0
	if(query.NextRow())
		days = text2num(query.item[1]) || 0
	qdel(query)

	return min(days, 5)

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

	if(!CONFIG_GET(flag/antag_weighted_selection))
		return TRUE

	var/base_weight = CONFIG_GET(number/antag_base_weight)
	var/current_weight = get_candidate_weight(candidate.ckey)
	var/selection_chance = 100 * current_weight / base_weight

	if(prob(selection_chance))
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
	var/weight = calculate_candidate_weight(recent_episodes, candidate_ckey)

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
