/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/datum/persistent_client/var/datum/help_ticket/current_help_ticket

/client
	/// What ticket will be opened after opening ui
	var/ticket_to_open
	/// Cooldown for player ticket response
	COOLDOWN_DECLARE(ticket_response)

/client/verb/ticket_manager()
	set name = "Ticket Manager"
	set desc = "Открыть интерфейс админ/ментор тикетов"
	set category = "Admin"

	GLOB.ticket_manager.ui_interact(mob)

/client/cmd_admin_pm(whom, message)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, span_danger("Ошибка: Вы не можете использовать ЛС (мут)."), MESSAGE_TYPE_ADMINPM)
		return

	if(!holder)
		to_chat(src, span_danger("ТЫ НЕДОСТОИН!"), MESSAGE_TYPE_ADMINPM)
		log_admin("[key_name(src)] попытался написать в ЛС не имея админки!")
		stack_trace("[key_name(src)] tried to send an admin PM without a holder.")
		return

	var/client/subject = disambiguate_client(whom)
	if(!istype(subject))
		return

	if(GLOB.ticket_manager.open_existing_ticket(src, subject))
		return

	var/message_to_send = tgui_input_text(src, "Введите сообщения для [subject.ckey]", "Личное сообщение", multiline = TRUE, encode = FALSE, ui_state = ADMIN_STATE(R_ADMIN))
	if(!message_to_send)
		return

	// Double check if user created a ticket during PM writing
	if(GLOB.ticket_manager.open_existing_ticket(src, subject, message_to_send))
		return

	var/datum/help_ticket/subject_ticket = new(subject, src, message_to_send, TICKET_TYPE_ADMIN)
	var/log_body = "[key_name(src)] написал личное сообщение [key_name_admin(whom)]."
	message_admins("[log_body] Создан тикет [TICKET_OPEN_LINK(subject_ticket.id, "#[subject_ticket.id]")].")
	log_admin(log_body)
