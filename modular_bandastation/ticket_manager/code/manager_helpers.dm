/datum/ticket_manager/proc/can_send_message(client/user, datum/help_ticket/user_ticket, datum/help_ticket/needed_ticket)
	if(user_ticket && (user_ticket.id != needed_ticket.id))
		to_chat(user, span_danger("Создатель этого тикета, уже имеет другой тикет, ответ в выбранный тикет невозможен!"))
		return FALSE

	if(needed_ticket.state != TICKET_OPEN)
		to_chat(user, span_danger("Этот тикет уже закрыт! Создайте новый при необходимости."))
		return FALSE

	if((!needed_ticket.admin_replied || !needed_ticket.linked_admin) && !check_rights_for(user, R_ADMIN))
		to_chat(user, span_danger("На ваш тикет ещё не ответил ни один администратор! Ожидайте ответа."))
		return FALSE
	return TRUE

/datum/ticket_manager/proc/link_admin_to_ticket(client/admin, datum/help_ticket/needed_ticket)
	if(!admin || !needed_ticket)
		CRASH("Tryed to link admin to ticket with invalid arguments!")

	if(!needed_ticket.linked_admin && check_rights_for(admin, R_ADMIN))
		needed_ticket.linked_admin = admin.persistent_client

/datum/ticket_manager/proc/add_ticket_message(client/sender, datum/help_ticket/needed_ticket, message)
	if(!sender || !message || !needed_ticket)
		CRASH("Invalid parameters passed to ticket_manager add_ticket_message()!")

	var/client/admin = needed_ticket.linked_admin.client
	if(admin.key == sender.key && !needed_ticket.admin_replied)
		needed_ticket.admin_replied = TRUE

	send_chat_message(admin, needed_ticket, message)
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

/datum/ticket_manager/proc/send_chat_message(client/admin, datum/help_ticket/needed_ticket, message)
	var/id = needed_ticket.id
	var/client/initiator = needed_ticket.initiator_client.client
	if(initiator)
		window_flash(initiator, ignorepref = TRUE)
		SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))
		to_chat(initiator, fieldset_block(
			span_adminhelp("Ответ на тикет [TICKET_OPEN_LINK(id, "#[id]")]"),
			"[TICKET_REPLY_LINK(id, span_bold(admin.key))]\n\n\
			[message]\n\n\
			[span_adminhelp("Нажмите на ник, чтобы ответить. Либо [TICKET_REPLY_LINK(id, "откройте чат")].")]",
			"boxed_message red_box"),
			MESSAGE_TYPE_ADMINPM)

	to_chat(admin, fieldset_block(
			span_adminhelp("Ответ на тикет [TICKET_OPEN_LINK(id, "#[id]")]"),
			"[TICKET_REPLY_LINK(id, span_bold(admin.key))]\n\n\
			[message]\n\n\
			[TICKET_FULLMONTY(initiator.mob, id)]",
			"boxed_message red_box"),
			MESSAGE_TYPE_ADMINPM)

/// Notifies the player about new admin pm ticket.
/datum/ticket_manager/proc/send_message_pm(client/receiver, client/admin, message, ticket_type)
	var/ticket_id = receiver.persistent_client.current_help_ticket.id
	var/ready_message = fieldset_block(
		span_adminhelp("Приватное сообщение от администратора"),
		"[TICKET_REPLY_LINK(ticket_id, span_bold(admin.key))]\n[message]\n\n\
		[span_adminhelp("Нажмите на ник, чтобы ответить. Либо [TICKET_REPLY_LINK(ticket_id, "откройте чат")].")]",
		"boxed_message red_box")
	window_flash(receiver, ignorepref = TRUE)
	SEND_SOUND(receiver, sound('sound/effects/adminhelp.ogg'))
	to_chat(receiver, ready_message, MESSAGE_TYPE_ADMINPM)
