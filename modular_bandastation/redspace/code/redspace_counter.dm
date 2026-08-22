#define REDSPACE_COUNTER_UPDATE_INTERVAL (2 SECONDS)
#define REDSPACE_COUNTER_MIN_DISPLAY_VALUE -10
#define REDSPACE_COUNTER_MAX_DISPLAY_VALUE 10

/// Converts a local field value into the normalized reading used by a portable counter.
/proc/redspace_counter_display_value(value)
	if(isnull(value))
		return "?"
	if(value < REDSPACE_COUNTER_MIN_DISPLAY_VALUE)
		return "10-"
	if(value > REDSPACE_COUNTER_MAX_DISPLAY_VALUE)
		return "10+"
	return "[round(value)]"

/// Maps normalized readings to the counter.dmi states.
/proc/redspace_counter_icon_state(reading)
	if(reading == "?")
		return "counter_on_unknown"
	if(reading == "10-" || reading == "-10")
		return "counter_on_unknown"
	if(reading == "10+")
		return "counter_on_above_10"

	var/numeric_reading = text2num(reading)
	if(numeric_reading == 0)
		return "counter_on_0"
	if(numeric_reading < 0)
		return "counter_on_minus_[abs(numeric_reading)]"
	return "counter_on_[numeric_reading]"

/// Passive handheld display for the local redspace field.
/obj/item/redspace_counter
	name = "\improper redspace disturbance counter"
	desc = "A passive handheld device that displays the local redspace disturbance. Its reading updates with a delay."
	icon = 'modular_bandastation/redspace/icons/counter.dmi'
	icon_state = "counter_on_unknown"
	base_icon_state = "counter_on_0"
	inhand_icon_state = "counter"
	worn_icon_state = "geiger_counter"
	lefthand_file = 'modular_bandastation/redspace/icons/inhands/l_hand/counter.dmi'
	righthand_file = 'modular_bandastation/redspace/icons/inhands/r_hand/counter.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON

	/// Normalized reading represented by the current icon_state.
	var/displayed_reading = "?"
	/// Earliest world time at which another reading may be taken.
	var/next_update = 0

/obj/item/redspace_counter/Initialize(mapload)
	. = ..()

	// The element refreshes the hand and worn icons when the display changes.
	AddElement(/datum/element/update_icon_updates_onmob)
	next_update = world.time + REDSPACE_COUNTER_UPDATE_INTERVAL
	START_PROCESSING(SSobj, src)

/obj/item/redspace_counter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/redspace_counter/process(seconds_per_tick)
	if(world.time < next_update)
		return

	next_update = world.time + REDSPACE_COUNTER_UPDATE_INTERVAL
	var/turf/sample_turf = get_turf(src)
	var/local_value
	if(SSredspace)
		local_value = SSredspace.get_value(sample_turf)
	update_counter_display(redspace_counter_display_value(local_value))

/obj/item/redspace_counter/proc/update_counter_display(new_reading)
	if(displayed_reading == new_reading)
		return

	displayed_reading = new_reading
	update_appearance(UPDATE_ICON)

/obj/item/redspace_counter/update_icon_state()
	icon_state = redspace_counter_icon_state(displayed_reading) || base_icon_state
	return ..()

/// The counter has no manual interaction; its display is updated automatically.
/obj/item/redspace_counter/interact(mob/user)
	return FALSE

/datum/design/redspace_counter
	name = "Redspace Disturbance Counter"
	desc = "A portable instrument for measuring local redspace disturbance."
#ifdef TECHWEB_NODE_STARTER
	// Design IDs were replaced with design typepaths by the techweb refactor.
#else
	id = "redspace_counter"
#endif
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/redspace_counter
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

#undef REDSPACE_COUNTER_UPDATE_INTERVAL
#undef REDSPACE_COUNTER_MIN_DISPLAY_VALUE
#undef REDSPACE_COUNTER_MAX_DISPLAY_VALUE
