ADMIN_VERB(ccheck_antagonists, R_ADMIN, "CCheck Antagonists", "See all antagonists for the round.", ADMIN_CATEGORY_GAME)
	// if(!SSticker.HasRoundStarted())
	// 	tgui_alert(usr, "The game hasn't started yet!")
	// 	return
	// user.holder.check_antagonists()
	var/datum/check_antagonists_panel/panel = new(usr.client)
	panel.ui_interact(usr)
	log_admin("[key_name(user)] checked antagonists.")
	if(!isobserver(user.mob) && SSticker.HasRoundStarted())
		message_admins("[key_name_admin(user)] checked antagonists.")
	BLACKBOX_LOG_ADMIN_VERB("Check Antagonists")


/datum/check_antagonists_panel
	var/client/user_client
	var/round_duration
	var/is_idle_or_recalled
	var/time_left
	var/is_called
	var/is_delayed
	var/connected_players
	var/lobby_players = 0
	var/observers = 0
	var/observers_connected = 0
	var/living_players = 0
	var/living_players_connected = 0
	var/antagonists = 0
	var/antagonists_dead = 0
	var/brains = 0
	var/other_players = 0
	var/living_skipped = 0
	var/drones = 0
	var/security = 0
	var/security_dead = 0
	var/antagonists_info = list()
	var/teams_info = list()

/datum/check_antagonists_panel/New(user)
	if(istype(user, /client))
		var/client/temp_user_client = user
		user_client = temp_user_client
	else
		var/mob/user_mob = user
		user_client = user_mob.client

	round_duration = DisplayTimeText(world.time - SSticker.round_start_time)
	is_idle_or_recalled = EMERGENCY_IDLE_OR_RECALLED
	time_left = SSshuttle.emergency.timeLeft()
	is_called = SSshuttle.emergency.mode == SHUTTLE_CALL
	is_delayed = SSticker.delay_end
	connected_players = GLOB.clients.len
	for(var/mob/checked_mob in GLOB.mob_list)
		if(checked_mob.ckey)
			if(isnewplayer(checked_mob))
				lobby_players++
				continue
			else if(checked_mob.mind && !isbrain(checked_mob) && !isobserver(checked_mob))
				if(checked_mob.stat != DEAD)
					if(isdrone(checked_mob))
						drones++
						continue
					if(is_centcom_level(checked_mob.z))
						living_skipped++
						continue
					living_players++
					if(checked_mob.client)
						living_players_connected++
				else if (checked_mob.ckey)
					// This finds all dead mobs that still have a ckey inside them
					// Ie, they have died, but have not ghosted
					observers++
					if (checked_mob.client)
						observers_connected++

				if(checked_mob.is_antag())
					antagonists++
					if(checked_mob.stat == DEAD)
						antagonists_dead++
				if(checked_mob.mind.assigned_role?.departments_list?.Find(/datum/job_department/security))
					security++
					if(checked_mob.stat == DEAD)
						security_dead++
			else if(checked_mob.stat == DEAD || isobserver(checked_mob))
				observers++
				if(checked_mob.client)
					observers_connected++
			else if(isbrain(checked_mob))
				brains++
			else
				other_players++

	build_antag_listing()


/datum/check_antagonists_panel/proc/build_antag_listing()
	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_teams |= A.get_team()
		all_antagonists += A

	for(var/datum/team/T in all_teams)
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		// sections += T.antag_listing_entry()

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	antagonists_info = all_antagonists
	teams_info = all_teams

/datum/check_antagonists_panel/Destroy()
	. = ..()

/datum/check_antagonists_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CheckAntagonists")
		ui.open()

/datum/check_antagonists_panel/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/check_antagonists_panel/ui_state(mob/user)
	. = ..()
	return ADMIN_STATE(R_ADMIN)

/datum/check_antagonists_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("game-mode-panel")
			dynamic_panel(ui.user)
		if("delay-round-end")
			return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/delay_round_end)
		if("undelay-round-end")
			if(!check_rights(R_SERVER))
				return

			if(tgui_alert(usr, "Really cancel current round end delay? The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Undelay round end", list("Yes", "No")) == "No")
				return

			SSticker.admin_delay_notice = null
			SSticker.delay_end = FALSE

			log_admin("[key_name(usr)] undelayed the round end.")
			if(SSticker.ready_for_reboot)
				message_admins("[key_name_admin(usr)] undelayed the round end. You must now manually Reboot World to start the next shift.")
			else
				message_admins("[key_name_admin(usr)] undelayed the round end.")
		if("end-round-now")
			return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/end_round)
		if("reboot-world")
			return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/restart)

/datum/check_antagonists_panel/ui_data(mob/user)
	var/data = list()
	data["round_duration"] = round_duration
	data["is_idle_or_recalled"] = is_idle_or_recalled
	data["time_left"] = time_left
	data["is_called"] = is_called
	data["is_delayed"] = is_delayed
	data["connected_players"] = connected_players
	data["lobby_players"] = lobby_players
	data["observers"] = observers
	data["observers_connected"] = observers_connected
	data["living_players"] = living_players
	data["living_players_connected"] = living_players_connected
	data["antagonists"] = antagonists
	data["antagonists_dead"] = antagonists_dead
	data["brains"] = brains
	data["other_players"] = other_players
	data["living_skipped"] = living_skipped
	data["drones"] = drones
	data["security"] = security
	data["security_dead"] = security_dead
	data["antagonists_info"] = antagonists_info
	return data;

// /datum/check_antagonists_panel/ui_assets(mob/user)
// 	return list(check_antagonists.dm
// 		get_asset_datum(/datum/asset/json/check_antagonists),
// 	)
