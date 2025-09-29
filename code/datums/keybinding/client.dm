/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Админхелп"
	description = "Попросить администрацию о помощи"
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/admin_help/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("Unbound") // BANDASTATION EDIT
	name = "screenshot"
	full_name = "Сделать скриншот"
	description = "Сделать скриншот"
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.auto")
	return TRUE

/datum/keybinding/client/toggle_fullscreen
	hotkey_keys = list("F11")
	name = "toggle_fullscreen"
	full_name = "Переключить полноэкранный режим"
	description = "Делает окно игры полноэкранным."
	keybind_signal = COMSIG_KB_CLIENT_FULLSCREEN_DOWN

/datum/keybinding/client/toggle_fullscreen/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.toggle_fullscreen()
	return TRUE

/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Переключить минимальный HUD"
	description = "Скрывает большинство элементов HUD"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/minimal_hud/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE

/datum/keybinding/client/close_every_ui
	hotkey_keys = list("Northwest") // HOME key
	name = "close_every_ui"
	full_name = "Close Open UIs"
	description = "Closes all UI windows you have open."
	keybind_signal = COMSIG_KB_CLIENT_CLOSEUI_DOWN

/datum/keybinding/client/close_every_ui/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SStgui.close_user_uis(user.mob)
	return TRUE
