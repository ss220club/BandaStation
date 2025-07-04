/datum/keybinding/mentor
	category = CATEGORY_MENTOR
	weight = WEIGHT_ADMIN

/datum/keybinding/mentor/mentor_say
	hotkey_keys = list("N")
	name = SAY_CHANNEL
	full_name = "Mentor say"
	description = "Talk with other mentors."
	keybind_signal = COMSIG_KB_MENTOR_MSAY_DOWN

/datum/keybinding/mentor/mentor_say/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(MENTOR_CHANNEL)]")
	return TRUE

ADMIN_VERB(mentor_message, R_MENTOR, "Mentor chat", "Allows mentors and admins to communicate with eachother.", ADMIN_CATEGORY_MAIN)

/client/verb/mentor(msg as text)
	set name = "Mentor chat" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "Admin"

	mentor_message(msg)

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	var/client_initalized = VALIDATE_CLIENT_INITIALIZATION(src)
	if(isnull(mob) || !client_initalized)
		if(!client_initalized)
			unvalidated_client_error() // we only want to throw this warning message when it's directly related to client failure.

		to_chat(usr, span_warning("Failed to send your OOC message. You attempted to send the following message:\n[span_big(msg)]"))
		return

/client/proc/mentor_message(msg, wall_pierce)
	for(var/client/receiver as anything in GLOB.admins + GLOB.mentors)
		var/keyname = get_ooc_badged_name()
		var/avoid_highlight = receiver == src
		if(GLOB.say_disabled)
			to_chat(usr, span_danger("Speech is currently admin-disabled."))
			return


		msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
		mob.log_talk(msg,LOG_OOC, tag="MSAY")
		to_chat(receiver, span_mentorsay(span_prefix("MOOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]")), avoid_highlighting = avoid_highlight)
