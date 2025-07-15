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
	SStgui.update_uis(src)

/datum/ticket_manager/proc/switch_ticket_state(ticket_id, new_state)
	var/datum/help_ticket/needed_ticket = all_tickets[ticket_id]
	if(!needed_ticket)
		CRASH("Ticket with id [ticket_id] not found in all tickets!")

	if(new_state != TICKET_OPEN)
		needed_ticket.closed_at = time_stamp(NONE)

		var/client/initiator = needed_ticket.initiator_client
		if(initiator && initiator.current_help_ticket == needed_ticket)
			initiator.current_help_ticket = null
	else
		needed_ticket.closed_at = null

	needed_ticket.state = new_state
	SStgui.update_uis(src)

/* NEEDED MENTOR SYSTEM
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
*/
