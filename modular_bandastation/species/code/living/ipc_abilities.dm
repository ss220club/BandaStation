// ============================================
// IPC ABILITIES
// ============================================
// Абилки для IPC: разгон системы, и т.д.

/// Абилка разгона системы - увеличивает скорость действий за счет нагрева процессора
/datum/action/cooldown/ipc_overclock
	name = "Разгон системы"
	desc = "Ускоряет процессы взаимодействия на 40% за счет повышения температуры процессора. Нагревает процессор на 1°C каждые 5 секунд."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "rnd_sync"
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	cooldown_time = 2 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/ipc_overclock/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	// Доступна только для IPC
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

/datum/action/cooldown/ipc_overclock/Remove(mob/living/remove_from)
	var/mob/living/carbon/human/H = owner
	if(istype(H) && istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		if(S.overclock_active)
			deactivate_overclock(H, S)
	return ..()

/datum/action/cooldown/ipc_overclock/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE

	var/datum/species/ipc/S = H.dna.species

	// Toggle
	if(S.overclock_active)
		deactivate_overclock(H, S)
	else
		activate_overclock(H, S)

	StartCooldown()
	return TRUE

/datum/action/cooldown/ipc_overclock/proc/activate_overclock(mob/living/carbon/human/H, datum/species/ipc/S)
	S.overclock_active = TRUE
	background_icon_state = "bg_tech_blue_active"
	to_chat(H, span_notice("Разгон системы активирован! Скорость взаимодействия увеличена на [S.overclock_speed_bonus * 100]%."))
	to_chat(H, span_warning("ПРЕДУПРЕЖДЕНИЕ: Температура процессора будет повышаться!"))
	build_all_button_icons()

/datum/action/cooldown/ipc_overclock/proc/deactivate_overclock(mob/living/carbon/human/H, datum/species/ipc/S)
	S.overclock_active = FALSE
	background_icon_state = "bg_tech_blue"
	to_chat(H, span_notice("Разгон системы отключен. Процессор вернулся к нормальной работе."))
	build_all_button_icons()

/// Абилка для проверки текущей температуры процессора (CTRL+клик)
/datum/action/innate/ipc_check_temperature
	name = "Проверить температуру"
	desc = "Показывает текущую температуру процессора и активные системы охлаждения."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "scanner"
	background_icon_state = "bg_tech"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/ipc_check_temperature/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

/datum/action/innate/ipc_check_temperature/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return

	var/datum/species/ipc/S = H.dna.species

	// Определяем статус температуры
	var/temp_status
	switch(S.cpu_temperature)
		if(-INFINITY to 20)
			temp_status = "низкой (переохлаждение)"
		if(20 to 40)
			temp_status = "оптимальной"
		if(40 to 80)
			temp_status = "повышенной"
		if(80 to 90)
			temp_status = "высокой (перегрев)"
		if(90 to 120)
			temp_status = "критически высокой (сильный перегрев)"
		if(120 to 130)
			temp_status = "экстремальной (процессор горит)"
		if(130 to INFINITY)
			temp_status = "АВАРИЙНОЙ (процессор плавится)"

	// Формируем сообщение
	var/message = "==== ДИАГНОСТИКА ТЕМПЕРАТУРЫ ===="
	message += "\nТемпература процессора: [round(S.cpu_temperature, 0.1)]°C ([temp_status])"
	message += "\nОптимальный диапазон: [S.cpu_temp_optimal_min]-[S.cpu_temp_optimal_max]°C"

	// Активные системы охлаждения
	message += "\n\n--- Системы охлаждения ---"
	if(S.thermal_paste_active)
		var/time_left = round((S.thermal_paste_end_time - world.time) / 600, 0.1)
		message += "\n+ Термопаста: АКТИВНА ([time_left] мин осталось)"
	if(S.cooling_block_active)
		var/time_left = round((S.cooling_block_end_time - world.time) / 600, 0.1)
		message += "\n+ Охладительный блок: АКТИВЕН ([time_left] мин осталось)"
	if(S.improved_cooling_installed)
		message += "\n+ Улучшенная система охлаждения: УСТАНОВЛЕНА"

	// Разгон
	if(S.overclock_active)
		message += "\n\n--- Разгон ---"
		message += "\n+ Разгон системы: АКТИВЕН (+[S.overclock_speed_bonus * 100]% скорости)"

	to_chat(H, span_notice(message))
