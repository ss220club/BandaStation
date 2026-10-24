/// Load canonical assignments before native loading can trigger a nested save.
/datum/preferences/proc/load_job_profile_assignments()
	pref_job_slots = list()
	var/list/assignments = savefile.get_entry("pref_job_slots")
	if(islist(assignments))
		for(var/job_title in assignments)
			if(!istext(job_title) || !length(job_title))
				continue
			var/slot_index = assignments[job_title]
			if(!isnum(slot_index) || !IS_FINITE__UNSAFE(slot_index) || round(slot_index) != slot_index || slot_index < JOB_SLOT_RANDOMISED_SLOT)
				continue
			if(slot_index != JOB_SLOT_CURRENT_SLOT)
				pref_job_slots[job_title] = slot_index
	// The native compatibility field is not a second assignment store.
	job_assigned_profiles = null

/// Stage canonical assignments for the single native save_preferences() flush.
/datum/preferences/proc/write_job_profile_assignments()
	savefile.remove_entry("job_assigned_profiles")
	savefile.set_entry("pref_job_slots", pref_job_slots)
