/datum/controller/subsystem/title
	/// The current notice text, or null.
	var/notice
	/// Currently set title screen
	var/datum/title_screen/current_title_screen
	/// The list of image files available to be picked for title screen
	var/list/title_images_pool = list()

/datum/controller/subsystem/title/Initialize()
	fill_title_images_pool()
	current_title_screen = new(screen_image_file = pick_title_image())
	show_title_screen_to_all_new_players()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/title/Recover()
	current_title_screen = SStitle.current_title_screen
	title_images_pool = SStitle.title_images_pool

/**
 * Iterates over all files in `TITLE_SCREENS_LOCATION` and loads all valid title screens to `title_screens` var.
 */
/datum/controller/subsystem/title/proc/fill_title_images_pool()
	for(var/file_name in flist(TITLE_SCREENS_LOCATION))
		if(validate_filename(file_name))
			var/file_path = "[TITLE_SCREENS_LOCATION][file_name]"
			title_images_pool += fcopy_rsc(file_path)

/**
 * Checks wheter passed title is valid
 * Currently validates extension and checks whether it's special image like default title screen etc.
 */
/datum/controller/subsystem/title/proc/validate_filename(filename)
	var/static/list/title_screens_to_ignore = list("blank.png")
	if(filename in title_screens_to_ignore)
		return FALSE

	var/static/list/supported_extensions = list("gif", "jpg", "jpeg", "png", "svg")
	var/extstart = findlasttext(filename, ".")
	if(!extstart)
		return FALSE

	var/extension = copytext(filename, extstart + 1)
	return (extension in supported_extensions)

/**
 * Show the title screen to all new players.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to_all_new_players()
	if(!current_title_screen)
		return

	for(var/mob/dead/new_player/viewer as anything in GLOB.new_player_list)
		show_title_screen_to(viewer.client)

/**
 * Show the title screen to specific client.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to(client/viewer)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, show_to), viewer)

	if(check_rights_for(viewer, R_ADMIN|R_DEBUG))
		addtimer(CALLBACK(src, PROC_REF(title_output), viewer, "true", "admin_buttons_visibility"), 1.75 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_CLIENT_TIME)

/**
 * Hide the title screen from specific client.
 */
/datum/controller/subsystem/title/proc/hide_title_screen_from(client/viewer)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, hide_from), viewer)

/**
 * Call JavaScript function on all clients
 */
/datum/controller/subsystem/title/proc/title_output_to_all(params, function)
	if(!current_title_screen)
		return

	for(var/mob/dead/new_player/viewer as anything in GLOB.new_player_list)
		title_output(viewer.client, params, function)

/**
 * Call JavaScript function for specific client.
 */
/datum/controller/subsystem/title/proc/title_output(client/viewer, params, function)
	if(!viewer || !current_title_screen)
		return

	viewer << output(params, "title_browser:[function]")

/**
 * Adds a notice to the main title screen in the form of big red text!
 */
/datum/controller/subsystem/title/proc/set_notice(new_notice)
	notice = sanitize_text(new_notice) || null
	title_output_to_all(notice, "update_notice")

/**
 * Change or reset title screen css
 */
/datum/controller/subsystem/title/proc/set_title_css()
	var/action = tgui_alert(usr, "Что делаем?", "Title Screen CSS", list("Меняем", "Сбрасываем", "Ничего"))
	switch(action)
		if("Меняем")
			var/new_css = input(usr, "Загрузи CSS файл со своими стилями.", "РИСКОВАННО: ИЗМЕНЕНИЕ СТИЛЕЙ ЛОББИ") as null|file
			if(!new_css)
				message_admins("Title Screen: [key_name_admin(usr)] changed mind to change title screen CSS.")
				return

			if(copytext("[new_css]",-4) != ".css")
				to_chat(usr, span_reallybig("Ты что загрузил, еблуша? Это не CSS!"))
				message_admins("Title Screen: [key_name_admin(usr)] загрузил какую-то хуйню вместо CSS.")
				return

			if(!current_title_screen)
				current_title_screen = new(styles = new_css)
			else
				current_title_screen.title_css = new_css
		if("Сбрасываем")
			if(!current_title_screen)
				current_title_screen = new(styles = current_title_screen::title_css)
			else
				current_title_screen.title_css = current_title_screen::title_css
		else
			return

	show_title_screen_to_all_new_players()
	message_admins("Title Screen: [key_name_admin(usr)] has changed the title screen CSS.")

/**
 * Changes title image to desired
 */
/datum/controller/subsystem/title/proc/set_title_image(desired_image_file)
	if(desired_image_file)
		if(!isfile(desired_image_file))
			CRASH("Not a file passed to `/datum/controller/subsystem/title/proc/set_title_image`")
	else
		desired_image_file = pick_title_image()

	if(!current_title_screen)
		current_title_screen = new(screen_image_file = desired_image_file)
	else
		current_title_screen.set_screen_image(desired_image_file)

	for(var/mob/dead/new_player/viewer as anything in GLOB.new_player_list)
		INVOKE_ASYNC(src, PROC_REF(update_title_image_for_client), viewer.client)

/**
 * Sends title image to client and updates title screen for it
 */
/datum/controller/subsystem/title/proc/update_title_image_for_client(client/update_for)
	PRIVATE_PROC(TRUE)

	if(!istype(update_for))
		return

	SSassets.transport.send_assets(update_for, current_title_screen.screen_image.name)
	update_for.browse_queue_flush()
	title_output(update_for, SSassets.transport.get_asset_url(asset_cache_item = current_title_screen.screen_image), "update_image")

/**
 * Update a user's character setup name.
 */
/datum/controller/subsystem/title/proc/update_character_name(mob/dead/new_player/user, name)
	if(!(istype(user)))
		return

	title_output(user.client, name, "update_character_name")

/**
 * Picks title image from `title_images_pool` list. If the list is empty, `DEFAULT_TITLE_SCREEN_IMAGE_PATH` is returned
 */
/datum/controller/subsystem/title/proc/pick_title_image()
	return length(title_images_pool) ? pick(title_images_pool) : DEFAULT_TITLE_SCREEN_IMAGE_PATH

#undef TITLE_SCREENS_LOCATION
