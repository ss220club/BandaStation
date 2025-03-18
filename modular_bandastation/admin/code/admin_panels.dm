ADMIN_VERB(game_panel, R_ADMIN, "Game Panel", "Opens Game Panel (TGUI).", ADMIN_CATEGORY_GAME)
	var/datum/gamepanel/tgui = new(user)
	tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Game Panel")

/datum/gamepanel
	var/client/user_client
	var/variable = null

/datum/gamepanel/New(user)
    if(istype(user, /client))
        var/client/temp_user_client = user
        user_client = temp_user_client //if its a client, assign it to user_client
    else
        var/mob/user_mob = user
        user_client = user_mob.client //if its a mob, assign the mob's client to user_client

/datum/gamepanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GamePanel")
		ui.open()

/datum/gamepanel/ui_close(mob/user) //Uses the destroy() proc. When the user closes the UI, we clean up variables.
	qdel(src)

/datum/gamepanel/ui_state(mob/user)
	. = ..()
	return ADMIN_STATE(R_ADMIN)

/datum/gamepanel/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("game-mode-panel")
			SSgamemode.admin_panel(usr)
		if("create-object")
			user_client.holder.create_object(user_client.mob)
		if("quick-create-object")
			user_client.holder.quick_create_object(user_client.mob)
		if("create-turf")
			user_client.holder.create_turf(user_client.mob)
		if("create-mob")
			var/datum/gamepanel/create_panels/mob_panel/tgui = new(user_client)
			tgui.ui_interact(user_client.mob)

/datum/gamepanel/create_panels/mob_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CreateMobPanel")
		ui.open()

/datum/gamepanel/create_panels/mob_panel/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	data["title"] = "Create Mob"
	return data

/datum/gamepanel/create_panels/mob_panel/New(mob/user)
	if(istype(user, /client))
		var/client/temp_user_client = user
		user_client = temp_user_client //if its a client, assign it to user_client
	else
		var/mob/user_mob = user
		user_client = user_mob.client //if its a mob, assign the mob's client to user_client

/datum/gamepanel/create_panels/mob_panel/ui_data(mob/user)
	var/list/data = list()
	data["mobs"] = typesof(/mob)
	return data

/datum/gamepanel/create_panels/mob_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/gamepanel/create_panels/mob_panel/ui_close()
	qdel(src)
