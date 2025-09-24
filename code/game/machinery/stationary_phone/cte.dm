GLOBAL_VAR_INIT(central_telephone_exchange, null)

#define STATUS_DIALING							"Dialing"
#define STATUS_RINGING							"Ringing"
#define TIMEOUT_DURATION            30 SECONDS

#define COMMSIG_OFFHOOK             "Communication Signal - Offhook"           // The telephone is removed from the hook
#define COMMSIG_DIALTONE            "Communication Signal - Dialtone"          // The phone should play the dialtone sound, indicating it's ready for dialing
#define COMMSIG_DIAL                "Communication Signal - Dial"	             // The phone sends a request to the CTE, attempting to call a `phone_id`
#define COMMSIG_RINGING             "Communication Signal - Ringing"           // The phone rings, being ready to pick up
#define COMMSIG_RINGBACK            "Communication Signal - Ringback"	         // The caller hears the ringback sounds, waiting for the other side to pick up
#define COMMSIG_BUSY                "Communication Signal - Busy"	             // The target phone is busy
#define COMMSIG_NUMBER_NOT_FOUND    "Communication Signal - Number Not Found"	 // The CTE couldn't find the device with such `phone_id`
#define COMMSIG_ANSWER              "Communication Signal - Answer"	           // The phone should initialize the call
#define COMMSIG_TALK                "Communication Signal - Talk"	             // The signal sent with the voice message itself
#define COMMSIG_HANGUP              "Communication Signal - Hangup"	           // The other side has hanged up
#define COMMSIG_TIMEOUT             "Communication Signal - Timeout"	         // The line has been inactive for over 30 seconds

/obj/structure/central_telephone_exchange
	name = "Central Telephone Exchange unit"
	desc = "A central switching unit responsible for connecting telephone calls within the station sectors."

/obj/structure/central_telephone_exchange/Initialize(mapload)
	. = ..()
	if(GLOB.central_telephone_exchange)
		return INITIALIZE_HINT_QDEL // there should only exist one of those

	GLOB.central_telephone_exchange = src
	to_chat(world, "DEBUG: New master CTE initialized at [get_area_name(src, TRUE)]")

/obj/structure/central_telephone_exchange/proc/find_device(device_id)
	for(var/obj/structure/transmitter/each_transmitter in GLOB.transmitters)
		if(each_transmitter.phone_id == device_id)
			return each_transmitter
	return null

/obj/structure/central_telephone_exchange/proc/process_commsig(device_id, commsig, data)
	// to_chat(world, "DEBUG: the master CTE received [commsig] from [device_id] with data ([data])")
	var/obj/structure/transmitter/device = find_device(device_id)
	if(!device)
		CRASH("A transmitter insists it's ID is [device_id], but was not found in the list for the given ID.")

	switch(commsig)
		if(COMMSIG_OFFHOOK)
			device.process_commsig(COMMSIG_DIALTONE)

		if(COMMSIG_DIAL)
			var/obj/structure/transmitter/target = find_device(data)
			if(!target)
				device.process_commsig(COMMSIG_NUMBER_NOT_FOUND)
				return

			if(is_device_busy(device) || is_device_busy(target))
				device.process_commsig(COMMSIG_BUSY)
				return

			device.process_commsig(COMMSIG_RINGBACK)
			target.process_commsig(COMMSIG_RINGING, device_id)

			addtimer(CALLBACK(src, PROC_REF(timeout_call), device_id, data), TIMEOUT_DURATION)

		if(COMMSIG_ANSWER)
			var/obj/structure/transmitter/new_caller = find_device(data)
			if(new_caller)
				device.process_commsig(COMMSIG_ANSWER, new_caller.phone_id)
				new_caller.process_commsig(COMMSIG_ANSWER, device_id)

		if(COMMSIG_HANGUP)
			var/obj/structure/transmitter/new_caller = find_device(data)
			if(new_caller)
				new_caller.process_commsig(COMMSIG_HANGUP)
			device.process_commsig(COMMSIG_HANGUP)

		if(COMMSIG_TALK)
			var/target_id = data["target_id"]
			var/message = data["message"]
			var/obj/structure/transmitter/target = find_device(target_id)
			if(target && are_devices_connected(device, target))
				target.process_commsig(COMMSIG_TALK, message)

/obj/structure/central_telephone_exchange/proc/is_device_busy(obj/structure/transmitter/device)
	return (device.status == STATUS_RINGING || device.status == STATUS_DIALING)

/obj/structure/central_telephone_exchange/proc/get_connected_device(obj/structure/transmitter/device)
	if(device.current_call)
		return device.current_call
	return null

/obj/structure/central_telephone_exchange/proc/are_devices_connected(obj/structure/transmitter/device1, obj/structure/transmitter/device2)
	return (device1.current_call == device2 && device2.current_call == device1)

/obj/structure/central_telephone_exchange/proc/timeout_call(caller_id, target_id)
	var/obj/structure/transmitter/new_caller = find_device(caller_id)
	var/obj/structure/transmitter/target = find_device(target_id)

	if(new_caller && target)
		if(new_caller.status == STATUS_DIALING && target.status == STATUS_RINGING)
			new_caller.process_commsig(COMMSIG_TIMEOUT)
			target.process_commsig(COMMSIG_TIMEOUT)

#undef COMMSIG_OFFHOOK
#undef COMMSIG_DIALTONE
#undef COMMSIG_DIAL
#undef COMMSIG_RINGING
#undef COMMSIG_RINGBACK
#undef COMMSIG_BUSY
#undef COMMSIG_NUMBER_NOT_FOUND
#undef COMMSIG_ANSWER
#undef COMMSIG_TALK
#undef COMMSIG_HANGUP
#undef COMMSIG_TIMEOUT

#undef STATUS_DIALING
#undef STATUS_RINGING
#undef TIMEOUT_DURATION
