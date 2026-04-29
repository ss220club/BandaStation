#define MAP_BAG_MAX_COPIES 10

ADMIN_VERB(admin_bag_editor, R_SERVER, "Map Pool Editor", "Edit the map rotation pool.", ADMIN_CATEGORY_SERVER)
	SSmap_vote.ui_interact(user.mob)

/datum/controller/subsystem/map_vote/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "BagEditor", "Map Pool Editor")
		ui.open()

/datum/controller/subsystem/map_vote/ui_status(mob/user)
	if(check_rights_for(user.client, R_SERVER))
		return UI_INTERACTIVE
	return UI_CLOSE

/datum/controller/subsystem/map_vote/ui_data(mob/user)
	var/list/remaining_counts = list()
	for(var/rem in remaining_bag)
		remaining_counts[rem] = (remaining_counts[rem] || 0) + 1

	var/list/maps = list()
	for(var/map_name in config.maplist)
		var/datum/map_config/mc = config.maplist[map_name]
		if(!mc?.votable)
			continue
		maps += list(list(
			"map_name" = map_name,
			"display_name" = mc.map_name,
			"initial_count" = initial_bag[map_name] || 0,
			"config_count" = config_bag[map_name] || 0,
			"remaining_count" = remaining_counts[map_name] || 0,
		))

	var/last_played_display = null
	if(last_played_map)
		var/datum/map_config/lp_mc = config.maplist[last_played_map]
		last_played_display = lp_mc?.map_name || last_played_map

	return list(
		"maps" = maps,
		"last_played" = last_played_display,
		"remaining_total" = length(remaining_bag),
	)

/datum/controller/subsystem/map_vote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("set_copies")
			var/map_name = params["map_name"]
			var/count = text2num(params["count"])
			if(!(map_name in config.maplist) || !count || count < 1 || count > MAP_BAG_MAX_COPIES)
				return
			var/old_count = initial_bag[map_name] || 0
			initial_bag[map_name] = count
			var/diff = count - old_count
			if(diff > 0)
				for(var/i in 1 to diff)
					remaining_bag += map_name
			else if(diff < 0)
				for(var/i in 1 to abs(diff))
					var/idx = remaining_bag.Find(map_name)
					if(idx)
						remaining_bag.Cut(idx, idx + 1)
			save_bag_state()
			log_admin("[key_name_admin(user.client)] set [map_name] copies to [count] in map bag.")
			message_admins("[key_name_admin(user.client)] set [map_name] copies to [count] in map bag.")
			return TRUE
		if("add_map")
			var/map_name = params["map_name"]
			if(!(map_name in config.maplist) || (map_name in initial_bag))
				return
			initial_bag[map_name] = 1
			remaining_bag += map_name
			save_bag_state()
			log_admin("[key_name_admin(user.client)] added [map_name] to map bag.")
			message_admins("[key_name_admin(user.client)] added [map_name] to map bag.")
			return TRUE
		if("remove_map")
			var/map_name = params["map_name"]
			if(!(map_name in initial_bag))
				return
			initial_bag -= map_name
			var/list/cleaned = list()
			for(var/rem in remaining_bag)
				if(rem != map_name)
					cleaned += rem
			remaining_bag = cleaned
			save_bag_state()
			log_admin("[key_name_admin(user.client)] removed [map_name] from map bag.")
			message_admins("[key_name_admin(user.client)] removed [map_name] from map bag.")
			return TRUE
		if("reset_remaining")
			load_bag_config()
			refill_bag()
			save_bag_state()
			log_admin("[key_name_admin(user.client)] reset remaining map bag to initial state.")
			message_admins("[key_name_admin(user.client)] reset remaining map bag to initial state.")
			return TRUE

#undef MAP_BAG_MAX_COPIES
