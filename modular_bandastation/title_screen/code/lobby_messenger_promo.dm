/datum/asset/simple/lobby_messenger_promo
	assets = list(
		"lobby_messenger_gosuslugi.png" = 'modular_bandastation/title_screen/icons/lobby_messenger/gosuslugi.png',
		"lobby_messenger_flag_ru.png" = 'modular_bandastation/title_screen/icons/lobby_messenger/flag_ru.png',
		"lobby_messenger_max_logo.png" = 'modular_bandastation/title_screen/icons/lobby_messenger/max_logo.png',
	)

/datum/lobby_messenger_promo
	var/step = 1

/datum/lobby_messenger_promo/ui_state(mob/user)
	return GLOB.always_state

/datum/lobby_messenger_promo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LobbyMessengerPromo", " ")
		ui.open()

/datum/lobby_messenger_promo/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/lobby_messenger_promo))

/datum/lobby_messenger_promo/ui_static_data(mob/user)
	return list(
		"asset_gosuslugi" = "lobby_messenger_gosuslugi.png",
		"asset_flag_ru" = "lobby_messenger_flag_ru.png",
		"asset_max_logo" = "lobby_messenger_max_logo.png",
	)

/datum/lobby_messenger_promo/ui_data(mob/user)
	var/list/data = list()
	data["step"] = step
	return data

/datum/lobby_messenger_promo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	var/discordurl = CONFIG_GET(string/discordurl)

	switch(action)
		if("download")
			if(user.client && discordurl)
				user << link(discordurl)
			ui.close()
			return TRUE
		if("skip_step1")
			step = 2
			return TRUE
		if("connect")
			if(user.client && discordurl)
				user << link(discordurl)
			ui.close()
			return TRUE
		if("dismiss")
			ui.close()
			return TRUE

	return FALSE

/datum/lobby_messenger_promo/ui_close(mob/user)
	. = ..()
	if(user?.client?.lobby_messenger_promo == src)
		user.client.lobby_messenger_promo = null
	qdel(src)

/client
	var/datum/lobby_messenger_promo/lobby_messenger_promo = null
