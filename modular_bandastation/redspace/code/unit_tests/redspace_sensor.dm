#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/redspace_sensor_record

/datum/unit_test/redspace_sensor_record/Run()
	var/datum/redspace_sensor_record/record = new("unit_test_sensor")
	record.record_sample(3.25, 10, "first sample")
	if(record.last_value != 3.25 || !record.last_available)
		return Fail("Sensor records must preserve the exact sample value")
	if(length(record.history) != 1)
		return Fail("The first sensor sample must be retained")

	record.record_sample(4.75, 20, "second sample")
	if(record.last_sample_state != REDSPACE_STATE_DISTURBANCE)
		return Fail("Sensor records must derive the range from the exact sample")

	for(var/i in 1 to REDSPACE_SENSOR_HISTORY_LIMIT + 3)
		record.record_sample(i, 20 + i, "history sample")
	if(length(record.history) != REDSPACE_SENSOR_HISTORY_LIMIT)
		return Fail("Sensor history must remain a bounded ring buffer")

	record.unbind_sensor()
	if(record.get_status() != "disconnected")
		return Fail("An unbound sensor record must report a disconnected status")
	qdel(record)

/datum/unit_test/redspace_sensor_linking

/datum/unit_test/redspace_sensor_linking/Run()
	var/mob/living/carbon/human/consistent/user = allocate(__IMPLIED_TYPE__)
	var/obj/item/redspace_sensor/sensor = allocate(__IMPLIED_TYPE__)
	var/obj/machinery/computer/redspace_console/console = allocate(__IMPLIED_TYPE__)
	var/obj/item/multitool/tool = allocate(__IMPLIED_TYPE__)
	var/list/examine_tags = list()

	SEND_SIGNAL(sensor, COMSIG_ATOM_EXAMINE_TAGS, user, examine_tags)
	if(!examine_tags["напольный"])
		return Fail("Redspace sensors must expose the floor-placeable examine tag")

	console.multitool_act(user, tool)
	if(tool.buffer != console)
		return Fail("Using a multitool on the console must store the console in its buffer")

	sensor.multitool_act(user, tool)
	if(sensor.connected_console != console || !(sensor in console.sensors))
		return Fail("A sensor must link to the console stored in the multitool buffer")
	if(tool.buffer != console)
		return Fail("Linking a sensor must preserve the console in the multitool buffer")

	sensor.forceMove(user)
	if(sensor.connected_console || (sensor in console.sensors))
		return Fail("Picking up a sensor must disconnect it from the console")
	var/datum/redspace_sensor_record/record = console.sensor_records[sensor.sensor_id]
	if(!record || record.get_status() != "disconnected")
		return Fail("A picked-up sensor must retain a disconnected console record")

#endif
