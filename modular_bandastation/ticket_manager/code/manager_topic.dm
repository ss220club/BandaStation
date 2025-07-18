/datum/ticket_manager/Topic(href, href_list)
	. = ..()
	var/ticket_id = text2num(href_list["ticket_id"])
	if(!ticket_id)
		return

	var/client/user = usr.client
	var/datum/help_ticket/user_ticket = user.persistent_client.current_help_ticket
	if(!check_rights_for(user, R_ADMIN) && (!user_ticket || user_ticket.id != ticket_id))
		to_chat(user, "Вы не можете взаимодействовать с этим тикетом!")
		message_admins("[key_name(user)] попытался взаимодействовать с тикетом #[href_list["open_ticket"]], который не является его. Возможен href эксплоит!")
		CRASH("Possible HREF exploit attempt by [key_name(user)]! Tried to interact with ticket #[href_list["open_ticket"]].")

	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		return

	if(href_list["open_ticket"])
		user.ticket_to_open = ticket_id
		ui_interact(user.mob)
		return

	if(href_list["reply_ticket"])
		if(!can_send_message(user, user_ticket, needed_ticket))
			return

		if(user.key in needed_ticket.writers)
			return // Already typing

		add_to_ticket_writers(user, needed_ticket)
		var/message = tgui_input_text(user, null, "Ответ на тикет #[ticket_id]", multiline = TRUE, encode = FALSE)
		if(!message)
			remove_from_ticket_writers(user, needed_ticket)
			return

		add_ticket_message(user, needed_ticket, message)
		return

	// Admin/Mentor only
	if(!check_rights_for(user, R_ADMIN))
		return

	if(needed_ticket.state != TICKET_OPEN)
		to_chat(user, span_danger("Тикет уже закрыт или решён!"))
		return

	if(href_list["resolve_ticket"])
		set_ticket_state(user, needed_ticket, TICKET_RESOLVED)
		return

	if(href_list["close_ticket"])
		set_ticket_state(user, needed_ticket, TICKET_CLOSED)
		return
