#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_stabilizer

/datum/unit_test/redspace_stabilizer/Run()
	if(redspace_stabilizer_calculate_contribution(2, 3, 4) != 0)
		return Fail("A stabilizer must not create a negative contribution below its target value")
	if(redspace_stabilizer_calculate_contribution(4, 3, 4) != -1)
		return Fail("A stabilizer must request only the correction needed to reach its target")
	if(redspace_stabilizer_calculate_contribution(10, 3, 4) != -4)
		return Fail("A stabilizer must respect its configurable maximum negative contribution")
	if(redspace_stabilizer_calculate_contribution(10, 3, 4, 0.5) != -2)
		return Fail("A stabilizer contribution must scale with machine efficiency")
	if(redspace_stabilizer_calculate_contribution(10.1, 3, 4) != 0)
		return Fail("A stabilizer must not counter an event-only invasion override")
	if(!SSredspace || SSredspace.max_stabilizer_negative_contribution != 8)
		return Fail("Overlapping stabilizers must allow a combined contribution of -8")

	var/turf/test_turf = run_loc_floor_bottom_left
	var/datum/redspace_field_source/stabilizer/source = new(0, test_turf, 4, 4, REDSPACE_PROFILE_STABILIZER)
	if(source.strength != 0)
		return Fail("Stabilizer sources must clamp their initial strength to zero or below")
	if(!source.set_strength(-3, "unit test") || source.strength != -3)
		return Fail("Stabilizer sources must accept negative strengths")
	if(!source.set_strength(3, "unit test") || source.strength > 0)
		return Fail("Stabilizer sources must never become positive sources")
	qdel(source)

TEST_FOCUS(/datum/unit_test/redspace_stabilizer)

#endif
