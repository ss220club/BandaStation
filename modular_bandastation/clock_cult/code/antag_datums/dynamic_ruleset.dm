/datum/dynamic_ruleset/roundstart/clock_cult
	name = "Clock Cult"
	config_tag = "Roundstart Clock Cult"
	preview_antag_datum = /datum/antagonist/clock_cultist
	pref_flag = ROLE_CLOCK_CULTIST
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)
	min_antag_cap = list("denominator" = 20, "offset" = 1)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/clock_cult/get_always_blacklisted_roles()
	return ..() | JOB_CHAPLAIN

/datum/dynamic_ruleset/roundstart/clock_cult/create_execute_args()
	return list(
		new /datum/team/clock_cult(),
		get_most_experienced(selected_minds, pref_flag),
	)

/datum/dynamic_ruleset/roundstart/clock_cult/execute()
	. = ..()
	var/datum/team/clock_cult/main_cult = locate() in GLOB.antagonist_teams
	main_cult.setup_objectives()

/datum/dynamic_ruleset/roundstart/clock_cult/assign_role(datum/mind/candidate, datum/team/clock_cult/cult, datum/mind/most_experienced)
	var/datum/antagonist/clock_cultist/cultist = new()
	cultist.give_slab = TRUE
	candidate.add_antag_datum(cultist, cult)

/datum/dynamic_ruleset/roundstart/clock_cult/round_result()
	if(GLOB.ratvar_risen)
		SSticker.mode_result = "win - clock cult summoned Ratvar"
		return TRUE

	SSticker.mode_result = "loss - crew stopped the clock cult"
	return TRUE
