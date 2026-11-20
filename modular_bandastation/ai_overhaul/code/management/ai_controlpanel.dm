GLOBAL_VAR_INIT(ai_control_code, num2text(rand(100000, 999999), 6, 10))

/** Обслуживает перенос ИИ через intelliCard с физической и аварийной авторизацией. */
/obj/machinery/computer/ai_control_console
	name = "\improper AI control console"
	desc = "Консоль доступа к ядрам ИИ для загрузки и выгрузки интеллекта."
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/computer/ai_upload_download
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK


	/// Сохраняет аварийную авторизацию консоли после использования одноразового кода.
	var/one_time_password_used = FALSE

	/// Физически установленная карта для переноса ИИ.
	var/obj/item/aicard/intellicard

	/// Исходный ИИ текущей незавершённой выгрузки.
	var/mob/living/silicon/ai/downloading
	/// Пользователь, начавший выгрузку на стационарной консоли.
	var/mob/user_downloading
	authenticated = FALSE
	/// Прогресс выгрузки от 0 до 100.
	var/download_progress = 0
	/// Отмечает уже отправленное предупреждение о выгрузке.
	var/download_warning = FALSE

/obj/machinery/computer/ai_control_console/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/aicard))
		if(intellicard)
			balloon_alert(user, "intelliCard уже вставлена!")
			return ITEM_INTERACT_BLOCKING
		if(user.transferItemToLoc(tool, src))
			to_chat(user, span_notice("Вы вставляете [tool.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
			intellicard = tool
			playsound(src, 'sound/machines/terminal/terminal_prompt_deny.ogg', 25, FALSE)
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/brain_processor))
		if(!can_create_ai(user))
			balloon_alert(user, "доступ запрещён!")
			return ITEM_INTERACT_BLOCKING
		var/obj/machinery/ai/data_core/core = available_ai_cores(source = src)
		if(!core)
			balloon_alert(user, "нет доступного ядра!")
			return ITEM_INTERACT_BLOCKING
		return core.create_ai_from_mmi(user, tool, CALLBACK(src, PROC_REF(can_create_ai), user)) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	return NONE

/obj/machinery/computer/ai_control_console/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	authenticated = TRUE
	obj_flags |= EMAGGED
	if(user)
		balloon_alert(user, "ограничения обойдены")

/obj/machinery/computer/ai_control_console/click_alt(mob/user)
	eject_intellicard(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/computer/ai_control_console/process(seconds_per_tick)
	if(!downloading)
		return
	if(machine_stat & (BROKEN|NOPOWER|EMPED) || !download_valid())
		stop_download()
		return
	download_progress = min(100, download_progress + AI_DOWNLOAD_PER_PROCESS * seconds_per_tick * downloading.download_speed_modifier)
	if(download_progress >= 50 && !download_warning)
		download_warning = TRUE
		to_chat(downloading, span_userdanger("Выгрузка в [ai_localized_area(src, PREPOSITIONAL)] завершена наполовину!"))
	if(download_progress >= 100)
		finish_download()

/obj/machinery/computer/ai_control_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiControlPanel", name)
		ui.open()

/obj/machinery/computer/ai_control_console/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated
	data["has_access"] = allowed(user) || (obj_flags & EMAGGED)
	data["username"] = user.name
	data["can_log_out"] = !one_time_password_used
	if(!authenticated)
		return data

	data["intellicard"] = !QDELETED(intellicard)
	if(intellicard && intellicard.AI)
		data["intellicard_ai"] = intellicard.AI.real_name
		data["intellicard_ai_health"] = intellicard.AI.health
	else
		data["intellicard_ai"] = null
		data["intellicard_ai_health"] = 0

	data["can_upload"] = !!available_ai_cores(source = src)

	if(downloading)
		data["downloading"] = downloading.real_name
		data["download_progress"] = download_progress
		data["downloading_ref"] = REF(downloading)
	else
		data["downloading"] = null
		data["download_progress"] = 0

	data["ais"] = list()
	data["current_ai_ref"] = null
	if(isAI(user))
		data["current_ai_ref"] = REF(user)

	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		if(!ai_same_debug_environment(src, ai) || istype(ai.loc, /obj/item/ai_neural_backup))
			continue
		data["ais"] += list(list(
			"name" = ai.name,
			"ref" = REF(ai),
			"can_download" = ai.can_download,
			"health" = ai.health,
			"active" = ai.mind ? TRUE : FALSE,
			"in_core" = istype(ai.loc, /obj/machinery/ai/data_core),
		))

	return data

/** Останавливает перенос и физически отдаёт карту пользователю; удалённое извлечение запрещено. */
/obj/machinery/computer/ai_control_console/proc/eject_intellicard(mob/living/user)
	if(!intellicard)
		return FALSE
	if(issilicon(user))
		to_chat(user, span_warning("Нельзя удалённо извлечь [intellicard.declent_ru(ACCUSATIVE)]!"))
		return FALSE
	stop_download()
	var/obj/item/aicard/card = intellicard
	if(!user.put_in_hands(card))
		card.forceMove(drop_location())
	intellicard = null
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 30, FALSE)
	return TRUE

/** Повторно проверяет ИИ, карту и доступность среды перед очередным шагом выгрузки. */
/obj/machinery/computer/ai_control_console/proc/download_valid()
	return !QDELETED(downloading) && downloading.can_download && downloading.can_be_carded && istype(downloading.loc, /obj/machinery/ai/data_core) && !QDELETED(intellicard) && intellicard.loc == src && !intellicard.AI && !intellicard.flush && ai_supported_location(src) && ai_same_debug_environment(src, downloading)

/** Выгружает ИИ на карту только при сохранении всех условий, затем очищает состояние операции. */
/obj/machinery/computer/ai_control_console/proc/finish_download()
	if(download_valid() && !(machine_stat & (BROKEN|NOPOWER|EMPED)))
		intellicard.capture_ai(downloading, user_downloading)
	stop_download(TRUE)

/** Отменяет выгрузку и очищает её участников; silent отключает уведомление ИИ. */
/obj/machinery/computer/ai_control_console/proc/stop_download(silent = FALSE)
	if(!downloading)
		return
	if(!silent)
		to_chat(downloading, span_userdanger("Выгрузка остановлена."))
	downloading = null
	user_downloading = null
	download_progress = 0
	download_warning = FALSE

/obj/machinery/computer/ai_control_console/transfer_ai(interaction, mob/user, mob/living/silicon/ai/ai, obj/item/aicard/card)
	if(!..() || interaction != AI_TRANS_FROM_CARD || !authenticated || (!allowed(user) && !(obj_flags & EMAGGED) && !one_time_password_used))
		return FALSE
	if(machine_stat & (BROKEN|NOPOWER|EMPED) || !ai_supported_location(src) || !ai || downloading)
		return FALSE
	var/obj/machinery/ai/data_core/core = available_ai_cores(source = src)
	if(!core || !core.transfer_AI(ai))
		return FALSE
	ai.setup_decentralized_ai()
	card.AI = null
	return TRUE

/obj/machinery/computer/ai_control_console/Destroy()
	stop_download()
	intellicard?.forceMove(drop_location())
	intellicard = null
	return ..()

/obj/machinery/computer/ai_control_console/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == intellicard)
		stop_download()
		intellicard = null

/obj/machinery/computer/ai_control_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	if(!authenticated)
		if(action == "log_in")
			if(allowed(user) || (obj_flags & EMAGGED))
				playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
				authenticated = TRUE
				return TRUE
			return .
		if(action == "log_in_control_code")
			var/code = params["control_code"]

			if(!GLOB.ai_control_code)
				return

			if(istext(code) && code == GLOB.ai_control_code)
				authenticated = TRUE
				one_time_password_used = TRUE
				var/msg = "<h4>Внимание!</h4><br>Обнаружено использование аварийного кода доступа ИИ для разблокировки консоли в координатах ([src.x], [src.y], [src.z]) пользователем [html_encode(user.name)]. Проверьте, что это разрешённое действие. Текущий код доступа аннулирован.<br>При необходимости новый код можно распечатать на консоли связи."
				priority_announce(msg, sender_override = "Служба кибербезопасности Центрального командования", has_important_message = TRUE, encode_text = FALSE)
				GLOB.ai_control_code = null
			else
				to_chat(user, span_warning("Неверный код. Убедитесь, что у вас последняя версия."))
		return

	if(!allowed(user) && !(obj_flags & EMAGGED) && !one_time_password_used && !(action == "skip_download" && user == downloading))
		return FALSE

	switch(action)
		if("log_out")
			if(one_time_password_used || downloading)
				return
			playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
			authenticated = FALSE
			. = TRUE
		if("upload_intellicard")
			if(!intellicard || intellicard.flush || downloading)
				return
			if(!intellicard.AI)
				return
			if(available_ai_cores(source = src) && !intellicard.flush)
				intellicard.upload_ai(src, user)

		if("eject_intellicard")
			return eject_intellicard(user)

		if("stop_download")
			if(isAI(user))
				to_chat(user, span_warning("Для остановки выгрузки нужен физический доступ!"))
				return
			if(!ai_supported_location(src))
				to_chat(user, span_warning("Нет связи. Повторите попытку позже."))
				return
			stop_download()
			playsound(src, 'sound/machines/terminal/terminal_prompt_deny.ogg', 25, FALSE)

		if("start_download")
			if(!intellicard || intellicard.flush || downloading)
				return
			var/mob/living/silicon/ai/target = locate(params["download_target"]) in GLOB.ai_list
			if(!target || !istype(target) || !ai_same_debug_environment(src, target))
				return
			if(!istype(target.loc, /obj/machinery/ai/data_core))
				return
			if(intellicard.AI || !target.can_be_carded || !target.can_download)
				return
			if(!ai_supported_location(src))
				to_chat(user, span_warning("Нет связи. Повторите попытку позже."))
				return
			playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 25, FALSE)
			downloading = target
			to_chat(downloading, span_userdanger("Внимание! Кто-то пытается выгрузить вас из [ai_localized_area(src, GENITIVE)]!"))
			user_downloading = user
			download_progress = 0
			. = TRUE
		if("skip_download")
			if(!downloading)
				return
			if(user == downloading)
				finish_download()

/** Физический носитель действующего одноразового аварийного кода консоли ИИ. */
/obj/item/paper/ai_control_code
	name = "paper - 'AI control code'"

/obj/item/paper/ai_control_code/Initialize(mapload)
	. = ..()
	add_raw_text("<center><h2>Смена кода доступа ИИ</h2></center><br>Новый код авторизации: «[GLOB.ai_control_code]».<br>Держите его в секрете и подальше от клоуна.<br>При выдаче нового кода этот может быть аннулирован.")
	update_appearance()

/** Проверяет физический доступ, авторизацию и готовность консоли к созданию ИИ из ММИ. */
/obj/machinery/computer/ai_control_console/proc/can_create_ai(mob/user)
	return !QDELETED(src) && ishuman(user) && !user.incapacitated && user.Adjacent(src) && !(machine_stat & (BROKEN | EMPED | NOPOWER)) && !downloading && authenticated && (allowed(user) || (obj_flags & EMAGGED) || one_time_password_used)
