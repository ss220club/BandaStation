GLOBAL_DATUM_INIT(help_ui_handler, /datum/help_ui_handler, new)

/client/verb/ask_help()
	set name = "Ask Help"
	set category = "Admin"

	/* Раскомментить после тестов
	if(help_timer_id)
		to_chat(src, span_danger("У вас уже имеется открытый тикет!"))
		return
	*/
	GLOB.help_ui_handler.ui_interact(mob)

/datum/help_ui_handler

/datum/help_ui_handler/ui_interact(mob/user, datum/tgui/ui)
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
	var/message = sanitize_text(trim(params["message"]))
	var/ticket_type = params["ticketType"]
	if(ticket_type != TICKET_TYPE_ADMIN && ticket_type != TICKET_TYPE_MENTOR)
		CRASH("Invalid ticket type created by [user]. Ticket type: [ticket_type]")

	perform_adminhelp(user, message, ticket_type)
	ui.close()

/datum/help_ui_handler/proc/perform_adminhelp(client/user, message, ticket_type)
	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(user, span_danger("Общение было заблокировано администрацией."), confidential = TRUE)
		return

	if(!message)
		return

	if(user.prefs.muted & MUTE_ADMINHELP)
		to_chat(user, span_danger("Ошибка: Вы не можете создавать тикеты (Заглушен)."), confidential = TRUE)
		return

	if(user.handle_spam_prevention(message, MUTE_ADMINHELP))
		return

	if(user.current_help_ticket)
		user.current_help_ticket.timeout_verb()
		return

	new /datum/help_ticket(user, message, ticket_type)
	SStgui.update_uis(GLOB.ticket_manager)
