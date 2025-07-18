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
	return TRUE

/datum/ticket_manager/proc/link_admin_to_ticket(client/admin, datum/help_ticket/needed_ticket)
	if(!admin || !needed_ticket)
		CRASH("Tryed to link admin to ticket with invalid arguments!")

	if(!needed_ticket.linked_admin && check_rights_for(admin, R_ADMIN))
		needed_ticket.linked_admin = admin.persistent_client
		message_admins("[key_name_admin(admin)] взял тикет #[needed_ticket.id] на рассмотрение.")
		log_admin("[key_name_admin(admin)] взял тикет #[needed_ticket.id] на рассмотрение.")

/datum/ticket_manager/proc/unlink_admin_from_ticket(client/admin, datum/help_ticket/needed_ticket)
	if(!admin || !needed_ticket)
		CRASH("Tryed to unlink admin from ticket with invalid arguments!")

	if(needed_ticket.linked_admin && check_rights_for(admin, R_ADMIN))
		needed_ticket.linked_admin = null
		message_admins("[key_name_admin(admin)] отказался от тикета #[needed_ticket.id].")
		log_admin("[key_name_admin(admin)] отказался от тикета #[needed_ticket.id].")

		to_chat(needed_ticket.initiator_client.client,
			custom_boxed_message("green_box", span_adminhelp("[admin.key] отказался от вашего тикета. Ожидайте другого администратора.")),
			MESSAGE_TYPE_ADMINPM)
		SStgui.update_uis(src)

/datum/ticket_manager/proc/add_to_ticket_writers(client/writer, datum/help_ticket/needed_ticket, update_ui = TRUE)
	if(!writer || !needed_ticket)
		CRASH("Tryed to add writer to ticket with invalid arguments!")

	if(writer.holder && !needed_ticket.linked_admin)
		message_admins("[key_name_admin(writer)] начал отвечать на тикет #[needed_ticket.id].")
		log_admin("[key_name_admin(writer)] начал отвечать на тикет #[needed_ticket.id].")

	needed_ticket.writers |= writer.key
	if(update_ui)
		SStgui.update_uis(src)

/datum/ticket_manager/proc/remove_from_ticket_writers(client/writer, datum/help_ticket/needed_ticket, update_ui = TRUE)
	if(!writer || !needed_ticket)
		CRASH("Tryed to remove writer to ticket with invalid arguments!")

	if(writer.holder && !needed_ticket.linked_admin)
		message_admins("[key_name_admin(writer)] перестал отвечать на тикет #[needed_ticket.id].")
		log_admin("[key_name_admin(writer)] перестал отвечать на тикет #[needed_ticket.id].")

	needed_ticket.writers -= writer.key
	if(update_ui)
		SStgui.update_uis(src)

/datum/ticket_manager/proc/add_ticket_message(client/sender, datum/help_ticket/needed_ticket, message)
	if(!sender || !message || !needed_ticket)
		CRASH("Invalid parameters passed to ticket_manager add_ticket_message()!")

	link_admin_to_ticket(sender, needed_ticket)

	var/client/initiator = needed_ticket.initiator_client.client
	var/client/linked_admin = needed_ticket.linked_admin.client
	if(sender.key != initiator.key && !needed_ticket.admin_replied)
		needed_ticket.admin_replied = TRUE

	if(sender == initiator || sender != linked_admin)
		send_chat_message_to_admin(initiator, needed_ticket, message)
	else
		send_chat_message_to_player(sender, needed_ticket, message)

	remove_from_ticket_writers(sender, needed_ticket, FALSE)
	needed_ticket.messages += list(list(
		"sender" = sender.key,
		"message" = message,
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)

/datum/ticket_manager/proc/set_ticket_state(client/admin, datum/help_ticket/needed_ticket, new_state)
	if(!admin || !needed_ticket || isnull(new_state))
		CRASH("Invalid parameters passed to ticket_manager set_ticket_state()!")

	var/user_message
	var/admin_message
	var/ticket_id = needed_ticket.id
	var/datum/persistent_client/initiator = needed_ticket.initiator_client
	if(new_state != TICKET_OPEN)
		if(initiator.current_help_ticket != needed_ticket)
			CRASH("Ticket with id [ticket_id] is not the current help ticket for [initiator.ckey]!")

		needed_ticket.closed_at = time_stamp(NONE)
		initiator.current_help_ticket = null
		admin_message = "[key_name_admin(admin)] [new_state == TICKET_CLOSED ? "закрыл" : "решил"] тикет #[ticket_id]!"
		user_message = "Ваш тикет #[ticket_id] был [new_state == TICKET_CLOSED ? "закрыт" : "решён"]!"
		SEND_SIGNAL(needed_ticket, COMSIG_ADMIN_HELP_MADE_INACTIVE)
	else
		if(initiator.current_help_ticket)
			to_chat(admin, span_danger("[key_name(initiator.ckey)] уже имеет открытый тикет!"), MESSAGE_TYPE_ADMINPM)
			return

		initiator.current_help_ticket = needed_ticket
		needed_ticket.closed_at = null
		admin_message = span_admin("[key_name_admin(admin)] открыл тикет #[ticket_id]!")
		user_message = "Ваш тикет #[ticket_id] был снова открыт! Проверьте Тикет Менеджер нажав F1!"

	needed_ticket.state = new_state
	SStgui.update_uis(src)

	if(initiator.client)
		to_chat(initiator.client, custom_boxed_message("green_box", "[user_message]"), MESSAGE_TYPE_ADMINPM)
	message_admins(span_admin(admin_message))
	log_admin_private(span_admin(admin_message))

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

/datum/ticket_manager/proc/client_logout(client/user)
	var/datum/help_ticket/needed_ticket = user.persistent_client.current_help_ticket
	if(!needed_ticket)
		return

	remove_from_ticket_writers(user, needed_ticket, FALSE)
	needed_ticket.messages += list(list(
		"sender" = "CLIENT_DISCONNECTED",
		"message" = "[user.key] отключился",
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)

/datum/ticket_manager/proc/client_login(client/user)
	var/datum/help_ticket/needed_ticket = user.persistent_client.current_help_ticket
	if(!needed_ticket)
		return

	needed_ticket.messages += list(list(
		"sender" = "CLIENT_CONNECTED",
		"message" = "[user.key] подключился",
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)

/// Send admin ticket reply to player, if he's online
/datum/ticket_manager/proc/send_chat_message_to_player(client/admin, datum/help_ticket/needed_ticket, message)
	var/id = needed_ticket.id
	var/title = span_adminhelp("Ответ на тикет #[id]")
	if(needed_ticket.ticket_type_hidden == TICKET_TYPE_HIDDEN_PM)
		title = span_adminhelp("Личное сообщение от администратора")

	var/client/player = needed_ticket.initiator_client.client
	if(player)
		SEND_SOUND(player, sound('sound/effects/adminhelp.ogg'))
		window_flash(player, ignorepref = TRUE)
		to_chat(player, fieldset_block(
			title, "[TICKET_REPLY_LINK(id, span_adminsay(admin.key))]\n\n\
			[span_adminsay(message)]\n\n\
			[span_adminsay("Нажмите на ник, чтобы ответить. Либо [TICKET_OPEN_LINK(id, "откройте чат")].")]",
			"boxed_message red_box"),
			MESSAGE_TYPE_ADMINPM)

/// Send player ticket reply to admin, if he's online
/datum/ticket_manager/proc/send_chat_message_to_admin(client/player, datum/help_ticket/needed_ticket, message)
	var/id = needed_ticket.id
	var/title = span_adminhelp("Ответ на тикет #[id]")
	if(needed_ticket.ticket_type_hidden == TICKET_TYPE_HIDDEN_PM)
		title = span_adminhelp("Ответ на личное сообщение")

	SEND_SIGNAL(needed_ticket, COMSIG_ADMIN_HELP_REPLIED)
	var/client/admin = needed_ticket.linked_admin.client
	if(admin)
		if(admin.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(admin, sound('sound/effects/adminhelp.ogg'))
		window_flash(admin, ignorepref = TRUE)
		to_chat(admin, fieldset_block(
			title, "[TICKET_REPLY_LINK(id, span_adminsay(player.key))]\n\n\
			[span_adminsay(message)]\n\n\
			[TICKET_FULLMONTY(player.mob, id)]",
			"boxed_message red_box"),
			MESSAGE_TYPE_ADMINPM)
