/datum/secrets_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("move_gamma_shuttle")
			if(!SSshuttle.getDock("gamma_home"))
				var/mob/living/user = ui.user
				to_chat(user, span_warning("There is no shuttle docks for the Gamma shuttle on [SSmapping.current_map.map_name]."))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Gamma Shuttle"))
			if(SSshuttle.gamma.getDockedId() == "gamma_away")
				SSshuttle.moveShuttle("gamma", "gamma_home", FALSE)
				priority_announce("К вам направлен оружейный шаттл «ГАММА».","[command_name()]: Департамент защиты активов")
			else
				SSshuttle.moveShuttle("gamma", "gamma_away", FALSE)
				priority_announce("Оружейный шаттл «ГАММА» был отозван.", "[command_name()]: Департамент защиты активов")
			message_admins("[key_name_admin(holder)] moved gamma shuttle")
			log_admin("[key_name(holder)] moved the gamma shuttle")
