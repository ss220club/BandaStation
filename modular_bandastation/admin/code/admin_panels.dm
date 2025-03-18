/datum/gamepanel
	var/client/user_client
	var/variable = null

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
			user_client.holder.create_mob(user_client.mob)

ADMIN_VERB(game_panel, R_ADMIN, "Game Panel", "Opens Game Panel menu.", ADMIN_CATEGORY_GAME)
	new /datum/gamepanel(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Game Panel")

/datum/gamepanel/New(user)
    if(istype(user, /client))
        var/client/temp_user_client = user
        user_client = temp_user_client //if its a client, assign it to user_client
    else
        var/mob/user_mob = user
        user_client = user_mob.client //if its a mob, assign the mob's client to user_client
    ui_interact(user_client.mob)
