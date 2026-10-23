// BANDASTATION ADD START - Перенос ИИ: русские сообщения восстановления ИИ.
/** Стационарное устройство восстановления исходного ИИ с intelliCard. */
/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	desc = "Восстанавливает работоспособность повреждённых ИИ, перенесённых на intelliCard."
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_COMMAND)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_state = MAP_SWITCH("computer", "/obj/machinery/computer/aifixer")
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	/// Variable containing transferred AI
	var/mob/living/silicon/ai/occupier
	/// Variable dictating if we are in the process of restoring the occupier AI
	var/restoring = FALSE

/** Проверяет состояние устройства перед открытием панели обслуживания. */
/obj/machinery/computer/aifixer/screwdriver_act(mob/living/user, obj/item/I)
	if(occupier)
		if(machine_stat & (NOPOWER|BROKEN))
			to_chat(user, span_warning("Винты экрана [declent_ru(GENITIVE)] не поддаются."))
		else
			to_chat(user, span_warning("Винты экрана [declent_ru(GENITIVE)] не поддаются; устройство подаёт предупреждающий сигнал."))
	else
		return ..()
// BANDASTATION ADD END - Перенос ИИ

/obj/machinery/computer/aifixer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRestorer", name)
		ui.open()

// BANDASTATION ADD START - Перенос ИИ: русские сообщения восстановления ИИ.
/** Передаёт состояние установленного носителя и доступные операции восстановления ИИ. */
/obj/machinery/computer/aifixer/ui_data(mob/user)
	var/list/data = list()

	data["ejectable"] = FALSE
	data["AI_present"] = FALSE
	data["error"] = null
	if(!occupier)
		data["error"] = "Перенесите ИИ в терминал."
	else
		data["AI_present"] = TRUE
		data["name"] = occupier.name
		data["restoring"] = restoring
		data["health"] = (occupier.health + 100) / 2
		data["isDead"] = occupier.stat == DEAD
		data["laws"] = occupier.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)

	return data

/** Проверяет доступ и неизменность носителя перед выполнением команды восстановления. */
/obj/machinery/computer/aifixer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!occupier)
		restoring = FALSE

	switch(action)
		if("PRG_beginReconstruction")
			if(occupier?.health < 100)
				to_chat(usr, span_notice("Восстановление началось. Это займёт несколько минут."))
				playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 25, FALSE)
				restoring = TRUE
				occupier.notify_revival("Ваши системные файлы восстанавливаются!", source = src)
				. = TRUE

/** Восстанавливает размещённого в устройстве ИИ без подмены исходного носителя. */
/obj/machinery/computer/aifixer/proc/Fix()
	if(!use_energy(active_power_usage, force = TRUE))
		say("Недостаточно энергии. Восстановление отменено.")
		return FALSE
	var/need_mob_update = FALSE
	need_mob_update += occupier.adjust_oxy_loss(-5, updating_health = FALSE)
	need_mob_update += occupier.adjust_fire_loss(-5, updating_health = FALSE)
	need_mob_update += occupier.adjust_brute_loss(-5, updating_health = FALSE)
	if(need_mob_update)
		occupier.updatehealth()
	if(occupier.health >= 0 && occupier.stat == DEAD)
		occupier.revive()
		if(!occupier.radio_enabled)
			occupier.radio_enabled = TRUE
			to_chat(occupier, span_warning("Ваш подпространственный приёмопередатчик включён!"))
	return occupier.health < 100
// BANDASTATION ADD END - Перенос ИИ

/obj/machinery/computer/aifixer/process()
	if(..())
		if(restoring)
			var/oldstat = occupier.stat
			restoring = Fix()
			if(oldstat != occupier.stat)
				update_appearance()

/obj/machinery/computer/aifixer/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(restoring)
		. += "ai-fixer-on"

	if(!occupier)
		. += "ai-fixer-empty"
		return

	if(occupier.stat == HARD_CRIT || IS_UNCONSCIOUS(occupier))
		. += "ai-fixer-404"
	else if(!IS_UNCONSCIOUS_OR_CRIT(occupier))
		. += "ai-fixer-full"

// BANDASTATION ADD START - Перенос ИИ: русские сообщения восстановления ИИ.
/** Обрабатывает штатный перенос через intelliCard с проверкой направления и действительного содержимого носителя. */
/obj/machinery/computer/aifixer/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(machine_stat & (NOPOWER|BROKEN))
			to_chat(user, span_alert("[declent_ru(NOMINATIVE)] отключён и не может принять ИИ."))
			return
		AI.forceMove(src)
		occupier = AI
		AI.set_control_disabled(TRUE)
		AI.radio_enabled = FALSE
		to_chat(AI, span_alert("Вы загружены в стационарный терминал. Удалённое управление отсюда недоступно."))
		to_chat(user, "[span_notice("Перенос завершён")]: [AI.name] ([rand(1000,9999)].exe) установлен и запущен. Копия на карте удалена.")
		card.AI = null
		update_appearance()

	else //Uploading AI from terminal to card
		if(occupier && !restoring)
			to_chat(occupier, span_notice("Вы выгружены на переносной накопитель. Удалённое управление по-прежнему недоступно."))
			to_chat(user, "[span_notice("Перенос завершён")]: [occupier.name] ([rand(1000,9999)].exe) снят с терминала и сохранён в памяти карты.")
			occupier.forceMove(card)
			card.AI = occupier
			occupier = null
			update_appearance()
		else if (restoring)
			to_chat(user, span_alert("ОШИБКА: Выполняется восстановление."))
		else if (!occupier)
			to_chat(user, span_alert("ОШИБКА: ИИ не обнаружен."))
// BANDASTATION ADD END - Перенос ИИ

/obj/machinery/computer/aifixer/Destroy()
	if(occupier)
		QDEL_NULL(occupier)
	return ..()

/obj/machinery/computer/aifixer/on_deconstruction(disassembled)
	if(occupier)
		QDEL_NULL(occupier)
