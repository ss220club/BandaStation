/obj/item/ticket_machine_ticket/talon
	name = "талон на услугу"
	desc = "Талон, который печатает автомат с талонами. Вы можете обменять его на один товар."
	icon_state = "paperslip_words"

/obj/machinery/ticket_machine/talon
	name = "Талонный автомат"
	desc = "Автомат для выдачи талонов на различные услуги."
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
