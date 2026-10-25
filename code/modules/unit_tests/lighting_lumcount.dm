/obj/effect/lighting_lumcount_static_test
	icon_state = "nothing"
	light_system = COMPLEX_LIGHT

/// Use real lighting corners and a native light source to keep their lifecycle valid.
/datum/unit_test/lighting_lumcount
	abstract_type = /datum/unit_test/lighting_lumcount
	var/turf/sample_turf
	var/list/previous_corners
	var/list/datum/lighting_corner/test_corners
	var/created_lighting = FALSE

/datum/unit_test/lighting_lumcount/New()
	. = ..()
	sample_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	previous_corners = list(sample_turf.lighting_corner_NE, sample_turf.lighting_corner_SE, sample_turf.lighting_corner_SW, sample_turf.lighting_corner_NW)
	if(!sample_turf.lighting_object)
		sample_turf.lighting_build_overlay()
		created_lighting = TRUE
	var/obj/effect/corner_owner = allocate(/obj/effect/lighting_lumcount_static_test, sample_turf)
	corner_owner.set_light(2, 1, COLOR_WHITE)
	test_corners = list()
	for(var/index in 1 to 4)
		var/datum/lighting_corner/corner = new(0, 0, 0)
		corner.affecting = list(corner_owner.light)
		test_corners += corner
	sample_turf.lighting_corner_NE = test_corners[1]
	sample_turf.lighting_corner_SE = test_corners[2]
	sample_turf.lighting_corner_SW = test_corners[3]
	sample_turf.lighting_corner_NW = test_corners[4]
	set_corner_values(0, 0, 0)

/datum/unit_test/lighting_lumcount/Destroy()
	if(sample_turf && previous_corners)
		sample_turf.lighting_corner_NE = previous_corners[1]
		sample_turf.lighting_corner_SE = previous_corners[2]
		sample_turf.lighting_corner_SW = previous_corners[3]
		sample_turf.lighting_corner_NW = previous_corners[4]
		if(created_lighting)
			sample_turf.lighting_clear_overlay()
		else
			sample_turf.lighting_object?.update()
	for(var/datum/lighting_corner/corner as anything in test_corners)
		qdel(corner, force = TRUE)
	test_corners = null
	previous_corners = null
	sample_turf = null
	return ..()

/// Apply real corner normalization/rounding before updating the native rendering matrix.
/datum/unit_test/lighting_lumcount/proc/set_corner_values(red, green, blue)
	for(var/datum/lighting_corner/corner as anything in test_corners)
		corner.lum_r = red
		corner.lum_g = green
		corner.lum_b = blue
		corner.update_objects()
	sample_turf.lighting_object.update()

/// Keep native geometry and grid evidence in a failed directional assertion.
/datum/unit_test/lighting_lumcount/proc/light_diagnostics(atom/movable/source, turf/target)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	var/datum/light_overlay/light = component.light
	var/matrix/transform = light.visible_mask.transform
	var/datum/spatial_grid_cell/target_cell = SSspatial_grid.get_cell_of(target)
	var/turf/source_turf = get_turf(source)
	var/icon/circle = icon(light.visible_mask.icon, light.visible_mask.icon_state, source.dir, 1)
	return "source=[source.type] at [source.x],[source.y],[source.z], source_turf=[source_turf.type]; holder=[light.current_holder.type] at [light.current_holder.x],[light.current_holder.y],[light.current_holder.z]; target=[target.type] at [target.x],[target.y],[target.z]; room=[run_loc_floor_bottom_left.x],[run_loc_floor_bottom_left.y]..[run_loc_floor_top_right.x],[run_loc_floor_top_right.y]; dir=[source.dir], tracked_dir=[light.current_direction], range=[light.range], cast=[light.cast_range], grid_range=[component.lumcount_range], in_cell=[component in target_cell.dynamic_light_sources]; direct=[light.get_lumcount(target)], circle_sample=[light.sample_lumcount(light.visible_mask, target)], cone_sample=[light.sample_lumcount(light.cone, target)]; matrix=[transform?.a],[transform?.b],[transform?.c],[transform?.d],[transform?.e],[transform?.f]; icon=[circle.Width()]x[circle.Height()], alpha=[light.visible_mask.alpha]"

/datum/unit_test/lighting_lumcount/static_normalization/Run()
	var/datum/lighting_corner/corner = test_corners[1]
	corner.lum_r = 3
	corner.update_objects()
	sample_turf.lighting_object.update()
	TEST_ASSERT_EQUAL(corner.cache_r, 1, "The native renderer did not normalize an overbright red corner.")
	TEST_ASSERT_EQUAL(sample_turf.get_static_lumcount(), 1 / 12, "Static gameplay light used raw source strength instead of the rendered corner channels.")
	TEST_ASSERT(sample_turf.check_lumcount_below(0.2), "A visually dim red corner exceeded the shadow-creature light threshold.")
	TEST_ASSERT(!sample_turf.check_lumcount_above(0.2), "The threshold helpers disagree about the rendered static light.")

/datum/unit_test/lighting_lumcount/static_channel_clipping/Run()
	set_corner_values(0.75, -0.75, 0)
	TEST_ASSERT_EQUAL(sample_turf.get_static_lumcount(), 0.25, "A negative colour channel cancelled a different rendered colour channel.")
	set_corner_values(-0.5, -0.5, -0.5)
	TEST_ASSERT_EQUAL(sample_turf.get_static_lumcount(), 0, "A black static lighting mask retained negative raw brightness.")

/datum/unit_test/lighting_lumcount/threshold_boundaries/Run()
	set_corner_values(0.25, 0.25, 0.25)
	TEST_ASSERT_EQUAL(sample_turf.get_lumcount(), 0.25, "The rendered static threshold fixture has the wrong light value.")
	TEST_ASSERT(!sample_turf.check_lumcount_below(0.25), "The below helper treated equality as below.")
	TEST_ASSERT(!sample_turf.check_lumcount_above(0.25), "The above helper treated equality as above.")
	TEST_ASSERT(sample_turf.check_lumcount_below(0.26), "The below helper rejected a larger threshold.")
	TEST_ASSERT(sample_turf.check_lumcount_above(0.24), "The above helper rejected a smaller threshold.")

/datum/unit_test/lighting_lumcount/soft_blackness/Run()
	TEST_ASSERT(sample_turf.is_softly_lit(), "A black static mask was not treated as unlit.")
	set_corner_values(0.25, 0.25, 0.25)
	TEST_ASSERT(!sample_turf.is_softly_lit(), "A visibly lit static mask was treated as unlit.")
	set_corner_values(0, 0, 0)
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 1, COLOR_WHITE)
	TEST_ASSERT(!sample_turf.is_softly_lit(), "A visible dynamic mask was treated as unlit.")
	source.set_light_on(FALSE)
	TEST_ASSERT(sample_turf.is_softly_lit(), "Disabling the last light did not restore blackness.")

/datum/unit_test/lighting_lumcount/small_light_footprint/Run()
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 1, COLOR_WHITE)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	TEST_ASSERT_NOTNULL(component, "The native overlay light component was not created.")
	TEST_ASSERT(sample_turf.get_dynamic_lumcount() > 0, "A light did not illuminate its own visible mask.")
	var/turf/adjacent = get_step(sample_turf, EAST)
	TEST_ASSERT_EQUAL(adjacent.get_dynamic_lumcount(), 0, "A one-tile light illuminated an adjacent tile outside its 32-pixel mask.")

/// A large light nearby must not expand the contribution of a smaller light.
/datum/unit_test/lighting_lumcount/unequal_ranges/Run()
	var/obj/effect/dummy/lighting_obj/small = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 1, COLOR_WHITE)
	var/turf/target = get_step(sample_turf, EAST)
	var/turf/large_location = get_step(target, EAST)
	var/obj/effect/dummy/lighting_obj/large = allocate(/obj/effect/dummy/lighting_obj, large_location, 3, 1, COLOR_WHITE)
	var/with_small = target.get_dynamic_lumcount()
	small.set_light_on(FALSE)
	TEST_ASSERT_EQUAL(target.get_dynamic_lumcount(), with_small, "A larger source expanded the small source's numeric footprint.")
	TEST_ASSERT(with_small > 0, "The larger source did not illuminate the chosen target.")
	large.set_light_on(FALSE)
	TEST_ASSERT_EQUAL(target.get_dynamic_lumcount(), 0, "Disabling both sources left ghost illumination.")

/// Native directional light translates its circular mask and also displays a cone.
/obj/effect/dummy/lighting_obj/lumcount_directional_test
	light_system = OVERLAY_LIGHT_DIRECTIONAL

/datum/unit_test/lighting_lumcount/directional_turn/Run()
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj/lumcount_directional_test, sample_turf, 2, 1, COLOR_WHITE)
	source.setDir(EAST)
	var/turf/in_front = get_step(get_step(sample_turf, EAST), EAST)
	var/turf/behind = get_step(get_step(sample_turf, WEST), WEST)
	TEST_ASSERT(in_front.get_dynamic_lumcount() > 0, "The translated light mask did not illuminate the forward tile. [light_diagnostics(source, in_front)]")
	TEST_ASSERT_EQUAL(behind.get_dynamic_lumcount(), 0, "A directional light illuminated a tile behind its visible mask.")
	source.setDir(WEST)
	TEST_ASSERT(behind.get_dynamic_lumcount() > 0, "Turning a directional light did not move its numeric footprint. [light_diagnostics(source, behind)]")
	TEST_ASSERT_EQUAL(in_front.get_dynamic_lumcount(), 0, "The old forward tile stayed numerically lit after turning away.")

/// Exercise the actual flashlight caller, including tracking its human holder's direction.
/datum/unit_test/lighting_lumcount/held_flashlight/Run()
	var/mob/living/carbon/human/carrier = allocate(/mob/living/carbon/human/consistent, sample_turf)
	var/obj/item/flashlight/source = allocate(/obj/item/flashlight, sample_turf)
	source.set_light_range(2)
	source.set_light_color(COLOR_WHITE)
	carrier.put_in_active_hand(source, forced = TRUE)
	carrier.setDir(EAST)
	source.set_light_on(TRUE)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	TEST_ASSERT_EQUAL(component.light.current_holder, carrier, "A held flashlight did not track the human as its visual holder.")
	var/turf/in_front = get_step(get_step(sample_turf, EAST), EAST)
	var/turf/behind = get_step(get_step(sample_turf, WEST), WEST)
	TEST_ASSERT(in_front.get_dynamic_lumcount() > 0, "A held flashlight did not illuminate its holder's forward tile. [light_diagnostics(source, in_front)]")
	TEST_ASSERT_EQUAL(behind.get_dynamic_lumcount(), 0, "A held flashlight illuminated a tile behind its visible mask.")
	carrier.setDir(WEST)
	TEST_ASSERT(behind.get_dynamic_lumcount() > 0, "Turning the human did not turn the held flashlight's numeric footprint. [light_diagnostics(source, behind)]")
	TEST_ASSERT_EQUAL(in_front.get_dynamic_lumcount(), 0, "Turning the human retained light in the old forward tile.")

/obj/effect/dummy/lighting_obj/lumcount_beam_test
	light_system = OVERLAY_LIGHT_BEAM

/datum/unit_test/lighting_lumcount/beam_width/Run()
	var/obj/effect/dummy/lighting_obj/wide = allocate(/obj/effect/dummy/lighting_obj/lumcount_directional_test, sample_turf, 3, 1, COLOR_WHITE)
	wide.setDir(EAST)
	var/turf/in_front = get_step(get_step(sample_turf, EAST), EAST)
	var/turf/transverse = get_step(in_front, NORTH)
	var/wide_value = transverse.get_dynamic_lumcount()
	TEST_ASSERT(wide_value > 0, "The ordinary directional light did not illuminate its side sample. [light_diagnostics(wide, transverse)]")
	wide.set_light_on(FALSE)
	var/obj/effect/dummy/lighting_obj/beam = allocate(/obj/effect/dummy/lighting_obj/lumcount_beam_test, sample_turf, 3, 1, COLOR_WHITE)
	beam.setDir(EAST)
	TEST_ASSERT(in_front.get_dynamic_lumcount() > 0, "The native beam did not illuminate its forward centre. [light_diagnostics(beam, in_front)]")
	TEST_ASSERT(transverse.get_dynamic_lumcount() < wide_value, "A compressed beam was numerically as wide as the ordinary light mask. [light_diagnostics(beam, transverse)]")

/datum/unit_test/lighting_lumcount/power_and_colour/Run()
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 0.1, COLOR_WHITE)
	var/dim_value = sample_turf.get_dynamic_lumcount()
	source.set_light_power(1)
	var/bright_value = sample_turf.get_dynamic_lumcount()
	TEST_ASSERT(dim_value > 0 && bright_value > dim_value, "Numeric illumination ignored the visible mask's power-dependent alpha.")
	source.set_light_color(COLOR_BLACK)
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "A black light mask added numeric white light.")
	source.set_light_color(COLOR_WHITE)
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), bright_value, "Restoring a mask's colour did not restore its light contribution.")

/datum/unit_test/lighting_lumcount/negative_sources/Run()
	var/obj/effect/dummy/lighting_obj/positive = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 1, COLOR_WHITE)
	var/obj/effect/dummy/lighting_obj/negative = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, -1, COLOR_WHITE)
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "Equal additive and subtractive masks did not cancel.")
	set_corner_values(0.25, 0.25, 0.25)
	TEST_ASSERT_EQUAL(sample_turf.get_lumcount(), 0.25, "Combined light differs from the static light after matching masks cancel.")
	positive.set_light_on(FALSE)
	var/darkened = sample_turf.get_lumcount()
	TEST_ASSERT(darkened < 0.25, "A subtractive overlay did not darken the static light.")
	TEST_ASSERT_EQUAL(sample_turf.check_lumcount_above(0.2), darkened > 0.2, "The above helper returned before subtractive lights were applied.")
	TEST_ASSERT_EQUAL(sample_turf.check_lumcount_below(0.2), darkened < 0.2, "The below helper returned before subtractive lights were applied.")
	negative.set_light_on(FALSE)
	TEST_ASSERT_EQUAL(sample_turf.get_lumcount(), 0.25, "Disabling a subtractive source did not restore static light.")

/datum/unit_test/lighting_lumcount/same_turf_toggle/Run()
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 1, COLOR_WHITE)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	var/datum/spatial_grid_cell/cell = SSspatial_grid.get_cell_of(sample_turf)
	var/original = sample_turf.get_dynamic_lumcount()
	TEST_ASSERT(original > 0, "The fixture started without visible light.")
	source.set_light_on(FALSE)
	TEST_ASSERT(!(component in cell.dynamic_light_sources), "Turning off a light retained its spatial-grid membership.")
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "Turning off a stationary light retained illumination.")
	source.set_light_on(TRUE)
	TEST_ASSERT(component in cell.dynamic_light_sources, "Turning on a stationary light did not restore grid membership.")
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), original, "Turning on a stationary light did not restore illumination.")

/datum/unit_test/lighting_lumcount/range_cleanup/Run()
	// Cross a real cell boundary while staying away from the map's clipped edges.
	var/turf/source_turf = locate(SPATIAL_GRID_CELLSIZE + 3, sample_turf.y, sample_turf.z)
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, source_turf, 6, 1, COLOR_WHITE)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	var/list/old_cells = SSspatial_grid.get_cells_in_range(source_turf, component.lumcount_range)
	TEST_ASSERT(length(old_cells), "The large light had no spatial-grid coverage.")
	source.set_light_range(1)
	var/list/current_cells = SSspatial_grid.get_cells_in_range(source_turf, component.lumcount_range)
	TEST_ASSERT(length(old_cells) > length(current_cells), "The range regression fixture did not cross a real spatial-grid boundary.")
	for(var/datum/spatial_grid_cell/cell as anything in old_cells)
		TEST_ASSERT_EQUAL((component in cell.dynamic_light_sources), (cell in current_cells), "Shrinking a light retained stale membership in an old grid cell.")
	qdel(source)
	for(var/datum/spatial_grid_cell/cell as anything in old_cells)
		TEST_ASSERT(!(component in cell.dynamic_light_sources), "Deleting a light retained membership in an affected grid cell.")
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "A deleted light retained numeric illumination.")

/datum/unit_test/lighting_lumcount/hidden_holder/Run()
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, sample_turf, 1, 1, COLOR_WHITE)
	var/obj/item/storage/box/container = allocate(/obj/item/storage/box, sample_turf)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	var/datum/spatial_grid_cell/cell = SSspatial_grid.get_cell_of(sample_turf)
	TEST_ASSERT(sample_turf.get_dynamic_lumcount() > 0, "The fixture started without visible light.")
	source.forceMove(container)
	TEST_ASSERT_NULL(component.light.current_holder, "Storage did not hide the light's native visual holder.")
	TEST_ASSERT(!(component in cell.dynamic_light_sources), "Storage retained a hidden light in the spatial grid.")
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "A light hidden in storage illuminated the outside turf.")
	source.forceMove(sample_turf)
	TEST_ASSERT(sample_turf.get_dynamic_lumcount() > 0, "Removing a source from storage did not restore its light.")
	source.moveToNullspace()
	TEST_ASSERT_NULL(component.light.current_holder, "A nullspace light retained a visual holder.")
	TEST_ASSERT(!(component in cell.dynamic_light_sources), "A nullspace light retained grid membership.")
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "A source in nullspace illuminated its old turf.")

/// A native shadow person's own physiology must follow the visible light footprint.
/datum/unit_test/lighting_lumcount/shadow_light_damage/Run()
	var/mob/living/carbon/human/shadow = allocate(/mob/living/carbon/human/consistent, sample_turf)
	shadow.set_species(/datum/species/shadow)
	var/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/physiology = locate() in shadow.status_effects
	TEST_ASSERT_NOTNULL(physiology, "Changing to the shadow species did not create native light-sensitive physiology.")
	TEST_ASSERT(length(physiology.bodyparts), "The native shadow physiology has no contributing bodyparts.")
	var/turf/adjacent = get_step(sample_turf, EAST)
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj, adjacent, 1, 1, COLOR_WHITE)
	var/initial_brute = shadow.get_brute_loss()
	var/initial_burn = shadow.get_fire_loss()
	physiology.tick(1)
	TEST_ASSERT_EQUAL(shadow.get_brute_loss(), initial_brute, "A shadow person took brute damage outside the visible one-tile light mask.")
	TEST_ASSERT_EQUAL(shadow.get_fire_loss(), initial_burn, "A shadow person was burned outside the visible one-tile light mask.")
	source.forceMove(sample_turf)
	physiology.tick(1)
	var/lit_brute = shadow.get_brute_loss()
	var/lit_burn = shadow.get_fire_loss()
	TEST_ASSERT(lit_brute > initial_brute && lit_burn > initial_burn, "Native shadow physiology did not react to visible light on its tile.")
	source.set_light_on(FALSE)
	physiology.tick(1)
	TEST_ASSERT(shadow.get_brute_loss() < lit_brute && shadow.get_fire_loss() < lit_burn, "Native shadow physiology did not heal after visible light was disabled.")

/// Define offsets before the real component initializes, matching sprites shifted in map definitions.
/obj/effect/dummy/lighting_obj/lumcount_offset_test
	pixel_w = 32
	pixel_z = 32

/datum/unit_test/lighting_lumcount/pixel_offsets/Run()
	var/obj/effect/dummy/lighting_obj/source = allocate(/obj/effect/dummy/lighting_obj/lumcount_offset_test, sample_turf, 1, 1, COLOR_WHITE)
	var/datum/component/overlay_lighting/component = source.GetComponent(/datum/component/overlay_lighting)
	var/turf/shifted = get_step(sample_turf, NORTHEAST)
	TEST_ASSERT_EQUAL(sample_turf.get_dynamic_lumcount(), 0, "A shifted light illuminated its unshifted origin instead of its visible mask.")
	TEST_ASSERT(shifted.get_dynamic_lumcount() > 0, "Pixel-w/z offsets moved the native visual mask without moving numeric illumination.")
	TEST_ASSERT_EQUAL(component.light.current_holder, source, "The shifted source acquired an unexpected visual holder.")
