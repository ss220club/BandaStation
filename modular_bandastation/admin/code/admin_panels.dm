ADMIN_VERB(game_panel, R_ADMIN, "Game Panel", "Opens Game Panel (TGUI).", ADMIN_CATEGORY_GAME)
    var/datum/gamepanel/tgui = new(user)
    tgui.ui_interact(user.mob)
    BLACKBOX_LOG_ADMIN_VERB("Game Panel")

/datum/gamepanel
    var/client/user_client
    var/variable = null
    var/subwindowTitle = ""
    var/objList = list()
    var/whereDropdownValue = ""

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
            subwindowTitle = "Create Object"
            objList = typesof(/obj)
        if("quick-create-object")
            user_client.holder.quick_create_object(user_client.mob)
        if("create-turf")
            subwindowTitle = "Create Turf"
            objList = typesof(/turf)
        if("create-mob")
            subwindowTitle = "Create Mob"
            objList = typesof(/mob)
        if("where-dropdown-changed")
            whereDropdownValue = params?["newWhere"]


// /datum/gamepanel/ui_static_data(mob/user)
// 	. = ..()
// 	var/list/data = list()

// 	return data

/datum/gamepanel/ui_data(mob/user)
    . = ..()
    var/list/data = list()
    data["subwindowTitle"] = subwindowTitle || "nothing"
    data["objList"] = objList
    data["whereDropdownValue"] = whereDropdownValue
    return data
