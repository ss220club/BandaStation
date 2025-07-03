#define STATUS_IDLE                 "Idle"
#define STATUS_DIALING              "Dialing"
#define STATUS_ENDED                "Ended"
#define TIMEOUT_DURATION            30 SECONDS

#define COMMSIG_OFFHOOK             "CS_OF"
#define COMMSIG_DIALTONE            "CS_DT"
#define COMMSIG_DIAL                "CS_DL"
#define COMMSIG_RINGING             "CS_RG"
#define COMMSIG_RINGBACK            "CS_RB"
#define COMMSIG_BUSY                "CS_BS"
#define COMMSIG_NUMBER_NOT_FOUND    "CS_NF"
#define COMMSIG_ANSWER              "CS_AN"
#define COMMSIG_TALK                "CS_TK"
#define COMMSIG_HANGUP              "CS_HU"
#define COMMSIG_TIMEOUT             "CS_TO"

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

/obj/structure/central_telephone_exchange/proc/process_commsig(device_id, commsig, data)
	var/obj/structure/transmitter/device = GLOB.transmitters[device_id]

	switch(commsig)
		if(COMMSIG_OFFHOOK)
			device.process_commsig(COMMSIG_DIALTONE)

		if(COMMSIG_DIAL)
			var/obj/structure/transmitter/target = GLOB.transmitters[data]
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
			var/obj/structure/transmitter/target = GLOB.transmitters[data]
			if(target)
				target.process_commsig(COMMSIG_BUSY)

		if(COMMSIG_ANSWER)
			var/obj/structure/transmitter/caller = GLOB.transmitters[data]
			var/datum/exchange_session/session = find_session_by_source(caller)
			if(session && session.target == device)
				device.process_commsig(COMMSIG_TALK, caller.phone_id)
				caller.process_commsig(COMMSIG_TALK, device.phone_id)

		if(COMMSIG_HANGUP)
			var/datum/exchange_session/session = find_session_by_source(device)
			if(!session)
				session = find_session_by_target(device)
			if(session)
				var/obj/structure/transmitter/other = (session.source == device) ? session.target : session.source
				device.process_commsig(COMMSIG_HANGUP)
				if(other)
					other.process_commsig(COMMSIG_HANGUP)
				active_sessions -= session // Удаляем сессию

		if(COMMSIG_NUMBER_NOT_FOUND)
			device.process_commsig(COMMSIG_NUMBER_NOT_FOUND)

		if(COMMSIG_RINGBACK)
			device.process_commsig(COMMSIG_RINGBACK)

		if(COMMSIG_RINGING)
			device.process_commsig(COMMSIG_RINGING, data)

		if(COMMSIG_TALK)
			var/obj/structure/transmitter/target = GLOB.transmitters[data]
			if(target)
				device.process_commsig(COMMSIG_TALK, data)
				target.process_commsig(COMMSIG_TALK, device_id)

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
