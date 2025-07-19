/datum/help_ticket
	/// Unique ID of the ticket
	var/id
	/// The current state of the ticket
	var/state = TICKET_OPEN
	/// Ticket type. Used for sorting Admin/Mentor tickets
	var/ticket_type
	/// Hidden type. Used for chat messages
	var/ticket_type_hidden = TICKET_TYPE_HIDDEN_TICKET
	/// The time at which the ticket was opened
	var/opened_at
	/// The time at which the ticket was closed
	var/closed_at
	/// Initiator key name
	var/initiator
	/// Initiator key. More stable
	var/initiator_key
	/// It's the person who ahelped/was bwoinked
	var/datum/persistent_client/initiator_client
	/// It's admin who linked to current ticket
	var/datum/persistent_client/linked_admin
	/// List of all client keys who currently write to this ticket
	var/list/writers = list()
	/// Collection of all ticket messages
	var/list/messages
	/// Has the admin replied to this ticket yet?
	var/admin_replied = FALSE
	/// Static counter used for generating each ticket ID
	var/static/ticket_counter = 0

/datum/help_ticket/New(client/creator, client/admin, message, new_type)
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
		"sender" = admin ? admin.key : initiator_key,
		"message" = message,
		"time" = opened_at,
	))

	if(initiator_client.current_help_ticket) //This is a bug
		stack_trace("Multiple help tickets opened by a single player!")
		GLOB.ticket_manager.set_ticket_state(initiator_client.current_help_ticket.id, TICKET_CLOSED)

	initiator_client.current_help_ticket = src
	GLOB.ticket_manager.all_tickets[id] = src
	SStgui.update_uis(GLOB.ticket_manager)

	if(admin)
		admin_replied = TRUE
		linked_admin = admin.persistent_client
		ticket_type_hidden = TICKET_TYPE_HIDDEN_PM
		GLOB.ticket_manager.send_chat_message_to_player(admin, src, message)
	else
		send_creation_message(creator, message, ticket_type)

/// Notifies the staff about the new ticket, and sends a creation confirmation to the creator
/datum/help_ticket/proc/send_creation_message(client/creator, message, ticket_type)
	var/title = "Тикет #[id]"
	var/body = "[TICKET_REPLY_LINK(id, span_adminsay(initiator))]\n\n[span_adminsay(sanitize(trim(message)))]"
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(admin, sound('sound/effects/adminhelp.ogg'))

		window_flash(admin, ignorepref = TRUE)
		to_chat(admin, fieldset_block(span_adminhelp(title), "[body]\n\n[TICKET_FULLMONTY(creator.mob, id)]", "boxed_message red_box"), MESSAGE_TYPE_ADMINPM)

	to_chat(creator, custom_boxed_message("green_box", "[title] был создан! Ожидайте ответ. Вы можете открыть тикет нажав F1"), MESSAGE_TYPE_ADMINPM)
