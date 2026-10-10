GLOBAL_LIST_EMPTY(objectives)

/datum/objective/New()
	. = ..()
	GLOB.objectives += src

/datum/objective/Destroy()
	GLOB.objectives -= src
	return ..()

/// Keep the objective when a new target is found; otherwise detach and delete it.
/// Returns TRUE for a successful replacement, FALSE for a cancelled task.
/// Adds the unavailable mind to the supplied blacklist in place.
/datum/objective/proc/replace_unavailable_target(datum/mind/old_target, list/blacklist)
	if(QDELETED(src) || target != old_target)
		return FALSE
	LAZYOR(blacklist, old_target)
	var/old_explanation = explanation_text
	prepare_target_replacement()
	var/datum/mind/replacement = find_target(blacklist = blacklist)
	// Target pickers can return a mind or only assign the target field.
	if(istype(replacement))
		target = replacement
	if(!target || (target in blacklist))
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
			to_chat(owner.current, span_userdanger("Ваша цель ушла в крио. [reason] Задание отменено: [explanation_text]"))
	if(team)
		team.objectives -= src
	qdel(src)

/datum/objective/escape/escape_with_identity/prepare_target_replacement()
	. = ..()
	target_real_name = null
	target_missing_id = FALSE

/datum/objective/sacrifice/prepare_target_replacement()
	clear_sacrifice()

/// Revolution tasks are tied to the original heads and cannot receive random replacements.
/datum/objective/mutiny/replace_unavailable_target(datum/mind/old_target)
	cancel_unavailable_target("Это задание не предусматривает замену цели.")
	return FALSE

/// active_ais returns bodies, but target blacklists contain minds.
/datum/objective/destroy/find_target(dupe_search_range, list/blacklist)
	var/list/possible_targets = list()
	for(var/mob/living/silicon/ai/candidate as anything in active_ais(TRUE))
		if(!(candidate.mind in blacklist))
			possible_targets += candidate
	target = null
	if(length(possible_targets))
		var/mob/living/silicon/ai/target_ai = pick(possible_targets)
		target = target_ai.mind
	update_explanation_text()
	return target

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
		to_chat(owner, span_userdanger("Ваш объект одержимости ушёл в крио. Нового найти не удалось. Задания отменены, одержимость прекращается."))
		qdel(src)
		return TRUE

	set_obsession(new_obsession, blacklist = list(old_target))
	to_chat(owner, span_userdanger("Ваш объект одержимости ушёл в крио. Теперь вы одержимы [obsession.declent_ru(INSTRUMENTAL)]. Все задания одержимости обновлены!"))
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
	if(identity.replace_unavailable_target(old_target))
		paired_maroon.target = identity.target
		paired_maroon.update_explanation_text()
		to_chat(owner.current, span_userdanger("Ваша цель ушла в крио. Задания на запрет эвакуации и побег под чужой личностью получили общую новую цель!"))
	else
		paired_maroon.cancel_unavailable_target("Новую цель для связанных заданий назначить не удалось.")
	return TRUE
