/datum/unit_test/overlay_lighting_directional_light
	Run()
		var/obj/effect/dummy/lighting_obj/light_source = new(locate(50, 50, 1))
		var/datum/component/overlay_lighting/light = light_source.AddComponent(/datum/component/overlay_lighting)

		light.current_holder = light_source
		light.directional = TRUE
		light.lumcount_range = 4

		// Север: только конус перед источником.
		light.current_direction = NORTH

		TEST_ASSERT(light.is_turf_in_directional_light(locate(50, 51, 1)), "NORTH: (0, 1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(49, 51, 1)), "NORTH: (-1, 1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(51, 51, 1)), "NORTH: (1, 1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(50, 54, 1)), "NORTH: (0, 4) should be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(50, 55, 1)), "NORTH: (0, 5) should be outside range.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(50, 49, 1)), "NORTH: tile behind the source should not be illuminated.")

		// Юг.
		light.current_direction = SOUTH

		TEST_ASSERT(light.is_turf_in_directional_light(locate(50, 49, 1)), "SOUTH: (0, -1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(49, 49, 1)), "SOUTH: (-1, -1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(51, 49, 1)), "SOUTH: (1, -1) should be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(50, 45, 1)), "SOUTH: (0, -5) should be outside range.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(50, 51, 1)), "SOUTH: tile behind the source should not be illuminated.")

		// Восток.
		light.current_direction = EAST

		TEST_ASSERT(light.is_turf_in_directional_light(locate(51, 50, 1)), "EAST: (1, 0) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(51, 49, 1)), "EAST: (1, -1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(51, 51, 1)), "EAST: (1, 1) should be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(55, 50, 1)), "EAST: (5, 0) should be outside range.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(49, 50, 1)), "EAST: tile behind the source should not be illuminated.")

		// Запад.
		light.current_direction = WEST

		TEST_ASSERT(light.is_turf_in_directional_light(locate(49, 50, 1)), "WEST: (-1, 0) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(49, 49, 1)), "WEST: (-1, -1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(49, 51, 1)), "WEST: (-1, 1) should be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(45, 50, 1)), "WEST: (-5, 0) should be outside range.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(51, 50, 1)), "WEST: tile behind the source should not be illuminated.")

		// Диагональное направление должно идти только по соответствующей диагонали.
		light.current_direction = NORTHEAST

		TEST_ASSERT(light.is_turf_in_directional_light(locate(51, 51, 1)), "NORTHEAST: (1, 1) should be illuminated.")
		TEST_ASSERT(light.is_turf_in_directional_light(locate(54, 54, 1)), "NORTHEAST: (4, 4) should be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(50, 51, 1)), "NORTHEAST: (0, 1) should not be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(51, 50, 1)), "NORTHEAST: (1, 0) should not be illuminated.")
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(55, 55, 1)), "NORTHEAST: (5, 5) should be outside range.")

		// Источник света сам себя освещает.
		TEST_ASSERT(light.is_turf_in_directional_light(locate(50, 50, 1)), "The source turf itself should always be illuminated.")

		// Другой уровень Z не должен попадать в освещение.
		TEST_ASSERT(!light.is_turf_in_directional_light(locate(50, 51, 2)), "A turf on another Z-level should not be illuminated.")

		qdel(light_source)
