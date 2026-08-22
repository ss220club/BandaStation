/// A spatial contribution to the redspace field.
/// Sources are sampled only for sparse cells created by observers or active zones.
/datum/redspace_field_source
	var/source_id
	var/profile_id
	var/z_level
	var/origin_x
	var/origin_y
	var/strength
	var/radius
	var/created_at
	/// world.time when the source expires. Null sources persist until removed.
	var/expires_at
	/// Human-readable reason for the latest registration or change. Kept for the journal.
	var/change_reason
	/// Resumable coverage discovery for large sources.
	var/list/coverage_turfs
	var/list/coverage_seen_cells
	var/coverage_cursor = 1

/datum/redspace_field_source/New(new_id, turf/origin, new_strength, new_radius, new_profile_id, new_lifetime = null, new_reason = null)
	. = ..()
	source_id = new_id
	profile_id = new_profile_id
	z_level = origin?.z
	origin_x = origin?.x
	origin_y = origin?.y
	strength = new_strength
	radius = max(0, new_radius)
	created_at = world.time
	if(isnum(new_lifetime) && new_lifetime > 0)
		expires_at = world.time + new_lifetime
	change_reason = new_reason

/datum/redspace_field_source/proc/reset_coverage_cache()
	coverage_turfs = null
	coverage_seen_cells = null
	coverage_cursor = 1

/// Whether the subsystem must track this source between registration and removal.
/datum/redspace_field_source/proc/requires_processing()
	return !isnull(expires_at)

/datum/redspace_field_source/proc/is_expired()
	return !isnull(expires_at) && world.time >= expires_at

/// Remaining lifetime in deciseconds. Null for persistent sources.
/datum/redspace_field_source/proc/get_remaining_lifetime()
	if(isnull(expires_at))
		return null
	return max(0, expires_at - world.time)

/// Moves the source origin on the same z-level. Returns TRUE when the position changed.
/datum/redspace_field_source/proc/set_position(turf/new_origin, reason = null)
	if(!new_origin || new_origin.z != z_level)
		return FALSE
	if(new_origin.x == origin_x && new_origin.y == origin_y)
		return FALSE
	origin_x = new_origin.x
	origin_y = new_origin.y
	reset_coverage_cache()
	change_reason = reason
	return TRUE

/datum/redspace_field_source/proc/set_strength(new_strength, reason = null)
	if(!isnum(new_strength) || strength == new_strength)
		return FALSE
	strength = new_strength
	change_reason = reason
	return TRUE

/datum/redspace_field_source/proc/set_radius(new_radius, reason = null)
	if(!isnum(new_radius))
		return FALSE
	new_radius = clamp(floor(new_radius + 0.5), 0, REDSPACE_MAX_SOURCE_RADIUS)
	if(radius == new_radius)
		return FALSE
	radius = new_radius
	reset_coverage_cache()
	change_reason = reason
	return TRUE

/// Returns this source's contribution at a canonical map tile.
/datum/redspace_field_source/proc/get_contribution(turf/target)
	if(!target || target.z != z_level || !origin_x || !origin_y)
		return 0

	var/delta_x = target.x - origin_x
	var/delta_y = target.y - origin_y
	return contribution_for_distance(delta_x * delta_x + delta_y * delta_y)

/// Shared radial falloff. Quadratic falloff avoids a square root in the sampling path.
/datum/redspace_field_source/proc/contribution_for_distance(distance_squared)
	if(!radius)
		return distance_squared ? 0 : strength

	var/radius_squared = radius * radius
	if(distance_squared > radius_squared)
		return 0

	return strength * (radius_squared - distance_squared) / radius_squared

/datum/redspace_field_source/proc/get_debug_label()
	var/lifetime_label = isnull(expires_at) ? "постоянный" : "осталось [round(get_remaining_lifetime() / (1 SECONDS))]с"
	return "#[source_id] [profile_id] ([origin_x], [origin_y], [z_level]), сила [round(strength, 0.1)], радиус [radius], [lifetime_label]"

/// A machine-owned negative source. The subsystem applies a shared local cap to
/// these sources so overlapping stabilizers have diminishing effective returns.
/datum/redspace_field_source/stabilizer

/datum/redspace_field_source/stabilizer/New(new_id, turf/origin, new_strength, new_radius, new_profile_id, new_lifetime = null, new_reason = null)
	if(!isnum(new_strength))
		new_strength = 0
	. = ..(new_id, origin, min(new_strength, 0), new_radius, new_profile_id, new_lifetime, new_reason)

/datum/redspace_field_source/stabilizer/set_strength(new_strength, reason = null)
	if(!isnum(new_strength))
		return FALSE
	return ..(min(new_strength, 0), reason)

/datum/redspace_field_source/stabilizer/get_debug_label()
	return "#[source_id] стабилизатор ([origin_x], [origin_y], [z_level]), сила [round(strength, 0.1)], радиус [radius]"

/// A stable local anomaly: a rift trace, an entity footprint or a faulty bluespace object.
/// Behaves like a static source but exists as its own type so events and the journal
/// can reason about persistent zones separately from debug contributions.
/datum/redspace_field_source/hotspot
	/// Optional description used in logs and debug tooling.
	var/description

/datum/redspace_field_source/hotspot/get_debug_label()
	return "#[source_id] горячая зона [profile_id] ([origin_x], [origin_y], [z_level]), сила [round(strength, 0.1)], радиус [radius][description ? ", [description]" : ""]"

/// A moving wave source. Its current center is derived from elapsed time, so the
/// subsystem only needs to refresh cached cells periodically instead of moving the datum each tick.
/datum/redspace_field_source/wave
	/// Horizontal speed in tiles per second.
	var/velocity_x = 0
	/// Vertical speed in tiles per second.
	var/velocity_y = 0

/datum/redspace_field_source/wave/New(new_id, turf/origin, new_strength, new_radius, new_profile_id, new_lifetime = null, new_reason = null, new_velocity_x = 0, new_velocity_y = 0)
	. = ..()
	velocity_x = new_velocity_x
	velocity_y = new_velocity_y

/// Moving waves always need cell refreshes and expiry checks.
/datum/redspace_field_source/wave/requires_processing()
	return TRUE

/// Wave center at the current time, in tile coordinates.
/datum/redspace_field_source/wave/proc/get_current_center()
	var/elapsed_seconds = max(0, world.time - created_at) / (1 SECONDS)
	return list(origin_x + velocity_x * elapsed_seconds, origin_y + velocity_y * elapsed_seconds)

/datum/redspace_field_source/wave/get_contribution(turf/target)
	if(!target || target.z != z_level || !origin_x || !origin_y)
		return 0

	var/list/center = get_current_center()
	var/delta_x = target.x - center[1]
	var/delta_y = target.y - center[2]
	return contribution_for_distance(delta_x * delta_x + delta_y * delta_y)

/datum/redspace_field_source/wave/get_debug_label()
	var/lifetime_label = isnull(expires_at) ? "постоянная" : "осталось [round(get_remaining_lifetime() / (1 SECONDS))]с"
	return "#[source_id] волна [profile_id] ([origin_x], [origin_y], [z_level]) -> ([round(velocity_x, 0.1)], [round(velocity_y, 0.1)]) т/с, амплитуда [round(strength, 0.1)], радиус [radius], [lifetime_label]"
