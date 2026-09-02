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
	/// Cached after the event registry has been initialized; this is queried
	/// for every active cell during refreshes.
	var/list/automatic_event_cache = list()

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

/datum/redspace_profile/proc/play_mob_spawn_telegraph(turf/target)
	return

/datum/redspace_profile/proc/play_mob_spawn_arrival(turf/target)
	return

/datum/redspace_profile/demonic
	profile_id = REDSPACE_PROFILE_DEMONIC
	allowed_event_ids = list(
		"calm_echo",
		"local_distortion",
		"storm_pulse",
		"debug_lightning",
		"demonic_crystal",
		"demonic_necropolis",
		"demonic_lesser_demon",
		"demonic_ranged_demon",
		"demonic_soldier",
		"demonic_minotaur",
		"demonic_devourer",
		"demonic_mature_beholder",
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
		30 SECONDS,
		60 SECONDS,
		35,
		list("local_distortion" = 1),
	)
	event_profiles["[REDSPACE_STATE_STORM]"] = new /datum/redspace_event_profile(
		REDSPACE_STATE_STORM,
		20 SECONDS,
		40 SECONDS,
		60,
		list(
			"storm_pulse" = 4,
			"demonic_crystal" = 1,
			"demonic_necropolis" = 4,
			"demonic_lesser_demon" = 2,
			"demonic_ranged_demon" = 2,
			"demonic_soldier" = 1,
			"demonic_minotaur" = 1,
			"demonic_devourer" = 1,
			"demonic_mature_beholder" = 1,
		),
	)

/datum/redspace_profile/demonic/play_mob_spawn_telegraph(turf/target)
	if(!target)
		return
	target.flash_lighting_fx(
		range = 2,
		power = 0.6,
		color = LIGHT_COLOR_FIRE,
		duration = REDSPACE_MOB_SPAWN_TELEGRAPH_DURATION,
	)
	var/obj/effect/temp_visual/focus_ring/ring = new(target)
	ring.color = "#ff3b20"
	playsound(target, 'modular_bandastation/redspace/sound/demon_warp.ogg', 70, TRUE)
	target.visible_message(span_warning("Разрыв редспейса начинает раскрываться."))

/datum/redspace_profile/demonic/play_mob_spawn_arrival(turf/target)
	if(!target)
		return
	target.flash_lighting_fx(
		range = 3,
		power = 1.2,
		color = LIGHT_COLOR_ORANGE,
		duration = 0.5 SECONDS,
	)
	new /obj/effect/temp_visual/circle_wave(target, "#ff3b20")
	playsound(target, 'sound/effects/magic/teleport_app.ogg', 50, TRUE)

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
