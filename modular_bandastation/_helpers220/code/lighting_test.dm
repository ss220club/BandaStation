/datum/unit_test/overlay_lighting_directional_light

/datum/unit_test/overlay_lighting_directional_light/Run()
	var/turf/center = locate(10, 10, 1)
	if(!center)
		return

	var/obj/effect/test_light = new(center)
	var/datum/component/overlay_lighting/light = test_light.AddComponent(/datum/component/overlay_lighting, 4, NORTH, TRUE)

	// Source turf is always illuminated.
	TEST_ASSERT(
		light.is_turf_in_directional_light(center),
		"Directional light must affect its source turf."
	)

	// Tiles directly in front of the source must be illuminated.
	for(var/distance = 1 to 4)
		var/turf/front = locate(center.x, center.y + distance, center.z)

		TEST_ASSERT(
			light.is_turf_in_directional_light(front),
			"Tile [front] at NORTH distance [distance] must be illuminated."
		)

	// The edges of the NORTH cone must be illuminated.
	for(var/distance = 1 to 4)
		var/turf/north_east_edge = locate(center.x + distance, center.y + distance, center.z)
		var/turf/north_west_edge = locate(center.x - distance, center.y + distance, center.z)

		TEST_ASSERT(
			light.is_turf_in_directional_light(north_east_edge),
			"Tile [north_east_edge] on the NORTH-EAST edge at distance [distance] must be illuminated."
		)

		TEST_ASSERT(
			light.is_turf_in_directional_light(north_west_edge),
			"Tile [north_west_edge] on the NORTH-WEST edge at distance [distance] must be illuminated."
		)

	// Tiles outside the NORTH cone must not be illuminated.
	for(var/distance = 1 to 4)
		var/turf/east = locate(center.x + distance, center.y, center.z)
		var/turf/west = locate(center.x - distance, center.y, center.z)
		var/turf/south = locate(center.x, center.y - distance, center.z)

		TEST_ASSERT(
			!light.is_turf_in_directional_light(east),
			"Tile [east] outside the NORTH cone must not be illuminated."
		)

		TEST_ASSERT(
			!light.is_turf_in_directional_light(west),
			"Tile [west] outside the NORTH cone must not be illuminated."
		)

		TEST_ASSERT(
			!light.is_turf_in_directional_light(south),
			"Tile [south] behind the light source must not be illuminated."
		)

	// Tiles beyond the light's range must not be illuminated.
	var/turf/beyond_range = locate(center.x, center.y + 5, center.z)

	TEST_ASSERT(
		!light.is_turf_in_directional_light(beyond_range),
		"Tile [beyond_range] outside the light range must not be illuminated."
	)

	qdel(test_light)
