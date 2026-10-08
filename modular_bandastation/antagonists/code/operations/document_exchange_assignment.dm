/// Assign exchanges once after all roundstart rulesets have assigned their candidates.
/datum/modpack/antagonists/initialize()
	. = ..()
	RegisterSignal(SSticker, COMSIG_TICKER_ROUNDSTART_ROLES_ASSIGNED, PROC_REF(on_roundstart_roles_assigned))

/datum/modpack/antagonists/proc/on_roundstart_roles_assigned(datum/source, list/antagonists)
	SIGNAL_HANDLER
	try_document_exchange(antagonists)

/// Only the roundstart antagonist pool can receive document exchanges.
/datum/modpack/antagonists/proc/try_document_exchange(list/antagonists)
	for(var/datum/antagonist/traitor/agent in antagonists)
		if(QDELETED(agent) || agent.type != /datum/antagonist/traitor || !agent.give_objectives || !length(agent.objectives))
			continue
		if(QDELETED(agent.owner) || !ishuman(agent.owner.current) || agent.owner.current.stat == DEAD)
			continue
		if(locate(/datum/objective/document_exchange) in agent.objectives)
			continue
		if(!prob(DOCUMENT_EXCHANGE_CHANCE))
			continue
		var/datum/antag_operation/document_exchange/operation = new()
		if(!operation.start(antagonists, list(agent)))
			qdel(operation)
