GLOBAL_LIST_EMPTY(antag_operations)

/// Coordinates personal antagonist objectives and their shared lifecycle.
/// Subtypes own selection, equipment and success conditions.
/datum/antag_operation
	/// Antagonist datums mapped to their original minds; body transfers preserve membership.
	var/list/participant_antagonists = list()
	/// Personal objectives mapped to the antagonist whose list contains them.
	var/list/operation_objectives = list()
	/// Signal sources mapped to the signals registered on each source.
	var/list/subscriptions = list()
	var/cancellation_reason

/datum/antag_operation/New()
	. = ..()
	GLOB.antag_operations += src

/datum/antag_operation/Destroy()
	for(var/datum/source as anything in subscriptions)
		UnregisterSignal(source, subscriptions[source])
	subscriptions.Cut()
	var/list/affected_minds = list()
	for(var/datum/objective/objective as anything in operation_objectives)
		var/datum/antagonist/antag = operation_objectives[objective]
		antag.objectives -= objective
		affected_minds |= participant_antagonists[antag]
		qdel(objective)
	operation_objectives.Cut()
	// Cancellation and direct deletion share cleanup and owner notifications.
	for(var/datum/mind/mind as anything in affected_minds)
		if(!QDELETED(mind) && mind.current)
			to_chat(mind.current, span_notice("Совместная операция отменена[cancellation_reason ? ": [cancellation_reason]" : "."]"))
			mind.announce_objectives()
	participant_antagonists.Cut()
	GLOB.antag_operations -= src
	return ..()

/datum/antag_operation/proc/subscribe(datum/source, signal, handler)
	RegisterSignal(source, signal, handler)
	if(!subscriptions[source])
		subscriptions[source] = list()
	var/list/signals = subscriptions[source]
	signals |= signal

/datum/antag_operation/proc/add_participant(datum/antagonist/antag)
	if(QDELETED(antag) || QDELETED(antag.owner) || (antag in participant_antagonists))
		return FALSE
	for(var/datum/antagonist/participant as anything in participant_antagonists)
		if(participant_antagonists[participant] == antag.owner)
			return FALSE
	participant_antagonists[antag] = antag.owner
	subscribe(antag, COMSIG_QDELETING, PROC_REF(on_participant_deleted))
	subscribe(antag, COMSIG_ANTAGONIST_OBJECTIVES_CHANGED, PROC_REF(on_objectives_changed))
	subscribe(antag.owner, COMSIG_QDELETING, PROC_REF(on_participant_deleted))
	subscribe(antag.owner, COMSIG_ANTAGONIST_REMOVED, PROC_REF(on_antagonist_removed))
	subscribe(antag.owner, COMSIG_MIND_ENTERED_CRYO, PROC_REF(on_participant_cryo))
	return TRUE

/datum/antag_operation/proc/add_objective(datum/antagonist/antag, datum/objective/objective)
	if(!(antag in participant_antagonists))
		return FALSE
	objective.owner = participant_antagonists[antag]
	antag.objectives += objective
	operation_objectives[objective] = antag
	subscribe(objective, COMSIG_QDELETING, PROC_REF(on_objective_deleted))
	return TRUE

/datum/antag_operation/proc/activate()
	if(!length(operation_objectives))
		return FALSE
	for(var/datum/antagonist/antag as anything in participant_antagonists)
		var/datum/mind/mind = participant_antagonists[antag]
		mind.announce_objectives()
	return TRUE

/// Cancellation is synchronous and idempotent, including when initiated by a signal.
/datum/antag_operation/proc/cancel(reason)
	if(QDELETED(src))
		return
	cancellation_reason = reason
	qdel(src)

/datum/antag_operation/proc/on_participant_deleted(datum/source)
	SIGNAL_HANDLER
	cancel("участник больше недоступен.")

/datum/antag_operation/proc/on_participant_cryo(datum/source)
	SIGNAL_HANDLER
	cancel("участник ушёл в криогенный стазис.")

/datum/antag_operation/proc/on_antagonist_removed(datum/mind/source, datum/antagonist/antag)
	SIGNAL_HANDLER
	if(antag in participant_antagonists)
		cancel("участник больше не участвует в операции.")

/datum/antag_operation/proc/on_objective_deleted(datum/source)
	SIGNAL_HANDLER
	cancel("одно из связанных заданий удалено.")

/datum/antag_operation/proc/on_objectives_changed(datum/antagonist/source)
	SIGNAL_HANDLER
	for(var/datum/objective/objective as anything in operation_objectives)
		if(operation_objectives[objective] == source && !(objective in source.objectives))
			cancel("участник отказался от связанного задания.")
			return
