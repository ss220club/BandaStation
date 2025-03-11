/datum/copypasta
	var/client/holder
	var/variable = null

/datum/copypasta/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Copypasta")
		var/status = ui.open()
		to_chat(user, status)

/datum/copypasta/ui_close(mob/user) //Uses the destroy() proc. When the user closes the UI, we clean up the temp_pod and supplypod_selector variables.
	qdel(src)

/datum/copypasta/ui_state(mob/user)
	. = ..()
	return ADMIN_STATE(R_ADMIN)
// /datum/copypasta/ui_data(mob/user)
// 	var/list/data = list()
// 	data["var"] = variable
// 	return data

/datum/copypasta/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("game-mode-panel")
			SSgamemode.admin_panel(usr)
		if("create-object")
			var/href="byond://?src=[REF(src)];[HrefToken()];create_object=1"
			// request somehow href
			to_chat(usr, "create-object")
		if("quick-create-object")
			to_chat(usr, "qcreate-object")
		if("create-turf")
			to_chat(usr, "create-turf")
		if("create-mob")
			to_chat(usr, "create-mob")


ADMIN_VERB(copypasta, R_ADMIN, "AACopypasta", "Description!", ADMIN_CATEGORY_MAIN)
	new /datum/copypasta(user.mob)

/datum/copypasta/New(user)
    if(istype(user, /client))
        var/client/user_client = user
        holder = user_client //if its a client, assign it to holder
    else
        var/mob/user_mob = user
        holder = user_mob.client //if its a mob, assign the mob's client to holder
    ui_interact(holder.mob)
