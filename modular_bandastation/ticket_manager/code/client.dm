/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/datum/persistent_client/var/datum/help_ticket/current_help_ticket

/client
	/// What ticket will be opened after opening ui
	var/ticket_to_open

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
