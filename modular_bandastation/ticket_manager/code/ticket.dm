/datum/help_ticket
	/// Unique ID of the ticket
	var/id
	/// The current state of the ticket
	var/state = TICKET_OPEN
	/// Ticket type. Used for sorting Admin/Mentor tickets in the UI
	var/ticket_type
	/// The time at which the ticket was opened
	var/opened_at
	/// The time at which the ticket was closed
	var/closed_at
	/// Initiator ckey and key name
	var/initiator
	/// Initiator ckey. More stable
	var/initiator_ckey
	/// Semi-misnomer, it's the person who ahelped/was bwoinked
	var/client/initiator_client
	/// Collection of all ticket messages
	var/list/messages
	/// Has the player replied to this ticket yet?
	var/player_replied = FALSE
	/// Static counter used for generating each ticket ID
	var/static/ticket_counter = 0

/datum/help_ticket/New(client/creator, raw_message, new_type)
	var/message = sanitize(copytext_char(raw_message, 1, MAX_MESSAGE_LEN))
	if(!message || !creator || !creator.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = time_stamp(NONE) // Reset format to Byond default
	initiator_client = creator
	initiator = key_name(initiator_client)
	initiator_ckey = initiator_client.ckey
	initiator_client.current_ticket = src
	ticket_type = new_type
	messages = list(list(
		"sender" = initiator_ckey,
		"message" = message,
		"time" = opened_at,
	))

	timeout_verb()
	notify_stuff(creator, message, ticket_type)
	GLOB.ticket_manager.all_tickets += src

// Removes the help verb and returns it after 2 minutes
/datum/help_ticket/proc/timeout_verb()
	remove_verb(initiator_client, /client/verb/adminhelp)
	initiator_client.help_timer_id = addtimer(CALLBACK(initiator_client, TYPE_PROC_REF(/client, giveadminhelpverb)), 2 MINUTES, TIMER_STOPPABLE)

/// Notifies the staff about the new ticket, and sends a creation confirmation to the creator
/datum/help_ticket/proc/notify_stuff(client/creator, message, ticket_type)
	var/chat_message
	switch(ticket_type)
		if(TICKET_TYPE_ADMIN)
			chat_message = fieldset_block(
				span_adminhelp("Тикет #[id]"),
				"<b>[initiator]</b><br>[message]",
				"boxed_message red_box")

		if(TICKET_TYPE_MENTOR)
			// TODO: Replace adminhelp span to mentorhelp
			chat_message = fieldset_block(
				span_adminhelp("Тикет #[id]"),
				"<b>[initiator]</b><br>[message]",
				"boxed_message blue_box")

	to_chat(
		creator,
		custom_boxed_message("green_box", "Тикет #[id] был создан! Ожидайте ответ."),
		MESSAGE_TYPE_ADMINPM,
		confidential = TRUE
	)

	for(var/client/admin in GLOB.admins)
		window_flash(admin, ignorepref = TRUE)
		if(admin.prefs.toggles & SOUND_ADMINHELP)
			SEND_SOUND(admin, sound('sound/effects/adminhelp.ogg'))

		to_chat(admin, chat_message, MESSAGE_TYPE_ADMINPM, confidential = TRUE)
