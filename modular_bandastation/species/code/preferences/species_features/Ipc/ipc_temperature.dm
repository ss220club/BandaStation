#include "_ipc_defines.dm"
// ============================================
// РАСШИРЕННАЯ ОБРАБОТКА ТЕМПЕРАТУРЫ
// ============================================

/datum/species/ipc/proc/get_temperature_state()
	// Определяем текущее состояние температуры
	if(cpu_temperature < IPC_TEMP_CRITICAL_LOW)
		return IPC_TEMP_STATE_COLD
	else if(cpu_temperature < IPC_TEMP_OPTIMAL_HIGH)
		return IPC_TEMP_STATE_OPTIMAL
	else if(cpu_temperature < IPC_TEMP_NEUTRAL_HIGH)
		return IPC_TEMP_STATE_NEUTRAL
	else if(cpu_temperature < IPC_TEMP_OVERHEAT_MID)
		return IPC_TEMP_STATE_WARM
	else if(cpu_temperature < IPC_TEMP_OVERHEAT_HIGH)
		return IPC_TEMP_STATE_HOT
	else if(cpu_temperature < IPC_TEMP_CRITICAL_HIGH)
		return IPC_TEMP_STATE_CRITICAL
	else
		return IPC_TEMP_STATE_BURNING

/datum/species/ipc/proc/get_temperature_effects(mob/living/carbon/human/H)
	// Возвращает эффекты текущей температуры
	var/state = get_temperature_state()

	switch(state)
		if(IPC_TEMP_STATE_COLD)
			// <20°C: -10% скорости
			return list("speed_mod" = 0.9, "damage" = 0, "description" = "Переохлаждение")

		if(IPC_TEMP_STATE_OPTIMAL)
			// 20-40°C: +10% скорости (оптимальное состояние)
			return list("speed_mod" = 1.1, "damage" = 0, "description" = "Оптимальное состояние")

		if(IPC_TEMP_STATE_NEUTRAL)
			// 40-80°C: нормальное состояние
			return list("speed_mod" = 1.0, "damage" = 0, "description" = "Нормальное состояние")

		if(IPC_TEMP_STATE_WARM)
			// 80-90°C: -10% скорости
			return list("speed_mod" = 0.9, "damage" = 0, "description" = "Перегрев")

		if(IPC_TEMP_STATE_HOT)
			// 90-120°C: -1 урон каждые 30 секунд
			return list("speed_mod" = 0.9, "damage" = 1, "damage_interval" = 30, "description" = "Сильный перегрев")

		if(IPC_TEMP_STATE_CRITICAL)
			// 120-130°C: -2 урон каждые 15 секунд, шанс потери стамины
			return list("speed_mod" = 0.9, "damage" = 2, "damage_interval" = 15, "stamina_loss" = TRUE, "description" = "Критический перегрев")

		if(IPC_TEMP_STATE_BURNING)
			// 130+°C: -3 урон каждые 10 секунд, 50% шанс крита
			return list("speed_mod" = 0.9, "damage" = 3, "damage_interval" = 10, "crit_chance" = 50, "description" = "Процессор горит")

	return list("speed_mod" = 1.0, "damage" = 0)

/datum/species/ipc/proc/apply_temperature_effects(mob/living/carbon/human/H)
	// Применяем эффекты температуры
	var/list/effects = get_temperature_effects(H)

	// Модификатор скорости
	if(effects["speed_mod"])
		H.add_or_update_variable_movespeed_modifier(
			/datum/movespeed_modifier/ipc_temperature,
			update = TRUE,
			multiplicative_slowdown = (1 - effects["speed_mod"]) * 2
		)

	// Урон от перегрева
	if(effects["damage"] && effects["damage_interval"])
		if(world.time % (effects["damage_interval"] * 10) == 0)
			H.adjust_fire_loss(effects["damage"])
			to_chat(H, "<span class='danger'>ПРЕДУПРЕЖДЕНИЕ: Критический перегрев! Получен урон от высокой температуры.</span>")

	// Потеря стамины
	if(effects["stamina_loss"] && prob(10))
		H.adjust_stamina_loss(20)
		to_chat(H, "<span class='warning'>Предупреждение: Системы нестабильны из-за перегрева.</span>")

	// Шанс крита
	if(effects["crit_chance"] && prob(effects["crit_chance"]))
		to_chat(H, "<span class='userdanger'>КРИТИЧЕСКАЯ ОШИБКА: Системный сбой!</span>")
		H.Paralyze(20)

// ============================================
// СИСТЕМА ОХЛАЖДЕНИЯ
// ============================================

/datum/species/ipc/proc/apply_passive_cooling(mob/living/carbon/human/H)
	// Пассивное охлаждение от окружающей среды
	var/turf/T = get_turf(H)
	if(!T)
		return

	var/datum/gas_mixture/environment = T.return_air()
	if(!environment)
		return

	var/env_temp = environment.temperature - T0C // Конвертируем в Цельсий

	// Охлаждаемся/нагреваемся в зависимости от окружения
	if(env_temp < cpu_temperature)
		// Окружение холоднее - охлаждаемся
		var/cooling_amount = min((cpu_temperature - env_temp) * 0.01, cpu_cooling_rate * 2)
		cpu_temperature = max(cpu_temperature - cooling_amount, env_temp)
	else if(env_temp > cpu_temperature && cpu_heating_from_environment)
		// Окружение горячее - нагреваемся
		var/heating_amount = min((env_temp - cpu_temperature) * 0.005, cpu_cooling_rate)
		cpu_temperature = min(cpu_temperature + heating_amount, env_temp)

/datum/species/ipc/proc/apply_active_cooling(mob/living/carbon/human/H, amount)
	// Активное охлаждение (от предметов, абилок и т.д.)
	cpu_temperature = max(cpu_temperature - amount, IPC_TEMP_OPTIMAL_LOW)
	to_chat(H, "<span class='notice'>Системы охлаждения активированы. Температура снижена до [round(cpu_temperature)]°C.</span>")

// ============================================
// ТЕРМОПАСТА
// ============================================

/obj/item/ipc_thermal_paste
	name = "thermal paste"
	desc = "Высококачественная термопаста для охлаждения процессоров IPC."
	icon = 'icons/bandastation/mob/species/ipc/chemical.dmi'
	icon_state = "bottle"
	w_class = WEIGHT_CLASS_TINY

	var/cooling_amount = 10
	var/uses = 3

/obj/item/ipc_thermal_paste/afterattack(atom/target, mob/user, proximity)
	. = ..()

	if(!proximity)
		return

	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target

	if(!istype(H.dna.species, /datum/species/ipc))
		to_chat(user, "<span class='warning'>[H] не является IPC!</span>")
		return

	if(uses <= 0)
		to_chat(user, "<span class='warning'>[src] пуст!</span>")
		return

	user.visible_message(
		"<span class='notice'>[user] наносит термопасту на процессор [H].</span>",
		"<span class='notice'>Вы наносите термопасту на процессор [H].</span>"
	)

	var/datum/species/ipc/S = H.dna.species
	S.apply_active_cooling(H, cooling_amount)

	uses--

	if(uses <= 0)
		qdel(src)

// ============================================
// ОХЛАДИТЕЛЬНЫЙ БЛОК (RnD)
// ============================================

/obj/item/ipc_cooling_unit
	name = "emergency cooling unit"
	desc = "Экстренный охладительный блок для IPC. Одноразовый."
	icon = 'icons/bandastation/mob/species/ipc/device.dmi'
	icon_state = "heat_sink"
	w_class = WEIGHT_CLASS_SMALL

	var/cooling_amount = 30
	var/duration = 5 MINUTES
	var/used = FALSE

/obj/item/ipc_cooling_unit/afterattack(atom/target, mob/user, proximity)
	. = ..()

	if(!proximity || used)
		return

	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target

	if(!istype(H.dna.species, /datum/species/ipc))
		to_chat(user, "<span class='warning'>[H] не является IPC!</span>")
		return

	user.visible_message(
		"<span class='notice'>[user] активирует охладительный блок на [H].</span>",
		"<span class='notice'>Вы активируете охладительный блок на [H].</span>"
	)

	var/datum/species/ipc/S = H.dna.species
	S.apply_active_cooling(H, cooling_amount)

	used = TRUE

	// Удаляем через duration
	spawn(duration)
		to_chat(H, "<span class='warning'>Охладительный блок исчерпан.</span>")
		qdel(src)

// ============================================
// UI ДЛЯ ОТОБРАЖЕНИЯ ТЕМПЕРАТУРЫ
// ============================================

/datum/species/ipc/proc/get_temperature_color()
	// Возвращает цвет для UI в зависимости от температуры
	var/state = get_temperature_state()

	switch(state)
		if(IPC_TEMP_STATE_COLD)
			return "#00BFFF" // Голубой
		if(IPC_TEMP_STATE_OPTIMAL)
			return "#00FF00" // Зеленый
		if(IPC_TEMP_STATE_NEUTRAL)
			return "#FFFF00" // Желтый
		if(IPC_TEMP_STATE_WARM)
			return "#FFA500" // Оранжевый
		if(IPC_TEMP_STATE_HOT)
			return "#FF4500" // Красно-оранжевый
		if(IPC_TEMP_STATE_CRITICAL)
			return "#FF0000" // Красный
		if(IPC_TEMP_STATE_BURNING)
			return "#8B0000" // Темно-красный

	return "#FFFFFF"

/datum/hud/human/proc/update_ipc_temperature_display(mob/living/carbon/human/H)
	// Обновляем отображение температуры в HUD
	// Будет реализовано полностью в Приоритете 2
	pass

// ============================================
// МОДИФИКАТОР СКОРОСТИ ОТ ТЕМПЕРАТУРЫ
// ============================================

/datum/movespeed_modifier/ipc_temperature
	variable = TRUE
	multiplicative_slowdown = 0
