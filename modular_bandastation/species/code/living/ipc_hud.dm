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

	// Иконка батареи рядом с баром
	battery_image = image(icon = 'icons/obj/machines/cell_charger.dmi', icon_state = "cell", pixel_x = -5)
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

/// Индикатор температуры CPU IPC (аналог hunger bar)
/atom/movable/screen/ipc_temperature
	name = "CPU temperature"
	icon_state = "hungerbar"  // Используем ту же основу
	screen_loc = ui_hunger  // Позиция где обычно hunger
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// Текущая температура
	var/temperature = 30
	/// Иконка термометра рядом с баром
	var/image/temp_image
	/// Сам бар
	var/atom/movable/screen/ipc_temperature_bar/temp_bar

/atom/movable/screen/ipc_temperature/Initialize(mapload, datum/hud/hud_owner)
	. = ..()

	// Иконка термометра рядом с баром
	temp_image = image(icon = 'icons/obj/devices/tool.dmi', icon_state = "thermometer", pixel_x = -5)
	temp_image.plane = plane
	temp_image.appearance_flags |= KEEP_APART
	temp_image.add_filter("simple_outline", 2, outline_filter(1, COLOR_BLACK, OUTLINE_SHARP))
	underlays += temp_image

	// Создаем бар
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
		0.0, "#0080FF",  // 0°C - синий (холодно)
		0.15, "#00FFFF", // 20°C - голубой
		0.3, "#00FF00",  // 40°C - зеленый (оптимально)
		0.6, "#FFFF00",  // 80°C - желтый (тепло)
		0.9, "#FF8000",  // 120°C - оранжевый (перегрев)
		1.0, "#FF0000",  // 130°C+ - красный (критично)
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
	// Нормализуем температуру в диапазон 0-1 (0°C -> 130°C)
	var/normalized_temp = clamp(new_temp / 130, 0, 1)
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

	// Удаляем mood datum если он есть
	if(H.mob_mood)
		QDEL_NULL(H.mob_mood)

	// Добавляем кастомные HUD элементы
	RegisterSignal(H, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	if(H.hud_used)
		on_hud_created(H)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(H, COMSIG_MOB_HUD_CREATED)
	remove_ipc_hud_elements(H, new_species)

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
	battery_indicator.hud = hud
	hud.infodisplay += battery_indicator
	H.client?.screen += battery_indicator

	// Создаем и добавляем индикатор температуры
	var/atom/movable/screen/ipc_temperature/temp_indicator = new(null, hud)
	temp_indicator.hud = hud
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

	// Обновляем battery indicator
	for(var/atom/movable/screen/ipc_battery/indicator in H.hud_used.infodisplay)
		indicator.charge_percent = charge_percent
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

// Вызываем обновление HUD при изменении температуры в spec_life
/datum/species/ipc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	handle_self_repair(H)
	handle_temperature(H)
	handle_battery(H)
	update_ipc_temperature_icon(H)
