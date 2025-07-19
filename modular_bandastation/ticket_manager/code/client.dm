/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/datum/persistent_client/var/datum/help_ticket/current_help_ticket
/// What ticket will be opened after opening ui
/client/var/ticket_to_open

/client/verb/ticket_manager()
	set name = "Ticket Manager"
	set desc = "Открыть интерфейс админ/ментор тикетов"
	set category = "Admin"

	GLOB.ticket_manager.ui_interact(mob)

/client/verb/ask_help()
	set name = "Ask Help"
	set category = "Admin"

	if(persistent_client.current_help_ticket)
		ticket_to_open = persistent_client.current_help_ticket.id
		GLOB.ticket_manager.ui_interact(mob)
		return

	GLOB.help_ui_handler.ui_interact(mob)

/client/cmd_admin_pm(whom, message)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, span_danger("Ошибка: Вы не можете использовать ЛС (мут)."), MESSAGE_TYPE_ADMINPM)
		return

	if(!holder)
		to_chat(src, span_danger("ТЫ НЕДОСТОИН!"), MESSAGE_TYPE_ADMINPM)
		log_admin("[key_name(src)] попытался написать в ЛС не имея админки!")
		stack_trace("[key_name(src)] tried to send an admin PM without a holder.")
		return

	var/client/subject
	if(istype(whom, /client))
		subject = whom
	else
		subject = disambiguate_client(whom)

	if(!subject || !istype(subject, /client))
		to_chat(src, span_danger("Клиент отключился пока вы писали сообщение..."), MESSAGE_TYPE_ADMINPM)
		return

	var/datum/help_ticket/subject_ticket = subject.persistent_client.current_help_ticket
	if(subject_ticket)
		ticket_to_open = subject_ticket.id
		GLOB.ticket_manager.ui_interact(mob)
		return

	var/message_to_send = tgui_input_text(src, "Введите сообщения для [subject.ckey]", "Личное сообщение", multiline = TRUE, encode = FALSE, ui_state = ADMIN_STATE(R_ADMIN))
	if(!message_to_send)
		return

	if(subject_ticket)
		to_chat(src, span_danger("Тикет уже открыт!"), MESSAGE_TYPE_ADMINPM)
		return

	new /datum/help_ticket(subject, src, message_to_send, TICKET_TYPE_ADMIN)
	subject_ticket = subject.persistent_client.current_help_ticket // update
	var/log_body = "[key_name(src)] написал личное сообщение [key_name_admin(whom)]."
	message_admins("[log_body] Создан тикет [TICKET_OPEN_LINK(subject_ticket.id, "#[subject_ticket.id]")].")
	log_admin(log_body)
