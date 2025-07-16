/datum/ticket_manager/Topic(href, href_list)
	. = ..()
	var/client/user = usr.client
	var/datum/help_ticket/user_ticket = user.persistent_client.current_help_ticket
	if(!check_rights(R_ADMIN) && (!user_ticket || user_ticket.id != href_list["ticket_id"]))
		to_chat(user, "Вы не можете взаимодействовать с чужим тикетом!")
		log_admin("[key_name(user)] попытался взаимодействовать с тикетом #[href_list["open_ticket"]], который не является его. Возможен href эксплоит!")
		CRASH("Possible HREF exploit attempt by [key_name(user)]! Tried to interact with ticket #[href_list["open_ticket"]].")

	var/ticket_id = text2num(href_list["ticket_id"])
	if(href_list["open_ticket"])
		user.ticket_to_open = ticket_id
		ui_interact(user.mob)
		return

	if(href_list["response"])
		var/message = tgui_input_text(user, null, "Ответ на тикет #[ticket_id]", multiline = TRUE, encode = FALSE)
		if(!message)
			return

		add_ticket_message(ticket_id, user.key, message)
