/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	hotkey_keys = list("F3", "T") // BANDASTATION EDIT
	name = SAY_CHANNEL
	full_name = "Говорить"
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/communication/say/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(SAY_CHANNEL)];")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE

/datum/keybinding/client/communication/radio
	hotkey_keys = list("Y")
	name = RADIO_CHANNEL
	full_name = "Общий канал рации (;)"
	keybind_signal = COMSIG_KB_CLIENT_RADIO_DOWN

/datum/keybinding/client/communication/radio/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(RADIO_CHANNEL)]")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE

/datum/keybinding/client/communication/ooc
	hotkey_keys = list("F2", "O") // BANDASTATION EDIT
	name = OOC_CHANNEL
	full_name = "OOC"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/communication/ooc/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(OOC_CHANNEL)]")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE

/datum/keybinding/client/communication/me
	hotkey_keys = list("F4", "M") // BANDASTATION EDIT
	name = ME_CHANNEL
	full_name = "Эмоция"
	keybind_signal = COMSIG_KB_CLIENT_ME_DOWN

/datum/keybinding/client/communication/me/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(ME_CHANNEL)]")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE
