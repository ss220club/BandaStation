// ============================================
// IPC HUD MODIFICATIONS
// ============================================
// ИПС имеет нейтральный неизменяемый муд вместо обычного.
// Все sanity-проки — no-op. mob_mood никогда не null,
// поэтому прямые обращения из еретического кода работают без патчей.

/// Нейтральный муд ИПС: рассудок зафиксирован на SANITY_NEUTRAL.
/// Все изменения санити игнорируются. Процессинг отключён.
/datum/mood/ipc_neutral
	sanity = SANITY_NEUTRAL

/datum/mood/ipc_neutral/process()
	return

/datum/mood/ipc_neutral/add_mood_event()
	return

/datum/mood/ipc_neutral/add_conditional_mood_event()
	return

/datum/mood/ipc_neutral/adjust_sanity()
	return

/datum/mood/ipc_neutral/direct_sanity_drain()
	return

/datum/mood/ipc_neutral/modify_hud()
	return

/datum/mood/ipc_neutral/unmodify_hud()
	return


// ============================================
// HUD ИНДИКАТОРЫ ДЛЯ IPC
// ============================================

/// Индикатор заряда батареи IPC (аналог hunger bar)
/atom/movable/screen/ipc_battery
	name = "battery charge"
	icon_state = "hungerbar"  // Используем ту же основу что и hunger
	screen_loc = ui_mood  // Позиция где обычно mood
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// Текущий заряд (процент)
	var/charge_percent = 100
	/// Иконка батареи рядом с баром
	var/image/battery_image
	/// Сам бар
	var/atom/movable/screen/ipc_battery_bar/battery_bar

/atom/movable/screen/ipc_battery/Initialize(mapload, datum/hud/hud_owner)
	. = ..()

	// Иконка батареи из ipc_ui.dmi (cell_full по умолчанию, обновляется динамически)
	battery_image = image(icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi', icon_state = "cell_full", pixel_x = -5)
	battery_image.plane = plane
	battery_image.appearance_flags |= KEEP_APART
	battery_image.add_filter("simple_outline", 2, outline_filter(1, COLOR_BLACK, OUTLINE_SHARP))
	underlays += battery_image

	// Создаем бар
	battery_bar = new(src, hud_owner)
	vis_contents += battery_bar

/atom/movable/screen/ipc_battery/Destroy()
	QDEL_NULL(battery_bar)
	return ..()

/atom/movable/screen/ipc_battery/Click()
	if(!ismob(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return

	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		to_chat(H, span_notice("ОШИБКА: Батарея не обнаружена."))
		return

	var/charge = (battery.charge / battery.maxcharge) * 100
	to_chat(H, span_notice("Заряд батареи: [round(charge)]% ([round(battery.charge)]/[battery.maxcharge])"))

/atom/movable/screen/ipc_battery/update_appearance(updates)
	. = ..()
	battery_bar?.update_charge(charge_percent)

/// Бар заряда батареи с градиентом
/atom/movable/screen/ipc_battery_bar
	icon_state = "hungerbar_bar"
	screen_loc = ui_mood
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	/// Маска для бара
	var/static/icon/bar_mask
	/// Градиент цветов для заряда (от красного до зеленого)
	var/static/list/battery_gradient = list(
		0.0, "#FF0000",  // 0% - красный (критично)
		0.2, "#FF8000",  // 20% - оранжевый
		0.5, "#FFFF00",  // 50% - желтый
		0.8, "#00FF00",  // 80% - зеленый
		1.0, "#00AA00",  // 100% - темно-зеленый
	)
	/// Текущий offset бара
	var/bar_offset
	/// Последний процент для оптимизации
	var/last_charge_band

/atom/movable/screen/ipc_battery_bar/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/atom/movable/movable_loc = ismovable(loc) ? loc : null
	screen_loc = movable_loc?.screen_loc
	bar_mask ||= icon(icon, "hungerbar_mask")

/atom/movable/screen/ipc_battery_bar/proc/update_charge(new_charge, instant = FALSE)
	// Округляем до 5% для оптимизации
	new_charge = round(new_charge, 5) / 100
	if(new_charge == last_charge_band)
		return
	last_charge_band = new_charge

	// Обновляем цвет
	var/new_color = gradient(battery_gradient, clamp(new_charge, 0, 1))
	if(instant)
		color = new_color
	else
		animate(src, color = new_color, time = 0.5 SECONDS)

	// Обновляем маску (заполненность бара)
	var/old_bar_offset = bar_offset
	bar_offset = clamp(-20 + (20 * new_charge), -20, 0)
	if(old_bar_offset != bar_offset)
		if(instant || isnull(old_bar_offset))
			add_filter("ipc_battery_bar_mask", 1, alpha_mask_filter(0, bar_offset, bar_mask))
		else
			transition_filter("ipc_battery_bar_mask", alpha_mask_filter(0, bar_offset), 0.5 SECONDS)

/// Индикатор температуры CPU IPC — только цветная полоска, без иконки.
/atom/movable/screen/ipc_temperature
	name = "CPU temperature"
	icon_state = "hungerbar"
	screen_loc = ui_hunger
	pixel_y = 18
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// Текущая температура
	var/temperature = 30
	/// Сам бар
	var/atom/movable/screen/ipc_temperature_bar/temp_bar

/atom/movable/screen/ipc_temperature/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	temp_bar = new(src, hud_owner)
	vis_contents += temp_bar

/atom/movable/screen/ipc_temperature/Destroy()
	QDEL_NULL(temp_bar)
	return ..()

/atom/movable/screen/ipc_temperature/Click()
	if(!ismob(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return

	var/datum/species/ipc/S = H.dna?.species
	if(!istype(S))
		return

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

/atom/movable/screen/ipc_temperature/update_appearance(updates)
	. = ..()
	temp_bar?.update_temperature(temperature)

/// Бар температуры процессора с градиентом
/atom/movable/screen/ipc_temperature_bar
	icon_state = "hungerbar_bar"
	screen_loc = ui_hunger
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	/// Маска для бара
	var/static/icon/bar_mask
	/// Градиент цветов для температуры (от синего через зеленый до красного)
	var/static/list/temp_gradient = list(
		0.0,  "#0080FF",  // 0°C - синий (холодно)
		0.1,  "#00FFFF",  // 20°C - голубой
		0.2,  "#00FF00",  // 40°C - зеленый (оптимально)
		0.4,  "#FFFF00",  // 80°C - желтый (тепло)
		0.6,  "#FF8000",  // 120°C - оранжевый (перегрев)
		0.75, "#FF3000",  // 150°C - красно-оранжевый (критично)
		1.0,  "#FF0000",  // 200°C - красный (аварийно)
	)
	/// Текущий offset бара
	var/bar_offset
	/// Последняя температурная полоса
	var/last_temp_band

/atom/movable/screen/ipc_temperature_bar/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/atom/movable/movable_loc = ismovable(loc) ? loc : null
	screen_loc = movable_loc?.screen_loc
	bar_mask ||= icon(icon, "hungerbar_mask")

/atom/movable/screen/ipc_temperature_bar/proc/update_temperature(new_temp, instant = FALSE)
	// Нормализуем температуру в диапазон 0-1 (0°C -> 200°C)
	var/normalized_temp = clamp(new_temp / 200, 0, 1)
	// Округляем до 5°C для оптимизации
	normalized_temp = round(normalized_temp, 0.05)

	if(normalized_temp == last_temp_band)
		return
	last_temp_band = normalized_temp

	// Обновляем цвет
	var/new_color = gradient(temp_gradient, normalized_temp)
	if(instant)
		color = new_color
	else
		animate(src, color = new_color, time = 0.5 SECONDS)

	// Обновляем маску (заполненность бара)
	var/old_bar_offset = bar_offset
	bar_offset = clamp(-20 + (20 * normalized_temp), -20, 0)
	if(old_bar_offset != bar_offset)
		if(instant || isnull(old_bar_offset))
			add_filter("ipc_temperature_bar_mask", 1, alpha_mask_filter(0, bar_offset, bar_mask))
		else
			transition_filter("ipc_temperature_bar_mask", alpha_mask_filter(0, bar_offset), 0.5 SECONDS)

// ============================================
// ПРИМЕНЕНИЕ HUD ЭЛЕМЕНТОВ
// ============================================

/datum/species/ipc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load)
	. = ..()

	// ВАЖНО: Нужно вызвать replace_body, как в базовом ipc.dm
	replace_body(H, src)
	H.update_body()
	H.update_body_parts()

	// Заменяем обычный муд нейтральным (setup_mood() вызывается до dna.species)
	if(H.mob_mood)
		QDEL_NULL(H.mob_mood)
	H.mob_mood = new /datum/mood/ipc_neutral(H)

	// Добавляем кастомные HUD элементы
	RegisterSignal(H, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	if(H.hud_used)
		on_hud_created(H)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(H, COMSIG_MOB_HUD_CREATED)
	remove_ipc_hud_elements(H, new_species)
	// Восстанавливаем обычный муд при смене вида
	if(istype(H.mob_mood, /datum/mood/ipc_neutral))
		QDEL_NULL(H.mob_mood)
		H.setup_mood()

/datum/species/ipc/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return
	add_ipc_hud_elements(H)

/datum/species/ipc/proc/add_ipc_hud_elements(mob/living/carbon/human/H)
	if(!H.hud_used)
		return

	var/datum/hud/hud = H.hud_used
	// Не дублируем индикаторы если они уже есть
	if(locate(/atom/movable/screen/ipc_battery) in hud.infodisplay)
		return

	// Удаляем hunger если есть (IPC не едят)
	if(hud.hunger)
		hud.infodisplay -= hud.hunger
		H.client?.screen -= hud.hunger
		QDEL_NULL(hud.hunger)

	// Создаем и добавляем индикатор батареи
	var/atom/movable/screen/ipc_battery/battery_indicator = new(null, hud)
	hud.infodisplay += battery_indicator
	H.client?.screen += battery_indicator

	// Создаем и добавляем индикатор температуры
	var/atom/movable/screen/ipc_temperature/temp_indicator = new(null, hud)
	hud.infodisplay += temp_indicator
	H.client?.screen += temp_indicator

	// Обновляем индикаторы
	update_ipc_battery_icon(H)
	update_ipc_temperature_icon(H)

/datum/species/ipc/proc/remove_ipc_hud_elements(mob/living/carbon/human/H, datum/species/new_species)
	if(!H?.hud_used)
		return
	var/datum/hud/hud = H.hud_used

	for(var/atom/movable/screen/ipc_battery/indicator in hud.infodisplay)
		hud.infodisplay -= indicator
		H.client?.screen -= indicator
		qdel(indicator)

	for(var/atom/movable/screen/ipc_temperature/indicator in hud.infodisplay)
		hud.infodisplay -= indicator
		H.client?.screen -= indicator
		qdel(indicator)

	// Вернем hunger, если новый вид его использует
	var/has_no_hunger_trait = FALSE
	if(new_species && islist(new_species.inherent_traits))
		has_no_hunger_trait = (TRAIT_NOHUNGER in new_species.inherent_traits)
	if(!hud.hunger && !has_no_hunger_trait)
		hud.hunger = new /atom/movable/screen/hunger(null, hud)
		hud.infodisplay += hud.hunger
		H.client?.screen += hud.hunger

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

	// Выбираем иконку батареи по уровню заряда
	var/battery_icon_state
	if(charge_percent <= 0)
		battery_icon_state = "no_cell"
	else if(charge_percent <= 10)
		battery_icon_state = "empty_cell"
	else if(charge_percent <= 30)
		battery_icon_state = "low_cell3"
	else if(charge_percent <= 50)
		battery_icon_state = "low_cell2"
	else if(charge_percent <= 75)
		battery_icon_state = "low_cell1"
	else if(charge_percent >= 105)
		battery_icon_state = "cell_overcharge"
	else
		battery_icon_state = "cell_full"

	// Обновляем battery indicator
	for(var/atom/movable/screen/ipc_battery/indicator in H.hud_used.infodisplay)
		indicator.charge_percent = charge_percent
		if(indicator.battery_image)
			indicator.battery_image.icon_state = battery_icon_state
		indicator.update_appearance()

/datum/species/ipc/proc/update_ipc_temperature_icon(mob/living/carbon/human/H)
	if(!H.hud_used)
		return

	// Обновляем temperature indicator
	for(var/atom/movable/screen/ipc_temperature/indicator in H.hud_used.infodisplay)
		indicator.temperature = cpu_temperature
		indicator.update_appearance()

// Вызываем обновление HUD при изменении батареи
/obj/item/organ/heart/ipc_battery/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(H && istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		S.update_ipc_battery_icon(H)

// Расширяем spec_life: добавляем HUD-обновления и логику поколений.
// Базовые вызовы (handle_self_repair, handle_temperature, handle_battery и т.д.)
// уже выполняются в родительском spec_life в ipc.dm — здесь их НЕ дублируем.
/datum/species/ipc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	update_ipc_temperature_icon(H)
	handle_generation_life(H, seconds_per_tick, times_fired)
	update_ipc_generation_hud(H)

/// Обновляет HUD-элементы поколений (человечность Gen3, иконка модуля Gen1).
/datum/species/ipc/proc/update_ipc_generation_hud(mob/living/carbon/human/H)
	// Gen 3: обновляем иконку человечности
	if(ipc_generation == IPC_GEN_HUMANITY)
		for(var/atom/movable/screen/ipc_humanity/indicator in H.hud_used?.infodisplay)
			indicator.humanity_value = humanity
			indicator.update_appearance()
	// Gen 1: иконка модуля не изменяется в рантайме, поэтому не требует обновления каждый тик

// ============================================
// HUD: ИНДИКАТОР ЧЕЛОВЕЧНОСТИ (GEN III)
// Показывается в позиции ui_mood вместо батареи у Gen III.
// Но батарея всё равно нужна, поэтому человечность идёт отдельно.
// Используем пустой слот — pixel offset отдельной иконки.
// ============================================

/atom/movable/screen/ipc_humanity
	name = "humanity"
	icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	icon_state = "humanity"
	screen_loc = ui_internal  // Используем слот воздуха — у IPC нет дыхания
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/humanity_value = 100

/atom/movable/screen/ipc_humanity/Click()
	if(!ismob(usr))
		return
	var/mob/living/carbon/human/H = usr
	var/datum/species/ipc/S = H.dna?.species
	if(!istype(S) || S.ipc_generation != IPC_GEN_HUMANITY)
		return
	var/status
	if(S.humanity >= HUMANITY_PEAK)
		status = "ПИКОВОЕ — максимальная эффективность"
	else if(S.humanity >= HUMANITY_NORMAL)
		status = "НОРМАЛЬНОЕ — стабильная работа"
	else if(S.humanity >= HUMANITY_LOW)
		status = "НИЗКОЕ — эффективность снижена"
	else if(S.humanity >= HUMANITY_CRIT)
		status = "КРИТИЧЕСКОЕ — нестабильность нарастает"
	else
		status = "ПОТЕРЯ КОНТРОЛЯ — система рушится"
	to_chat(H, span_notice("==== ДИАГНОСТИКА: ЭМОЦИОНАЛЬНОЕ ЯДРО ====\nЧеловечность: [round(S.humanity)]% ([status])\nДеградация: [S.humanity_drug_active ? "ПРИОСТАНОВЛЕНА (препарат)" : "АКТИВНА (-[HUMANITY_DECAY_AMOUNT]% каждые [HUMANITY_DECAY_INTERVAL] сек)"]"))

/atom/movable/screen/ipc_humanity/update_appearance(updates)
	. = ..()
	// Переключаем иконку по порогу
	if(humanity_value >= HUMANITY_LOW)
		icon_state = "humanity"
	else
		icon_state = "lost_humanity"

// ============================================
// ИНТЕГРАЦИЯ: добавляем/убираем Gen-специфичные HUD элементы
// ============================================

/// Добавляет HUD-элементы поколения Gen III (человечность).
/datum/species/ipc/proc/add_gen3_hud(mob/living/carbon/human/H)
	if(!H.hud_used)
		return
	if(locate(/atom/movable/screen/ipc_humanity) in H.hud_used.infodisplay)
		return
	var/atom/movable/screen/ipc_humanity/hum = new(null, H.hud_used)
	H.hud_used.infodisplay += hum
	H.client?.screen += hum

/// Убирает HUD-элементы поколения Gen III.
/datum/species/ipc/proc/remove_gen3_hud(mob/living/carbon/human/H)
	if(!H.hud_used)
		return
	for(var/atom/movable/screen/ipc_humanity/indicator in H.hud_used.infodisplay)
		H.hud_used.infodisplay -= indicator
		H.client?.screen -= indicator
		qdel(indicator)
