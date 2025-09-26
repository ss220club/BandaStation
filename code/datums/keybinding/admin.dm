/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return user.holder ? TRUE : FALSE

/datum/keybinding/admin/admin_say
	hotkey_keys = list("F5") // BANDASTATION EDIT
	name = ADMIN_CHANNEL
	full_name = "Asay"
	description = "Разговаривайте с другими админами"
	keybind_signal = COMSIG_KB_ADMIN_ASAY_DOWN

/datum/keybinding/admin/admin_ghost
	hotkey_keys = list("F6") // BANDASTATION EDIT
	name = "admin_ghost"
	full_name = "Aghost"
	description = "Уйти в призраки"
	keybind_signal = COMSIG_KB_ADMIN_AGHOST_DOWN

/datum/keybinding/admin/admin_ghost/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	return TRUE

/datum/keybinding/admin/player_panel_new
	hotkey_keys = list("F7") // BANDASTATION EDIT
	name = "player_panel_new"
	full_name = "Player Panel New"
	description = "Открывает панель новых игроков"
	keybind_signal = COMSIG_KB_ADMIN_PLAYERPANELNEW_DOWN

/datum/keybinding/admin/player_panel_new/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.holder.player_panel_new()
	return TRUE

/datum/keybinding/admin/toggle_buildmode_self
	hotkey_keys = list("F11") // BANDASTATION EDIT
	name = "toggle_buildmode_self"
	full_name = "Toggle Buildmode Self"
	description = "Включает режим строительства"
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN

/datum/keybinding/admin/toggle_buildmode_self/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/build_mode_self)
	return TRUE

/datum/keybinding/admin/stealthmode
	hotkey_keys = list("CtrlF9") // BANDASTATION EDIT
	name = "stealth_mode"
	full_name = "Stealth mode"
	description = "Включает стелс режим"
	keybind_signal = COMSIG_KB_ADMIN_STEALTHMODETOGGLE_DOWN

/datum/keybinding/admin/stealthmode/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/stealth)
	return TRUE

/datum/keybinding/admin/invisimin
	hotkey_keys = list("F9") // BANDASTATION EDIT
	name = "invisimin"
	full_name = "Invisimin"
	description = "Включает невидимость, как у призраков (Не абузьте этим)"
	keybind_signal = COMSIG_KB_ADMIN_INVISIMINTOGGLE_DOWN

/datum/keybinding/admin/invisimin/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/invisimin)
	return TRUE

/datum/keybinding/admin/deadsay
	hotkey_keys = list("F10")
	name = "dsay"
	full_name = "Dsay"
	description = "Отправляет сообщение в чат мертвых"
	keybind_signal = COMSIG_KB_ADMIN_DSAY_DOWN

/datum/keybinding/admin/deadsay/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.get_dead_say()
	return TRUE

/datum/keybinding/admin/deadmin
	hotkey_keys = list("Unbound")
	name = "deadmin"
	full_name = "Deadmin"
	description = "Избавиться от своих админских сил"
	keybind_signal = COMSIG_KB_ADMIN_DEADMIN_DOWN

/datum/keybinding/admin/deadmin/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/deadmin)
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list("Unbound")
	name = "readmin"
	full_name = "Readmin"
	description = "Вернуть свои админские силы"
	keybind_signal = COMSIG_KB_ADMIN_READMIN_DOWN

/datum/keybinding/admin/readmin/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.readmin()
	return TRUE

/datum/keybinding/admin/view_tags
	hotkey_keys = list("CtrlF11") // BANDASTATION EDIT
	name = "view_tags"
	full_name = "View Tags"
	description = "Открывает меню View-Tags"
	keybind_signal = COMSIG_KB_ADMIN_VIEWTAGS_DOWN

/datum/keybinding/admin/view_tags/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/display_tags)
	return TRUE
