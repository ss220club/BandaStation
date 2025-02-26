GLOBAL_DATUM(who_tgui, /datum/tgui_who)

/datum/tgui_who
	/// Client of whoever is using this datum
	var/client/viewer
	/// Selected client mob for advanced info. Admin only.
	var/mob/living/subject
	/// If true, modal window with additional mob info is open. Admin only.
	var/modal_open = FALSE

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
	data["modalOpen"] = modal_open
	if(modal_open)
		data["subject"] = list(
			"key" = subject.client.key,
			"ping" = list(
				"lastPing" = subject.client.lastping,
				"avgPing" = subject.client.avgping,
			),
			"name" = list(
				"real" = subject?.real_name,
				"mind" = subject?.mind.name,
			),
			"role" = get_role(subject),
			"type" = subject.type,
			"gender" = subject.gender,
			"state" = get_state(subject),
			"health" = get_health(subject),
			"location" = get_position(subject),
			"accountAge" = subject.client.account_age,
			"accountIp" = subject.client.address,
			"byondVersion" = subject.client.byond_version,
			"byondBuild" = subject.client.byond_build,
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

		// More info for admins
		if(viewer.holder && check_rights(R_ADMIN, FALSE))
			clients[client] += list(
				"status" = get_status(client.mob),
				"mobRef" = REF(client.mob),
				"accountAge" = client.account_age,
			)

	data["clients"] = clients
	return data

/datum/tgui_who/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = viewer.mob
	// Free to use by anyone
	switch(action)
		if("update")
			update_static_data(user)
			return TRUE

		if("hide_more_info")
			modal_open = FALSE
			subject = null
			return TRUE

	if(!check_rights(R_ADMIN))
		return FALSE

	var/mob/user_subject = locate(params["ref"])
	if(!user_subject)
		return FALSE

	if(!ismob(user_subject))
		to_chat(viewer, "Просматривать дополнительную информацию, можно только у /mob.")
		return FALSE

	// Admin only actions
	switch(action)
		if("show_more_info")
			modal_open = TRUE
			subject = user_subject
			return TRUE

		if("follow")
			if(!isobserver(user))
				return FALSE

			user.client.admin_follow(user_subject)
			return TRUE

		if("logs")
			show_individual_logging_panel(user_subject)
			return TRUE

		if("smite")
			SSadmin_verbs.dynamic_invoke_verb(viewer, /datum/admin_verb/admin_smite, user_subject)
			return TRUE

		if("subtlepm")
			SSadmin_verbs.dynamic_invoke_verb(viewer, /datum/admin_verb/cmd_admin_subtle_message, user_subject)
			return TRUE

		if("view_variables")
			viewer.debug_variables(user_subject)
			return TRUE

		if("traitor_panel")
			if(!SSticker.HasRoundStarted())
				tgui_alert(viewer,"Игра ещё не началась!")
				return FALSE

			SSadmin_verbs.dynamic_invoke_verb(viewer, /datum/admin_verb/show_traitor_panel, user_subject)
			return TRUE

		if("player_panel")
			SSadmin_verbs.dynamic_invoke_verb(viewer, /datum/admin_verb/show_player_panel, user_subject)
			return TRUE

/datum/tgui_who/proc/get_status(mob/living/user)
	var/list/status = list()
	if(isnewplayer(user))
		status["where"] = "В лобби"
	else
		status["where"] = "[user.real_name]"
		status["state"] = get_state(user)

		if(is_special_character(user))
			status["antagonist"] = TRUE
		else
			status["antagonist"] = FALSE

	return status

/datum/tgui_who/proc/get_state(mob/living/user)
	switch(user.stat)
		if(CONSCIOUS)
			return "Живой"
		if(UNCONSCIOUS)
			return "Без сознания"
		if(SOFT_CRIT, HARD_CRIT)
			return "В крите"
		if(DEAD)
			if(!isobserver(user))
				return "Мёртв"
			else
				var/mob/dead/observer/observer = user
				if(observer.started_as_observer)
					return "Наблюдает"
				else
					return "Мёртв"

/datum/tgui_who/proc/get_health(mob/living/user)
	if(!isliving(user))
		return

	var/list/health = list()
	health["brute"] = user.getBruteLoss()
	health["burn"] = user.getFireLoss()
	health["toxin"] = user.getToxLoss()
	health["oxygen"] = user.getOxyLoss()
	health["brain"] = user.get_organ_loss(ORGAN_SLOT_BRAIN)
	health["stamina"] = user.getStaminaLoss()
	return health

/datum/tgui_who/proc/get_position(mob/living/user)
	var/turf/position = get_turf(user)
	if(!isturf(position))
		return

	var/list/location_info = list()
	location_info["area"] = "\improper [position.loc.name || position.loc || user.loc.name || user.loc]"
	location_info["x"] = position.x
	location_info["y"] = position.y
	location_info["z"] = position.z
	return location_info

/datum/tgui_who/proc/get_role(mob/living/user)
	if(!user.mind)
		return

	var/list/role = list()
	role["assigned"] = job_title_ru(user.mind.assigned_role.title)
	role["antagonist"] = user.mind.antag_datums
	return role

/client/who()
	set name = "Who"
	set category = "OOC"

	var/datum/tgui_who/who = new(src)
	who.ui_interact(mob)
