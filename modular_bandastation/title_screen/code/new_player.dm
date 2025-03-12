/mob/dead/new_player
	var/title_collapsed = FALSE

/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	. = ..()
	if(isnewplayer(target_ai))
		SStitle.hide_title_screen_from(client)

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return

	if(!client || client.interviewee)
		return

	if(href_list["toggle_ready"])
		ready = !ready
		SStitle.title_output(client, ready, "toggle_ready")
		lobby_button_sound()

	else if(href_list["late_join"])
		lobby_button_sound()
		GLOB.latejoin_menu.ui_interact(usr)

	else if(href_list["observe"])
		lobby_button_sound()
		if(!SSticker || SSticker.current_state <= GAME_STATE_STARTUP)
			to_chat(usr, span_warning("Сервер ещё не загрузился!"))
			return

		make_me_an_observer()

	else if(href_list["character_setup"])
		lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
		preferences.update_static_data(src)
		preferences.ui_interact(src)

	else if(href_list["settings"])
		lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)

	else if(href_list["manifest"])
		lobby_button_sound()
		ViewManifest()

	else if(href_list["changelog"])
		lobby_button_sound()
		client?.changelog()

	else if(href_list["wiki"])
		lobby_button_sound()
		if(tgui_alert(usr, "Хотите открыть нашу вики?", "Вики", list("Да", "Нет")) != "Да")
			return
		client << link("https://tg.ss220.club")

	else if(href_list["trait_signup"])
		var/datum/station_trait/clicked_trait
		for(var/datum/station_trait/trait as anything in GLOB.lobby_station_traits)
			if(trait.name == href_list["trait_signup"])
				clicked_trait = trait

		clicked_trait.on_lobby_button_click(usr, href_list["id"])
		lobby_button_sound()

	else if(href_list["picture"])
		if(!check_rights(R_FUN))
			log_admin("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			message_admins("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			return

		lobby_button_sound()
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/change_title_screen)

	else if(href_list["notice"])
		if(!check_rights(R_FUN))
			log_admin("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			message_admins("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			return

		lobby_button_sound()
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/change_title_screen_notice)

	else if(href_list["start_now"])
		if(!check_rights(R_SERVER))
			log_admin("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			message_admins("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			return

		lobby_button_sound()
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/start_now)

	else if(href_list["delay"])
		if(!check_rights(R_SERVER))
			log_admin("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			message_admins("Title Screen: Possible href exploit attempt by [key_name(usr)]!")
			return

		lobby_button_sound()
		if(SSticker.current_state > GAME_STATE_PREGAME)
			return tgui_alert(usr, "Too late... The game has already started!")

		var/static/time = 1.5 MINUTES
		if(time == 1.5 MINUTES)
			time = 1984 DAYS
		else
			time = 1.5 MINUTES

		SSticker.SetTimeLeft(time)
		SSticker.start_immediately = FALSE
		to_chat(world, span_infoplain(span_bold("Игра начнётся через [DisplayTimeText(time)].")), confidential = TRUE)
		SEND_SOUND(world, sound('sound/announcer/default/attention.ogg'))
		log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(time)].")
		BLACKBOX_LOG_ADMIN_VERB("Delay Game Start")

	else if(href_list["collapse"])
		title_collapsed = !title_collapsed

		if(title_collapsed)
			SEND_SOUND(src, sound('sound/misc/menu/menu_rollup1.ogg'))
		else
			SEND_SOUND(src, sound('sound/misc/menu/menu_rolldown1.ogg'))

	else if(href_list["title_ready"])
		if(check_rights_for(client, R_ADMIN|R_DEBUG))
			SStitle.title_output(client, "true", "admin_buttons_visibility")

	else if(href_list["focus"])
		winset(client, "map", "focus=true")

/mob/dead/new_player/proc/lobby_button_sound()
	var/sound/ui_select_sound = sound('sound/misc/menu/ui_select1.ogg')
	ui_select_sound.frequency = get_rand_frequency_low_range()
	SEND_SOUND(src, ui_select_sound)
