#define MAP_POOL_MAX_COPIES 10

ADMIN_VERB(admin_pool_editor, R_SERVER, "Map Pool Editor", "Edit the map rotation pool.", ADMIN_CATEGORY_SERVER)
	SSmap_vote.ui_interact(user.mob)

/datum/controller/subsystem/map_vote/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "MapPoolEditor", "Map Pool Editor")
		ui.open()

/datum/controller/subsystem/map_vote/ui_status(mob/user)
	if(check_rights_for(user.client, R_SERVER))
		return UI_INTERACTIVE
	return UI_CLOSE

/datum/controller/subsystem/map_vote/ui_data(mob/user)
	var/list/remaining_counts = list()
	for(var/rem in remaining_pool)
		remaining_counts[rem] = (remaining_counts[rem] || 0) + 1

	var/list/maps = list()
	for(var/map_name in config.maplist)
		var/datum/map_config/mc = config.maplist[map_name]
		if(!mc?.votable)
			continue
		maps += list(list(
			"map_name" = map_name,
			"display_name" = mc.map_name,
			"config_count" = config_pool[map_name] || 0,
			"remaining_count" = remaining_counts[map_name] || 0,
		))

	var/datum/map_config/last_played_map_datum = config.maplist[last_played_map]
	var/last_played_display = last_played_map ? (last_played_map_datum.map_name || last_played_map) : null

	return list(
		"maps" = maps,
		"last_played" = last_played_display,
		"remaining_total" = length(remaining_pool),
	)

/datum/controller/subsystem/map_vote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("remove_one")
			var/map_name = params["map_name"]
			var/idx = remaining_pool.Find(map_name)
			if(!idx)
				return
			remaining_pool.Cut(idx, idx + 1)
			save_pool_state()
			log_admin("[key_name_admin(user.client)] removed 1x [map_name] from remaining map pool.")
			message_admins("[key_name_admin(user.client)] removed 1x [map_name] from remaining map pool.")
			return TRUE
		if("add_one")
			var/map_name = params["map_name"]
			if(!(map_name in config.maplist))
				return
			var/max_copies = config_pool[map_name] || 0
			if(max_copies <= 0)
				return
			var/current = 0
			for(var/rem in remaining_pool)
				if(rem == map_name)
					current++
			if(current >= max_copies)
				return
			remaining_pool += map_name
			save_pool_state()
			log_admin("[key_name_admin(user.client)] added 1x [map_name] to remaining map pool.")
			message_admins("[key_name_admin(user.client)] added 1x [map_name] to remaining map pool.")
			return TRUE
		if("reset_remaining")
			load_pool_config()
			refill_pool()
			save_pool_state()
			log_admin("[key_name_admin(user.client)] reset remaining map pool to initial state.")
			message_admins("[key_name_admin(user.client)] reset remaining map pool to initial state.")
			return TRUE

#undef MAP_POOL_MAX_COPIES
