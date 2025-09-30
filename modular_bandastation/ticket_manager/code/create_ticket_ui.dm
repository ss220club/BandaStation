GLOBAL_DATUM_INIT(help_ui_handler, /datum/help_ui_handler, new)

/datum/help_ui_handler

/datum/help_ui_handler/ui_interact(mob/user, datum/tgui/ui)
	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(user, span_danger("Общение было заблокировано администрацией."), confidential = TRUE)
		return

	if(user.client.prefs.muted & MUTE_ADMINHELP)
		to_chat(user, span_danger("Ошибка: Вы не можете создавать тикеты (Заглушен)."), confidential = TRUE)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketCreation")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/help_ui_handler/ui_state(mob/user)
	return GLOB.always_state

/datum/help_ui_handler/ui_data(mob/user)
	var/list/data = list()
	data["adminCount"] = length(GLOB.admins)
	return data

/datum/help_ui_handler/ui_static_data(mob/user)
	var/list/data = list()
	data["maxMessageLength"] = MAX_MESSAGE_LEN
	data["ticketTypes"] = list(
		list("name" = "Админ", "type" = TICKET_TYPE_ADMIN),
		list("name" = "Ментор", "type" = TICKET_TYPE_MENTOR),
	)
	return data

/datum/help_ui_handler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_ticket")
			var/ticket_message = sanitize(trim(params["message"], MAX_MESSAGE_LEN))
			if(!ticket_message)
				return FALSE

			var/client/user_client = ui.user.client
			var/ticket_type = params["ticketType"]
			if(ticket_type != TICKET_TYPE_ADMIN && ticket_type != TICKET_TYPE_MENTOR)
				CRASH("Invalid ticket type created by [user_client]. Ticket type: [ticket_type]")

			if(!isnull(user_client.persistent_client.current_help_ticket))
				var/active_ticket_id = user_client.persistent_client.current_help_ticket.id
				to_chat(
					user_client,
					custom_boxed_message("red_box", "У вас уже есть [TICKET_OPEN_LINK(active_ticket_id, "активный тикет #[active_ticket_id]")]"),
					MESSAGE_TYPE_ADMINPM
				)
			else
				if(user_client.handle_spam_prevention(ticket_message, MUTE_ADMINHELP))
					return FALSE

				new /datum/help_ticket(user_client, message = ticket_message, new_type = ticket_type)

			ui.close()
