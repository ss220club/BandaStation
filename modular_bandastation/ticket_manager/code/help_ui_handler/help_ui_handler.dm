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
	data["adminCount"] = get_admins_count_by_ticket_type()
	return data

/datum/help_ui_handler/proc/get_admins_count_by_ticket_type()
	var/list/count_by_ticket_type = list()
	for(var/key,value in GLOB.help_ticket_types)
		var/datum/help_ticket_type/type = value
		for(var/client/admin as anything in GLOB.admins)
			if(!check_rights_for(admin, type.required_permissions))
				continue

			count_by_ticket_type[key] += 1

	return count_by_ticket_type

/datum/help_ui_handler/ui_static_data(mob/user)
	var/list/data = list()
	data["maxMessageLength"] = MAX_MESSAGE_LEN

	var/list/ticket_types = list()
	for(var/key,value in GLOB.help_ticket_types)
		var/datum/help_ticket_type/type = value

		var/list/ticket_type_data = list()
		ticket_type_data["id"] = type.id
		ticket_type_data["name"] = type.name
		UNTYPED_LIST_ADD(ticket_types, ticket_type_data)

	data["ticketTypes"] = ticket_types

	return data

/datum/help_ui_handler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_ticket")
			var/ticket_message = sanitize(trim(params["message"], MAX_MESSAGE_LEN))
			if(!ticket_message)
				return

			var/client/user_client = ui.user.client
			var/ticket_type = params["ticketType"]
			if(isnull(ticket_type) || !GLOB.help_ticket_types[ticket_type])
				CRASH("Invalid ticket type created by [user_client]. Ticket type: [ticket_type]")

			if(user_client.handle_spam_prevention(ticket_message, MUTE_ADMINHELP))
				return

			new /datum/help_ticket(creator = user_client, message = ticket_message, ticket_type_id = ticket_type)
			ui.close()
