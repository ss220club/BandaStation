/// Native candidacy has already checked the mind and queued rulesets before this phase.
/datum/dynamic_ruleset/roundstart/blood_worm/proc/get_host_profile_species(mob/candidate, client/candidate_client, current_species)
	if(isnewplayer(candidate))
		var/mob/dead/new_player/player = candidate
		var/datum/job/host_job = player.get_eligible_crew_job(get_blacklisted_roles() | get_bloodless_jobs(candidate_client))
		if(!host_job)
			return null
		var/datum/job_character_selection/selection = candidate_client.prefs.select_job_character(host_job)
		. = selection.species
		qdel(selection)
		return
	return current_species

/datum/dynamic_ruleset/roundstart/blood_worm/proc/get_bloodless_jobs(client/player)
	var/list/bloodless_jobs = list()
	if(!player)
		return bloodless_jobs
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/datum/job_character_selection/selection = player.prefs.select_job_character(job)
		var/datum/species/species = GLOB.species_prototypes[selection.species]
		qdel(selection)
		if(!species || (TRAIT_NOBLOOD in species.inherent_traits))
			bloodless_jobs += job.title
	return bloodless_jobs

/datum/dynamic_ruleset/roundstart/blood_worm/prepare_for_role(datum/mind/candidate)
	..()
	LAZYADDASSOC(SSjob.prevented_occupations, candidate, get_bloodless_jobs(GET_CLIENT(candidate.current)))
	RegisterSignal(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, PROC_REF(check_roundstart_host))

/datum/dynamic_ruleset/roundstart/blood_worm/proc/check_roundstart_host(datum/mind/source, mob/living/character)
	SIGNAL_HANDLER
	if(!CAN_HAVE_BLOOD(character))
		return COMPONENT_CANCEL_CHARACTER_SPAWN
	// This prepared assignment only validates its initial body; rejected bodies are cleaned up by cancellation.
	UnregisterSignal(source, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED)

/datum/dynamic_ruleset/roundstart/blood_worm/cancel_assignment(datum/mind/candidate)
	if(!..())
		return FALSE
	UnregisterSignal(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED)
	return TRUE
