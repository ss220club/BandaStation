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

	var/rounded_q = round(q)
	var/rounded_r = round(r)
	var/rounded_s = round(s)
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

/datum/redspace_field_cell/New(new_z, new_q, new_r, new_key, initial_value = REDSPACE_DEFAULT_VALUE)
	. = ..()
	z_level = new_z
	q = new_q
	r = new_r
	key = new_key
	value = initial_value
	previous_value = initial_value
	state = redspace_state_from_value(initial_value)
	previous_state = state

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
