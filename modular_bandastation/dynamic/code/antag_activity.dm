/// Cache for count_player_antag_episodes() proc that performs a complex database query.
GLOBAL_ALIST_EMPTY(player_antag_episodes_cache)
GLOBAL_PROTECT(player_antag_episodes_cache)

/**
 * Gets the number of episodes a player has taken an antagonist role within a time window.
 *
 * * ckey - The player's ckey
 * * days_back - How many days back to check
 * * ignored_antagonists - List of antagonist types to ignore
 *
 * Returns the count of times the player was assigned an antagonist role excluding the ones in ignored_antagonists.
 * Returns 0 if arguments are invalid or database is unavailable.
 */
/proc/count_player_antag_episodes(ckey, days_back, list/ignored_antagonists = list())
	if(!ckey || !IS_FINITE(days_back) || days_back <= 0)
		return 0

	var/alist/cache = GLOB.player_antag_episodes_cache;
	cache[ckey] = (ckey in cache) ? cache[ckey] : alist()
	cache[ckey][days_back] = (days_back in cache[ckey]) ? cache[ckey][days_back] : alist()
	var/cache_key = jointext(sort_list(ignored_antagonists), ",")

	if(cache_key in cache[ckey][days_back])
		// We have cached value for the provided args, return it
		return cache[ckey][days_back][cache_key]

	if(!SSdbcore.Connect())
		return 0

	var/ignored_antagonists_clause = "TRUE"
	if(length(ignored_antagonists))
		ignored_antagonists_clause = "antagonist.antagonist_type NOT IN (\"[jointext(ignored_antagonists, "\", \"")]\")"

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT COUNT(*) as role_count
		FROM [format_table_name("feedback")] f
		CROSS JOIN JSON_TABLE(
			f.json,
			'$.data.*' COLUMNS (
				ckey_field VARCHAR(32) PATH '$.key',
				antagonist_type VARCHAR(255) PATH '$.antagonist_type'
			)
		) AS antagonist
		WHERE f.key_name = 'antagonists'
			AND f.datetime >= NOW() - INTERVAL :days_back DAY
			AND antagonist.ckey_field = :ckey
			AND [ignored_antagonists_clause]
	"}, list(
		"days_back" = days_back,
		"ckey" = ckey
	))

	if(!query.Execute())
		qdel(query)
		return 0

	var/count = 0
	if(query.NextRow())
		count = text2num(query.item[1]) || 0

	qdel(query)

	// Cache the result
	cache[ckey][days_back][cache_key] = count
	return count
