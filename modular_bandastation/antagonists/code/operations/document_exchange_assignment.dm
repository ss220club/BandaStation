/// Assign exchanges once after all roundstart rulesets have assigned their candidates.
/datum/modpack/antagonists/initialize()
	. = ..()
	RegisterSignal(SSticker, COMSIG_TICKER_ROUNDSTART_ROLES_ASSIGNED, PROC_REF(on_roundstart_roles_assigned))

/datum/modpack/antagonists/proc/on_roundstart_roles_assigned(datum/source, list/antagonists)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_document_exchange), antagonists)

/// Only the roundstart antagonist pool can receive document exchanges.
/datum/modpack/antagonists/proc/try_document_exchange(list/antagonists)
	var/datum/antag_operation/document_exchange/operation = new()

	for(var/datum/antagonist/traitor/agent in antagonists)
		if(!operation.is_eligible(agent))
			continue
		if(locate(/datum/objective/document_exchange) in agent.objectives)
			continue
		if(!prob(DOCUMENT_EXCHANGE_CHANCE))
			continue
		if(operation.start(antagonists, list(agent)))
			operation = new()

	if(!length(operation.document_refs))
		qdel(operation)
