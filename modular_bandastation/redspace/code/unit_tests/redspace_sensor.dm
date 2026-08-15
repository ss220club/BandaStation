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

#endif
