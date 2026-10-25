// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	lighting_corner_NE?.vis_update()
	lighting_corner_SE?.vis_update()
	lighting_corner_SW?.vis_update()
	lighting_corner_NW?.vis_update()

/turf/proc/lighting_clear_overlay()
	if (lighting_object)
		qdel(lighting_object, force=TRUE)

// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/lighting_build_overlay()
	if (lighting_object)
		qdel(lighting_object, force=TRUE) //Shitty fix for lighting objects persisting after death

	new /atom/movable/lighting_object(src)

/// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	if (!lighting_object)
		return 1

	var/totallums = get_static_lumcount(minlum, maxlum)
	totallums += get_dynamic_lumcount()
	return CLAMP01(totallums)

// BANDASTATION EDIT START - Thresholds must use the complete light value, including subtractive lights
/// Uses the same final light value as get_lumcount, preserving strict threshold comparisons.
/turf/proc/check_lumcount_below(value)
	return get_lumcount() < value

/// Uses the same final light value as get_lumcount, preserving strict threshold comparisons.
/turf/proc/check_lumcount_above(value)
	return get_lumcount() > value
// BANDASTATION EDIT END - Thresholds must use the complete light value, including subtractive lights

/// Returns lumcount from turf lighting
/turf/proc/get_static_lumcount(minlum = 0, maxlum = 1)
	// BANDASTATION EDIT START - Read the normalized colour channels that lighting_object renders
	var/red = 0
	var/green = 0
	var/blue = 0
	var/datum/lighting_corner/L
	L = lighting_corner_NE
	if (L)
		red += L.cache_r
		green += L.cache_g
		blue += L.cache_b
	L = lighting_corner_SE
	if (L)
		red += L.cache_r
		green += L.cache_g
		blue += L.cache_b
	L = lighting_corner_SW
	if (L)
		red += L.cache_r
		green += L.cache_g
		blue += L.cache_b
	L = lighting_corner_NW
	if (L)
		red += L.cache_r
		green += L.cache_g
		blue += L.cache_b

	// Clip after interpolation, as the renderer does; negative channels cannot cancel another colour.
	var/totallums = (CLAMP01(red / 4) + CLAMP01(green / 4) + CLAMP01(blue / 4)) / 3
	return (totallums - minlum) / (maxlum - minlum)
	// BANDASTATION EDIT END - Read the normalized colour channels that lighting_object renders

/// Fetches dynamic lumcount from lightsources potentially in view of this turf from our spatial grid
/turf/proc/get_dynamic_lumcount()
	. = 0
	// BANDASTATION EDIT START - Sum actual visible mask contributions, not a constant per source
	var/list/light_contributions = collect_dynamic_lightsources()
	for (var/datum/component/overlay_lighting/light as anything in light_contributions)
		. += light_contributions[light]
	// BANDASTATION EDIT END - Sum actual visible mask contributions, not a constant per source

// You've heard of oranges_ear, prepare for oranges_eye
/// Uses the same optimization via viewers() that get_hearers_in_view does by allocating oranges ears to overlay lights
/// And collecting viewers rather than checking view() for each one of them
/turf/proc/collect_dynamic_lightsources()
	. = list()

	var/datum/spatial_grid_cell/grid_cell = SSspatial_grid.get_cell_of(src)
	var/list/light_sources = list()
	var/furthest_range = 0
	for (var/datum/component/overlay_lighting/light as anything in grid_cell.dynamic_light_sources)
		// BANDASTATION ADDITION - Stale or hidden candidates cannot illuminate a turf
		if(QDELETED(light) || QDELETED(light.light) || !light.light.currently_displaying || !(light.light.overlay_lighting_flags & LIGHTING_ON) || !light.light.current_holder)
			continue
		furthest_range = max(furthest_range, light.lumcount_range)
		var/atom/current_holder = light.light.current_holder
		// BANDASTATION EDIT - One holder can carry lights with different shapes and ranges
		LAZYADD(light_sources[current_holder], light)

	var/list/assigned_oranges_ears = SSspatial_grid.assign_oranges_ears(light_sources)
	for(var/mob/oranges_ear/ear in hearers(furthest_range, src))
		for (var/atom/glowie as anything in ear.references)
			// BANDASTATION EDIT START - Use each source's own transformed mask after the shared visibility query
			for(var/datum/component/overlay_lighting/light as anything in light_sources[glowie])
				var/contribution = light.light.get_lumcount(src)
				if(contribution)
					.[light] = contribution
			// BANDASTATION EDIT END - Use each source's own transformed mask after the shared visibility query

	for(var/mob/oranges_ear/remaining_ear as anything in assigned_oranges_ears)
		remaining_ear.unassign()

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	// BANDASTATION EDIT - Blackness uses the same final illumination as other light checks
	return get_lumcount() <= 0


///Proc to add movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/add_opacity_source(atom/movable/new_source)
	LAZYADD(opacity_sources, new_source)
	if(opacity)
		return
	recalculate_directional_opacity()


///Proc to remove movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/remove_opacity_source(atom/movable/old_source)
	LAZYREMOVE(opacity_sources, old_source)
	if(opacity) //Still opaque, no need to worry on updating.
		return
	recalculate_directional_opacity()


///Calculate on which directions this turfs block view.
/turf/proc/recalculate_directional_opacity()
	. = directional_opacity
	if(opacity)
		directional_opacity = ALL_CARDINALS
		if(. != directional_opacity)
			reconsider_lights()
		return
	directional_opacity = NONE
	if(opacity_sources)
		for(var/atom/movable/opacity_source as anything in opacity_sources)
			if(opacity_source.flags_1 & ON_BORDER_1)
				directional_opacity |= opacity_source.dir
			else //If fulltile and opaque, then the whole tile blocks view, no need to continue checking.
				directional_opacity = ALL_CARDINALS
				break
	else
		for(var/atom/movable/content as anything in contents)
			SEND_SIGNAL(content, COMSIG_TURF_NO_LONGER_BLOCK_LIGHT)
	if(. != directional_opacity && (. == ALL_CARDINALS || directional_opacity == ALL_CARDINALS))
		reconsider_lights() //The lighting system only cares whether the tile is fully concealed from all directions or not.

///Transfer the lighting of one area to another
/turf/proc/transfer_area_lighting(area/old_area, area/new_area)
	if(SSlighting.initialized && !space_lit)
		if (new_area.static_lighting != old_area.static_lighting)
			if (new_area.static_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

	// We will only run this logic on turfs off the prime z layer
	// Since on the prime z layer, we use an overlay on the area instead, to save time
	if(SSmapping.z_level_to_plane_offset[z])
		var/index = SSmapping.z_level_to_plane_offset[z] + 1
		//Inherit overlay of new area
		if(old_area.lighting_effects)
			cut_overlay(old_area.lighting_effects[index])
		if(new_area.lighting_effects)
			add_overlay(new_area.lighting_effects[index])

	// Manage removing/adding starlight overlays, we'll inherit from the area so we can drop it if the area has it already
	if(space_lit)
		if(!new_area.lighting_effects && old_area.lighting_effects)
			overlays += GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
		else if (new_area.lighting_effects && !old_area.lighting_effects)
			overlays -= GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
