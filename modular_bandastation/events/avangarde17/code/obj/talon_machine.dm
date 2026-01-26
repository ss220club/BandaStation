/obj/item/ticket_machine_ticket/talon
	name = "талонный лист"
	desc = "Лист с вырезаемыми талонами, который печатает автомат с талонными листами. Вы можете вписать назначение кусочков листа и вырезать их в соответствующие талоны."
	icon_state = "paperslip_words"
	/// Общее количество ячеек на талонном листе
	var/total_cells = 20
	/// Количество использованных ячеек
	var/used_cells = 0
	/// Сопоставление типов талонов с их весом в ячейках
	var/static/list/talon_types = list(
		"Еда" = list(
			"path" = /obj/item/stack/talon/food,
			"weight" = 1
		),
		"Одежда" = list(
			"path" = /obj/item/stack/talon/clothes,
			"weight" = 2
		),
		"Инструменты" = list(
			"path" = /obj/item/stack/talon/tools,
			"weight" = 3
		),
		"Алкоголь" = list(
			"path" = /obj/item/stack/talon/alcohol,
			"weight" = 2
		),
		"Бытовые товары" = list(
			"path" = /obj/item/stack/talon/household,
			"weight" = 1
		),
		"Бытовая техника" = list(
			"path" = /obj/item/stack/talon/machinery,
			"weight" = 1
		)
	)

/obj/item/ticket_machine_ticket/talon/examine(mob/user)
	. = ..()
	var/remaining = total_cells - used_cells
	if(remaining > 0)
		. += span_notice("На листе осталось [remaining] из [total_cells] ячеек.")
	else
		. += span_warning("Все ячейки на листе использованы!")

/obj/item/ticket_machine_ticket/talon/attack_self(mob/user)
	ui_interact(user)

/obj/item/ticket_machine_ticket/talon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TalonTicketModal")
		ui.open()

/obj/item/ticket_machine_ticket/talon/ui_state(mob/user)
	return GLOB.always_state

/obj/item/ticket_machine_ticket/talon/ui_static_data(mob/user)
	var/list/data = list()
	data["title"] = "Талонный лист"
	data["message"] = "Выберите тип талона для вырезания:"
	var/list/buttons_data = list()
	for(var/talon_name in talon_types)
		var/list/talon_info = talon_types[talon_name]
		buttons_data += list(list(
			"name" = talon_name,
			"weight" = talon_info["weight"]
		))
	data["buttons"] = buttons_data
	return data

/obj/item/ticket_machine_ticket/talon/ui_data(mob/user)
	var/list/data = list()
	data["remaining_cells"] = total_cells - used_cells
	data["total_cells"] = total_cells
	return data

/obj/item/ticket_machine_ticket/talon/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			var/payload = params["choice"]
			handle_choice(payload)
			return TRUE

/// Обрабатывает выбор пользователя из модального окна
/obj/item/ticket_machine_ticket/talon/proc/handle_choice(payload)
	if(!(payload in talon_types))
		to_chat(usr, span_warning("Неизвестный тип талона!"))
		return

	var/list/talon_info = talon_types[payload]
	var/weight = talon_info["weight"]
	var/remaining_cells = total_cells - used_cells

	if(weight > remaining_cells)
		to_chat(usr, span_warning("Недостаточно ячеек на талонном листе для вырезания этого талона!"))
		return

	// Создаем талон
	var/talon_path = talon_info["path"]
	var/obj/item/stack/talon/new_talon = new talon_path(get_turf(src))

	// Выдаем талон игроку
	if(!usr.put_in_hands(new_talon))
		new_talon.forceMove(get_turf(usr))

	// Увеличиваем количество использованных ячеек
	used_cells += weight

	playsound(loc, 'sound/items/poster/poster_ripped.ogg', vol = 50, vary = TRUE)
	to_chat(usr, span_notice("Вы вырезали талон на [payload] из талонного листа."))

	// Обновляем UI
	SStgui.update_uis(src)

	// Если все ячейки использованы, удаляем лист
	if(used_cells >= total_cells)
		to_chat(usr, span_notice("Талонный лист полностью использован!"))
		qdel(src)

/obj/machinery/ticket_machine/talon
	name = "Талонный автомат"
	desc = "Автомат для выдачи талонных листов на различные услуги."
	icon_state = "ticketmachine"
	/// cooldown in seconds per-player
	var/ticket_cooldown = 600 SECONDS
	/// global cooldown in deciseconds (50 = 5 seconds) between any ticket issuances
	var/global_cooldown = 20 SECONDS
	/// last ticket time per-player: last_ticket_time[REF(mob)] = world.time
	var/list/last_ticket_time = list()
	/// last ticket time for the machine (global cooldown)
	var/last_global_ticket_time = 0
	var/fails_counter = 0
	/// Список запрещенных профессий, для которых нельзя получить талон
	var/list/banned_roles = list("Assistant")
	/// Фразы для наказания при злоупотреблении
	var/static/list/not_ready_frases = list(
		"Вы попытались воспользоваться талонным аппаратом раньше срока. Вам начислено -500 к социальному рейтингу.",
		"Злоупотребление талонным аппаратом может привести к санкциям в виде перманентного заключения.",
		"Расстрельная команда уже выехала к вам за попытку обмана талонного аппарата.",
		"Ваш социальный рейтинг понижен за попытку обмана талонного аппарата.",
		"Талонный аппарат зафиксировал попытку злоупотребления. Ваши действия переданы в отдел кадров."
	)


/// Helper proc to get remaining cooldown seconds for a user
/obj/machinery/ticket_machine/talon/proc/get_remaining_cooldown_seconds(user_ref)
	if(!(user_ref in last_ticket_time))
		return 0
	var/real_elapsed = world.time - last_ticket_time[user_ref]
	if(real_elapsed >= ticket_cooldown)
		return 0
	var/remaining_deciseconds = ticket_cooldown - real_elapsed
	var/remaining_seconds = floor((remaining_deciseconds + 9) / 10)
	return remaining_seconds <= 0 ? 0 : remaining_seconds


/// Helper proc to get remaining global cooldown seconds
/obj/machinery/ticket_machine/talon/proc/get_remaining_global_cooldown_seconds()
	if(last_global_ticket_time == 0)
		return 0
	var/real_elapsed = world.time - last_global_ticket_time
	if(real_elapsed >= global_cooldown)
		return 0
	var/remaining_deciseconds = global_cooldown - real_elapsed
	var/remaining_seconds = floor((remaining_deciseconds + 9) / 10)
	return remaining_seconds <= 0 ? 0 : remaining_seconds


/obj/machinery/ticket_machine/talon/examine(mob/user)
	// don't call base examine; talon shows its own messages
	var/ref = REF(user)
	var/player_remaining = get_remaining_cooldown_seconds(ref)
	var/global_remaining = get_remaining_global_cooldown_seconds()

	if(global_remaining > 0)
		. += span_notice("Автомат сможет выдать талон через [global_remaining] секунд.")
	if(player_remaining > 0)
		. += span_notice("Вам можно получить новый талон через [player_remaining] секунд.")
	else if(global_remaining == 0)
		. += span_notice("Вы можете взять талон сейчас.")


/// Disable emag interaction for talon machines
/obj/machinery/ticket_machine/talon/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE


/// Disable multitool interaction for talon machines
/obj/machinery/ticket_machine/talon/multitool_act(mob/living/user, obj/item/multitool/M)
	return NONE


/// Strike user and nearby mobs with chain lightning
/obj/machinery/ticket_machine/talon/proc/strike_with_chain_lightning(mob/living/user)
	if(!user)
		return
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return

	// Strike primary target
	Beam(user, icon_state = "purple_lightning", time = 0.5 SECONDS)
	if(!user.can_block_magic(MAGIC_RESISTANCE_HOLY))
		user.electrocute_act(20, src, flags = SHOCK_NOGLOVES)
		do_sparks(4, FALSE, user)
	playsound(user_turf, 'sound/machines/defib/defib_zap.ogg', 50, TRUE, -1)

	// Strike nearby mobs in radius 2
	for(var/mob/living/carbon/human/nearby_mob in view(2, user_turf))
		if(nearby_mob == user)
			continue
		Beam(nearby_mob, icon_state = "lightning5", time = 0.5 SECONDS)
		if(!nearby_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
			nearby_mob.electrocute_act(15, src, flags = SHOCK_NOGLOVES)
			do_sparks(3, FALSE, nearby_mob)
		playsound(nearby_mob, 'sound/machines/defib/defib_zap.ogg', 50, TRUE, -1)


/// Проверка и наказание за злоупотребление автоматом
/obj/machinery/ticket_machine/talon/proc/check_and_punish_abuse(mob/living/user)
	if(fails_counter > 5)
		playsound(src, 'modular_bandastation/events/avangarde17/audio/angry_communist_speach.ogg', 100, FALSE)
		var/chosen_frase = pick(not_ready_frases)
		say("[user.name]: [chosen_frase]")
		strike_with_chain_lightning(user)
		fails_counter = 0
		return TRUE
	return FALSE

/obj/machinery/ticket_machine/talon/increment()
	// Talon-specific increment: quietly accept current ticket and advance
	if(current_ticket)
		// remove current ticket from existence without audible alerts
		QDEL_NULL(current_ticket)
		tickets.Cut(1,2)
		say("Талон был принят.")
		current_ticket = null
	// advance to next if any
	if(LAZYLEN(tickets))
		current_ticket = tickets[1]
		current_number++
		update_appearance()

/obj/machinery/ticket_machine/talon/attack_hand(mob/living/carbon/user, list/modifiers)
	// Проверка запрещенных ролей
	if(user.mind && (user.mind.assigned_role in banned_roles))
		fails_counter++
		if(check_and_punish_abuse(user))
			return
		balloon_alert(user, "Ваша профессия не может получить талон.")
		return

	// check global cooldown first (machine limitation)
	var/global_remaining = get_remaining_global_cooldown_seconds()
	if(global_remaining > 0)
		fails_counter++
		if(check_and_punish_abuse(user))
			return
		balloon_alert(user, "Подождите [global_remaining] секунд перед получением нового талона.")
		return

	// per-player cooldown check
	var/user_ref = REF(user)
	var/player_remaining = get_remaining_cooldown_seconds(user_ref)
	if(player_remaining > 0)
		fails_counter++
		if(check_and_punish_abuse(user))
			return
		balloon_alert(user, "Вы должны подождать [player_remaining] секунд перед получением нового талона.")
		return

	// reproduce base attack_hand logic but issue talon-specific ticket that is not queued
	if(!ready)
		fails_counter = 0
		to_chat(user,span_warning("Вы нажали кнопку, но ничего не произошло..."))
		return
	if(ticket_number >= max_number)
		fails_counter = 0
		to_chat(user,span_warning("Запас талонов исчерпан, пожалуйста, пополните запас картриджем для ручного этикетировщика!"))
		return
	// create a talon ticket (not part of numbering queue)
	fails_counter = 0
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 100, FALSE)
	// consume supply number but do not add to tickets/ticket_holders
	//ticket_number++
	var/obj/item/ticket_machine_ticket/talon/theirticket = new /obj/item/ticket_machine_ticket/talon(get_turf(src))
	theirticket.source = src
	theirticket.owner_ref = user_ref
	user.put_in_hands(theirticket)
	// record last ticket time for this player and globally
	last_ticket_time[user_ref] = world.time
	last_global_ticket_time = world.time
	if(obj_flags & EMAGGED)
		ready = FALSE
		addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), cooldown)
		theirticket.fire_act()
		user.dropItemToGround(theirticket)
		user.adjust_fire_stacks(1)
		user.ignite_mob()
	update_appearance()
