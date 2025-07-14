GLOBAL_DATUM_INIT(ticket_manager, /datum/ticket_manager, new)

/// Client var used for returning the ahelp verb
/client/var/help_timer_id = 0
/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/client/var/datum/help_ticket/current_help_ticket

/**
 * Admin/Mentor help ticket manager
 */
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
	data["userCkey"] = user.client.ckey
	data["allTickets"] = get_tickets_data(user.client)
	return data

/datum/ticket_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/ticket_number = params["ticketNumber"]
	if(!ticket_number)
		CRASH("Called ticket_manager ui_act() without a ticket number!")

	// Can be used by anyone
	switch(action)
		if("reply")
			if(!params["message"])
				return FALSE

			add_ticket_message(ticket_number, user.client.ckey, params["message"])
			SStgui.update_uis(src)
			return TRUE

	if(!check_rights(R_ADMIN))
		return FALSE

	// Admin/Mentor only
	switch(action)
		if("reopen")
			switch_ticket_state(ticket_number, TICKET_OPEN)
			return TRUE

		if("close")
			switch_ticket_state(ticket_number, TICKET_CLOSED)
			return TRUE

		if("resolve")
			switch_ticket_state(ticket_number, TICKET_RESOLVED)
			return TRUE

		if("convert")
			convert_ticket(ticket_number)
			return TRUE

/datum/ticket_manager/proc/get_tickets_data(client/user)
	var/list/tickets = list()
	if(check_rights(R_ADMIN))
		for(var/ticket_key, ticket_datum in all_tickets)
			var/datum/help_ticket/ticket = ticket_datum
			tickets += list(list(
				"number" = ticket_key,
				"state" = ticket.state,
				"type" = ticket.ticket_type,
				"initiator" = ticket.initiator,
				"initiatorCkey" = ticket.initiator_ckey,
				"openedTime" = ticket.opened_at,
				"closedTime" = ticket.closed_at,
				"replied" = ticket.player_replied,
				"messages" = ticket.messages,
			))
	return tickets

/datum/ticket_manager/proc/add_ticket_message(ticket_id, sender, message)
	if(!sender || !message)
		CRASH("Invalid parameters passed to ticket_manager add_ticket_message()!")

	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	needed_ticket.messages += list(list(
		"sender" = sender,
		"message" = message,
		"time" = time_stamp(NONE),
	))

/datum/ticket_manager/proc/switch_ticket_state(ticket_id, new_state)
	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	if(new_state != TICKET_OPEN)
		needed_ticket.closed_at = time_stamp(NONE)
	else
		needed_ticket.closed_at = null

	needed_ticket.state = new_state
	SStgui.update_uis(src)

/datum/ticket_manager/proc/convert_ticket(ticket_id)
	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	switch(needed_ticket.ticket_type)
		if(TICKET_TYPE_ADMIN)
			needed_ticket.ticket_type = TICKET_TYPE_MENTOR
		if(TICKET_TYPE_MENTOR)
			needed_ticket.ticket_type = TICKET_TYPE_ADMIN

	SStgui.update_uis(src)
