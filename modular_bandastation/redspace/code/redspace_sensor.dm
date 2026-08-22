/// Precise stationary observer of the redspace field.
/obj/machinery/redspace_sensor
	name = "redspace disturbance sensor"
	desc = "A stationary instrument that sends precise local redspace measurements to a linked console."
	circuit = /obj/item/circuitboard/machine/redspace_sensor
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "gsensor1"
	density = FALSE
	use_power = NO_POWER_USE
	processing_flags = START_PROCESSING_ON_INIT
	resistance_flags = FIRE_PROOF

	/// Stable identifier shown by the scientific console.
	var/sensor_id
	/// Console currently receiving this sensor's measurements.
	var/obj/machinery/computer/redspace_console/connected_console
	/// Whether the sensor has a registered SSredspace field listener.
	var/field_listener_registered = FALSE
	/// Turf used for the current field listener registration.
	var/turf/registered_turf
	/// Most recent exact sample. Null means that no supported sample was available.
	var/last_sample_value
	/// World time of the most recent sample, including unavailable samples.
	var/last_sample_time
	/// Gameplay range derived from the most recent exact sample.
	var/last_sample_state
	/// Reason attached to the most recent sample.
	var/last_sample_reason
	/// Earliest world time at which the next periodic sample may be taken.
	var/next_sample_at = 0

/obj/machinery/redspace_sensor/Initialize(mapload)
	sensor_id = assign_random_name(prefix = "redspace_sensor_")
	id_tag = sensor_id
	return ..()

/obj/machinery/redspace_sensor/post_machine_initialize()
	. = ..()
	RegisterSignal(src, COMSIG_REDSPACE_FIELD_CHANGED, PROC_REF(on_redspace_field_changed))
	next_sample_at = world.time
	take_sample("датчик инициализирован")

/obj/machinery/redspace_sensor/Destroy(force)
	if(connected_console)
		var/obj/machinery/computer/redspace_console/old_console = connected_console
		connected_console = null
		if(!QDELETED(old_console))
			old_console.unlink_sensor(src, null, FALSE)
	if(SSredspace)
		SSredspace.unregister_field_listener(src)
	UnregisterSignal(src, COMSIG_REDSPACE_FIELD_CHANGED, PROC_REF(on_redspace_field_changed))
	return ..()

/obj/machinery/redspace_sensor/process(seconds_per_tick)
	if(world.time < next_sample_at)
		return
	next_sample_at = world.time + REDSPACE_SENSOR_UPDATE_INTERVAL
	take_sample("плановая выборка")

/obj/machinery/redspace_sensor/examine(mob/user)
	. = ..()
	. += span_notice("Используйте мультитул на консоли и датчике, чтобы связать их.")
	. += span_notice("Используйте мультитул вторично, чтобы разорвать текущую привязку.")

/// Ensures that this sensor listens to the canonical turf where it currently stands.
/obj/machinery/redspace_sensor/proc/ensure_field_listener()
	if(!SSredspace || !SSredspace.initialized)
		return FALSE

	var/turf/current_turf = get_turf(src)
	if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
		if(field_listener_registered || !isnull(SSredspace.field_listeners[src]))
			SSredspace.unregister_field_listener(src)
		field_listener_registered = FALSE
		registered_turf = null
		return FALSE

	var/list/hex_coordinates = redspace_hex_coordinates(current_turf)
	var/expected_cell_key
	if(hex_coordinates)
		expected_cell_key = redspace_hex_key(current_turf.z, hex_coordinates[1], hex_coordinates[2])

	if(field_listener_registered && registered_turf == current_turf && SSredspace.field_listeners[src] == expected_cell_key)
		return TRUE

	if(field_listener_registered || !isnull(SSredspace.field_listeners[src]))
		SSredspace.unregister_field_listener(src)

	registered_turf = current_turf
	field_listener_registered = SSredspace.register_field_listener(src, current_turf)
	return field_listener_registered

/// Records an exact value and forwards it to the linked console.
/obj/machinery/redspace_sensor/proc/receive_sample(new_value, sample_time = world.time, reason = null)
	last_sample_value = new_value
	last_sample_time = sample_time
	last_sample_state = isnull(new_value) ? null : redspace_state_from_value(new_value)
	last_sample_reason = reason
	if(connected_console)
		connected_console.record_sensor_sample(src, new_value, sample_time, reason)

/// Takes the canonical point sample for this sensor's current turf.
/obj/machinery/redspace_sensor/proc/take_sample(reason = null)
	ensure_field_listener()
	var/turf/sample_turf = get_turf(src)
	var/new_value
	if(SSredspace && SSredspace.initialized && sample_turf)
		new_value = SSredspace.get_value(sample_turf)
	receive_sample(new_value, world.time, reason || "выборка датчика")

/obj/machinery/redspace_sensor/proc/on_redspace_field_changed(datum/source, datum/redspace_field_cell/cell, old_value, new_value, old_state, new_state, reason)
	SIGNAL_HANDLER
	if(source != src)
		return
	receive_sample(new_value, world.time, reason || "изменение поля")

/obj/machinery/redspace_sensor/multitool_act(mob/living/user, obj/item/multitool/tool)
	var/obj/machinery/computer/redspace_console/console = tool.buffer
	if(istype(console))
		if(console.link_sensor(src, user))
			tool.set_buffer(null)
			to_chat(user, span_notice("[src] подключён к [console]."))
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	tool.set_buffer(src)
	to_chat(user, span_notice("[src] сохранён в buffer мультитула."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/redspace_sensor/multitool_act_secondary(mob/living/user, obj/item/multitool/tool)
	if(!connected_console)
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/computer/redspace_console/console = connected_console
	if(console.unlink_sensor(src, user))
		to_chat(user, span_notice("Привязка [src] к консоли разорвана."))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/redspace_sensor/wrench_act(mob/living/user, obj/item/tool)
	return default_unfasten_wrench(user, tool)

/obj/machinery/redspace_sensor/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, tool)

/obj/machinery/redspace_sensor/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(user, tool)

/obj/item/circuitboard/machine/redspace_sensor
	name = "redspace disturbance sensor"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/redspace_sensor
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/capacitor = 1,
		/obj/item/stack/cable_coil = 2,
	)

/datum/design/board/redspace_sensor
	name = "Redspace Disturbance Sensor Board"
	desc = "The circuit board for a redspace disturbance sensor."
#ifdef TECHWEB_NODE_STARTER
	// Design IDs were replaced with design typepaths by the techweb refactor.
#else
	id = "redspace_sensor"
#endif
	build_path = /obj/item/circuitboard/machine/redspace_sensor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE
