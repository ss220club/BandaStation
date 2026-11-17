ADMIN_VERB(create_document_exchange, R_FUN, "Create Document Exchange", "Выдать двум обычным агентам операцию обмена документами.", ADMIN_CATEGORY_EVENTS)
	var/datum/antag_operation/document_exchange/operation = new()
	if(!operation.admin_start(user))
		qdel(operation)

/// The same pairing path serves roundstart assignment and explicit administrative creation.
/datum/antag_operation/document_exchange/proc/admin_start(client/user)
	var/list/candidates = list()
	for(var/datum/antagonist/traitor/agent in GLOB.antagonists)
		if(is_eligible(agent))
			candidates["[length(candidates) + 1]. [agent.owner.name] ([agent.owner.key || "без клиента"])"] = agent
	if(length(candidates) < 2)
		to_chat(user, span_warning("Для обмена нужны хотя бы два живых агента, не участвующих в другом обмене."), confidential = TRUE)
		return FALSE

	var/red_choice = tgui_input_list(user, "Выберите агента, которому выдадут красные документы.", "Обмен документами", candidates)
	if(isnull(red_choice))
		return FALSE
	var/datum/antagonist/traitor/red_agent = candidates[red_choice]
	var/blue_choice = tgui_input_list(user, "Выберите агента, которому выдадут синие документы.", "Обмен документами", candidates - red_choice)
	if(isnull(blue_choice))
		return FALSE
	var/datum/antagonist/traitor/blue_agent = candidates[blue_choice]

	var/static/list/modes = list(
		"Обычный обмен" = list(FALSE, FALSE),
		"Предательство агента с красными документами" = list(TRUE, FALSE),
		"Предательство агента с синими документами" = list(FALSE, TRUE),
		"Предательство обоих агентов" = list(TRUE, TRUE),
		"Случайные условия" = list(null, null),
	)
	var/mode = tgui_input_list(user, "Выберите условия операции.", "Обмен документами", modes)
	if(isnull(mode))
		return FALSE
	var/list/betrayal_flags = modes[mode]
	var/static/list/delivery_modes = list(
		"Выдать документы без чемодана" = FALSE,
		"Спрятать в чемодане в технических тоннелях" = TRUE,
		"Случайный способ выдачи" = null,
	)
	var/red_delivery = tgui_input_list(user, "Выберите способ выдачи красных документов.", "Обмен документами", delivery_modes)
	if(isnull(red_delivery))
		return FALSE
	var/blue_delivery = tgui_input_list(user, "Выберите способ выдачи синих документов.", "Обмен документами", delivery_modes)
	if(isnull(blue_delivery))
		return FALSE
	// Revalidate in start_pair(): players may leave, lose their role or join another exchange during input.
	if(!start_pair(red_agent, blue_agent, betrayal_flags[1], betrayal_flags[2], delivery_modes[red_delivery], delivery_modes[blue_delivery]))
		to_chat(user, span_warning("Не удалось выдать обмен: выбранные участники больше не подходят для операции."), confidential = TRUE)
		return FALSE

	var/datum/objective/document_exchange/red_objective = locate() in red_agent.objectives
	var/datum/objective/document_exchange/blue_objective = locate() in blue_agent.objectives
	var/details = "[key_name(red_agent.owner)] (red betrayal: [red_objective.betrayal], stashed: [red_objective.briefcase_stashed]) and [key_name(blue_agent.owner)] (blue betrayal: [blue_objective.betrayal], stashed: [blue_objective.briefcase_stashed])"
	log_admin("[key_name(user)] created a document exchange between [details].")
	message_admins("[key_name_admin(user)] created a document exchange between [details]. [ADMIN_VV(src)]")
	to_chat(user, span_notice("Обмен документами выдан выбранным агентам. Операция: [ADMIN_VV(src)]"), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Create Document Exchange")
	return TRUE
