/datum/unit_test/overlay_lighting_directional_light

/datum/unit_test/overlay_lighting_directional_light/Run()
	var/turf/center = locate(10, 10, 1)
	if(!center)
		return
	var/obj/effect/test_light = new(center)
	var/datum/component/overlay_lighting/light = test_light.AddComponent(/datum/component/overlay_lighting, 4, null, null, TRUE, TRUE, FALSE, TRUE)
	var/expected_power = light.lum_power
	for(var/dx = -4 to 4)
		for(var/dy = -4 to 4)
			var/turf/T = locate(center.x + dx, center.y + dy, center.z)
			if(!T)
				continue
			var/expected_lit = light.is_turf_in_directional_light(T)
			var/actual_lum = T.get_dynamic_lumcount()
			if(expected_lit)
				TEST_ASSERT_EQUAL(actual_lum, expected_power, "Expected directional light to affect [T], but dynamic lumcount was [actual_lum].")
			else
				TEST_ASSERT_EQUAL(actual_lum, 0, "Expected directional light to not affect [T], but dynamic lumcount was [actual_lum].")

	qdel(test_light)
