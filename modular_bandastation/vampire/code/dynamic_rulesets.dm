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

// TODO: add to the everyone_an_antag thing?
