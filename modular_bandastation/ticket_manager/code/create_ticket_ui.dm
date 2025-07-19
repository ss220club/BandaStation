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

	var/client/user = usr.client
	var/ticket_message = sanitize(trim(params["message"], MAX_MESSAGE_LEN))
	if(!ticket_message)
		return

	var/ticket_type = params["ticketType"]
	if(ticket_type != TICKET_TYPE_ADMIN && ticket_type != TICKET_TYPE_MENTOR)
		CRASH("Invalid ticket type created by [user]. Ticket type: [ticket_type]")

	if(user.handle_spam_prevention(ticket_message, MUTE_ADMINHELP))
		return

	new /datum/help_ticket(user, message = ticket_message, new_type = ticket_type)
	ui.close()
