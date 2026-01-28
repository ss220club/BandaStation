/datum/traitor_objective/ultimate/dark_matteor
	name = "Призовите сингулярность из тёмной материи на станцию."
	description = "Отправляйтесь в %AREA% чтобы получить специальный ЕМАГ и нужное количество спутников, \
	после нужного количества перенастройки спутников емагом ПРИЙДЁТ ОНО. Внимание: Данная сингулярность будет преследовать ЛЮБОЕ живое существо, включая вас."

	//this is a prototype so this progression is for all basic level kill objectives

	///area type the objective owner must be in to receive the satellites
	var/area/satellites_spawnarea_type
	///checker on whether we have sent the satellites yet.
	var/sent_satellites = FALSE

/datum/traitor_objective/ultimate/dark_matteor/can_generate_objective(generating_for, list/possible_duplicates)
	. = ..()
	if(!.)
		return FALSE
	if(SSmapping.is_planetary())
		return FALSE //meteors can't spawn on planets
	return TRUE

/datum/traitor_objective/ultimate/dark_matteor/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(!ispath(possible_area, /area/station/maintenance/solars) && !ispath(possible_area, /area/station/solars))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	satellites_spawnarea_type = pick(possible_areas)
	replace_in_name("%AREA%", initial(satellites_spawnarea_type.name))
	return TRUE

/datum/traitor_objective/ultimate/dark_matteor/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_satellites)
		buttons += add_ui_button("", "Нажатие этой кнопки вызовет капсулу которая содержит украденные спутники", "satellite", "satellite")
	return buttons

/datum/traitor_objective/ultimate/dark_matteor/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("satellite")
			if(sent_satellites)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != satellites_spawnarea_type)
				to_chat(user, span_warning("Отправляйтесь в [initial(satellites_spawnarea_type.name)] чтобы заполучить спутники."))
				return
			sent_satellites = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = /datum/pod_style/syndicate,
				"spawn" = /obj/structure/closet/crate/engineering/smuggled_meteor_shields,
			))

/obj/structure/closet/crate/engineering/smuggled_meteor_shields

/obj/structure/closet/crate/engineering/smuggled_meteor_shields/PopulateContents()
	..()
	for(var/i in 1 to 11)
		new /obj/machinery/satellite/meteor_shield(src)
	new /obj/item/card/emag/meteor_shield_recalibrator(src)
	new /obj/item/paper/dark_matteor_summoning(src)

/obj/item/paper/dark_matteor_summoning
	name = "записка - призыв сингуляроности из тёмной материи"
	default_raw_text = {"
		Призыв сингулярности из тёмной материи.<br>
		<br>
		<br>
		Оперативник, этот ящик содержит 10+1(1 запасной) спуников против метеоритов, украденных с логистической станции НТ. Твоя миссия заключается
		в том чтобы ты распложил спутники рядом со станцией, а также перенастроих их своим специальным для этого Емагом. Важно: ЕМАГ уходит на перезарядку
		на 30 секунд после каждой настройки, также НТ обнаружит странные сигналы которые издают перенастроенные спутники. Это значит
		у тебя есть 5 минут для тихой работы, и 1 минута после того как об тебе сообщит ЦК НТ.<br>
		<br>
		Это крайне опасная операция. Тебе крайне будет нужна удача, оружие и подготовка. А какая награда?
		Сингулярность уничтожит под чистую эту станцию.<br>
		<br>
		<b>**Смерть Нанотрейзен.**</b>
"}

/obj/item/card/emag/meteor_shield_recalibrator
	name = "cryptographic satellite recalibrator"
	desc = "Этот ЕМАГ настроен на более эффективное перепрограммирование метеоритных спутников."
