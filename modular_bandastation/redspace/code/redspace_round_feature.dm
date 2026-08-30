/// A station trait that makes redspace a real round feature instead of a debug-only field.
/datum/station_trait/redspace_activity
	abstract_type = /datum/station_trait/redspace_activity
	name = "Возмущение редспейса"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 0
	cost = STATION_TRAIT_COST_FULL
	show_in_report = TRUE
	trait_processes = TRUE
	blacklist = list(
		/datum/station_trait/redspace_activity/calm,
		/datum/station_trait/redspace_activity/disturbance,
		/datum/station_trait/redspace_activity/storm,
	)

	/// Selected round-start intensity. Admins may change it after the round starts.
	var/redspace_intensity = REDSPACE_INTENSITY_DISTURBANCE
	var/round_initialized = FALSE
	var/primary_source_id
	var/list/managed_source_ids = list()
	/// Earliest time at which the initial or replacement hotspot may appear.
	var/next_hotspot_at = 0
	/// Set when the primary hotspot is removed, so an intensity change can update its cooldown.
	var/hotspot_cooldown_started_at = 0
	var/next_wave_at = 0
	var/storm_active = FALSE
	var/storm_announcement_sent = FALSE

/datum/station_trait/redspace_activity/on_round_start()
	. = ..()
	if(!SSredspace?.initialized)
		return

	round_initialized = TRUE
	SSredspace.register_event_listener(src)
	configure_intensity(redspace_intensity, FALSE)
	next_hotspot_at = get_initial_source_at()
	next_wave_at = next_hotspot_at

/datum/station_trait/redspace_activity/process(seconds_per_tick)
	if(!round_initialized || !SSredspace?.initialized)
		return

	if(primary_source_id && !SSredspace.field_sources["[primary_source_id]"])
		primary_source_id = null
		hotspot_cooldown_started_at = world.time
		next_hotspot_at = world.time + get_hotspot_respawn_delay()
		next_wave_at = 0

	if(!primary_source_id && (!next_hotspot_at || world.time >= next_hotspot_at))
		if(ensure_primary_source())
			next_hotspot_at = 0
			hotspot_cooldown_started_at = 0
			next_wave_at = world.time + get_next_wave_delay()

	if(primary_source_id && (!next_wave_at || world.time >= next_wave_at))
		spawn_wave()
		next_wave_at = world.time + get_next_wave_delay()

	update_storm_state()

/datum/station_trait/redspace_activity/proc/configure_intensity(new_intensity, update_source = TRUE)
	if(!(new_intensity in list(
		REDSPACE_INTENSITY_CALM,
		REDSPACE_INTENSITY_DISTURBANCE,
		REDSPACE_INTENSITY_STORM,
	)))
		return FALSE

	redspace_intensity = new_intensity
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			name = "Слабые возмущения редспейса"
			report_message = "В окрестностях станции фиксируются слабые возмущения редспейса. Ожидаются редкие локальные отклонения без существенной угрозы для смены."
		if(REDSPACE_INTENSITY_DISTURBANCE)
			name = "Возмущение редспейса"
			report_message = "В окрестностях станции наблюдается возмущение редспейса. Научному и инженерному отделам следует подготовить наблюдение и локальную стабилизацию зон риска."
		if(REDSPACE_INTENSITY_STORM)
			name = "Шторм редспейса"
			report_message = "Станция проходит через активный шторм редспейса. Ожидаются существенные локальные воздействия, а стабилизация границы является приоритетной задачей."

	if(update_source && primary_source_id && SSredspace?.initialized)
		SSredspace.update_source_strength(primary_source_id, get_primary_source_strength(), "изменена интенсивность особенности раунда")
		SSredspace.update_source_radius(primary_source_id, get_primary_source_radius(), "изменён радиус особенности раунда")
		next_wave_at = next_wave_at ? min(next_wave_at, world.time + 10 SECONDS) : world.time + 10 SECONDS

	if(hotspot_cooldown_started_at)
		next_hotspot_at = hotspot_cooldown_started_at + get_hotspot_respawn_delay()
	return TRUE

/datum/station_trait/redspace_activity/proc/ensure_primary_source()
	if(primary_source_id && SSredspace?.field_sources["[primary_source_id]"])
		return TRUE

	var/turf/origin = get_safe_random_station_turf_equal_weight()
	if(!origin || !SSredspace?.is_supported_z(origin.z))
		return FALSE
	var/datum/redspace_field_source/hotspot/primary_source = SSredspace.register_hotspot(
		origin,
		get_primary_source_strength(),
		get_primary_source_radius(),
		REDSPACE_PROFILE_DEMONIC,
		"начальный источник особенности раунда",
		"источник станционной особенности",
	)
	if(!primary_source)
		return FALSE
	primary_source_id = primary_source.source_id
	managed_source_ids += primary_source.source_id
	return TRUE

/datum/station_trait/redspace_activity/proc/on_redspace_reset()
	managed_source_ids.Cut()
	primary_source_id = null
	storm_active = FALSE
	round_initialized = TRUE
	SSredspace.register_event_listener(src)
	next_hotspot_at = get_initial_source_at()
	hotspot_cooldown_started_at = 0
	next_wave_at = next_hotspot_at

/datum/station_trait/redspace_activity/proc/set_intensity(new_intensity)
	if(!configure_intensity(new_intensity))
		return FALSE

	log_game("Redspace round intensity changed to [redspace_intensity] by live round control.")
	return TRUE

/datum/station_trait/redspace_activity/proc/get_primary_source_strength()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return 1.5
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return 4.5
		if(REDSPACE_INTENSITY_STORM)
			return 7.5
	return 0

/datum/station_trait/redspace_activity/proc/get_primary_source_radius()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return 8
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return 10
		if(REDSPACE_INTENSITY_STORM)
			return 12
	return 0

/datum/station_trait/redspace_activity/proc/get_initial_source_at()
	var/round_start_at = SSticker?.round_start_time
	if(!round_start_at)
		return world.time + REDSPACE_INITIAL_SOURCE_DELAY
	return max(world.time, round_start_at + REDSPACE_INITIAL_SOURCE_DELAY)

/datum/station_trait/redspace_activity/proc/get_hotspot_respawn_delay()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return REDSPACE_HOTSPOT_RESPAWN_DELAY_CALM
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return REDSPACE_HOTSPOT_RESPAWN_DELAY_DISTURBANCE
		if(REDSPACE_INTENSITY_STORM)
			return REDSPACE_HOTSPOT_RESPAWN_DELAY_STORM
	return REDSPACE_HOTSPOT_RESPAWN_DELAY_DISTURBANCE

/datum/station_trait/redspace_activity/proc/get_next_wave_delay()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return rand(120 SECONDS, 240 SECONDS)
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return rand(60 SECONDS, 120 SECONDS)
		if(REDSPACE_INTENSITY_STORM)
			return rand(25 SECONDS, 60 SECONDS)
	return 120 SECONDS

/datum/station_trait/redspace_activity/proc/get_wave_amplitude()
	var/minimum
	var/maximum
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			minimum = 1
			maximum = 2
		if(REDSPACE_INTENSITY_DISTURBANCE)
			minimum = 2
			maximum = 4
		if(REDSPACE_INTENSITY_STORM)
			minimum = 4
			maximum = 7
	return rand(minimum * 10, maximum * 10) / 10

/datum/station_trait/redspace_activity/proc/get_wave_radius()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return 5
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return 6
		if(REDSPACE_INTENSITY_STORM)
			return 8
	return 5

/datum/station_trait/redspace_activity/proc/get_wave_speed()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return rand(25, 40) / 100
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return rand(30, 50) / 100
		if(REDSPACE_INTENSITY_STORM)
			return rand(40, 75) / 100
	return 1

/datum/station_trait/redspace_activity/proc/get_wave_lifetime()
	switch(redspace_intensity)
		if(REDSPACE_INTENSITY_CALM)
			return 180 SECONDS
		if(REDSPACE_INTENSITY_DISTURBANCE)
			return 180 SECONDS
		if(REDSPACE_INTENSITY_STORM)
			return 180 SECONDS
	return 180 SECONDS

/datum/station_trait/redspace_activity/proc/spawn_wave()
	var/turf/origin = get_safe_random_station_turf_equal_weight()
	if(!origin || !SSredspace.is_supported_z(origin.z))
		return

	var/static/list/directions = list(
		list(0, 1),
		list(0, -1),
		list(1, 0),
		list(-1, 0),
		list(0.7071, 0.7071),
		list(-0.7071, 0.7071),
		list(0.7071, -0.7071),
		list(-0.7071, -0.7071),
	)
	var/list/direction = pick(directions)
	var/wave_speed = get_wave_speed()
	var/datum/redspace_field_source/wave/wave = SSredspace.register_wave_source(
		origin,
		get_wave_amplitude(),
		get_wave_radius(),
		direction[1] * wave_speed,
		direction[2] * wave_speed,
		get_wave_lifetime(),
		REDSPACE_PROFILE_DEMONIC,
		"волна станционной особенности редспейса",
	)
	if(wave)
		managed_source_ids += wave.source_id

/datum/station_trait/redspace_activity/proc/update_storm_state()
	var/has_storm = FALSE
	for(var/cell_key in SSredspace.field_cells)
		var/datum/redspace_field_cell/cell = SSredspace.field_cells[cell_key]
		if(cell?.state == REDSPACE_STATE_STORM)
			has_storm = TRUE
			break

	if(!has_storm)
		storm_active = FALSE
		return

	if(storm_active)
		return
	storm_active = TRUE
	if(storm_announcement_sent)
		return
	storm_announcement_sent = TRUE
	priority_announce(
		"На станции зарегистрировано активное возмущение редспейса. Научному отделу следует локализовать горячие зоны, а инженерному отделу подготовить стабилизаторы блюспейс-границы.",
		"Активный шторм редспейса",
		'sound/announcer/notice/notice1.ogg',
	)

/datum/station_trait/redspace_activity/Destroy()
	if(SSredspace)
		SSredspace.unregister_event_listener(src)
		SSredspace.cancel_active_events("станционная особенность завершена")
		for(var/source_id in managed_source_ids.Copy())
			SSredspace.remove_source(source_id, "станционная особенность завершена")
	STOP_PROCESSING(SSstation, src)
	return ..()

/// The weak profile is known to the crew in the round-start report and mostly stays quiet.
/datum/station_trait/redspace_activity/calm
	name = "Слабые возмущения редспейса"
	report_message = "В окрестностях станции фиксируются слабые возмущения редспейса. Ожидаются редкие локальные отклонения без существенной угрозы для смены."
	redspace_intensity = REDSPACE_INTENSITY_CALM
	weight = 80
	dynamic_threat_id = "Redspace Calm"

/// The default profile creates an observable but manageable science and engineering problem.
/datum/station_trait/redspace_activity/disturbance
	name = "Возмущение редспейса"
	report_message = "В окрестностях станции наблюдается возмущение редспейса. Научному и инженерному отделам следует подготовить наблюдение и локальную стабилизацию зон риска."
	redspace_intensity = REDSPACE_INTENSITY_DISTURBANCE
	weight = 15
	dynamic_threat_id = "Redspace Disturbance"

/// The storm profile is a declared major round feature with frequent, telegraphed local effects.
/datum/station_trait/redspace_activity/storm
	name = "Шторм редспейса"
	report_message = "Станция проходит через активный шторм редспейса. Ожидаются существенные локальные воздействия, а стабилизация границы является приоритетной задачей."
	redspace_intensity = REDSPACE_INTENSITY_STORM
	weight = 5
	dynamic_threat_id = "Redspace Storm"
