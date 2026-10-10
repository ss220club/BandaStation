//TEST_FOCUS(/datum/unit_test/overlay_lighting_directional_light)
/// Checks a range-4 flashlight against independently sampled visual-mask positions in all cardinal directions.
/datum/unit_test/overlay_lighting_directional_light

/datum/unit_test/overlay_lighting_directional_light/Run()
	var/turf/center = locate(
		(run_loc_floor_bottom_left.x + run_loc_floor_top_right.x) / 2,
		(run_loc_floor_bottom_left.y + run_loc_floor_top_right.y) / 2,
		run_loc_floor_bottom_left.z,
	)
	TEST_ASSERT_NOTNULL(center, "Missing center of the unit test room.")
	var/obj/item/flashlight/flashlight = allocate(/obj/item/flashlight, center)
	flashlight.set_light_range(4)
	flashlight.set_light_power(1)

	// Each sample is (tiles forward, tiles to the left, visibly lit).
	// light_224.dmi is centered two tiles forward; light_cone.dmi only reaches adjacent tiles.
	// Lit samples have mask alpha > 100 at their centers; dark samples are entirely outside both masks.
	// Keep these expectations independent of is_turf_in_directional_light() and away from the fade boundary.
	var/list/samples = list(
		list(0, 0, TRUE),
		list(2, 0, TRUE),
		list(0, 1, TRUE),
		list(0, -1, TRUE),
		list(1, 2, TRUE),
		list(1, -2, TRUE),
		list(-2, 0, FALSE),
		list(-2, 2, FALSE),
		list(-2, -2, FALSE),
	)
	for(var/direction in GLOB.cardinals)
		flashlight.setDir(direction)
		var/forward_x = (direction == EAST) - (direction == WEST)
		var/forward_y = (direction == NORTH) - (direction == SOUTH)
		for(var/is_on in list(FALSE, TRUE, FALSE))
			flashlight.set_light_on(is_on)
			for(var/list/sample as anything in samples)
				var/turf/target = locate(
					center.x + forward_x * sample[1] - forward_y * sample[2],
					center.y + forward_y * sample[1] + forward_x * sample[2],
					center.z,
				)
				TEST_ASSERT(istype(target, /turf/open/indestructible), "Light sample must be on the open unit test floor.")
				var/expected_lum = (is_on && sample[3]) ? 0.5 : 0
				var/actual_lum = target.get_dynamic_lumcount()
				if(actual_lum != expected_lum)
					TEST_FAIL("[dir2text(direction)], forward=[sample[1]], left=[sample[2]], light_on=[is_on]: expected dynamic lumcount [expected_lum], got [actual_lum].")
