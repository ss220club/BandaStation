#define JOB_SLOT_RANDOMISED_SLOT -1
#define JOB_SLOT_CURRENT_SLOT 0

/datum/preferences
	/// Assoc list of [job title] = [slot number]. Stores which character slot to use for each job.
	var/list/pref_job_slots = list()

/// Resets pref_job_slots to empty list and saves preferences
/datum/preferences/proc/reset_job_slots()
	pref_job_slots = list()
	save_preferences()
	return TRUE

/**
 * Loads assigned character slot for a job
 *
 * Loads appropriate character slot for the given job as assigned in preferences,
 *
 * Arguments:
 * * job_title - Job title to load configuration for
 * * is_late_join - Whether this is for late join
 *
 * Returns TRUE if randomized appearance should be used
 */
/datum/preferences/proc/set_assigned_slot(job_title, is_late_join = FALSE)
	// SS220 EDIT - START
	// A committed lobby profile is already loaded; reuse its appearance mode without selecting or switching again.
	var/mob/dead/new_player/requester = isnewplayer(parent?.mob) ? parent.mob : null
	if(requester?.assigned_character)
		var/datum/job/assigned_job = SSjob.get_job(job_title)
		if(requester.assigned_character.job_type == assigned_job?.type)
			return requester.assigned_character.randomized
	// SS220 EDIT - END
	if(is_late_join ? read_preference(/datum/preference/toggle/late_join_always_current_slot) : read_preference(/datum/preference/toggle/round_start_always_join_current_slot))
		return
	var/slot = pref_job_slots[job_title] || JOB_SLOT_CURRENT_SLOT
	switch(slot)
		if(JOB_SLOT_RANDOMISED_SLOT)
			return TRUE
		if(JOB_SLOT_CURRENT_SLOT)
			return

	if(slot != default_slot)
		switch_to_slot(slot)

/// Whether joining at roundstart ignores assigned character slot for the job and uses currently selected slot.
/datum/preference/toggle/round_start_always_join_current_slot
	savefile_key = "round_start_always_join_current_slot"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/// Whether joining during the round ignores assigned character slot for the job and uses currently selected slot.
/datum/preference/toggle/late_join_always_current_slot
	savefile_key = "late_join_always_current_slot"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
