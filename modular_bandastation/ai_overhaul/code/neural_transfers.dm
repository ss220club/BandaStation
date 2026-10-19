/datum/computer_file/program/neural_service
	/// Исходный ИИ текущей незавершённой выгрузки.
	var/mob/living/silicon/ai/downloading
	/// Оператор исходной выгрузки для повторной проверки доступа.
	var/datum/weakref/download_operator_ref
	/// Исходная карта выгрузки для защиты от подмены содержимого компьютера.
	var/datum/weakref/download_card_ref
	/// Исходная сеть выгрузки для отмены при смене подключения.
	var/datum/weakref/download_network_ref
	/// Исходное ядро выгрузки для отмены при переносе ИИ.
	var/datum/weakref/download_core_ref
	/// Прогресс выгрузки от 0 до 100.
	var/download_progress = 0
	/// Отмечает уже отправленное предупреждение о выгрузке.
	var/download_warning = FALSE
	/// Подтверждённое ядро назначения при загрузке с карты.
	var/datum/weakref/upload_core_ref
	/// Подтверждённая сеть назначения при загрузке с карты.
	var/datum/weakref/upload_network_ref

/** Возвращает установленную в компьютере программу восстановления для доступа к слоту карты. */
/datum/computer_file/program/neural_service/proc/card_slot()
	RETURN_TYPE(/datum/computer_file/program/ai_restorer)
	if(QDELETED(computer))
		return null
	return locate(/datum/computer_file/program/ai_restorer) in computer.stored_files

/** Возвращает физически находящуюся в компьютере intelliCard либо null. */
/datum/computer_file/program/neural_service/proc/slotted_card()
	RETURN_TYPE(/obj/item/aicard)
	var/obj/item/aicard/card = card_slot()?.stored_card
	return !QDELETED(card) && card.loc == computer ? card : null

/** Проверяет права оператора, компьютер и слот карты перед переносом ИИ. */
/datum/computer_file/program/neural_service/proc/can_transfer(mob/user)
	return !QDELETED(user) && !QDELETED(computer) && can_allocate_resources(user) && (src in computer.stored_files) && (computer.active_program == src || (src in computer.idle_threads))

/** Повторно проверяет ИИ, карту и доступность среды перед очередным шагом выгрузки. */
/datum/computer_file/program/neural_service/proc/download_valid()
	var/mob/living/operator = download_operator_ref?.resolve()
	var/obj/item/aicard/card = download_card_ref?.resolve()
	var/obj/machinery/ai/data_core/core = download_core_ref?.resolve()
	var/datum/ai_network/network = download_network_ref?.resolve()
	return !QDELETED(downloading) && !QDELETED(operator) && !QDELETED(core) && !QDELETED(network) && can_transfer(operator) && local_network() == network && downloading.ai_network == network && downloading.loc == core && core.can_transfer_ai() && downloading.can_download && downloading.can_be_carded && downloading.stat != DEAD && !QDELETED(card) && slotted_card() == card && !card.AI && !card.flush && !card_slot().restoring

/** Отменяет выгрузку и очищает её участников; silent отключает уведомление ИИ. */
/datum/computer_file/program/neural_service/proc/stop_download(silent = FALSE)
	if(!silent && !QDELETED(downloading))
		to_chat(downloading, span_userdanger("Выгрузка через нейросервис остановлена."))
	downloading = null
	download_operator_ref = null
	download_card_ref = null
	download_network_ref = null
	download_core_ref = null
	download_progress = 0
	download_warning = FALSE

/** Выгружает ИИ на карту только при сохранении всех условий, затем очищает состояние операции. */
/datum/computer_file/program/neural_service/proc/finish_download()
	var/success = FALSE
	if(download_valid())
		var/obj/item/aicard/card = download_card_ref.resolve()
		var/mob/living/operator = download_operator_ref.resolve()
		var/mob/living/silicon/ai/target = downloading
		success = card.capture_ai(target, operator)
	stop_download(silent = success)
	return success

/datum/computer_file/program/neural_service/process_tick(seconds_per_tick)
	. = ..()
	if(!downloading)
		return
	if(!download_valid())
		stop_download()
		return
	download_progress = min(100, download_progress + AI_DOWNLOAD_PER_PROCESS * seconds_per_tick * downloading.download_speed_modifier)
	if(download_progress >= 50 && !download_warning)
		download_warning = TRUE
		to_chat(downloading, span_userdanger("Выгрузка в [ai_localized_area(computer, PREPOSITIONAL)] завершена наполовину!"))
	if(download_progress >= 100)
		finish_download()

/** Обрабатывает перенос через карту, проверяя действительные объекты и исходную сеть. */
/datum/computer_file/program/neural_service/proc/transfer_action(action, list/params, mob/user, datum/ai_network/network)
	if(!can_transfer(user))
		return FALSE
	var/obj/item/aicard/card = slotted_card()
	switch(action)
		if("stop_download")
			stop_download()
			return TRUE
		if("start_download")
			var/mob/living/silicon/ai/target = locate(params["host"]) in GLOB.ai_list
			if(QDELETED(target) || target.ai_network != network || !istype(target.loc, /obj/machinery/ai/data_core) || downloading || !card || card.AI || card.flush || card_slot().restoring)
				return FALSE
			downloading = target
			download_operator_ref = WEAKREF(user)
			download_card_ref = WEAKREF(card)
			download_network_ref = WEAKREF(network)
			download_core_ref = WEAKREF(target.loc)
			if(!download_valid())
				stop_download(TRUE)
				return FALSE
			to_chat(target, span_userdanger("Внимание! [user.name] пытается выгрузить вас через нейросервис в [ai_localized_area(computer, PREPOSITIONAL)]! Запретите выгрузку командой «Разрешить выгрузку», чтобы остановить перенос."))
			log_silicon("[key_name(user)] began a Neural Service download of [key_name(target)]", list(computer, target))
			return TRUE
		if("upload_card")
			var/obj/machinery/ai/data_core/core = locate(params["core"]) in network.nodes
			if(!istype(core) || !card?.AI || card.flush || downloading || card_slot().restoring || !core.can_transfer_ai())
				return FALSE
			upload_core_ref = WEAKREF(core)
			upload_network_ref = WEAKREF(network)
			var/success = card.upload_ai(computer, user)
			upload_core_ref = null
			upload_network_ref = null
			return success
	return FALSE

/obj/item/modular_computer/transfer_ai(interaction, mob/user, mob/living/silicon/ai/ai, obj/item/aicard/card)
	if(!..() || interaction != AI_TRANS_FROM_CARD)
		return FALSE
	for(var/datum/computer_file/program/neural_service/service in stored_files)
		var/obj/machinery/ai/data_core/core = service.upload_core_ref?.resolve()
		var/datum/ai_network/network = service.upload_network_ref?.resolve()
		if(QDELETED(core) || QDELETED(network) || service.slotted_card() != card || card.AI != ai || QDELETED(ai) || ai.loc != card || !service.can_transfer(user) || service.local_network() != network || core.ai_network != network)
			continue
		if(core.transfer_AI(ai))
			ai.setup_decentralized_ai()
			card.AI = null
			return TRUE
	return FALSE

/datum/computer_file/program/neural_service/Destroy()
	stop_download()
	return ..()

/** Повторно проверяет человека, ММИ, ядро и исходную сеть перед созданием ИИ. */
/datum/computer_file/program/neural_service/proc/mmi_upload_valid(mob/user, obj/item/brain_processor/brain, obj/machinery/ai/data_core/core, datum/ai_network/network)
	return istype(brain) && !QDELETED(brain) && istype(core) && !QDELETED(core) && !QDELETED(network) && can_transfer(user) && !downloading && user.is_holding(brain) && brain.loc == user && local_network() == network && core.ai_network == network && (core in network.nodes) && core.can_transfer_ai()

/** Подтверждает создание ИИ из ММИ и повторно проверяет участников после диалога. */
/datum/computer_file/program/neural_service/proc/upload_mmi(list/params, mob/user, datum/ai_network/network)
	var/obj/item/brain_processor/brain = user.is_holding_item_of_type(/obj/item/brain_processor)
	var/obj/machinery/ai/data_core/core = locate(params["core"]) in network.nodes
	if(!brain || params["mmi"] != REF(brain) || !mmi_upload_valid(user, brain, core, network))
		return FALSE
	return !!core.create_ai_from_mmi(user, brain, CALLBACK(src, PROC_REF(mmi_upload_valid), user, brain, core, network))

/** Создаёт ИИ в готовом ядре после проверки ММИ, физического доступа и callback разрешения. */
/obj/machinery/ai/data_core/proc/create_ai_from_mmi(mob/living/user, obj/item/brain_processor/brain, datum/callback/authorize)
	RETURN_TYPE(/mob/living/silicon/ai)
	if(QDELETED(user) || QDELETED(brain) || !CONFIG_GET(flag/allow_ai) || !brain.brain_check(user))
		return null
	var/mob/living/brain/occupant = brain.brainmob
	var/occupant_ckey = occupant.ckey
	if(occupant_ckey && is_banned_from(occupant_ckey, JOB_AI))
		balloon_alert(user, "мозг не может стать ИИ!")
		return null
	if(QDELETED(src) || QDELETED(user) || QDELETED(brain) || QDELETED(occupant) || brain.brainmob != occupant || occupant.ckey != occupant_ckey || !CONFIG_GET(flag/allow_ai) || !brain.brain_check(user) || !can_transfer_ai() || !authorize?.Invoke() || !user.is_holding(brain) || brain.loc != user)
		return null
	if(!user.transferItemToLoc(brain, src))
		return null
	occupant.mind.remove_antags_for_borging()
	if(!occupant.mind.has_ever_been_ai)
		SSblackbox.record_feedback("amount", "ais_created", 1)
	var/mob/living/silicon/ai/ai = new(src, occupant, brain.laws)
	if(brain.replacement_ai_name())
		ai.fully_replace_character_name(ai.name, brain.replacement_ai_name())
	ai.posibrain_inside = brain.braintype == "Android"
	log_silicon("[key_name(user)] commissioned [key_name(ai)] from an MMI in [src].", list(src, ai))
	deadchat_broadcast(" включён в <b>[get_area_name(ai, format_text = TRUE)]</b>.", span_name("[ai]"), follow_target = ai, message_type = DEADCHAT_ANNOUNCEMENT)
	qdel(brain)
	balloon_alert(user, "ИИ создан")
	return ai
