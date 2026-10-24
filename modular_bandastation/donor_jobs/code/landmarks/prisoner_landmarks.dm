GLOBAL_LIST_EMPTY(donor_prisoner_starts)

/datum/job/prisoner
	/// Prefer a different safe turf for each initial prisoner, as native landmarks do.
	var/list/used_prisoner_starts = list()

/obj/effect/landmark/start/prisoner
	icon = 'modular_bandastation/donor_jobs/icons/landmarks.dmi'
	icon_state = "prisoner"

// A persistent native override; the existing safe-permabrig checks still apply.
/obj/effect/landmark/start/prisoner/latejoin
	icon_state = "prisoner_arrive"
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

// Native roundstart landmarks are deleted once the round starts; keep their turfs for latejoin.
/obj/effect/landmark/start/prisoner/Initialize(mapload)
	. = ..()
	if(!jobspawn_override)
		GLOB.donor_prisoner_starts |= get_turf(src)

/datum/job/prisoner/proc/get_safe_prisoner_turfs()
	var/list/overrides = GLOB.jobspawn_overrides?[title]
	var/list/candidates
	if(length(overrides))
		// Native overrides replace ordinary starts, even if none pass the safety checks.
		candidates = list()
		for(var/atom/override_spawn as anything in overrides)
			candidates |= get_turf(override_spawn)
	else
		candidates = GLOB.donor_prisoner_starts.Copy()
	var/list/result = list()
	for(var/turf/location as anything in candidates)
		if(QDELETED(location) || !is_station_level(location.z) || location.is_blocked_turf(TRUE))
			continue
		if(!istype(get_area(location), /area/station/security/prison))
			continue
		result += location
	return result

/datum/job/prisoner/special_check_latejoin(client/player)
	return ..() && (!CONFIG_GET(flag/donor_prisoner_gate) || length(get_safe_prisoner_turfs()))

/datum/job/prisoner/get_latejoin_spawn_point()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return ..()
	var/list/locations = get_safe_prisoner_turfs()
	return length(locations) ? pick(locations) : null

/datum/job/prisoner/get_roundstart_spawn_point()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return ..()
	var/list/locations = get_safe_prisoner_turfs()
	var/list/unused_locations = locations - used_prisoner_starts
	if(length(unused_locations))
		locations = unused_locations
	. = length(locations) ? pick(locations) : null
	if(.)
		used_prisoner_starts |= .

/datum/job/prisoner/donor_lock_reason(client/player)
	. = ..()
	if(. || !CONFIG_GET(flag/donor_prisoner_gate))
		return
	if(!length(get_safe_prisoner_turfs()))
		return "На карте нет безопасной точки появления в пермабриге."
