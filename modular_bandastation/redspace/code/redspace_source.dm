/// A spatial contribution to the redspace field.
/// Sources are queried only when a registered observer or an explicit debug request samples a turf.
/datum/redspace_field_source
	var/source_id
	var/profile_id
	var/z_level
	var/origin_x
	var/origin_y
	var/strength
	var/radius
	var/created_at

/datum/redspace_field_source/New(new_id, turf/origin, new_strength, new_radius, new_profile_id)
	. = ..()
	source_id = new_id
	profile_id = new_profile_id
	z_level = origin?.z
	origin_x = origin?.x
	origin_y = origin?.y
	strength = new_strength
	radius = max(0, new_radius)
	created_at = world.time

/// Returns this source's contribution at a canonical map tile.
/datum/redspace_field_source/proc/get_contribution(turf/target)
	if(!target || target.z != z_level || !origin_x || !origin_y)
		return 0

	var/delta_x = target.x - origin_x
	var/delta_y = target.y - origin_y
	var/distance_squared = delta_x * delta_x + delta_y * delta_y
	if(!radius)
		return distance_squared ? 0 : strength

	var/radius_squared = radius * radius
	if(distance_squared > radius_squared)
		return 0

	// Quadratic falloff avoids a square root in the sampling path.
	return strength * (radius_squared - distance_squared) / radius_squared

/datum/redspace_field_source/proc/get_debug_label()
	return "#[source_id] [profile_id] ([origin_x], [origin_y], [z_level]), сила [round(strength, 0.1)], радиус [radius]"
