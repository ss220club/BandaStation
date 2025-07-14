GLOBAL_DATUM_INIT(ticket_manager, /datum/ticket_manager, new)

/// Client var used for returning the ahelp verb
/client/var/help_timer_id = 0
/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/client/var/datum/help_ticket/current_help_ticket

/**
 * Admin/Mentor help ticket manager
 */
/datum/ticket_manager
	var/used_by = list()
	/// The set of all active tickets
	var/list/active_tickets = list()
	/// The set of all closed tickets
	var/list/closed_tickets = list()

/datum/ticket_manager/Destroy()
	QDEL_LIST(active_tickets)
	QDEL_LIST(closed_tickets)
	return ..()

/datum/ticket_manager/ui_state()
	return ADMIN_STATE(R_ADMIN)

/datum/ticket_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketManager")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ticket_manager/ui_data(mob/user)
	var/list/data = list()
	data["userName"] = key_name(user)
	data["activeTickets"] = get_active_tickets_data(user.client)
	return data

/datum/ticket_manager/ui_static_data(mob/user)
	var/list/data = list()
	data["closedTickets"] = get_closed_tickets_data(user.client)
	return data

/datum/ticket_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/ticket_number = params["ticketNumber"]
	if(!ticket_number)
		CRASH("Called ticket_manager ui_act() without a ticket number")

	var/mob/user = ui.user

	// Can be used by anyone
	switch(action)
		if("reply")
			if(!params["message"])
				return FALSE

			add_message(ticket_number, user.client.ckey, params["message"])
			SStgui.update_uis(src)
			return TRUE

	if(!check_rights(R_ADMIN))
		return FALSE

/datum/ticket_manager/proc/get_active_tickets_data(client/user)
	var/list/tickets = list()
	for(var/datum/help_ticket/ticket in active_tickets)
		tickets += list(list(
			"number" = ticket.id,
			"type" = ticket.ticket_type,
			"initiator" = ticket.initiator,
			"initiatorCkey" = ticket.initiator_ckey,
			"openedTime" = ticket.opened_at,
			"closedTime" = ticket.closed_at,
			"replied" = ticket.player_replied,
			"messages" = ticket.messages,
		))
	return tickets

/datum/ticket_manager/proc/get_closed_tickets_data(client/user)
	var/list/tickets = list()
	for(var/datum/help_ticket/ticket as anything in closed_tickets)
		tickets += list(
			"number" = ticket.id,
			"type" = ticket.ticket_type,
			"initiator" = ticket.initiator,
			"initiatorCkey" = ticket.initiator_ckey,
			"openedTime" = ticket.opened_at,
			"closedTime" = ticket.closed_at,
			"state" = ticket.state,
			"messages" = ticket.messages,
		)
	return tickets

/datum/ticket_manager/proc/add_message(ticket_id, sender, message)
	if(!ticket_id || !sender || !message)
		CRASH("Invalid parameters passed to ticket_manager add_message()")

	var/datum/help_ticket/needed_ticket
	for(var/datum/help_ticket/ticket as anything in active_tickets)
		if(ticket.id == ticket_id)
			needed_ticket = ticket
			break

	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in active_tickets")

	needed_ticket.messages += list(list(
		"sender" = sender,
		"message" = message,
		"time" = time_stamp(NONE),
	))
