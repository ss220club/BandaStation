/datum/unit_test/overlay_lighting_directional_light

/datum/unit_test/overlay_lighting_directional_light/Run()
	var/turf/center = locate(10, 10, 1)
	if(!center)
		return

	var/obj/effect/test_light = new(center)
	var/datum/component/overlay_lighting/light = test_light.AddComponent(/datum/component/overlay_lighting, 4, NORTH, TRUE)

	// Center tile is always illuminated.
	TEST_ASSERT(
		light.is_turf_in_directional_light(center),
		"Directional light must affect its source turf."
	)

	// Directly in front of the light.
	for(var/distance = 1 to 4)
		var/turf/front = locate(center.x, center.y + distance, center.z)

		TEST_ASSERT(
			light.is_turf_in_directional_light(front),
			"Tile [front] at distance [distance] should be affected by NORTH directional light."
		)

	// Tiles outside the cone.
	for(var/distance = 1 to 4)
		var/turf/side = locate(center.x + distance, center.y, center.z)

		TEST_ASSERT(
			!light.is_turf_in_directional_light(side),
			"Tile [side] should not be affected by NORTH directional light."
		)

	qdel(test_light)
