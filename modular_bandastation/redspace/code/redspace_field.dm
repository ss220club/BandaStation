/// Converts a field value into its gameplay range.
/proc/redspace_state_from_value(value)
	if(isnull(value))
		return
	if(value < 0)
		return REDSPACE_STATE_EBB
	if(value <= 3)
		return REDSPACE_STATE_CALM
	if(value <= 6)
		return REDSPACE_STATE_DISTURBANCE
	if(value <= 10)
		return REDSPACE_STATE_STORM
	return REDSPACE_STATE_INVASION

/// Returns a short human-readable label for a gameplay range.
/proc/redspace_state_name(state)
	switch(state)
		if(REDSPACE_STATE_EBB)
			return "отлив"
		if(REDSPACE_STATE_CALM)
			return "штиль"
		if(REDSPACE_STATE_DISTURBANCE)
			return "возмущение"
		if(REDSPACE_STATE_STORM)
			return "шторм"
		if(REDSPACE_STATE_INVASION)
			return "вторжение"
	return "неизвестно"

/// Returns pointy-top axial coordinates for the hex containing a turf.
/proc/redspace_hex_coordinates(turf/target) as /list
	if(!target)
		return

	// Use tile centers as points in a coordinate plane with a fixed round origin.
	var/px = target.x - 0.5
	var/py = target.y - 0.5
	var/q = (REDSPACE_HEX_SQRT3 / 3 * px - 0.3333333333333333 * py) / REDSPACE_HEX_RADIUS
	var/r = (0.6666666666666666 * py) / REDSPACE_HEX_RADIUS
	var/s = -q - r

	// DM's round() rounds toward the lower multiple for these values; use an
	// explicit nearest-integer operation for cube-coordinate rounding.
	var/rounded_q = floor(q + 0.5)
	var/rounded_r = floor(r + 0.5)
	var/rounded_s = floor(s + 0.5)
	var/q_difference = abs(rounded_q - q)
	var/r_difference = abs(rounded_r - r)
	var/s_difference = abs(rounded_s - s)

	if(q_difference > r_difference && q_difference > s_difference)
		rounded_q = -rounded_r - rounded_s
	else if(r_difference > s_difference)
		rounded_r = -rounded_q - rounded_s

	return list(rounded_q, rounded_r)

/proc/redspace_hex_key(z_level, q, r)
	return "[z_level]:[q]:[r]"

/// Returns the representative map tile of a hex: the tile containing its center.
/// Zone-level rules such as area-based susceptibility coefficients use this point
/// so the controller never has to scan every tile inside the hex.
/proc/redspace_hex_representative_turf(z_level, q, r) as /turf
	if(!z_level || !isnum(q) || !isnum(r))
		return

	var/center_x = REDSPACE_HEX_RADIUS * (REDSPACE_HEX_SQRT3 * q + REDSPACE_HEX_SQRT3 / 2 * r)
	var/center_y = REDSPACE_HEX_RADIUS * 1.5 * r
	return locate(floor(center_x) + 1, floor(center_y) + 1, z_level)

/datum/redspace_field_cell
	/// Z-level containing this field cell.
	var/z_level
	/// Axial q coordinate.
	var/q
	/// Axial r coordinate.
	var/r
	/// Stable key used by the subsystem's sparse cell table.
	var/key

	/// Local contribution relative to the subsystem background value.
	var/local_delta = 0
	/// Cached current value for this cell.
	var/value = REDSPACE_DEFAULT_VALUE
	/// Value before the last change.
	var/previous_value = REDSPACE_DEFAULT_VALUE
	/// Current gameplay range.
	var/state = REDSPACE_STATE_CALM
	/// Range before the last change.
	var/previous_state = REDSPACE_STATE_CALM
	/// Last world.time when the cached value changed.
	var/last_updated = 0
	/// Explicit value set by an event or an administrative test. Null means the cell is source-driven.
	var/forced_value
	/// Whether the explicit value is allowed to represent an invasion state.
	var/forced_value_allows_invasion = FALSE
	/// Representative tile used to refresh this sparse cell from field sources.
	var/sample_x
	var/sample_y

/datum/redspace_field_cell/New(new_z, new_q, new_r, new_key, initial_value = REDSPACE_DEFAULT_VALUE, turf/sample_turf = null)
	. = ..()
	z_level = new_z
	q = new_q
	r = new_r
	key = new_key
	value = initial_value
	previous_value = initial_value
	state = redspace_state_from_value(initial_value)
	previous_state = state
	if(sample_turf)
		sample_x = sample_turf.x
		sample_y = sample_turf.y

/// Applies a local delta and refreshes the cached value.
/datum/redspace_field_cell/proc/set_delta(new_delta, background_value, update_time = world.time)
	local_delta = new_delta
	return set_value(background_value + local_delta, update_time)

/// Updates the cached value and range. Returns TRUE when anything changed.
/datum/redspace_field_cell/proc/set_value(new_value, update_time = world.time)
	if(value == new_value)
		return FALSE

	previous_value = value
	previous_state = state
	value = new_value
	state = redspace_state_from_value(new_value)
	last_updated = update_time
	return TRUE

/// Sets an explicit value, optionally allowing the event-only invasion range.
/datum/redspace_field_cell/proc/set_forced_value(new_value, allow_invasion = FALSE, update_time = world.time)
	forced_value = new_value
	forced_value_allows_invasion = allow_invasion
	return set_value(new_value, update_time)

/// Removes an explicit value and returns whether one was present.
/datum/redspace_field_cell/proc/clear_forced_value()
	var/was_forced = !isnull(forced_value)
	forced_value = null
	forced_value_allows_invasion = FALSE
	return was_forced

/// Returns the representative tile used for source refreshes, if it is still on the map.
/datum/redspace_field_cell/proc/get_sample_turf() as /turf
	if(!sample_x || !sample_y || !z_level)
		return
	return locate(sample_x, sample_y, z_level)
