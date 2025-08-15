/**
 * Enables an admin to upload a new titlescreen image.
 */
ADMIN_VERB(change_title_screen, R_ADMIN, "Лобби: Изменить изображение", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_EVENTS)
	if(!check_rights(R_ADMIN))
		return

	switch(tgui_alert(usr, "Что делаем с изображением в лобби?", "Лобби", list("Меняем", "Сбрасываем", "Ничего")))
		if("Меняем")
			var/file = input(usr) as icon|null
			if(file)
				SStitle.set_title_image(usr, file)

		if("Сбрасываем")
			SStitle.set_title_image(usr)

/**
 * Sets a titlescreen notice, a big red text on the main screen.
 */
ADMIN_VERB(change_title_screen_notice, R_ADMIN, "Лобби: Изменить уведомление", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_EVENTS)
	if(!check_rights(R_ADMIN))
		return

	var/new_notice = tgui_input_text(usr, "Введи то что должно отображаться в лобби:", "Уведомление в лобби", max_length = 2048)
	if(isnull(new_notice))
		return

	var/announce_text
	if(new_notice == "")
		announce_text = "УВЕДОМЛЕНИЕ В ЛОББИ УДАЛЕНО."
	else
		announce_text = "УВЕДОМЛЕНИЕ В ЛОББИ ОБНОВЛЕНО: [new_notice]"

	SStitle.set_notice(new_notice)
	log_admin("Title Screen: [key_name(usr)] setted the title screen notice, which contains: [new_notice]")
	message_admins("Title Screen: [key_name_admin(usr)] setted the title screen notice, which contains: [new_notice]")

	for(var/mob/dead/new_player/new_player as anything in GLOB.new_player_list)
		to_chat(new_player, span_boldannounce(emoji_parse(announce_text)))
		SEND_SOUND(new_player,  sound('sound/mobs/humanoids/moth/scream_moth.ogg'))

/**
 * An admin debug command that enables you to change the CSS on the go.
 */
ADMIN_VERB(change_title_screen_css, R_DEBUG, "Title Screen: Set CSS", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_EVENTS)
	if(!check_rights(R_DEBUG))
		to_chat(src, span_warning("Недостаточно прав! Необходимы права R_DEBUG."))
		return

	log_admin("Title Screen: [key_name(usr)] is setting the title screen CSS.")
	message_admins("Title Screen: [key_name_admin(usr)] is setting the title screen CSS.")

	SStitle.set_title_css()

/**
 * Reloads the titlescreen if it is bugged for someone.
 */
/client/verb/fix_title_screen()
	set name = "Fix Lobby Screen"
	set desc = "Lobbyscreen broke? Press this."
	set category = "Special"

	if(!isnewplayer(src.mob))
		SStitle.hide_title_screen_from(src)
		return

	SStitle.show_title_screen_to(src)

/client/open_escape_menu()
	if(isnewplayer(mob))
		return
	. = ..()
