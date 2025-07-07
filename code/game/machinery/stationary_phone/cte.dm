GLOBAL_VAR_INIT(central_telephone_exchange, null)

#define STATUS_IDLE                 "Idle"
#define STATUS_DIALING              "Dialing"
#define STATUS_ENDED                "Ended"
#define TIMEOUT_DURATION            30 SECONDS

#define COMMSIG_OFFHOOK             "Communication Signal - Offhook" // The telephone is removed from the hook
#define COMMSIG_DIALTONE            "Communication Signal - Dialtone" // The phone should play the dialtone sound, indicating it's ready for dialing
#define COMMSIG_DIAL                "Communication Signal - Dial"	// The phone sends a request to the CTE, attempting to call a `phone_id`
#define COMMSIG_RINGING             "Communication Signal - Ringing" // The phone rings, being ready to pick up
#define COMMSIG_RINGBACK            "Communication Signal - Ringback"	// The caller hears the ringback sounds, waiting for the other side to pick up
#define COMMSIG_BUSY                "Communication Signal - Busy"	// The target phone is busy
#define COMMSIG_NUMBER_NOT_FOUND    "Communication Signal - Number Not Found"	// The CTE couldn't find the device with such `phone_id`
#define COMMSIG_ANSWER              "Communication Signal - Answer"	// The phone should initialize the call
#define COMMSIG_TALK                "Communication Signal - Talk"	// The signal sent with the voice message itself
#define COMMSIG_HANGUP              "Communication Signal - Hangup"	// The other side has hanged up
#define COMMSIG_TIMEOUT             "Communication Signal - Timeout" // The line has been inactive for over 30 seconds

/datum/exchange_session
	var/obj/structure/transmitter/source
	var/obj/structure/transmitter/target
	var/status
	var/starttime
	var/endtime
	var/list/history = list()

/datum/exchange_session/New(obj/structure/transmitter/source_call, obj/structure/transmitter/target_call)
	. = ..()
	source = source_call
	target = target_call
	status = STATUS_IDLE
	starttime = time2text(world.time)

	addtimer(CALLBACK(src, PROC_REF(timeout)), TIMEOUT_DURATION)

/datum/exchange_session/proc/timeout()
	if(status == STATUS_IDLE)
		source.process_commsig(COMMSIG_TIMEOUT)

/obj/structure/central_telephone_exchange
	name = "Central Telephone Exchange unit"
	desc = "A central switching unit responsible for connecting telephone calls within the station sectors."
	var/list/active_sessions = list()

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
	to_chat(world, "DEBUG: the master CTE received [commsig] from [device_id] with data ([data])")
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

			if(find_session_by_source(device) || find_session_by_target(target))
				device.process_commsig(COMMSIG_BUSY)
				return

			device.process_commsig(COMMSIG_RINGBACK)
			target.process_commsig(COMMSIG_RINGING, device_id)

			init_session(device, target)

		if(COMMSIG_BUSY)
			var/obj/structure/transmitter/target = find_device(data)
			if(target)
				target.process_commsig(COMMSIG_BUSY)

		if(COMMSIG_ANSWER)
			var/obj/structure/transmitter/new_caller = find_device(data)
			var/datum/exchange_session/session = find_session_by_source(new_caller)
			if(session && session.target == device)
				device.process_commsig(COMMSIG_TALK, new_caller.phone_id)
				new_caller.process_commsig(COMMSIG_TALK, device.phone_id)

		if(COMMSIG_HANGUP)
			var/datum/exchange_session/session = find_session_by_source(device)
			if(!session)
				session = find_session_by_target(device)
			if(session)
				var/obj/structure/transmitter/other = (session.source == device) ? session.target : session.source
				device.process_commsig(COMMSIG_HANGUP)
				if(other)
					other.process_commsig(COMMSIG_HANGUP)
				active_sessions -= session

		if(COMMSIG_NUMBER_NOT_FOUND)
			device.process_commsig(COMMSIG_NUMBER_NOT_FOUND)

		if(COMMSIG_RINGBACK)
			device.process_commsig(COMMSIG_RINGBACK)

		if(COMMSIG_RINGING)
			device.process_commsig(COMMSIG_RINGING, data)

		if(COMMSIG_TALK)
			var/target_id = data["target_id"]
			var/message = data["message"]
			var/obj/structure/transmitter/target = find_device(target_id)
			if(target)
				// device.process_commsig(COMMSIG_TALK, data)
				target.process_commsig(COMMSIG_TALK, message)

/obj/structure/central_telephone_exchange/proc/init_session(obj/structure/transmitter/source, obj/structure/transmitter/target)
	var/datum/exchange_session/session = new(source, target)
	active_sessions += session
	return session

/obj/structure/central_telephone_exchange/proc/find_session_by_source(src)
	for(var/datum/exchange_session/session in active_sessions)
		if(session.source == src)
			return session
	return null

/obj/structure/central_telephone_exchange/proc/find_session_by_target(tgt)
	for(var/datum/exchange_session/session in active_sessions)
		if(session.target == tgt)
			return session
	return null

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
