/datum/preferences
	/// Error-only storage snapshot; malformed assignments must survive unrelated native saves.
	var/list/invalid_job_profile_assignment_entries

/// Convert supported saved assignments before native loading can trigger a nested save.
/datum/preferences/proc/load_job_profile_assignments()
	var/list/source_entries = list()
	var/list/save_entries = savefile.get_entry()
	for(var/entry in list("job_assigned_profiles", "pref_job_slots"))
		if(entry in save_entries)
			source_entries[entry] = savefile.get_entry(entry)

	// As in the offline converter, explicit canonical values win, including current (0) and random (-1).
	pref_job_slots = list()
	var/legacy_valid = merge_job_profile_assignment_entries(source_entries["job_assigned_profiles"], 1, pref_job_slots)
	var/canonical_valid = merge_job_profile_assignment_entries(source_entries["pref_job_slots"], JOB_SLOT_RANDOMISED_SLOT, pref_job_slots)
	invalid_job_profile_assignment_entries = legacy_valid && canonical_valid ? null : source_entries
	if(!isnull(invalid_job_profile_assignment_entries))
		log_game("Saved job profile assignments could not be converted; preserving their original entries.")

	// The restored native field stays empty; its sanitation must never mutate canonical assignments.
	job_assigned_profiles = null

/// Read one map without rejecting temporarily unavailable jobs or slots above the current limit.
/datum/preferences/proc/merge_job_profile_assignment_entries(entries, minimum_slot, list/assignments)
	if(isnull(entries))
		return TRUE
	if(!islist(entries))
		return FALSE
	var/valid = TRUE
	for(var/job_title in entries)
		if(!istext(job_title) || !length(job_title))
			valid = FALSE
			continue
		var/slot_index = entries[job_title]
		if(!isnum(slot_index) || !IS_FINITE__UNSAFE(slot_index) || round(slot_index) != slot_index || slot_index < minimum_slot)
			valid = FALSE
			continue
		if(slot_index == JOB_SLOT_CURRENT_SLOT)
			assignments -= job_title
		else
			assignments[job_title] = slot_index
	return valid

/// Stage the assignment format for the native save_preferences() flush.
/datum/preferences/proc/write_job_profile_assignments()
	if(!isnull(invalid_job_profile_assignment_entries))
		// Restore presence as well as values after the native compatibility-field write.
		for(var/entry in list("job_assigned_profiles", "pref_job_slots"))
			if(entry in invalid_job_profile_assignment_entries)
				savefile.set_entry(entry, invalid_job_profile_assignment_entries[entry])
			else
				savefile.remove_entry(entry)
		return
	savefile.remove_entry("job_assigned_profiles")
	savefile.set_entry("pref_job_slots", pref_job_slots)
