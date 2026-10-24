/// Civilian donor jobs receive the native Assistant benefit from Cybernetic Revolution.
/datum/modpack/donor_jobs/proc/initialize_donor_station_traits()
	var/list/cybernetics = /datum/station_trait/cybernetic_revolution::job_to_cybernetic
	for(var/job_type in typesof(/datum/job/donor))
		cybernetics[job_type] = cybernetics[/datum/job/assistant]
