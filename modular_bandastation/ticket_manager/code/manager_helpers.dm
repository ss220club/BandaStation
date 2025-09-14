/// Checks if user can send message to ticket.
/datum/ticket_manager/proc/can_send_message(client/user, datum/help_ticket/user_ticket, datum/help_ticket/needed_ticket)
	if(user_ticket && (user_ticket.id != needed_ticket.id))
		to_chat(user, span_danger("Создатель этого тикета, уже имеет другой тикет, ответ в выбранный тикет невозможен!"), MESSAGE_TYPE_ADMINPM)
		return FALSE

	if(needed_ticket.state != TICKET_OPEN)
		to_chat(user, span_danger("Этот тикет уже закрыт! Создайте новый при необходимости."), MESSAGE_TYPE_ADMINPM)
		return FALSE

	if(!needed_ticket.admin_replied && !check_rights_for(user, R_ADMIN))
		to_chat(user, span_danger("На ваш тикет ещё не ответил ни один администратор! Ожидайте ответа."), MESSAGE_TYPE_ADMINPM)
		return FALSE

	if(!needed_ticket.linked_admin && !check_rights_for(user, R_ADMIN))
		to_chat(user, span_danger("У вашего тикета нет привязанного администратора! Ожидайте пока кто-то вам ответит."), MESSAGE_TYPE_ADMINPM)
		return FALSE

	if(!user.holder && !COOLDOWN_FINISHED(user, ticket_response))
		to_chat(user, span_danger("Слишком быстро! Разрешено писать 1 сообщение в [TICKET_REPLY_COOLDOWN / 1 SECONDS] секунд."), MESSAGE_TYPE_ADMINPM)
		return FALSE
	return TRUE

/// Link admin to ticket.
/datum/ticket_manager/proc/link_admin_to_ticket(client/admin, datum/help_ticket/needed_ticket)
	if(!admin || !needed_ticket)
		CRASH("Tried to link admin to ticket with invalid arguments!")

	if(!needed_ticket.linked_admin)
		needed_ticket.linked_admin = admin.persistent_client
		deltimer(needed_ticket.ticket_autoclose_timer_id)
		message_admins("[key_name_admin(admin)] взял тикет #[needed_ticket.id] на рассмотрение.")
		log_admin("[key_name_admin(admin)] взял тикет #[needed_ticket.id] на рассмотрение.")

/datum/ticket_manager/proc/unlink_admin_from_ticket(client/admin, datum/help_ticket/needed_ticket)
	if(!admin || !needed_ticket)
		CRASH("Tried to unlink admin from ticket with invalid arguments!")

	if(!needed_ticket.linked_admin)
		message_admins("[key_name_admin(admin)] попытался отказался от тикета #[needed_ticket.id], к которому не привязан администратор.")
		CRASH("Tried to unlink admin from ticket without linked admin!")

	if(!admin.holder)
		message_admins("[key_name_admin(admin)] попытался отказался от тикета #[needed_ticket.id], не имея прав администратора!")
		CRASH("Tried to unlink admin from ticket without a required rights!")

	var/autoclose_delay = TICKET_AUTOCLOSE_TIMER / 2
	needed_ticket.linked_admin = null
	needed_ticket.ticket_autoclose_timer_id = addtimer(CALLBACK(src, PROC_REF(autoclose_ticket), needed_ticket), autoclose_delay, TIMER_STOPPABLE)
	to_chat(GLOB.admins, span_admin("[key_name_admin(admin)] отказался от тикета [TICKET_OPEN_LINK(needed_ticket.id, "#[needed_ticket.id]")]."), MESSAGE_TYPE_ADMINPM)
	log_admin("[key_name_admin(admin)] отказался от тикета #[needed_ticket.id].")
	SStgui.update_uis(src)

	var/client/initiator = needed_ticket.initiator_client.client
	if(!initiator)
		return

	to_chat(initiator,
		custom_boxed_message("green_box", span_adminhelp("[admin.key] отказался от вашего тикета. Ожидайте другого администратора. Если никто не ответит на ваш тикет, он автоматически закроется через [autoclose_delay / 1 SECONDS] секунд.")),
		MESSAGE_TYPE_ADMINPM)

/// Adds user to ticket writers when he starts typing. Used for type indicator in ticket chat UI
/datum/ticket_manager/proc/add_to_ticket_writers(client/writer, datum/help_ticket/needed_ticket, update_ui = TRUE)
	if(!writer || !needed_ticket)
		CRASH("Tried to add writer to ticket with invalid arguments!")

	if(writer.holder && !needed_ticket.linked_admin)
		message_admins("[key_name_admin(writer)] начал отвечать на тикет #[needed_ticket.id].")
		log_admin("[key_name_admin(writer)] начал отвечать на тикет #[needed_ticket.id].")

	needed_ticket.writers |= writer.key
	if(update_ui)
		SStgui.update_uis(src)

/// Removes user from ticket writers when he stops typing or sends message. Used for type indicator in ticket chat UI
/datum/ticket_manager/proc/remove_from_ticket_writers(client/writer, datum/help_ticket/needed_ticket, update_ui = TRUE)
	if(!writer || !needed_ticket)
		CRASH("Tried to remove writer to ticket with invalid arguments!")

	if(writer.holder && !needed_ticket.linked_admin)
		message_admins("[key_name_admin(writer)] перестал отвечать на тикет #[needed_ticket.id].")
		log_admin("[key_name_admin(writer)] перестал отвечать на тикет #[needed_ticket.id].")

	needed_ticket.writers -= writer.key
	if(update_ui)
		SStgui.update_uis(src)

/// Adds message to ticket. Allows HTML tags from both sides and parses emoji
/// Will send chat message about new ticket message to admin, if reply from ticket initiator
/// and message to player if replies someone from admins
/datum/ticket_manager/proc/add_ticket_message(client/sender, datum/help_ticket/needed_ticket, message)
	if(!sender || !message || !needed_ticket)
		CRASH("Invalid arguments passed to ticket_manager add_ticket_message()!")

	if(sender.holder)
		link_admin_to_ticket(sender, needed_ticket)
	else
		COOLDOWN_START(sender, ticket_response, TICKET_REPLY_COOLDOWN)

	var/client/initiator = needed_ticket.initiator_client.client
	if(sender.key != initiator.key && !needed_ticket.admin_replied)
		needed_ticket.admin_replied = TRUE

	if(sender == initiator)
		send_chat_message_to_admin(sender, needed_ticket, message)
	else
		send_chat_message_to_player(sender, needed_ticket, message)

	remove_from_ticket_writers(sender, needed_ticket, FALSE)
	needed_ticket.messages += list(list(
		"sender" = sender.key,
		"message" = emoji_parse(message),
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)

/// Changes ticket state. Allowed new states: TICKET_OPEN, TICKET_CLOSED, TICKET_RESOLVED
/datum/ticket_manager/proc/set_ticket_state(client/admin, datum/help_ticket/needed_ticket, new_state)
	if(!needed_ticket || isnull(new_state))
		CRASH("Invalid parameters passed to ticket_manager set_ticket_state()!")

	var/user_message
	var/admin_message
	var/ticket_id = needed_ticket.id
	var/ticket_closed = new_state == TICKET_CLOSED
	var/datum/persistent_client/initiator = needed_ticket.initiator_client

	if(new_state != TICKET_OPEN)
		if(initiator.current_help_ticket != needed_ticket)
			CRASH("Ticket with id [ticket_id] is not the current help ticket for [initiator.ckey]!")

		needed_ticket.closed_at = time_stamp(NONE)
		initiator.current_help_ticket = null

		var/blackbox_action = ticket_closed ? "Closed" : "Resolved"
		if(!admin)
			admin_message = "Тикет #[ticket_id] был автоматически закрыт!"
			user_message = "Ваш тикет был автоматически закрыт! Вы можете создать новый если вам всё ещё нужна помощь."
			SSblackbox.LogAhelp(ticket_id, blackbox_action, "[blackbox_action] automatically", null, "TicketManager")
		else
			admin_message = "[key_name_admin(admin)] [ticket_closed ? "закрыл" : "решил"] тикет #[ticket_id]!"
			user_message = "Ваш тикет #[ticket_id] был [ticket_closed ? "закрыт" : "решён"]!"
			SSblackbox.LogAhelp(ticket_id, blackbox_action, "[blackbox_action] by [admin.key]", null, admin.key)

		SEND_SIGNAL(needed_ticket, COMSIG_ADMIN_HELP_MADE_INACTIVE)
	else
		if(initiator.current_help_ticket)
			if(admin)
				to_chat(admin, span_danger("[key_name(initiator.ckey)] уже имеет открытый тикет!"), MESSAGE_TYPE_ADMINPM)
			return

		if(needed_ticket.ticket_autoclose_timer_id)
			deltimer(needed_ticket.ticket_autoclose_timer_id)

		initiator.current_help_ticket = needed_ticket
		needed_ticket.closed_at = null
		user_message = "Ваш тикет #[ticket_id] был снова открыт! Проверьте Тикет Менеджер нажав F1!"

		if(admin)
			admin_message = span_admin("[key_name_admin(admin)] открыл тикет #[ticket_id]!")
			SSblackbox.LogAhelp(ticket_id, "Reopened", "Reopened by [admin.key]", admin.key)

	needed_ticket.state = new_state
	SStgui.update_uis(src)

	if(initiator.client)
		to_chat(initiator.client, custom_boxed_message("red_box", "[user_message]"), MESSAGE_TYPE_ADMINPM)
	message_admins(span_admin(admin_message))
	log_admin_private(admin_message)
	internal_admin_ticket_log(needed_ticket, admin_message)

/datum/ticket_manager/proc/autoclose_ticket(datum/help_ticket/needed_ticket)
	if(!needed_ticket)
		CRASH("Tried to autoclose null ticket!")

	set_ticket_state(null, needed_ticket, TICKET_CLOSED)

/* NEEDED MENTOR SYSTEM
/datum/ticket_manager/proc/convert_ticket(ticket_id)
	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	switch(needed_ticket.ticket_type)
		if(TICKET_TYPE_ADMIN)
			needed_ticket.ticket_type = TICKET_TYPE_MENTOR
		if(TICKET_TYPE_MENTOR)
			needed_ticket.ticket_type = TICKET_TYPE_ADMIN

	SStgui.update_uis(src)
*/

/// Adds little notification to ticket chat about player disconnect
/datum/ticket_manager/proc/client_logout(datum/persistent_client/p_client)
	var/datum/help_ticket/needed_ticket = p_client.current_help_ticket
	if(!needed_ticket)
		return

	var/client/user = p_client.client
	if(!user)
		return

	remove_from_ticket_writers(user, needed_ticket, FALSE)
	needed_ticket.messages += list(list(
		"sender" = "CLIENT_DISCONNECTED",
		"message" = "[user.key] отключился",
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)
	// Gotta async this cause clients only logout on destroy, and sleeping in destroy is disgusting
	INVOKE_ASYNC(SSblackbox, TYPE_PROC_REF(/datum/controller/subsystem/blackbox, LogAhelp), needed_ticket.id, "Disconnected", "Client disconnected", user.key)

/// Adds little notification to ticket chat about player reconnect
/datum/ticket_manager/proc/client_login(datum/persistent_client/p_client)
	var/datum/help_ticket/needed_ticket = p_client.current_help_ticket
	if(!needed_ticket)
		return

	var/client/user = p_client.client
	if(!user)
		return

	needed_ticket.messages += list(list(
		"sender" = "CLIENT_CONNECTED",
		"message" = "[user.key] подключился",
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)
	SSblackbox.LogAhelp(needed_ticket.id, "Reconnected", "Client reconnected", user.key)

/// Send admin ticket reply to player, if he's online. And make some logs for other admins
/datum/ticket_manager/proc/send_chat_message_to_player(client/admin, datum/help_ticket/needed_ticket, raw_message)
	var/message = emoji_parse(raw_message)
	var/id = needed_ticket.id
	var/is_pm = needed_ticket.ticket_type_hidden == TICKET_TYPE_HIDDEN_PM
	var/title = span_adminhelp("Ответ на тикет #[id]")
	if(is_pm)
		title = span_adminhelp("Личное сообщение от администратора")

	var/client/player = needed_ticket.initiator_client.client
	var/admin_key = key_name(admin, TRUE, FALSE)
	var/player_key = needed_ticket.initiator_client.ckey
	if(player)
		player_key = key_name(player, TRUE, FALSE)
		SEND_SOUND(player, sound('sound/effects/adminhelp.ogg'))
		window_flash(player, ignorepref = TRUE)
		to_chat(player, fieldset_block(
			title, "[TICKET_REPLY_LINK(id, admin.key)]\n\n\
			[span_adminsay(message)]\n\n\
			[span_adminsay("Нажмите на ник, чтобы ответить. Либо [TICKET_OPEN_LINK(id, "откройте чат")].")]",
			"boxed_message red_box"),
			MESSAGE_TYPE_ADMINPM)

	var/log_prefix = "[is_pm ? "PM" : "Ticket #[id]"]: [admin_key] → [player_key]:"
	var/log_message = "[message]"
	to_chat(GLOB.admins, span_notice("[span_bold(log_prefix)] [log_message]"), MESSAGE_TYPE_ADMINPM)
	log_admin_private("[log_prefix] [log_message]")
	SSblackbox.LogAhelp(id, "Reply", message, player_key, admin_key)

/// Send player ticket reply to admin, if he's online. And make some logs for other admins
/datum/ticket_manager/proc/send_chat_message_to_admin(client/player, datum/help_ticket/needed_ticket, raw_message)
	var/message = emoji_parse(sanitize(trim(raw_message)))
	if(!message)
		return

	var/id = needed_ticket.id
	var/is_pm = needed_ticket.ticket_type_hidden == TICKET_TYPE_HIDDEN_PM
	var/title = span_adminhelp("Ответ на тикет #[id]")
	if(is_pm)
		title = span_adminhelp("Ответ на личное сообщение")

	var/client/admin = needed_ticket.linked_admin.client
	var/admin_key = needed_ticket.linked_admin.ckey
	var/player_key = key_name(player, TRUE, FALSE)
	if(admin)
		admin_key = key_name(admin, TRUE, FALSE)
		if(admin.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(admin, sound('sound/effects/adminhelp.ogg'))
		window_flash(admin, ignorepref = TRUE)
		to_chat(admin, fieldset_block(
			title, "[TICKET_REPLY_LINK(id, player.key)]\n\n\
			[span_adminsay(message)]\n\n\
			[TICKET_FULLMONTY(player.mob, id)]",
			"boxed_message red_box"),
			MESSAGE_TYPE_ADMINPM)

	var/log_prefix = "[is_pm ? "PM" : "Ticket #[id]"]: [player_key] → [admin_key]:"
	var/log_message = "[message]"
	for(var/client/A in GLOB.admins)
		if(A.key == admin.key)
			continue
		to_chat(A, span_notice("[span_bold(log_prefix)] [log_message]"), MESSAGE_TYPE_ADMINPM)

	log_admin_private("[log_prefix] [log_message]")
	SEND_SIGNAL(needed_ticket, COMSIG_ADMIN_HELP_REPLIED)
	SSblackbox.LogAhelp(id, "Reply", message, admin_key, player_key)

/// Checking existing user ticket, and send message to it IF stuff writed something
/datum/ticket_manager/proc/open_existing_ticket(client/stuff, client/ticket_holder, message)
	if(!ticket_holder)
		to_chat(stuff, span_danger("Кажется клиент покинул сервер..."), MESSAGE_TYPE_ADMINPM)
		return TRUE

	var/datum/help_ticket/subject_ticket = ticket_holder.persistent_client.current_help_ticket
	if(subject_ticket)
		if(message)
			add_ticket_message(stuff, subject_ticket, message)

		stuff.ticket_to_open = subject_ticket.id
		ui_interact(stuff.mob)
		return TRUE
	return FALSE

/// Logging any actions on ticket initiator mob/client, and sending it to ticket chat
/// Stripped all html tags, so we got only text
/proc/admin_ticket_log(thing, message, player_message, log_in_blackbox)
	var/client/user_client
	var/mob/user = thing
	if(istype(user))
		user_client = user.client
	else
		user_client = thing

	if(!user_client)
		return

	var/datum/help_ticket/user_ticket = user_client.persistent_client.current_help_ticket
	if(!user_ticket)
		return

	user_ticket.messages += list(list(
		"sender" = "ADMIN_TICKET_LOG",
		"message" = strip_html_full(message),
		"time" = time_stamp(NONE),
	))

	SStgui.update_uis(GLOB.ticket_manager)

/// Logging internal ticket actions. Requires only ticket datum and message
/proc/internal_admin_ticket_log(datum/help_ticket/ticket, message)
	if(!ticket || !message)
		return

	ticket.messages += list(list(
		"sender" = "ADMIN_TICKET_LOG",
		"message" = strip_html_full(message),
		"time" = time_stamp(NONE),
	))

	SStgui.update_uis(GLOB.ticket_manager)
