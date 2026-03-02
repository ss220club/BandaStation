/datum/traitor_objective/ultimate/battle_royale
	name = "Установите в экипаж скрытые импланты, затем заставьте их сражаться насмерть на подписочных стриминговых сервисах."
	description = "Пройдите в %AREA% и получите комплект для проведения стрима по Баттл Роялю. \
		Используйте имплантер на экипаже, чтобы тайно внедрить им взрывное устройство. \
		Как только у вас будет как минимум шесть участников, используйте пульт для запуска прямой трансляции. \
		Если после десяти минут останется более одного участника, все импланты взорвутся."

	///Area type the objective owner must be in to receive the tools.
	var/area/kit_spawn_area
	///Whether the kit was sent already.
	var/equipped = FALSE

/datum/traitor_objective/ultimate/battle_royale/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(ispath(possible_area, /area/station/hallway) || ispath(possible_area, /area/station/security))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	kit_spawn_area = pick(possible_areas)
	replace_in_name("%AREA%", initial(kit_spawn_area.name))
	return TRUE

/datum/traitor_objective/ultimate/battle_royale/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!equipped)
		buttons += add_ui_button("", "Нажатие на кнопку вызовет капсулу с комплектом для стриминга.", "biohazard", "deliver_kit")
	return buttons

/datum/traitor_objective/ultimate/battle_royale/ui_perform_action(mob/living/user, action)
	. = ..()
	if(action != "deliver_kit" || equipped)
		return
	var/area/delivery_area = get_area(user)
	if(delivery_area.type != kit_spawn_area)
		to_chat(user, span_warning("Вы должны находится в [initial(kit_spawn_area.name)] чтобы получить комплект стримера."))
		return
	equipped = TRUE
	podspawn(list(
		"target" = get_turf(user),
		"style" = /datum/pod_style/syndicate,
		"spawn" = /obj/item/storage/box/syndie_kit/battle_royale,
	))
