// BANDASTATION ADD START - Перенос ИИ: русские сообщения программы восстановления.
/** Обслуживает физический слот intelliCard на модульном компьютере. */
/datum/computer_file/program/ai_restorer
	filename = "ai_restore"
	filedesc = "Управление и восстановление ИИ"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "generic"
	extended_desc = "Специальный инструмент для восстановления прошивки, способный восстанавливать поврежденные системы ИИ. Требуется прямое подключение к ИИ через слот интел-карты."
	size = 12
	can_run_on_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	download_access = list(ACCESS_RD)
	tgui_id = "NtosAiRestorer"
	program_icon = "laptop-code"

	/// The AI stored in the program
	var/obj/item/aicard/stored_card
	/// Variable dictating if we are in the process of restoring the AI in the inserted intellicard
	var/restoring = FALSE

/** Добавляет физический слот карты программы восстановления в осмотр компьютера. */
/datum/computer_file/program/ai_restorer/on_examine(obj/item/modular_computer/source, mob/user)
	var/list/examine_text = list()
	if(!stored_card)
		examine_text += "Установлен разъём для intelliCard."
		return examine_text

	if(computer.Adjacent(user))
		examine_text += "В разъёме для intelliCard установлена [stored_card.declent_ru(NOMINATIVE)]."
	else
		examine_text += "В разъёме для intelliCard находится карта."
	examine_text += span_info("Alt-клик — извлечь intelliCard.")
	return examine_text
// BANDASTATION ADD END - Перенос ИИ

/datum/computer_file/program/ai_restorer/kill_program(mob/user)
	try_eject(forced = TRUE)
	return ..()

/datum/computer_file/program/ai_restorer/process_tick(seconds_per_tick)
	. = ..()
	if(!restoring) //Put the check here so we don't check for an ai all the time
		return

	var/mob/living/silicon/ai/A = stored_card.AI
	if(stored_card.flush)
		restoring = FALSE
		return
	A.adjust_oxy_loss(-5, FALSE)
	A.adjust_fire_loss(-5, FALSE)
	A.adjust_brute_loss(-5, FALSE)

	// Please don't forget to update health, otherwise the below if statements will probably always fail.
	A.updatehealth()
	if(A.health >= 0 && A.stat == DEAD)
		A.revive()
		stored_card.update_appearance()

	// Finished restoring
	if(A.health >= 100)
		restoring = FALSE

	return TRUE

/datum/computer_file/program/ai_restorer/application_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/aicard))
		return aicard_act(user, tool)

// BANDASTATION ADD START - Перенос ИИ: русские сообщения программы восстановления.
/** Устанавливает карту в программу восстановления, проверяя физический доступ и занятость слота. */
/datum/computer_file/program/ai_restorer/proc/aicard_act(mob/living/user, obj/item/aicard/used_aicard)
	if(!computer)
		return NONE
	if(stored_card)
		to_chat(user, span_warning("Вы пытаетесь вставить [used_aicard.declent_ru(ACCUSATIVE)] в [computer.declent_ru(ACCUSATIVE)], но разъём занят."))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(used_aicard, computer))
		return ITEM_INTERACT_BLOCKING

	stored_card = used_aicard
	to_chat(user, span_notice("Вы вставляете [used_aicard.declent_ru(ACCUSATIVE)] в [computer.declent_ru(ACCUSATIVE)]."))
	return ITEM_INTERACT_SUCCESS

/** Извлекает исходную карту и прекращает несовместимые операции восстановления. */
/datum/computer_file/program/ai_restorer/try_eject(mob/living/user, forced = FALSE)
	if(!stored_card)
		if(user)
			to_chat(user, span_warning("В [computer.declent_ru(PREPOSITIONAL)] нет карты."))
		return FALSE

	if(restoring && !forced)
		if(user)
			to_chat(user, span_warning("Защитная блокировка не позволяет извлечь карту до завершения восстановления..."))
		return FALSE

	if(user && computer.Adjacent(user))
		to_chat(user, span_notice("Вы извлекаете [stored_card.declent_ru(ACCUSATIVE)] из [computer.declent_ru(GENITIVE)]."))
		user.put_in_hands(stored_card)
	else
		stored_card.forceMove(computer.drop_location())

	stored_card = null
	restoring = FALSE
	return TRUE


/** Проверяет доступ и неизменность носителя перед выполнением команды восстановления. */
/datum/computer_file/program/ai_restorer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PRG_beginReconstruction")
			if(!stored_card || !stored_card.AI)
				return FALSE
			var/mob/living/silicon/ai/A = stored_card.AI
			if(A && A.health < 100)
				restoring = TRUE
				A.notify_revival("Ваши системные файлы восстанавливаются!", source = computer)
			return TRUE
		if("PRG_eject")
			if(stored_card)
				try_eject(usr)
				return TRUE

/** Передаёт состояние установленного носителя и доступные операции восстановления ИИ. */
/datum/computer_file/program/ai_restorer/ui_data(mob/user)
	var/list/data = list()

	data["ejectable"] = TRUE
	data["AI_present"] = !!stored_card?.AI
	data["error"] = null

	if(!stored_card)
		data["error"] = "Вставьте intelliCard."
	else if(!stored_card.AI)
		data["error"] = "ИИ не обнаружен..."
	else if(stored_card.flush)
		data["error"] = "Идёт очистка карты!"
	else
		data["name"] = stored_card.AI.name
		data["restoring"] = restoring
		data["health"] = (stored_card.AI.health + 100) / 2
		data["isDead"] = stored_card.AI.stat == DEAD
		data["laws"] = stored_card.AI.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)

	return data
// BANDASTATION ADD END - Перенос ИИ
