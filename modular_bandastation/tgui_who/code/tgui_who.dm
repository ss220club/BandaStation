GLOBAL_DATUM(who_tgui, /datum/tgui_who)

/datum/tgui_who
	/// Client of whoever is using this datum
	var/client/viewer

/datum/tgui_who/New(user)
	if(istype(user, /client))
		var/client/client = user
		viewer = client
	else
		var/mob/mob = user
		viewer = mob.client

/datum/tgui_who/ui_state()
	return GLOB.always_state

/datum/tgui_who/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Who")
		ui.open()

/datum/tgui_who/ui_data(mob/user)
	var/list/data = list()
	data["user"] = list(
		"ckey" = viewer.key,
		"ping" = list(
			"lastPing" = viewer.lastping,
			"avgPing" = viewer.avgping,
		),
		"admin"  = !!viewer.holder,
	)
	return data

/datum/tgui_who/ui_static_data(mob/user)
	var/list/data = list()

	var/list/clients = list()
	for(var/client/client in GLOB.clients)
		clients[client] += list(
			"ckey" = client.ckey,
			"ping" = list(
				"lastPing" = client.lastping,
				"avgPing" = client.avgping,
			),
			"adminRank" = client?.holder?.ranks[1],
		)

		// More info for admins in observe
		if(viewer.holder && check_rights(R_ADMIN, FALSE) && isobserver(viewer.mob))
			clients[client] += list(
				"status" = get_status(client),
				"account" = get_account_info(client),
				"mobRef" = REF(client.mob),
			)

	data["clients"] = clients

	return data

/datum/tgui_who/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = viewer.mob
	switch(action)
		if("update")
			update_static_data(user)
			return TRUE

		if("follow")
			if(!isobserver(user) && !check_rights(R_ADMIN))
				return FALSE

			user.client.admin_follow(locate(params["ref"]))
			return TRUE

/datum/tgui_who/proc/get_status(client/client)
	var/list/status = list()
	if(isnewplayer(client.mob))
		status["where"] = "В лобби"
	else
		status["where"] = "Играет за [client.mob.real_name]"
		switch(client.mob.stat)
			if(UNCONSCIOUS)
				status["state"] = "Без сознания"
			if(SOFT_CRIT|HARD_CRIT)
				status["state"] = "В крите"
			if(DEAD)
				if(!isobserver(client.mob))
					status["state"] = "Мёртв"
				else
					var/mob/dead/observer/observer = client.mob
					if(observer.started_as_observer)
						status["state"] = "Наблюдает"
					else
						status["state"] = "Мёртв"

		if(is_special_character(client.mob))
			status["antag"] = TRUE
		else
			status["antag"] = FALSE

	return status

/datum/tgui_who/proc/get_account_info(client/client)
	var/list/account = list()
	account["age"] = client.account_age
	account["donorTier"] = client.donator_level
	account["byondVersion"] = client.byond_version
	account["byondBuild"] = client.byond_build
	return account

/client/who()
	set name = "Who"
	set category = "OOC"

	var/datum/tgui_who/who = new(src)
	who.ui_interact(mob)
