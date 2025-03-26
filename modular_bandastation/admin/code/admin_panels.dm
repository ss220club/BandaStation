#define FLOOR_BELOW_MOB "On floor below own mob"
#define SUPPLY_BELOW_MOB "On floor below own mob, dropped via supply pod"
#define MOB_HAND "In own's mob hand"
#define MARKED_OBJECT "In marked object"

ADMIN_VERB(game_panel, R_ADMIN, "Game Panel", "Opens Game Panel (TGUI).", ADMIN_CATEGORY_GAME)
	var/datum/gamepanel/tgui = new(user)
	tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Game Panel")

/datum/gamepanel
	var/client/user_client
	var/subwindowTitle = ""
	var/objList = list()
	var/whereDropdownValue = FLOOR_BELOW_MOB
	var/selected_object = ""
	var/itemCount = 1
	var/item = null
	var/loc = null
	var/currentList = "obj"

/datum/gamepanel/New(user)
	if(istype(user, /client))
		var/client/temp_user_client = user
		user_client = temp_user_client //if its a client, assign it to user_client
	else
		var/mob/user_mob = user
		user_client = user_mob.client //if its a mob, assign the mob's client to user_client
	if(!objList["obj"])
		objList["obj"] = typesof(/obj)

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
			subwindowTitle = "Create Object"
			if(!objList["obj"])
				objList["obj"] = typesof(/obj)
			currentList = "obj"
		if("quick-create-object")
			user_client.holder.quick_create_object(user_client.mob)
		if("create-turf")
			subwindowTitle = "Create Turf"
			if(!objList["turf"])
				objList["turf"] = typesof(/turf)
			currentList = "turf"
		if("create-mob")
			subwindowTitle = "Create Mob"
			if(!objList["mob"])
				objList["mob"] = typesof(/mob)
			currentList = "mob"
		if("where-dropdown-changed")
			whereDropdownValue = params?["newWhere"]
		// if("set-relative-cords")
		//     cords = RELATIVE_CORDS
		// if("set-absolute-cords")
		//     whereDropdownValue = params?["newWhere"]
		if("selected-object-changed")
			selected_object = params?["newObj"]
		if("create-object-action")
			spawn_item(objList[currentList][selected_object], user_client, whereDropdownValue, loc)

/datum/gamepanel/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["subwindowTitle"] = subwindowTitle || "nothing"
	return data

/datum/gamepanel/proc/spawn_item(spawn_path, mob/user, spawn_action, loc)
	switch(spawn_action)
		if(FLOOR_BELOW_MOB)
			to_chat(usr, "below")
			// if(ismovable(spawn_path))
			//     var/atom/movable/return_item = new spawn_path()
			//     if(isnull(return_item))
			//         return_item.moveToNullspace()
			//     else
			//         return_item.forceMove(get_turf(user))
			//     return return_item
			// if(ispath(spawn_path))
			//     return new spawn_path(get_turf(user))
			if(ispath(spawn_path))
				spawn_atom_to_turf(spawn_path, user_client.mob, itemCount, TRUE)
		if(SUPPLY_BELOW_MOB)
			to_chat(usr, "supply")
			var/obj/structure/closet/supplypod/spawned_pod = podspawn(list(
				"target" = user_client.mob,
			))
			return new spawn_path(spawned_pod)
		if(MOB_HAND)
			to_chat(usr, "hand")
			var/mob/living/carbon/human_user = user
			if(istype(human_user) && isitem(spawn_path) && human_user.put_in_hands(spawn_path))
				return
		if(MARKED_OBJECT)
			to_chat(usr, "marked")

/datum/gamepanel/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["subwindowTitle"] = subwindowTitle || "nothing"
	data["objList"] = objList
	data["whereDropdownValue"] = whereDropdownValue
	data["currentList"] = currentList
	return data

#undef MARKED_OBJECT
#undef MOB_HAND
#undef SUPPLY_BELOW_MOB
#undef FLOOR_BELOW_MOB
