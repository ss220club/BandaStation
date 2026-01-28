/datum/traitor_objective/ultimate/romerol
	name = "Проверьте наш новый био агент Ромерол на экипаже станции. Посылку можно забрать в %AREA%"
	description = "Отправляйтесь в %AREA%, и получите наш эксперементальный био агент. Распространите его среди экипажа \
	и созерцайте как трупы востают из мёртвых. Внимание: нежить будет крайне агрессивна ко всем разумных видам жизни."

	//this is a prototype so this progression is for all basic level kill objectives

	///area type the objective owner must be in to receive the romerol
	var/area/romerol_spawnarea_type
	///checker on whether we have sent the romerol yet.
	var/sent_romerol = FALSE

/datum/traitor_objective/ultimate/romerol/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(ispath(possible_area, /area/station/hallway) || ispath(possible_area, /area/station/security))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	romerol_spawnarea_type = pick(possible_areas)
	replace_in_name("%AREA%", initial(romerol_spawnarea_type.name))
	return TRUE

/datum/traitor_objective/ultimate/romerol/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_romerol)
		buttons += add_ui_button("", "нажатие на эту кнопку вызовет капсулу с комплектом который содержит Ромерол.", "biohazard", "romerol")
	return buttons

/datum/traitor_objective/ultimate/romerol/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("romerol")
			if(sent_romerol)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != romerol_spawnarea_type)
				to_chat(user, span_warning("Вы должны находится в [initial(romerol_spawnarea_type.name)] чтобы получить Ромерол."))
				return
			sent_romerol = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = /datum/pod_style/syndicate,
				"spawn" = /obj/item/storage/box/syndie_kit/romerol,
			))
