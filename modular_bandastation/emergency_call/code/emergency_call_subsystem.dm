SUBSYSTEM_DEF(emergency_call)
	name = "Emergency call"
	flags = SS_NO_FIRE

	var/emergency_call_dispatched = FALSE
	var/list/datum/emergency_calls


/datum/controller/subsystem/emergency_call/Initialize()
	for(var/datum/emergency_call/emergency_call_type as anything in typesof(/datum/emergency_call))
		var/weight = emergency_call_type.weight
		if(weight <= 0)
			continue

		LAZYSET(emergency_calls, emergency_call_type, weight)

/datum/controller/subsystem/emergency_call/proc/activate(datum/emergency_call/emergency_call, announce_launch, announce_incoming)
	emergency_call = new emergency_call
	if(emergency_call.activate(announce_launch, announce_incoming))
		emergency_call_dispatched = TRUE

/datum/controller/subsystem/emergency_call/proc/activate_random_emergency_call()
	activate(pick_weight(emergency_calls), TRUE, TRUE)

