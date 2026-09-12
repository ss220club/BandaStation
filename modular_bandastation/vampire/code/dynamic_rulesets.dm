// Copied from traitor
/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	config_tag = "Roundstart Vampire"
	preview_antag_datum = /datum/antagonist/vampire
	pref_flag = ROLE_VAMPIRE
	weight = 10
	min_pop = 3
	max_antag_cap = list("denominator" = 24)

// Only "normal" blood species are allowed to be vampires
/datum/dynamic_ruleset/roundstart/vampire/is_valid_candidate(mob/candidate, client/candidate_client)
	. = ..()
	if(!.)
		return

	var/species_type = candidate_client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]

	if(TRAIT_NOBLOOD in species.inherent_traits)
		return FALSE

	if(species.exotic_bloodtype && (species.exotic_bloodtype::reagent_type != /datum/reagent/blood))
		return FALSE

/datum/dynamic_ruleset/roundstart/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire)

// TODO: add to the everyone_an_antag thing?
