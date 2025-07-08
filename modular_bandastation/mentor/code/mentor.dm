/datum/keybinding/mentor
	category = CATEGORY_MENTOR
	weight = WEIGHT_ADMIN

/datum/keybinding/mentor/mentor_say
	hotkey_keys = list("ShiftF5")
	name = MENTOR_CHANNEL
	full_name = "Msay"
	description = "Разговаривайте с другими менторами."
	keybind_signal = COMSIG_KB_MENTOR_MSAY_DOWN

/datum/keybinding/mentor/mentor_say/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(MENTOR_CHANNEL)]")
	return TRUE

ADMIN_VERB(mentor_message, R_MENTOR | R_ADMIN, "Mentor chat", "Позволяет менторам общяться между собой.", ADMIN_CATEGORY_MENTOR, msg as text)
	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return
	// Сюда добавь проверку на то, ментор ли чел, и если нет то ретурн

	if(!check_rights(R_ADMIN | R_MENTOR))
		return

		msg = "[span_mentorsay("[span_prefix("MENTOR:")] <EM>[key_name_admin(user)]</EM> [ADMIN_FLW(user.mob)]: <span class='message linkify'>[msg]")]</span>"
		to_chat(GLOB.admins + GLOB.mentors,
			type = MESSAGE_TYPE_MENTORCHAT,
			html = msg,
			confidential = TRUE)
		user.mob.log_talk(msg,LOG_OOC, tag="MSAY")

/client/proc/mentor_message(msg, wall_pierce)

	if(!msg)
		return

    // Сюда добавь проверку на то, ментор ли чел, и если нет то ретурн

