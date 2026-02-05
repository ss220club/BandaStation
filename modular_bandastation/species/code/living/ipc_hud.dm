// ============================================
// IPC HUD MODIFICATIONS
// ============================================
// Отключает mood для IPC и добавляет кастомные HUD элементы
// для батареи и температуры процессора

/mob/living/carbon/human/setup_mood()
	// Если IPC - не создаем mood datum
	if(istype(dna?.species, /datum/species/ipc))
		return
	return ..()

// ============================================
// HUD ИНДИКАТОРЫ ДЛЯ IPC
// ============================================

// Screen object для отображения заряда батареи
/atom/movable/screen/mood/ipc_battery
	name = "battery charge"
	icon_state = "mood_neutral"  // Временно используем mood icons, можно заменить
	screen_loc = ui_mood  // Используем ту же позицию что и mood

/atom/movable/screen/mood/ipc_battery/Click()
	if(!ismob(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return

	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		to_chat(H, span_notice("ОШИБКА: Батарея не обнаружена."))
		return

	var/charge_percent = (battery.charge / battery.maxcharge) * 100
	to_chat(H, span_notice("Заряд батареи: [round(charge_percent)]%"))

// Screen object для отображения температуры процессора
/atom/movable/screen/mood/ipc_temperature
	name = "CPU temperature"
	icon_state = "mood_neutral"  // Временно используем mood icons, можно заменить
	screen_loc = ui_healthdoll  // Рядом с healthdoll

/atom/movable/screen/mood/ipc_temperature/Click()
	if(!ismob(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return

	var/datum/species/ipc/S = H.dna?.species
	if(!istype(S))
		return

	var/temp = S.cpu_temperature
	var/status = "оптимальном"
	if(temp < S.cpu_temp_optimal_min)
		status = "низкой"
	else if(temp > S.cpu_temp_optimal_max && temp < 80)
		status = "повышенной"
	else if(temp >= 80 && temp < 120)
		status = "высокой (перегрев!)"
	else if(temp >= 120)
		status = "критической (ОПАСНО!)"

	to_chat(H, span_notice("Температура процессора: [round(temp)]°C ([status])"))

// ============================================
// ПРИМЕНЕНИЕ HUD ЭЛЕМЕНТОВ
// ============================================

/datum/species/ipc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()

	// Удаляем mood datum если он есть
	if(H.mob_mood)
		QDEL_NULL(H.mob_mood)

	// Добавляем кастомные HUD элементы
	add_ipc_hud_elements(H)

/datum/species/ipc/proc/add_ipc_hud_elements(mob/living/carbon/human/H)
	if(!H.hud_used)
		return

	var/datum/hud/hud = H.hud_used

	// Удаляем старые индикаторы если они есть (предотвращаем дубликаты)
	for(var/atom/movable/screen/mood/ipc_battery/old_indicator in hud.static_inventory)
		hud.static_inventory -= old_indicator
		H.client?.screen -= old_indicator
		qdel(old_indicator)

	for(var/atom/movable/screen/mood/ipc_temperature/old_indicator in hud.static_inventory)
		hud.static_inventory -= old_indicator
		H.client?.screen -= old_indicator
		qdel(old_indicator)

	// Создаем и добавляем индикатор батареи
	var/atom/movable/screen/mood/ipc_battery/battery_indicator = new()
	battery_indicator.hud = hud
	hud.static_inventory += battery_indicator
	H.client?.screen += battery_indicator

	// Создаем и добавляем индикатор температуры
	var/atom/movable/screen/mood/ipc_temperature/temp_indicator = new()
	temp_indicator.hud = hud
	// Позиционируем рядом с голодом (который мы скрыли)
	temp_indicator.screen_loc = ui_hunger
	hud.static_inventory += temp_indicator
	H.client?.screen += temp_indicator

	// Обновляем индикаторы
	update_ipc_battery_icon(H)
	update_ipc_temperature_icon(H)

// ============================================
// ОБНОВЛЕНИЕ ИКОНОК HUD
// ============================================

/datum/species/ipc/proc/update_ipc_battery_icon(mob/living/carbon/human/H)
	if(!H.hud_used)
		return

	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		return

	var/charge_percent = (battery.charge / battery.maxcharge) * 100

	// Ищем battery indicator в HUD
	for(var/atom/movable/screen/mood/ipc_battery/indicator in H.hud_used.static_inventory)
		// Меняем icon_state в зависимости от заряда
		switch(charge_percent)
			if(80 to INFINITY)
				indicator.icon_state = "mood_happy"  // Зеленый
			if(50 to 80)
				indicator.icon_state = "mood_neutral"  // Желтый
			if(20 to 50)
				indicator.icon_state = "mood_sad"  // Оранжевый
			if(-INFINITY to 20)
				indicator.icon_state = "mood_insane"  // Красный

/datum/species/ipc/proc/update_ipc_temperature_icon(mob/living/carbon/human/H)
	if(!H.hud_used)
		return

	var/temp = cpu_temperature

	// Ищем temperature indicator в HUD
	for(var/atom/movable/screen/mood/ipc_temperature/indicator in H.hud_used.static_inventory)
		// Меняем icon_state в зависимости от температуры
		if(temp < cpu_temp_optimal_min)
			indicator.icon_state = "mood_sad"  // Холодно
		else if(temp >= cpu_temp_optimal_min && temp <= cpu_temp_optimal_max)
			indicator.icon_state = "mood_happy"  // Оптимально
		else if(temp > cpu_temp_optimal_max && temp < 80)
			indicator.icon_state = "mood_neutral"  // Тепло
		else if(temp >= 80 && temp < 120)
			indicator.icon_state = "mood_sad"  // Перегрев
		else
			indicator.icon_state = "mood_insane"  // Критический перегрев

// Вызываем обновление HUD при изменении батареи или температуры
/obj/item/organ/heart/ipc_battery/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(H && istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		S.update_ipc_battery_icon(H)
