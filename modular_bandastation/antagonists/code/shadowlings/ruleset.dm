/datum/dynamic_ruleset/roundstart/shadowling
	name = "Shadowlings"
	config_tag = "Roundstart Shadowlings"
	preview_antag_datum = /datum/antagonist/shadowling

	repeatable = FALSE
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30

	pref_flag = ROLE_SHADOWLING
	jobban_flag = ROLE_SHADOWLING

	min_antag_cap = 3
	max_antag_cap = 3
	var/decimator = 15

/datum/dynamic_ruleset/roundstart/shadowling/New(list/dynamic_config)
	var/list/alive_players = get_active_player_list(alive_check = TRUE, afk_check = TRUE)
	var/left_count = alive_players - min_pop
	var/add_units = floor(left_count / decimator)
	min_antag_cap += add_units

/datum/dynamic_ruleset/roundstart/shadowling/get_always_blacklisted_roles()
	. = ..()
	for(var/datum/job/J as anything in SSjob.all_occupations)
		if(J.job_flags & JOB_HEAD_OF_STAFF)
			. |= J.title

/datum/dynamic_ruleset/roundstart/shadowling/is_valid_candidate(mob/candidate, client/candidate_client)
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/shadowling/proc/target_count_for(population_size)
	if(population_size < 30)
		return 0
	var/excess = population_size - 30
	return 3 + floor(excess / 15)

/datum/dynamic_ruleset/roundstart/shadowling/execute()
	var/list/alive_players = get_active_player_list(alive_check = TRUE, afk_check = TRUE)
	var/population_size = length(alive_players)
	var/need_total = target_count_for(population_size)
	var/got = length(selected_minds)
	var/need_extra = max(0, need_total - got)

	if(need_extra <= 0)
		return ..()

	var/list/minds_already_taken = list()
	for(var/datum/dynamic_ruleset/roundstart/R in SSdynamic.queued_rulesets)
		for(var/datum/mind/M in R.selected_minds)
			minds_already_taken |= M

	var/list/candidates = list()
	for(var/mob/living/carbon/human/H in alive_players)
		var/datum/mind/M = H.mind
		if(!M)
			continue
		if(M in minds_already_taken)
			continue
		if(H.client?.get_remaining_days(minimum_required_age) > 0)
			continue
		if(!is_valid_candidate(H, H.client))
			continue
		if(H.mind?.assigned_role?.job_flags & JOB_HEAD_OF_STAFF)
			continue
		candidates += H

	if(!length(candidates))
		return ..()

	candidates = shuffle(candidates)
	for(var/i = 1 to min(need_extra, length(candidates)))
		assign_role(candidates[i])

	return ..()

/datum/dynamic_ruleset/roundstart/shadowling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/shadowling)
