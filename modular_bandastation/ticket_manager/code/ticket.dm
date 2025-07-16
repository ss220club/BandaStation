/datum/help_ticket
	/// Unique ID of the ticket
	var/id
	/// The current state of the ticket
	var/state = TICKET_OPEN
	/// Ticket type. Used for sorting Admin/Mentor tickets
	var/ticket_type
	/// The time at which the ticket was opened
	var/opened_at
	/// The time at which the ticket was closed
	var/closed_at
	/// Initiator key name
	var/initiator
	/// Initiator key. More stable
	var/initiator_key
	/// Semi-misnomer, it's the person who ahelped/was bwoinked
	var/datum/persistent_client/initiator_client
	/// Collection of all ticket messages
	var/list/messages
	/// Has the player replied to this ticket yet?
	var/player_replied = FALSE
	/// Static counter used for generating each ticket ID
	var/static/ticket_counter = 0

/datum/help_ticket/New(client/creator, message, new_type)
	if(!message || !creator || !creator.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = time_stamp(NONE) // Reset format to Byond default
	initiator_client = creator.persistent_client
	initiator = key_name(creator)
	initiator_key = creator.key
	ticket_type = new_type
	messages = list(list(
		"sender" = initiator_key,
		"message" = message,
		"time" = opened_at,
	))

	if(initiator_client.current_help_ticket) //This is a bug
		stack_trace("Multiple help tickets opened by a single player!")
		GLOB.ticket_manager.set_ticket_state(initiator_client.current_help_ticket.id, TICKET_CLOSED)

	initiator_client.current_help_ticket = src
	GLOB.ticket_manager.all_tickets[id] = src
	notify_admins(creator, message, ticket_type)
	SStgui.update_uis(GLOB.ticket_manager)

/// Notifies the staff about the new ticket, and sends a creation confirmation to the creator
/datum/help_ticket/proc/notify_admins(client/creator, message, ticket_type)
	var/title = "Тикет <a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];open_ticket=1'>#[id]</a>"
	var/body = "<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];response=1'>[span_bold(initiator)]</a>\n[message]"
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(admin, sound('sound/effects/adminhelp.ogg'))

		window_flash(admin, ignorepref = TRUE)
		to_chat(admin, fieldset_block(span_adminhelp(title), "[body]\n\n[ADMIN_FULLMONTY_NONAME(creator.mob)]", "boxed_message red_box"), MESSAGE_TYPE_ADMINPM)

	to_chat(creator, custom_boxed_message("green_box", "[title] был создан! Ожидайте ответ."), MESSAGE_TYPE_ADMINPM)
