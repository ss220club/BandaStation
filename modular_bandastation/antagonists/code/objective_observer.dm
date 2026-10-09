GLOBAL_DATUM_INIT(objective_observer, /datum/objective_observer, new)

/// Register new characters from the module, without changing the core mind constructor.
/datum/mind/New(_key)
	. = ..()
	GLOB.objective_observer.watch_mind(src)

/// Listens for cryo departures, replacing dependent role tasks before individual objectives.
/datum/objective_observer
	var/list/watched_minds = list()

/datum/objective_observer/Destroy()
	for(var/datum/mind/mind as anything in watched_minds.Copy())
		stop_watching_mind(mind)
	return ..()

/datum/objective_observer/proc/watch_mind(datum/mind/mind)
	if(QDELETED(mind) || (mind in watched_minds))
		return
	watched_minds += mind
	RegisterSignal(mind, COMSIG_MIND_ENTERED_CRYO, PROC_REF(on_mind_cryo))
	RegisterSignal(mind, COMSIG_QDELETING, PROC_REF(on_mind_deleted))

/datum/objective_observer/proc/stop_watching_mind(datum/mind/mind)
	watched_minds -= mind
	UnregisterSignal(mind, COMSIG_MIND_ENTERED_CRYO)
	UnregisterSignal(mind, COMSIG_QDELETING)

/datum/objective_observer/proc/on_mind_deleted(datum/mind/deleted_mind)
	SIGNAL_HANDLER
	stop_watching_mind(deleted_mind)

/datum/objective_observer/proc/on_mind_cryo(datum/mind/cryo_mind)
	SIGNAL_HANDLER
	var/list/affected_owners = list()
	// Roles with dependent tasks handle the departure once, using their own objective list.
	for(var/datum/mind/mind as anything in watched_minds.Copy())
		if(QDELETED(mind) || mind == cryo_mind)
			continue
		for(var/datum/antagonist/antag as anything in mind.antag_datums?.Copy())
			if(!QDELETED(antag) && antag.replace_unavailable_objectives(cryo_mind))
				affected_owners |= mind

	// Cancellation can remove objectives from the registry during this loop.
	for(var/datum/objective/objective as anything in GLOB.objectives.Copy())
		if(QDELETED(objective) || objective.target != cryo_mind)
			continue
		var/list/owners = objective.get_owners()
		var/replaced = objective.replace_unavailable_target(cryo_mind)
		affected_owners |= owners
		for(var/datum/mind/owner as anything in owners)
			if(QDELETED(owner) || !owner.current || owner == cryo_mind)
				continue
			if(replaced)
				to_chat(owner.current, span_userdanger("Ваша цель ушла в крио. Назначена новая цель!"))

	// Show the final objective list once all replacements and cancellations are complete.
	for(var/datum/mind/owner as anything in affected_owners)
		if(!QDELETED(owner) && owner.current && owner != cryo_mind)
			owner.announce_objectives()
