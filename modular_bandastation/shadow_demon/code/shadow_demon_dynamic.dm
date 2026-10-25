/// A single ghost-controlled predator, selected by the normal heavy-midround pool.
/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon
	name = "Shadow Demon"
	config_tag = "Shadow Demon"
	candidate_role = "тенедемон"
	preview_antag_datum = /datum/antagonist/shadow_demon
	midround_type = HEAVY_MIDROUND
	pref_flag = ROLE_SHADOW_DEMON
	ruleset_flags = RULESET_INVADER
	weight = 1
	min_pop = 20
	min_antag_cap = 1
	max_antag_cap = 1
	repeatable = FALSE
	signup_atom_appearance = /mob/living/basic/demon/shadow

/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/can_be_selected()
	return ..() && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))

/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/is_valid_candidate(mob/candidate, client/candidate_client)
	// The role-specific preference and ban are checked by trim_candidates; retain the former sentience ban too.
	if(!..() || QDELETED(candidate) || !candidate.ckey || candidate.stat != DEAD)
		return FALSE
	return !is_banned_from(candidate.ckey, list(ROLE_SENTIENCE))

/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/create_ruleset_body()
	var/turf/spawn_turf = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE)
	if(isnull(spawn_turf))
		return
	return new /mob/living/basic/demon/shadow(spawn_turf)

/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/assign_role(datum/mind/candidate)
	var/mob/living/basic/demon/shadow/body = candidate?.current
	if(!istype(body) || QDELETED(body))
		return
	candidate.set_assigned_role(SSjob.get_job_type(/datum/job/shadow_demon))
	// Login initializes this role for real players; non-client transfers still need the explicit assignment.
	if(!candidate.has_antag_datum(/datum/antagonist/shadow_demon))
		candidate.add_antag_datum(/datum/antagonist/shadow_demon)
