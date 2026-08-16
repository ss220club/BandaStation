/// Server-side history owned by one redspace scientific console.
/datum/redspace_sensor_record
	var/sensor_id
	var/display_name = "датчик возмущения редспейса"
	var/obj/machinery/redspace_sensor/sensor
	var/last_value
	var/last_sample_time
	var/last_sample_state
	var/last_sample_reason
	var/last_available = FALSE
	var/last_x
	var/last_y
	var/last_z
	var/list/history = list()

/datum/redspace_sensor_record/New(new_sensor_id)
	. = ..()
	sensor_id = new_sensor_id

/datum/redspace_sensor_record/proc/bind_sensor(obj/machinery/redspace_sensor/new_sensor)
	sensor = new_sensor
	if(!new_sensor)
		return
	sensor_id = new_sensor.sensor_id
	display_name = new_sensor.declent_ru(NOMINATIVE)

/datum/redspace_sensor_record/proc/unbind_sensor()
	sensor = null

/datum/redspace_sensor_record/proc/record_sample(new_value, sample_time = world.time, reason = null)
	var/sample_available = !isnull(new_value)
	if(last_sample_time == sample_time && last_available == sample_available && (!sample_available || last_value == new_value))
		return FALSE

	last_value = new_value
	last_sample_time = sample_time
	last_sample_state = sample_available ? redspace_state_from_value(new_value) : null
	last_sample_reason = reason
	last_available = sample_available

	var/turf/sample_turf = get_turf(sensor)
	if(sample_turf)
		last_x = sample_turf.x
		last_y = sample_turf.y
		last_z = sample_turf.z

	var/list/sample = list(
		"time" = sample_time,
		"available" = sample_available,
		"state" = last_sample_state,
	)
	if(sample_available)
		sample["value"] = new_value
	if(sample_turf)
		sample += list(
			"x" = sample_turf.x,
			"y" = sample_turf.y,
			"z" = sample_turf.z,
		)
	history += list(sample)
	while(length(history) > REDSPACE_SENSOR_HISTORY_LIMIT)
		history.Cut(1, 2)
	return TRUE

/datum/redspace_sensor_record/proc/get_status()
	if(!sensor || QDELETED(sensor))
		return "disconnected"
	if(!last_available || isnull(last_sample_time))
		return "unknown"
	if(world.time - last_sample_time > REDSPACE_SENSOR_STALE_AFTER)
		return "stale"
	return "fresh"

/datum/redspace_sensor_record/proc/serialize_ui_data()
	var/status = get_status()
	var/list/data = list(
		"id" = sensor_id,
		"name" = display_name,
		"connected" = status != "disconnected",
		"available" = last_available,
		"status" = status,
		"state" = last_available ? redspace_state_name(last_sample_state) : "неизвестно",
		"state_code" = last_sample_state || 0,
		"last_sample_age_seconds" = isnull(last_sample_time) ? -1 : max(0, (world.time - last_sample_time) / (1 SECONDS)),
		"last_sample_reason" = last_sample_reason || "нет данных",
		"history" = list(),
	)
	if(last_available)
		data["value"] = last_value
	if(last_x && last_y && last_z)
		data["position"] = list(
			"x" = last_x,
			"y" = last_y,
			"z" = last_z,
		)

	var/list/history_data = list()
	for(var/list/sample as anything in history)
		var/sample_time = sample["time"]
		var/sample_available = sample["available"]
		var/list/sample_data = list(
			"available" = sample_available,
			"state" = sample_available ? redspace_state_name(sample["state"]) : "неизвестно",
			"age_seconds" = isnum(sample_time) ? max(0, (world.time - sample_time) / (1 SECONDS)) : -1,
		)
		if(sample_available)
			sample_data["value"] = sample["value"]
		if(sample["x"] && sample["y"] && sample["z"])
			sample_data["position"] = list(
				"x" = sample["x"],
				"y" = sample["y"],
				"z" = sample["z"],
			)
		history_data += list(sample_data)
	data["history"] = history_data
	return data

/// Console that collects precise readings from explicitly linked sensors.
/obj/machinery/computer/redspace_console
	name = "redspace disturbance console"
	desc = "A scientific console that collects local measurements from linked redspace sensors."
	icon_state = MAP_SWITCH("computer", "/obj/machinery/computer/atmos_control")
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	light_color = LIGHT_COLOR_CYAN
	use_power = ACTIVE_POWER_USE

	/// Currently linked live sensor objects.
	var/list/obj/machinery/redspace_sensor/sensors = list()
	/// Sensor records are retained after unlinking so the console can show history and loss of connection.
	var/list/sensor_records = list()

/obj/machinery/computer/redspace_console/Destroy(force)
	for(var/obj/machinery/redspace_sensor/sensor as anything in sensors.Copy())
		if(!sensor)
			continue
		UnregisterSignal(sensor, COMSIG_QDELETING, PROC_REF(on_sensor_deleted))
		if(sensor.connected_console == src)
			sensor.connected_console = null
	sensors.Cut()
	for(var/record_id in sensor_records)
		var/datum/redspace_sensor_record/record = sensor_records[record_id]
		if(record)
			qdel(record)
	sensor_records.Cut()
	return ..()

/obj/machinery/computer/redspace_console/examine(mob/user)
	. = ..()
	. += span_notice("Используйте мультитул на консоли и датчике, чтобы связать их.")
	. += span_notice("Датчики можно отвязать через интерфейс или вторичным нажатием мультитула.")

/obj/machinery/computer/redspace_console/multitool_act(mob/living/user, obj/item/multitool/tool)
	var/obj/machinery/redspace_sensor/sensor = tool.buffer
	if(istype(sensor))
		if(link_sensor(sensor, user))
			tool.set_buffer(null)
			to_chat(user, span_notice("[sensor] подключён к [src]."))
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	tool.set_buffer(src)
	to_chat(user, span_notice("[src] сохранён в buffer мультитула."))
	return ITEM_INTERACT_SUCCESS

/// Links a sensor to this console, transferring it from another console if necessary.
/obj/machinery/computer/redspace_console/proc/link_sensor(obj/machinery/redspace_sensor/sensor, mob/user)
	if(!istype(sensor) || QDELETED(sensor))
		return FALSE
	if(sensor.connected_console && sensor.connected_console != src)
		if(!QDELETED(sensor.connected_console))
			sensor.connected_console.unlink_sensor(sensor, user)
		else
			sensor.connected_console = null

	if(!(sensor in sensors))
		sensors += sensor
		RegisterSignal(sensor, COMSIG_QDELETING, PROC_REF(on_sensor_deleted))

	var/datum/redspace_sensor_record/record = sensor_records[sensor.sensor_id]
	if(!record)
		record = new(sensor.sensor_id)
		sensor_records[sensor.sensor_id] = record
	record.bind_sensor(sensor)
	sensor.connected_console = src
	sensor.take_sample("датчик подключён к консоли")
	SStgui.update_uis(src)
	return TRUE

/// Removes a live sensor while retaining its last samples as a disconnected record.
/obj/machinery/computer/redspace_console/proc/unlink_sensor(obj/machinery/redspace_sensor/sensor, mob/user, notify = TRUE)
	if(!sensor)
		return FALSE
	var/datum/redspace_sensor_record/record = sensor_records[sensor.sensor_id]
	var/was_linked = (sensor in sensors) || (record && record.sensor == sensor)
	if(!was_linked)
		return FALSE

	sensors -= sensor
	UnregisterSignal(sensor, COMSIG_QDELETING, PROC_REF(on_sensor_deleted))
	if(record)
		record.unbind_sensor()
	if(sensor.connected_console == src)
		sensor.connected_console = null
	if(notify)
		SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/redspace_console/proc/on_sensor_deleted(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/redspace_sensor/sensor = source
	if(!sensor)
		return
	var/datum/redspace_sensor_record/record = sensor_records[sensor.sensor_id]
	if(record)
		record.unbind_sensor()
	sensors -= sensor
	UnregisterSignal(sensor, COMSIG_QDELETING, PROC_REF(on_sensor_deleted))
	if(sensor.connected_console == src)
		sensor.connected_console = null
	SStgui.update_uis(src)

/// Receives a sample from a sensor and stores it in the console-owned ring buffer.
/obj/machinery/computer/redspace_console/proc/record_sensor_sample(obj/machinery/redspace_sensor/sensor, new_value, sample_time = world.time, reason = null)
	if(!sensor || QDELETED(sensor) || !(sensor in sensors))
		return FALSE
	var/datum/redspace_sensor_record/record = sensor_records[sensor.sensor_id]
	if(!record)
		record = new(sensor.sensor_id)
		sensor_records[sensor.sensor_id] = record
	record.bind_sensor(sensor)
	if(record.record_sample(new_value, sample_time, reason))
		SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/redspace_console/proc/forget_sensor_record(sensor_id)
	var/datum/redspace_sensor_record/record = sensor_records[sensor_id]
	if(!record || record.sensor)
		return FALSE
	sensor_records -= sensor_id
	qdel(record)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/redspace_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RedspaceConsole", name)
		ui.open()

/obj/machinery/computer/redspace_console/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps),
	)

/obj/machinery/computer/redspace_console/ui_static_data(mob/user)
	var/list/data = list()
	data["mapData"] = SSmapping.get_map_ui_data()
	data["sample_interval_seconds"] = REDSPACE_SENSOR_UPDATE_INTERVAL / (1 SECONDS)
	data["stale_after_seconds"] = REDSPACE_SENSOR_STALE_AFTER / (1 SECONDS)
	return data

/obj/machinery/computer/redspace_console/ui_data(mob/user)
	var/list/data = list(
		"sensor_count" = length(sensors),
		"sensors" = list(),
	)

	var/list/sensor_data = list()
	for(var/record_id in sensor_records)
		var/datum/redspace_sensor_record/record = sensor_records[record_id]
		if(record)
			sensor_data += list(record.serialize_ui_data())
	data["sensors"] = sensor_data
	return data

/obj/machinery/computer/redspace_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/sensor_id = params["sensor_id"]
	if(isnull(sensor_id))
		return TRUE

	switch(action)
		if("unlink_sensor")
			var/datum/redspace_sensor_record/record = sensor_records[sensor_id]
			if(record && record.sensor)
				unlink_sensor(record.sensor, usr)
			return TRUE
		if("forget_sensor")
			forget_sensor_record(sensor_id)
			return TRUE
	return FALSE
