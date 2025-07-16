GLOBAL_DATUM_INIT(ticket_manager, /datum/ticket_manager, new)
GLOBAL_VAR_INIT(ticket_manager_ref, REF(GLOB.ticket_manager))

/datum/ticket_manager
	/// The set of all  tickets
	var/alist/all_tickets = alist()

/datum/ticket_manager/ui_state()
	return GLOB.always_state

/datum/ticket_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketManager")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ticket_manager/ui_data(mob/user)
	var/list/data = list()
	var/client/C = user.client
	data["userKey"] = C.key
	data["isAdmin"] = check_rights_for(C, R_ADMIN)
	data["isMentor"] = null // NEEDED MENTOR SYSTEM
	data["ticketToOpen"] = C.ticket_to_open
	data["allTickets"] = get_tickets_data(C)
	return data

/datum/ticket_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/user = ui.user.client
	var/ticket_number = params["ticketNumber"]
	if(!ticket_number)
		CRASH("Called ticket_manager ui_act() without a ticket number!")

	// Can be used by anyone
	switch(action)
		if("reply")
			if(!params["message"])
				return FALSE

			add_ticket_message(ticket_number, user.key, params["message"])
			return TRUE

	if(!check_rights(R_ADMIN)) // Check for mentor rights after implementing mentors
		return FALSE

	// Admin/Mentor only
	switch(action)
		if("reopen")
			set_ticket_state(user, ticket_number, TICKET_OPEN)
			return TRUE

		if("close")
			set_ticket_state(user, ticket_number, TICKET_CLOSED)
			return TRUE

		if("resolve")
			set_ticket_state(user, ticket_number, TICKET_RESOLVED)
			return TRUE

		/* NEEDED MENTOR SYSTEM
		if("convert")
			convert_ticket(ticket_number)
			return TRUE
		*/

	return FALSE

/datum/ticket_manager/ui_close(mob/user)
	. = ..()
	user.client.ticket_to_open = null

/datum/ticket_manager/proc/get_tickets_data(client/user)
	var/list/tickets = list()
	for(var/ticket_key, ticket_datum in all_tickets)
		var/datum/help_ticket/ticket = ticket_datum
		if(!check_rights_for(user, R_ADMIN))
			/*
			if(check_rights_for(user, R_MENTOR) && ticket.ticket_type != TICKET_TYPE_MENTOR)
				continue // Skip non-mentor tickets for mentors
			*/
			if(ticket.initiator_key != user.key)
				continue // Skip any tickets not initiated by the user

		tickets += list(list(
			"number" = ticket_key,
			"state" = ticket.state,
			"type" = ticket.ticket_type,
			"initiator" = ticket.initiator,
			"initiatorKey" = ticket.initiator_key,
			"openedTime" = ticket.opened_at,
			"closedTime" = ticket.closed_at,
			"replied" = ticket.player_replied,
			"messages" = ticket.messages,
		))

	return tickets
