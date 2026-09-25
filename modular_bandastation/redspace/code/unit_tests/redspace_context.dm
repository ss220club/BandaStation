#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_context

/datum/unit_test/redspace_context/Run()
	var/turf/test_turf = run_loc_floor_bottom_left

	var/datum/redspace_context_provider/test_stub/first_stub = new()
	first_stub.forced_background = 3
	first_stub.forced_z_levels = list(test_turf.z)
	first_stub.forced_profile = "first_profile"

	var/datum/redspace_context_provider/test_stub/second_stub = new()
	second_stub.provider_id = "test_stub_second"
	second_stub.forced_background = 5
	second_stub.forced_z_levels = list(test_turf.z)
	second_stub.forced_profile = "second_profile"

	var/list/test_hex = redspace_hex_coordinates(test_turf)
	first_stub.coefficient_target_key = redspace_hex_key(test_turf.z, test_hex[1], test_hex[2])

	var/datum/redspace_context/test_context = new(list(first_stub, second_stub))
	test_context.refresh()
	if(test_context.background_value != 5)
		return Fail("Context background must use the last provider proposal")
	if(test_context.active_profile_id != "second_profile")
		return Fail("Context profile must use the last provider proposal")
	if(length(test_context.active_z_levels) != 1 || !(test_turf.z in test_context.active_z_levels))
		return Fail("Context must union provider z-levels without duplicates")

	var/coefficient = test_context.get_zone_coefficient(test_turf.z, test_hex[1], test_hex[2])
	if(coefficient != 0.5)
		return Fail("Stub provider must apply a zone coefficient to its hex")
	var/cached_key = redspace_hex_key(test_turf.z, test_hex[1], test_hex[2])
	if(!isnum(test_context.zone_coefficients[cached_key]))
		return Fail("Zone coefficients must be cached by hex key")
	var/lookups_before = first_stub.coefficient_lookups
	test_context.get_zone_coefficient(test_turf.z, test_hex[1], test_hex[2])
	if(first_stub.coefficient_lookups != lookups_before)
		return Fail("Cached zone coefficients must not consult providers again")

	var/other_coefficient = test_context.get_zone_coefficient(test_turf.z, test_hex[1] + 40, test_hex[2] + 40)
	if(other_coefficient != REDSPACE_DEFAULT_COEFFICIENT)
		return Fail("Hexes without provider rules must keep the default coefficient")
	qdel(test_context)

	var/datum/redspace_context/default_context = new(list(new /datum/redspace_context_provider/default()))
	default_context.refresh()
	if(!length(default_context.active_z_levels))
		return Fail("Default provider must resolve station z-levels")
	for(var/station_z in default_context.active_z_levels)
		if(!SSmapping.level_trait(station_z, ZTRAIT_STATION))
			return Fail("Default provider must only return z-levels with the station trait")
	if(default_context.active_profile_id != REDSPACE_PROFILE_DEMONIC)
		return Fail("Default provider must select the demonic MVP profile")
	if(default_context.get_zone_coefficient(test_turf.z, test_hex[1], test_hex[2]) != REDSPACE_DEFAULT_COEFFICIENT)
		return Fail("Non-bridge hexes must keep the default coefficient")
	qdel(default_context)

	// The representative turf of a hex must convert back into the same hex.
	var/list/hex_checks = list(
		list(test_hex[1], test_hex[2]),
		list(test_hex[1] + 1, test_hex[2]),
		list(test_hex[1] + 1, test_hex[2] - 1),
		list(test_hex[1], test_hex[2] - 1),
		list(test_hex[1] - 1, test_hex[2]),
		list(test_hex[1] - 1, test_hex[2] + 1),
		list(test_hex[1], test_hex[2] + 1),
	)
	for(var/list/hex_pair as anything in hex_checks)
		var/turf/representative_turf = redspace_hex_representative_turf(test_turf.z, hex_pair[1], hex_pair[2])
		if(!representative_turf)
			continue
		var/list/roundtrip = redspace_hex_coordinates(representative_turf)
		if(roundtrip[1] != hex_pair[1] || roundtrip[2] != hex_pair[2])
			return Fail("Representative turf of hex ([hex_pair[1]], [hex_pair[2]]) must convert back into the same hex")

	var/datum/redspace_field_source/wave/test_wave = new(0, test_turf, 10, 2, "test")
	test_wave.velocity_x = 1
	test_wave.created_at = world.time - 5 SECONDS
	var/list/wave_center = test_wave.get_current_center()
	if(abs(wave_center[1] - (test_turf.x + 5)) > 0.01)
		return Fail("Wave center must move with elapsed time")
	var/turf/wave_arrival_turf = locate(test_turf.x + 5, test_turf.y, test_turf.z)
	if(test_wave.get_contribution(wave_arrival_turf) <= 0)
		return Fail("Wave must affect tiles near its current center")
	if(!test_wave.can_affect(wave_arrival_turf) || test_wave.can_affect(test_turf))
		return Fail("Wave range checks must follow its moving center")
	if(test_wave.get_contribution(test_turf) != 0)
		return Fail("Wave must stop affecting tiles it has moved away from")
	if(!test_wave.requires_processing())
		return Fail("Waves must require processing")
	qdel(test_wave)

	var/datum/redspace_field_source/timed_source = new(0, test_turf, 5, 3, "test", 10 SECONDS, "unit test")
	if(timed_source.is_expired())
		return Fail("Fresh timed source must not be expired")
	if(!timed_source.requires_processing())
		return Fail("Timed sources must require processing")
	if(timed_source.get_remaining_lifetime() > 10 SECONDS)
		return Fail("Remaining lifetime must not exceed the registered lifetime")
	timed_source.expires_at = world.time - 1
	if(!timed_source.is_expired())
		return Fail("Sources past their lifetime must expire")
	qdel(timed_source)

	var/datum/redspace_field_source/hotspot/test_hotspot = new(0, test_turf, 5, 3, "test")
	if(!test_hotspot.requires_processing())
		return Fail("Growable hotspots must require processing")
	if(test_hotspot.get_contribution(test_turf) != 5)
		return Fail("Hotspots must contribute their strength at the origin")
	test_hotspot.strength = REDSPACE_MAX_NORMAL_VALUE
	test_hotspot.radius = REDSPACE_MAX_SOURCE_RADIUS
	if(test_hotspot.requires_processing())
		return Fail("Fully grown hotspots must not require processing")
	qdel(test_hotspot)

	var/datum/redspace_field_source/mutable_source = new(0, test_turf, 5, 3, "test")
	if(!mutable_source.set_strength(8, "unit test") || mutable_source.strength != 8)
		return Fail("Strength updates must apply")
	if(mutable_source.change_reason != "unit test")
		return Fail("Source changes must record their reason")
	var/turf/next_turf = get_step(test_turf, NORTH)
	if(!mutable_source.set_position(next_turf, "unit test") || mutable_source.origin_y != next_turf.y)
		return Fail("Position updates must apply on the same z-level")
	if(mutable_source.set_position(null, "unit test"))
		return Fail("Position updates without a turf must fail")
	qdel(mutable_source)

/datum/redspace_context_provider/test_stub
	provider_id = "test_stub"
	var/forced_background
	var/list/forced_z_levels
	var/forced_profile
	var/coefficient_target_key
	var/coefficient_lookups = 0

/datum/redspace_context_provider/test_stub/get_background_value()
	return forced_background

/datum/redspace_context_provider/test_stub/get_active_z_levels()
	return forced_z_levels

/datum/redspace_context_provider/test_stub/get_profile_id()
	return forced_profile

/datum/redspace_context_provider/test_stub/get_zone_coefficient(z_level, q, r, turf/representative_turf)
	coefficient_lookups++
	if(coefficient_target_key == redspace_hex_key(z_level, q, r))
		return 0.5
	return null

#endif
