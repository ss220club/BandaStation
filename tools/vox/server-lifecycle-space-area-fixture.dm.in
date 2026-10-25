#ifndef LIFECYCLE_HARNESS
#error This fixture is only included by test-server-lifecycle.ps1.
#endif

/// Exercise the three lazy space-area callers without modifying a real map tile.
/datum/controller/subsystem/lifecycle_probe/proc/mapping_regression_probe()
	var/list/result = list("success" = FALSE, "checks" = 3, "cache_restored" = FALSE, "change_turf" = FALSE, "lattice_initialize" = FALSE, "lattice_destroy" = FALSE)
	var/datum/turf_reservation/reservation
	for(var/reserved_z in SSmapping.levels_by_trait(ZTRAIT_RESERVED))
		if(!SSmapping.reservation_ready["[reserved_z]"] || SSmapping.clearing_reserved_turfs)
			continue
		reservation = SSmapping.request_turf_block_reservation(1, 1, z_reservation = reserved_z)
		if(reservation)
			break
	if(!reservation)
		result["error"] = "No existing reserved level had a free scratch tile"
		return result

	var/turf/scratch = reservation.bottom_left_turfs[1]
	var/area/original_area = get_area(scratch)
	var/area/space/original_space = GLOB.areas_by_type[/area/space]
	var/area/space/nearstation/original_nearstation = GLOB.areas_by_type[/area/space/nearstation]
	var/list/created_areas = list()
	var/area/space/probe_space = new
	created_areas += probe_space
	var/obj/structure/lattice/lattice
	// No sleeps or CHECK_TICK while the cache is temporarily empty.
	try
		set_turf_to_area(scratch, probe_space)
		GLOB.areas_by_type[/area/space/nearstation] = null
		scratch = scratch.ChangeTurf(/turf/closed/wall)
		var/area/space/nearstation/changed_area = GLOB.areas_by_type[/area/space/nearstation]
		if(changed_area)
			created_areas += changed_area
		result["change_turf"] = istype(changed_area) && get_area(scratch) == changed_area

		scratch = scratch.ChangeTurf(/turf/open/space)
		set_turf_to_area(scratch, probe_space)
		GLOB.areas_by_type[/area/space/nearstation] = null
		lattice = new(scratch)
		var/area/space/nearstation/lattice_area = GLOB.areas_by_type[/area/space/nearstation]
		if(lattice_area)
			created_areas += lattice_area
		result["lattice_initialize"] = !QDELETED(lattice) && istype(lattice_area) && get_area(scratch) == lattice_area

		GLOB.areas_by_type[/area/space] = null
		QDEL_NULL(lattice)
		var/area/space/recreated_space = GLOB.areas_by_type[/area/space]
		if(recreated_space)
			created_areas += recreated_space
		result["lattice_destroy"] = istype(recreated_space) && recreated_space.type == /area/space && get_area(scratch) == recreated_space
	catch(var/exception/error)
		result["error"] = "[error]"

	// Also collect an area if its caller threw after constructing it.
	if(GLOB.areas_by_type[/area/space] && GLOB.areas_by_type[/area/space] != original_space)
		created_areas |= GLOB.areas_by_type[/area/space]
	if(GLOB.areas_by_type[/area/space/nearstation] && GLOB.areas_by_type[/area/space/nearstation] != original_nearstation)
		created_areas |= GLOB.areas_by_type[/area/space/nearstation]
	// Restore the real caches before cleanup can invoke any other space-area caller.
	GLOB.areas_by_type[/area/space] = original_space
	GLOB.areas_by_type[/area/space/nearstation] = original_nearstation
	QDEL_NULL(lattice)
	set_turf_to_area(scratch, original_area)
	for(var/area/created_area as anything in created_areas)
		qdel(created_area)
	qdel(reservation)
	result["cache_restored"] = GLOB.areas_by_type[/area/space] == original_space && GLOB.areas_by_type[/area/space/nearstation] == original_nearstation
	result["success"] = result["change_turf"] && result["lattice_initialize"] && result["lattice_destroy"] && result["cache_restored"]
	return result
