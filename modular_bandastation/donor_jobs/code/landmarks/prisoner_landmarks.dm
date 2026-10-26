/obj/effect/landmark/start/prisoner
	icon = 'modular_bandastation/donor_jobs/icons/landmarks.dmi'
	icon_state = "prisoner"

// A persistent native override; the existing safe-permabrig checks still apply.
/obj/effect/landmark/start/prisoner/latejoin
	icon_state = "prisoner_arrive"
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/// Native roundstart selection and its used flag finish before these become latejoin overrides.
/// Preserve the existing landmarks; native latejoin selection and Destroy() own the registered state.
/obj/effect/landmark/start/prisoner/after_round_start()
	if(CONFIG_GET(flag/donor_prisoner_gate) && !length(GLOB.jobspawn_overrides[name]))
		var/datum/job/prisoner/job = SSjob.get_job(name)
		var/list/locations = job?.get_safe_prisoner_turfs()
		for(var/obj/effect/landmark/start/point as anything in GLOB.start_landmarks_list)
			if(QDELETED(point) || point.name != name || !(get_turf(point) in locations))
				continue
			point.delete_after_roundstart = FALSE
			point.jobspawn_override = TRUE
			LAZYADDASSOCLIST(GLOB.jobspawn_overrides, name, point)
	return ..()

/datum/job/prisoner/proc/get_safe_prisoner_turfs()
	var/list/candidates = GLOB.jobspawn_overrides?[title]
	if(!length(candidates))
		candidates = GLOB.start_landmarks_list
	var/list/result = list()
	for(var/atom/point as anything in candidates)
		if(QDELETED(point) || point.name != title)
			continue
		var/turf/location = get_turf(point)
		if(QDELETED(location) || !is_station_level(location.z) || location.is_blocked_turf(TRUE))
			continue
		if(!istype(get_area(location), /area/station/security/prison))
			continue
		result += location
	return result

/datum/job/prisoner/special_check_latejoin(client/player)
	return ..() && (!CONFIG_GET(flag/donor_prisoner_gate) || length(get_safe_prisoner_turfs()))

/datum/job/prisoner/get_latejoin_spawn_point()
	. = ..()
	if(CONFIG_GET(flag/donor_prisoner_gate) && !(get_turf(.) in get_safe_prisoner_turfs()))
		return null

/datum/job/prisoner/get_roundstart_spawn_point()
	. = ..()
	if(CONFIG_GET(flag/donor_prisoner_gate) && !(get_turf(.) in get_safe_prisoner_turfs()))
		return null

/datum/job/prisoner/donor_lock_reason(client/player)
	. = ..()
	if(. || !CONFIG_GET(flag/donor_prisoner_gate))
		return
	if(!length(get_safe_prisoner_turfs()))
		return "На карте нет безопасной точки появления в пермабриге."
