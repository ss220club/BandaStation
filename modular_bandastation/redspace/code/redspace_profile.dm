/// Data owned by a round context that describes which content a profile permits.
/datum/redspace_profile
	var/profile_id
	var/list/allowed_event_ids = list()
	var/list/source_parameters = list()
	/// State-specific scheduler settings. The field state remains independent from the influence profile.
	var/list/event_profiles = list()

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

/datum/redspace_profile/proc/get_event_profile(state) as /datum/redspace_event_profile
	if(isnull(state))
		return
	return event_profiles["[state]"]

/// Event cadence and weights for one gameplay range of an influence profile.
/datum/redspace_event_profile
	var/state
	var/attempt_delay_min
	var/attempt_delay_max
	var/attempt_probability = 100
	var/list/event_weights = list()

/datum/redspace_event_profile/New(new_state, new_attempt_delay_min, new_attempt_delay_max, new_attempt_probability, list/new_event_weights)
	. = ..()
	state = new_state
	attempt_delay_min = max(new_attempt_delay_min, 0)
	attempt_delay_max = max(new_attempt_delay_max, attempt_delay_min)
	attempt_probability = clamp(new_attempt_probability, 0, 100)
	if(islist(new_event_weights))
		event_weights = new_event_weights.Copy()

/datum/redspace_event_profile/proc/get_next_attempt_delay()
	return rand(attempt_delay_min, attempt_delay_max)

/datum/redspace_event_profile/proc/should_attempt()
	return attempt_probability >= 100 || prob(attempt_probability)

/datum/redspace_event_profile/proc/get_event_weight(event_id)
	return event_weights[event_id]

/datum/redspace_event_profile/proc/has_events()
	return length(event_weights)

/datum/redspace_profile/demonic
	profile_id = REDSPACE_PROFILE_DEMONIC
	allowed_event_ids = list(
		"calm_echo",
		"local_distortion",
		"storm_pulse",
		"debug_lightning",
	)

/datum/redspace_profile/demonic/New()
	. = ..()
	event_profiles["[REDSPACE_STATE_EBB]"] = new /datum/redspace_event_profile(REDSPACE_STATE_EBB, 0, 0, 0, list())
	event_profiles["[REDSPACE_STATE_CALM]"] = new /datum/redspace_event_profile(
		REDSPACE_STATE_CALM,
		90 SECONDS,
		180 SECONDS,
		15,
		list("calm_echo" = 1),
	)
	event_profiles["[REDSPACE_STATE_DISTURBANCE]"] = new /datum/redspace_event_profile(
		REDSPACE_STATE_DISTURBANCE,
		45 SECONDS,
		90 SECONDS,
		25,
		list("local_distortion" = 1),
	)
	event_profiles["[REDSPACE_STATE_STORM]"] = new /datum/redspace_event_profile(
		REDSPACE_STATE_STORM,
		20 SECONDS,
		40 SECONDS,
		60,
		list("storm_pulse" = 3),
	)

/datum/redspace_profile/demonic/Destroy()
	for(var/state in event_profiles)
		qdel(event_profiles[state])
	event_profiles.Cut()
	return ..()

/proc/redspace_profile_from_id(profile_id) as /datum/redspace_profile
	if(!profile_id)
		return
	switch(profile_id)
		if(REDSPACE_PROFILE_DEMONIC)
			return new /datum/redspace_profile/demonic
	return new /datum/redspace_profile(profile_id)
