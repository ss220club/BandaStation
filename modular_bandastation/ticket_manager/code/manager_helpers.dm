/datum/ticket_manager/proc/add_ticket_message(ticket_id, sender, message)
	if(!sender || !message)
		CRASH("Invalid parameters passed to ticket_manager add_ticket_message()!")

	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	needed_ticket.messages += list(list(
		"sender" = sender,
		"message" = message,
		"time" = time_stamp(NONE),
	))
	SStgui.update_uis(src)

/datum/ticket_manager/proc/set_ticket_state(var/client/admin, ticket_id, new_state)
	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	var/user_message
	var/admin_message
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
