GLOBAL_LIST_EMPTY(objectives)
GLOBAL_DATUM_INIT(objective_replacement_handler, /datum/objective_replacement_handler, new)

/// One global subscription handles departures without keeping references to individual minds.
/datum/objective_replacement_handler/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MIND_ENTERED_CRYO, PROC_REF(on_mind_cryo))

/datum/objective_replacement_handler/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MIND_ENTERED_CRYO)
	return ..()

/datum/objective_replacement_handler/proc/on_mind_cryo(datum/source, datum/mind/departing_mind)
	SIGNAL_HANDLER
	replace_unavailable_objectives(departing_mind)

/datum/objective/New()
	. = ..()
	GLOB.objectives += src

/datum/objective/Destroy()
	GLOB.objectives -= src
	return ..()

/// Replace role-dependent tasks first, then individual tasks, before a character leaves the round.
/proc/replace_unavailable_objectives(datum/mind/unavailable_mind)
	if(QDELETED(unavailable_mind))
		return
	var/list/affected_owners = list()
	for(var/datum/antagonist/antag as anything in GLOB.antagonists.Copy())
		if(QDELETED(antag) || QDELETED(antag.owner) || antag.owner == unavailable_mind)
			continue
		var/datum/mind/owner = antag.owner
		if(antag.replace_unavailable_objectives(unavailable_mind))
			affected_owners |= owner

	// Replacements and cancellations can change the registry during this loop.
	for(var/datum/objective/objective as anything in GLOB.objectives.Copy())
		if(QDELETED(objective) || objective.target != unavailable_mind)
			continue
		var/list/owners = objective.get_owners()
		var/replaced = objective.replace_unavailable_target(unavailable_mind, blacklist = list(unavailable_mind))
		if(!replaced && !QDELETED(objective))
			continue
		affected_owners |= owners
		for(var/datum/mind/owner as anything in owners)
			if(QDELETED(owner) || !owner.current || owner == unavailable_mind)
				continue
			if(replaced)
				to_chat(owner.current, span_userdanger("Ваша цель покинула раунд. Назначена новая цель!"))

	// Announce once, after all dependent and individual tasks have been updated.
	for(var/datum/mind/owner as anything in affected_owners)
		if(!QDELETED(owner) && owner.current && owner != unavailable_mind)
			owner.announce_objectives()

/// Keep the objective when a new target is found; otherwise detach and delete it.
/// Returns TRUE for a successful replacement, FALSE otherwise.
/// Callers exclude the departing mind from target selection through the blacklist.
/datum/objective/proc/replace_unavailable_target(datum/mind/old_target, list/blacklist)
	if(QDELETED(src) || target != old_target)
		return FALSE
	var/old_explanation = explanation_text
	prepare_target_replacement()
	var/datum/mind/replacement = find_target(blacklist = blacklist)
	// Target pickers can return a mind or only assign the target field.
	if(istype(replacement))
		target = replacement
	if(!target || target == old_target)
		explanation_text = old_explanation
		cancel_unavailable_target()
		return FALSE
	update_explanation_text()
	return TRUE

/// Tasks with target-specific subscriptions override this to release them first.
/datum/objective/proc/prepare_target_replacement()
	target = null

/// Remove the task from personal and team lists before scheduling its deletion.
/datum/objective/proc/cancel_unavailable_target(reason = "Новую цель назначить не удалось.")
	for(var/datum/mind/owner as anything in get_owners())
		if(QDELETED(owner))
			continue
		for(var/datum/antagonist/antag as anything in owner.antag_datums)
			antag.objectives -= src
		if(owner.current)
			to_chat(owner.current, span_userdanger("Ваша цель покинула раунд. [reason] Задание отменено: [explanation_text]"))
	if(team)
		team.objectives -= src
	qdel(src)

/datum/objective/escape/escape_with_identity/prepare_target_replacement()
	. = ..()
	target_real_name = null
	target_missing_id = FALSE

/// Cult replaces its victim through the existing body-deletion subscription.
/datum/objective/sacrifice/replace_unavailable_target(datum/mind/old_target, list/blacklist)
	return FALSE

/// Revolution tasks are tied to the original heads and cannot receive random replacements.
/datum/objective/mutiny/replace_unavailable_target(datum/mind/old_target)
	if(!team)
		return FALSE
	cancel_unavailable_target("Это задание не предусматривает замену цели.")
	return FALSE

/// Returns TRUE when the role has handled its dependent tasks before individual replacements.
/datum/antagonist/proc/replace_unavailable_objectives(datum/mind/old_target)
	return FALSE

/// The trauma and all its tasks must refer to the same new obsession.
/datum/antagonist/obsessed/replace_unavailable_objectives(datum/mind/old_target)
	if(QDELETED(trauma))
		return FALSE
	return trauma.replace_unavailable_obsession(old_target)

/datum/brain_trauma/special/obsessed/proc/replace_unavailable_obsession(datum/mind/old_target)
	if(obsession?.mind != old_target || QDELETED(antagonist))
		return FALSE
	var/mob/living/new_obsession = find_obsession(blacklist = list(old_target))
	if(!new_obsession)
		QDEL_LIST(antagonist.objectives)
		to_chat(owner, span_userdanger("Ваш объект одержимости покинул раунд. Нового найти не удалось. Задания отменены, одержимость прекращается."))
		qdel(src)
		return TRUE

	set_obsession(new_obsession, blacklist = list(old_target))
	to_chat(owner, span_userdanger("Ваш объект одержимости покинул раунд. Теперь вы одержимы [obsession.declent_ru(INSTRUMENTAL)]. Все задания одержимости обновлены!"))
	log_game("[key_name(owner)] has changed their obsession from [key_name(old_target)] to [key_name(obsession)] after a cryo departure.")
	return TRUE

/// A paired maroon task must follow the identity selected for the escape task.
/datum/antagonist/changeling/replace_unavailable_objectives(datum/mind/old_target)
	// Normal generation creates at most one identity task and one maroon task.
	var/datum/objective/escape/escape_with_identity/identity = locate() in objectives
	var/datum/objective/maroon/paired_maroon = locate() in objectives
	if(QDELETED(identity) || QDELETED(paired_maroon))
		return FALSE
	if(identity.target != old_target || paired_maroon.target != old_target)
		return FALSE

	// The identity picker also checks whether the replacement's DNA can be copied.
	if(identity.replace_unavailable_target(old_target, blacklist = list(old_target)))
		paired_maroon.target = identity.target
		paired_maroon.update_explanation_text()
		to_chat(owner.current, span_userdanger("Ваша цель покинула раунд. Задания на запрет эвакуации и побег под чужой личностью получили общую новую цель!"))
	else
		paired_maroon.cancel_unavailable_target("Новую цель для связанных заданий назначить не удалось.")
	return TRUE
