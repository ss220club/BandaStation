// Copied from traitor
/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	config_tag = "Roundstart Vampire"
	preview_antag_datum = /datum/antagonist/vampire
	pref_flag = ROLE_VAMPIRE
	weight = 10
	min_pop = 3
	max_antag_cap = list("denominator" = 24)

/datum/dynamic_ruleset/roundstart/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire)

/datum/dynamic_ruleset/latejoin/vampire
	name = "Vampire"
	config_tag = "Latejoin Vampire"
	preview_antag_datum = /datum/antagonist/vampire
	pref_flag = ROLE_SYNDICATE_INFILTRATOR
	jobban_flag = ROLE_VAMPIRE
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire)

/datum/dynamic_ruleset/midround/from_living/vampire
	name = "Vampire"
	config_tag = "Midround Vampire"
	preview_antag_datum = /datum/antagonist/vampire
	midround_type = LIGHT_MIDROUND
	false_alarm_able = TRUE
	pref_flag = ROLE_SLEEPER_AGENT
	jobban_flag = ROLE_VAMPIRE
	ruleset_flags = RULESET_VARIATION
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/midround/from_living/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire)


// TODO: add to the everyone_an_antag thing?
