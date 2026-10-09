#define DOCUMENT_EXCHANGE_CHANCE 5
#define DOCUMENT_EXCHANGE_BETRAYAL_CHANCE 25
#define DOCUMENT_EXCHANGE_STASH_CHANCE 50

/// One exchange owns both agents, both originals and both personal objectives.
/datum/antag_operation/document_exchange
	/// Indexed by personal objective; references identify originals, not merely their color.
	var/list/document_refs = list()

/datum/antag_operation/document_exchange/Destroy()
	// Unsubscribe first: deleting equipment during cleanup must not initiate another cancellation.
	for(var/datum/objective/document_exchange/objective as anything in document_refs)
		var/datum/weakref/document_ref = document_refs[objective]
		var/obj/item/documents/document = document_ref.resolve()
		if(document)
			UnregisterSignal(document, COMSIG_QDELETING)
			subscriptions -= document
			qdel(document)
	document_refs.Cut()
	return ..()

/// Only ordinary agents with generated objectives and a living human body can participate.
/datum/antag_operation/document_exchange/proc/is_eligible(datum/antagonist/traitor/agent)
	if(QDELETED(agent) || agent.type != /datum/antagonist/traitor || !agent.give_objectives || !length(agent.objectives))
		return FALSE
	if(QDELETED(agent.owner) || !ishuman(agent.owner.current) || agent.owner.current.stat == DEAD)
		return FALSE
	for(var/datum/antag_operation/document_exchange/operation in GLOB.antag_operations)
		if(operation != src && (agent in operation.participant_antagonists))
			return FALSE
	return TRUE

/// Find the complete pair before creating either objectives or equipment.
/datum/antag_operation/document_exchange/proc/start(list/antagonists, list/first_candidates)
	if(length(participant_antagonists))
		return FALSE
	var/list/candidates = list()
	for(var/datum/antagonist/traitor/agent in antagonists)
		if(is_eligible(agent))
			candidates |= agent
	if(length(candidates) < 2)
		return FALSE
	var/list/first_pool = first_candidates ? (candidates & first_candidates) : candidates
	if(!length(first_pool))
		return FALSE
	var/datum/antagonist/traitor/first_agent = pick(first_pool)
	candidates -= first_agent
	for(var/datum/antagonist/traitor/agent as anything in candidates.Copy())
		if(agent.owner == first_agent.owner)
			candidates -= agent
	if(!length(candidates))
		return FALSE
	return start_pair(first_agent, pick(candidates))

/// Explicit pairing also permits administrative selection of conditions and delivery.
/datum/antag_operation/document_exchange/proc/start_pair(datum/antagonist/traitor/red_agent, datum/antagonist/traitor/blue_agent, red_betrayal = null, blue_betrayal = null, red_stash = null, blue_stash = null)
	if(length(participant_antagonists) || !is_eligible(red_agent) || !is_eligible(blue_agent) || red_agent.owner == blue_agent.owner)
		return FALSE
	if(!add_participant(red_agent) || !add_participant(blue_agent))
		cancel("не удалось назначить участников.")
		return FALSE
	var/datum/objective/document_exchange/red_objective = new(src)
	var/datum/objective/document_exchange/blue_objective = new(src)
	add_objective(red_agent, red_objective)
	add_objective(blue_agent, blue_objective)
	red_objective.partner = blue_agent.owner
	blue_objective.partner = red_agent.owner
	// Null preserves automatic assignment odds; administrative setup can choose either outcome.
	red_objective.betrayal = isnull(red_betrayal) ? prob(DOCUMENT_EXCHANGE_BETRAYAL_CHANCE) : red_betrayal
	blue_objective.betrayal = isnull(blue_betrayal) ? prob(DOCUMENT_EXCHANGE_BETRAYAL_CHANCE) : blue_betrayal
	var/obj/item/documents/syndicate/exchange_red/red_documents = new(red_agent.owner.current.loc)
	var/obj/item/documents/syndicate/exchange_blue/blue_documents = new(blue_agent.owner.current.loc)
	document_refs[red_objective] = WEAKREF(red_documents)
	document_refs[blue_objective] = WEAKREF(blue_documents)
	red_objective.own_document_ref = WEAKREF(red_documents)
	red_objective.target_document_ref = WEAKREF(blue_documents)
	blue_objective.own_document_ref = WEAKREF(blue_documents)
	blue_objective.target_document_ref = WEAKREF(red_documents)
	subscribe(red_documents, COMSIG_QDELETING, PROC_REF(on_document_deleted))
	subscribe(blue_documents, COMSIG_QDELETING, PROC_REF(on_document_deleted))
	var/turf/red_stash_turf = deliver_documents(red_agent.owner.current, red_documents, red_objective, red_stash)
	deliver_documents(blue_agent.owner.current, blue_documents, blue_objective, blue_stash, red_stash_turf)
	red_objective.update_explanation_text()
	blue_objective.update_explanation_text()
	log_game("Document exchange started between [key_name(red_agent.owner)] and [key_name(blue_agent.owner)].")
	return activate()

/// Hide the cargo on the receiver's station level, where a pinpointer can guide them.
/// Maps without a suitable maintenance spawn fall back to direct delivery.
/datum/antag_operation/document_exchange/proc/deliver_documents(mob/living/carbon/human/agent, obj/item/documents/documents, datum/objective/document_exchange/objective, stash = null, turf/excluded_turf = null)
	// Each agent independently rolls whether their own documents are hidden.
	var/use_stash = isnull(stash) ? prob(DOCUMENT_EXCHANGE_STASH_CHANCE) : stash
	if(use_stash && is_station_level(agent.z))
		var/turf/stash_turf = find_maintenance_spawn(atmos_sensitive = TRUE)
		if(stash_turf)
			var/obj/item/storage/briefcase/secure/document_exchange/briefcase = new(stash_turf)
			documents.forceMove(briefcase)
			var/obj/item/pinpointer/document_exchange/receiver = new(agent.loc)
			receiver.briefcase_ref = WEAKREF(briefcase)
			if(!agent.equip_to_storage(receiver, ITEM_SLOT_BACK, indirect_action = TRUE))
				agent.put_in_hands(receiver)
			objective.briefcase_stashed = TRUE
			objective.briefcase_code = briefcase.stored_lock_code
			to_chat(agent, span_notice("Ваш чемодан с документами спрятан в технических тоннелях. Вам выдан целеуказатель для его поиска. Код замка указан в описании цели."))
			return stash_turf
	if(!agent.equip_to_storage(documents, ITEM_SLOT_BACK, indirect_action = TRUE))
		agent.put_in_hands(documents)
	to_chat(agent, span_notice("Вам выданы документы для обмена. Проверьте рюкзак, руки и пол рядом с собой."))
	return null

/datum/antag_operation/document_exchange/proc/on_document_deleted(datum/source)
	SIGNAL_HANDLER
	cancel("оригиналы документов больше недоступны.")

/datum/antag_operation/document_exchange/proc/check_completion(datum/objective/document_exchange/objective)
	if(!(objective in operation_objectives))
		return FALSE
	var/datum/antagonist/agent = operation_objectives[objective]
	if(agent.owner != participant_antagonists[agent] || !(objective in agent.objectives))
		return FALSE
	if(!isliving(objective.owner.current))
		return FALSE
	var/list/items = objective.owner.current.get_all_contents()
	var/obj/item/documents/target_document = objective.target_document_ref?.resolve()
	if(!target_document || !(target_document in items) || HAS_TRAIT(target_document, TRAIT_ITEM_OBJECTIVE_BLOCKED))
		return FALSE
	if(!objective.betrayal)
		return TRUE
	var/obj/item/documents/own_document = objective.own_document_ref?.resolve()
	return own_document && (own_document in items) && !HAS_TRAIT(own_document, TRAIT_ITEM_OBJECTIVE_BLOCKED)

/datum/objective/document_exchange
	name = "document exchange"
	// Like the completion check, this permits the originals to remain on the agent's corpse.
	martyr_compatible = TRUE
	/// Personal success is evaluated by the shared operation.
	var/datum/weakref/operation_ref
	var/datum/mind/partner
	var/datum/weakref/own_document_ref
	var/datum/weakref/target_document_ref
	/// Initial code of the briefcase hiding this objective owner's documents.
	var/briefcase_code
	/// Whether the owner must retrieve their cargo using the issued pinpointer.
	var/briefcase_stashed = FALSE
	var/betrayal = FALSE

/datum/objective/document_exchange/New(datum/antag_operation/document_exchange/operation)
	..()
	if(operation)
		operation_ref = WEAKREF(operation)

/datum/objective/document_exchange/Destroy()
	operation_ref = null
	partner = null
	own_document_ref = null
	target_document_ref = null
	return ..()

/datum/objective/document_exchange/update_explanation_text()
	var/obj/item/documents/document = target_document_ref?.resolve()
	if(betrayal)
		explanation_text = "[partner?.name] ожидает обмена документами. Завладейте оригиналом «[document?.name]» этого агента и сохраните собственный оригинал до конца смены."
	else
		explanation_text = "Договоритесь об обмене с агентом [partner?.name]. Получите его оригинал «[document?.name]» и сохраните до конца смены."
	if(briefcase_stashed)
		explanation_text += " Сначала заберите свои документы: чемодан спрятан в технических тоннелях станции. Найдите его с помощью выданного целеуказателя."
		explanation_text += " Ваши документы находятся в запертом чемодане. Код вашего чемодана: [briefcase_code]."

/datum/objective/document_exchange/check_completion()
	var/datum/antag_operation/document_exchange/operation = operation_ref?.resolve()
	return completed || operation?.check_completion(src) || FALSE
