/// Keep native declarations while this instance exposes only the canonical slot action.
/datum/preference_middleware/jobs/New(datum/preferences)
	. = ..()
	action_delegations = action_delegations.Copy()
	action_delegations -= "set_job_to_profile"

/datum/preference_middleware/jobs/get_ui_data(mob/user)
	. = ..()
	for(var/list/job_data as anything in .["job_preferences"])
		job_data["assigned_profile_slot"] = preferences.pref_job_slots[job_data["job"]]
	// Project canonical assignments into the native UI contract, including roles without a priority.
	for(var/job_title in preferences.pref_job_slots)
		if(job_title in preferences.job_preferences)
			continue
		.["job_preferences"] += list(list(
			"job" = job_title,
			"priority" = null,
			"assigned_profile_slot" = preferences.pref_job_slots[job_title],
		))

/datum/preference_middleware/jobs/set_job_preference(list/params, mob/user)
	if(user.client?.prefs != preferences || params["edit_slot"] != preferences.default_slot)
		return FALSE
	var/job_title = params["job"]
	if(!istext(job_title))
		return FALSE
	var/datum/job/job = SSjob.get_job(job_title)
	if(!job || job.title != job_title)
		return FALSE
	// Clearing remains available when a role or its selected profile becomes unavailable.
	if(!isnull(params["level"]) && job.get_join_lock_reason(user.client))
		return FALSE
	return ..()
