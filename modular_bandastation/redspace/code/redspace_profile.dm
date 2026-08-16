/// Data owned by a round context that describes which content a profile permits.
/datum/redspace_profile
	var/profile_id
	var/list/allowed_event_ids = list()
	var/list/source_parameters = list()

/datum/redspace_profile/New(new_profile_id = null)
	. = ..()
	if(!isnull(new_profile_id))
		profile_id = new_profile_id

/datum/redspace_profile/proc/is_event_allowed(event_id)
	if(!event_id)
		return FALSE
	if(!length(allowed_event_ids))
		return TRUE
	return event_id in allowed_event_ids

/datum/redspace_profile/demonic
	profile_id = REDSPACE_PROFILE_DEMONIC
	allowed_event_ids = list(
		"local_distortion",
		"storm_pulse",
		"debug_lightning",
	)

/proc/redspace_profile_from_id(profile_id) as /datum/redspace_profile
	if(!profile_id)
		return
	switch(profile_id)
		if(REDSPACE_PROFILE_DEMONIC)
			return new /datum/redspace_profile/demonic
	return new /datum/redspace_profile(profile_id)
