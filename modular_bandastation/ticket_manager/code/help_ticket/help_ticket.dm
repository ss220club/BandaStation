/datum/help_ticket
	/// Unique ID of the ticket
	var/id
	/// Name used for stat panel
	var/stat_name
	/// The current state of the ticket
	var/state = TICKET_OPEN
	/// Ticket type id. Used for sorting Admin/Mentor tickets.
	var/ticket_type_id
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
	/// Has the admin replied to this ticket yet?
	var/admin_replied = FALSE
	/// ID for the autoclose timer
	var/ticket_autoclose_timer_id
	/// It's the person who ahelped/was bwoinked
	var/datum/persistent_client/initiator_client
	/// It's admin who linked to current ticket
	var/datum/persistent_client/linked_admin
	/// Cached ticket type datum instance
	var/datum/help_ticket_type/ticket_type
	/// List of all client keys who currently write to this ticket
	var/list/writers = list()
	/// Collection of all ticket messages
	var/list/messages
	/// Static counter used for generating each ticket ID
	var/static/ticket_counter = 0
	/// Prevents convert spam
	COOLDOWN_DECLARE(convert_cooldown)

/datum/help_ticket/New(client/creator, client/admin, message, ticket_type_id)
	if(!message || !creator || !creator.mob)
		qdel(src)
		CRASH("Tried to create a ticket with invalid arguments!")

	stat_name = sanitize(trim(message, TICKET_STAT_PANEL_MESSAGE_MAX_LENGTH))
	if(length(message) > TICKET_STAT_PANEL_MESSAGE_MAX_LENGTH)
		stat_name += "..."

	id = ++ticket_counter
	opened_at = time_stamp(NONE) // Reset format to Byond default
	initiator_client = creator.persistent_client
	initiator = key_name(creator)
	initiator_key = creator.key
	set_ticket_type_id(ticket_type_id)
	messages = list(list(
		"sender" = admin ? admin.key : initiator_key,
		"message" = emoji_parse(message),
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
		send_creation_message(creator, message, ticket_type_id)

	ticket_autoclose_timer_id = addtimer(CALLBACK(GLOB.ticket_manager, TYPE_PROC_REF(/datum/ticket_manager, autoclose_ticket), src), TICKET_AUTOCLOSE_TIMER, TIMER_STOPPABLE)
	SSblackbox.LogAhelp(id, "Ticket Opened", message, null, initiator_key)

/datum/help_ticket/ui_data(mob/user)
	var/list/data = list()
	data["number"] = id
	data["state"] = state
	data["type"] = ticket_type_id
	data["initiator"] = initiator
	data["openedTime"] = opened_at
	data["closedTime"] = closed_at
	data["linkedAdmin"] = !!linked_admin
	data["writers"] = writers
	data["messages"] = messages
	data["userHasStaffAccess"] = has_staff_access(user.client)
	data["isLinkedToCurrentAdmin"] = !isnull(linked_admin) && (linked_admin.client == user.client)
	return data

/// Notifies the staff about the new ticket, and sends a creation confirmation to the creator
/datum/help_ticket/proc/send_creation_message(client/creator, message)
	var/text_span_class = get_text_span_class()
	var/boxed_message_class = get_boxed_message_class()

	var/title = span_class(text_span_class, "Тикет #[id]")
	var/body = "[TICKET_REPLY_LINK(id, initiator)]\n\n[span_class(get_text_span_class(), (sanitize(trim(message))))]"
	for(var/client/admin as anything in GLOB.admins)
		if(!has_user_access(admin))
			continue


		var/ticket_body_actions = check_rights_for(admin, R_ADMIN) ? TICKET_ADMIN(creator.mob, id) : TICKET_MENTOR(creator.mob, id)
		send_adminhelp_message(
			admin,
			fieldset_block(\
				title, \
				"[body]\n\n[ticket_body_actions]", \
				"boxed_message [boxed_message_class]" \
			)
		)

	to_chat(
		creator,
		custom_boxed_message("[boxed_message_class]", span_class(text_span_class, "[title] был создан! Ожидайте ответ. Вы можете открыть тикет нажав F1")),
		MESSAGE_TYPE_ADMINPM
	)

/// Converts ticket to ticket type specified `type_to_convert_to`
/datum/help_ticket/proc/convert(client/converter)
	if(!has_staff_access(converter))
		message_admins("[key_name_admin(converter)] попытался конвертировать тикет #[id] не имея прав доступа.")
		log_admin("[key_name(converter)] попытался конвертировать тикет #[id] не имея прав доступа.")
		return FALSE

	var/type_to_convert_to = type_to_convert_to()
	if(!type_to_convert_to)
		to_chat(
			converter,
			span_danger("Тикет `[id]` не может быть конвертирован."),
			MESSAGE_TYPE_ADMINPM
		)
		return FALSE

	if(!isnull(linked_admin))
		unlink_linked_admin()

	set_ticket_type_id(type_to_convert_to)

	message_admins("[key_name_admin(converter)] конвертировал тикет #[id] в [ticket_type_id].")
	log_admin("[key_name(converter)] конвертировал тикет #[id] в [ticket_type_id].")

	var/boxed_message_class = get_boxed_message_class()
	var/text_span_class = get_text_span_class()

	var/ticket_converted_message = custom_boxed_message(\
		"[boxed_message_class]", \
		span_class(text_span_class, "[key_name_admin(converter)] конвертировал тикет [TICKET_OPEN_LINK(id, "#[id]")] в [ticket_type_id].") \
	)
	for(var/client/admin as anything in GLOB.admins)
		if(admin == converter || !has_user_access(admin))
			continue

		send_adminhelp_message(admin, ticket_converted_message)

	messages += list(list(
		"sender" = TICKET_LOG_SENDER_ADMIN_TICKET_LOG,
		"message" = "[converter.ckey] конвертировал тикет в [ticket_type_id]",
		"time" = time_stamp(NONE),
	))

	return TRUE

/// Sets `ticket_type_id` and and updates `ticket_type` variable
/datum/help_ticket/proc/set_ticket_type_id(new_ticket_type_id)
	ticket_type_id = new_ticket_type_id
	ticket_type = GLOB.help_ticket_types[ticket_type_id]
	return ticket_type

/// Return actual client of `initiator_client` persistent client
/datum/help_ticket/proc/get_initiator_client()
	return initiator_client?.client

/// Links passed admin to the ticket, if required permissions are present
/datum/help_ticket/proc/link_admin(client/admin)
	if(!isnull(linked_admin))
		return FALSE

	if(!has_user_access(admin))
		message_admins(
			"[key_name_admin(admin)] попытался взять тикет #[id], не имея прав доступа к нему!"
		)

		stack_trace("Tried to link admin to ticket without required rights!")
		return FALSE

	linked_admin = admin.persistent_client
	deltimer(ticket_autoclose_timer_id)
	message_admins("[key_name_admin(admin)] взял тикет #[id] на рассмотрение.")
	log_admin("[key_name_admin(admin)] взял тикет #[id] на рассмотрение.")
	return TRUE

/// Unlnks `linked_admin` from the ticket,
/// start autoclosure timer and notifies responsible admins
/datum/help_ticket/proc/unlink_linked_admin()
	var/autoclose_delay = TICKET_AUTOCLOSE_TIMER / 2
	ticket_autoclose_timer_id = addtimer(\
		CALLBACK(GLOB.ticket_manager, TYPE_PROC_REF(/datum/ticket_manager, autoclose_ticket), src), \
		autoclose_delay, \
		TIMER_STOPPABLE \
	)

	var/client/initiator = get_initiator_client()
	if(initiator)
		var/chat_message = custom_boxed_message(\
			"[get_boxed_message_class()]",\
			span_class(\
				get_text_span_class(), \
				("[linked_admin.key] отказался от вашего тикета. Ожидайте другого администратора. Если никто не ответит на ваш тикет, он автоматически закроется через [autoclose_delay / (1 SECONDS)] секунд.") \
			) \
		)

		to_chat(initiator, chat_message, MESSAGE_TYPE_ADMINPM)

	messages += list(list(
		"sender" = TICKET_LOG_SENDER_ADMIN_TICKET_LOG,
		"message" = "[linked_admin.key] отказался от тикета",
		"time" = time_stamp(NONE),
	))

	linked_admin = null

	return TRUE

/// Checks if the ticket can be viewed and interacted by passed `target`
/datum/help_ticket/proc/has_user_access(client/target)
	return check_rights_for(target, get_ticket_type()?.required_permissions) || initiator_key == target.key

/// Checks if the ticket can be converted by passed `target`
/datum/help_ticket/proc/has_staff_access(client/target)
	return check_rights_for(target, get_ticket_type()?.required_permissions)

/// Returns type this help ticket can be converted to
/datum/help_ticket/proc/type_to_convert_to()
	return get_ticket_type()?.type_to_convert_to

/// Returns ticket type datum instance
/datum/help_ticket/proc/get_ticket_type() as /datum/help_ticket_type
	if(isnull(ticket_type))
		ticket_type = GLOB.help_ticket_types[ticket_type_id]

		if(isnull(ticket_type))
			stack_trace("ticket `[id]` without valid ticket type `[ticket_type_id]`")
			return null

	return ticket_type

/// Returns boxed messaged class for this ticket
/datum/help_ticket/proc/get_boxed_message_class()
	return get_ticket_type()?.boxed_message_class || /datum/help_ticket_type::boxed_message_class

/// Returns boxed messaged class for this ticket
/datum/help_ticket/proc/get_text_span_class()
	return get_ticket_type()?.text_span_class || /datum/help_ticket_type::text_span_class
