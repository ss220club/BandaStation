/datum/copypasta
	var/client/user_client
	var/variable = null

/datum/copypasta/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Copypasta")
		ui.open()

/datum/copypasta/ui_close(mob/user) //Uses the destroy() proc. When the user closes the UI, we clean up variables.
	qdel(src)

/datum/copypasta/ui_state(mob/user)
	. = ..()
	return ADMIN_STATE(R_ADMIN)

/datum/copypasta/ui_act(action, params)
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

ADMIN_VERB(copypasta, R_ADMIN, "AACopypasta", "Description!", ADMIN_CATEGORY_MAIN)
	new /datum/copypasta(user.mob)

/datum/copypasta/New(user)
    if(istype(user, /client))
        var/client/temp_user_client = user
        user_client = temp_user_client //if its a client, assign it to user_client
    else
        var/mob/user_mob = user
        user_client = user_mob.client //if its a mob, assign the mob's client to user_client
    ui_interact(user_client.mob)
