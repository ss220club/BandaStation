/// Sends a diagnostic report for one canonical map tile to an administrator.
/proc/redspace_debug_report(client/user, turf/target)
	if(!user || !target || !SSredspace.is_supported_z(target.z))
		return

	var/value = SSredspace.get_value(target)
	var/state = SSredspace.get_state(target)
	var/datum/redspace_field_cell/cell = SSredspace.get_cell(target)
	var/datum/station_trait/redspace_activity/round_trait = SSredspace.get_round_trait()
	var/current_intensity = round_trait?.redspace_intensity
	var/list/report = list(
		"Редспейс на ([target.x], [target.y], [target.z])",
		"Значение: [round(value, 0.1)] ([redspace_state_name(state)])",
		"Фон: [round(SSredspace.context.background_value, 0.1)]",
		"Коэффициент зоны: [SSredspace.get_zone_coefficient(target, cell)]",
		"Профиль раунда: [SSredspace.context.active_profile_id]",
		"Интенсивность особенности: [isnull(current_intensity) ? "не выбрана" : "[redspace_intensity_name(current_intensity)] ([current_intensity])"]",
		"Активный шторм: [round_trait?.storm_active ? "да" : "нет"]",
		"Метрики: источники [length(SSredspace.field_sources)], ячейки [length(SSredspace.field_cells)], dirty-ячеек [length(SSredspace.dirty_cells)]/[length(SSredspace.currentrun)], выборок [SSredspace.metric_sample_count], расчётов [SSredspace.metric_value_calculation_count], проверок источников [SSredspace.metric_source_check_count], dirty поставлено/обработано [SSredspace.metric_dirty_cells_enqueued]/[SSredspace.metric_dirty_cells_processed], событий запущено/завершено [SSredspace.metric_events_started]/[SSredspace.metric_events_finished]",
		"Пики: ячейки [SSredspace.metric_peak_field_cells], dirty-ячеек [SSredspace.metric_peak_dirty_cells], источников в обработке [SSredspace.metric_peak_processing_sources]",
	)

	if(cell)
		report += "Ячейка: [cell.key], q=[cell.q], r=[cell.r]"
		report += "Кеш: [round(cell.value, 0.1)], предыдущее: [round(cell.previous_value, 0.1)]"
		report += "Последнее обновление: [cell.last_updated ? "[world.time - cell.last_updated] тиков назад" : "нет"]"
		report += "Причина последнего изменения: [cell.last_change_reason || "не указана"]"
		if(cell.pending_change_reason)
			report += "Причина ожидающего обновления: [cell.pending_change_reason]"
		if(!isnull(cell.forced_value))
			report += "Обычный override: [round(cell.forced_value, 0.1)]"
		if(!isnull(cell.event_override_value))
			report += "Event-only override: [round(cell.event_override_value, 0.1)]"
	else
		report += "Разреженная ячейка: не создана"

	var/source_count = 0
	for(var/source_key in SSredspace.field_sources)
		var/datum/redspace_field_source/source = SSredspace.field_sources[source_key]
		if(!source)
			continue
		var/contribution = source.get_contribution(target)
		if(!contribution)
			continue
		source_count++
		report += "Источник [source.get_debug_label()]: вклад [round(contribution, 0.1)]"
	if(!source_count)
		report += "Источники: нет локального вклада"

	to_chat(user, span_notice(report.Join("<br>")), confidential = TRUE)

/// Applies an ordinary or event-only explicit value to a turf selected by an administrator.
/proc/redspace_debug_set_cell_value(client/user, turf/target, event_only = FALSE)
	if(!user || !target || !SSredspace.is_supported_z(target.z))
		if(user)
			to_chat(user, span_warning("Этот тайл не находится на активном станционном z-уровне редспейса."), confidential = TRUE)
		return

	var/current_value = SSredspace.get_value(target)
	var/min_value = event_only ? REDSPACE_EVENT_MIN_VALUE : -100
	var/max_value = event_only ? 100 : REDSPACE_MAX_NORMAL_VALUE
	var/default_value = event_only ? REDSPACE_EVENT_MIN_VALUE : clamp(current_value, min_value, max_value)
	if(event_only && isnum(current_value))
		default_value = max(default_value, current_value)
	var/new_value = tgui_input_number(
		user,
		event_only ? "Новое event-only значение для текущей ячейки" : "Новое обычное значение для текущей ячейки",
		"Redspace Cell",
		default = default_value,
		max_value = max_value,
		min_value = min_value,
		round_value = !event_only,
	)
	if(isnull(new_value))
		return

	if(event_only)
		SSredspace.set_event_override(target, new_value, "установлен из debug-панели")
	else
		SSredspace.set_cell_value(target, new_value, "установлен из debug-панели")
	var/override_kind = event_only ? "event override" : "обычное значение"
	to_chat(user, span_notice("Значение ячейки установлено: [round(new_value, 0.1)] ([override_kind])."), confidential = TRUE)
	log_admin("[key_name(user)] set redspace [override_kind] to [new_value] at ([target.x], [target.y], [target.z]).")
	message_admins("[key_name_admin(user)] установил [override_kind] редспейса [new_value] на ([target.x], [target.y], [target.z]).")

/// Asks the administrator for a source to operate on. Returns the source id or null.
/proc/redspace_debug_pick_source(client/user)
	var/list/source_choices = list()
	for(var/source_key in SSredspace.field_sources)
		var/datum/redspace_field_source/source = SSredspace.field_sources[source_key]
		if(source)
			source_choices[source.get_debug_label()] = source.source_id
	if(!length(source_choices))
		to_chat(user, span_warning("Активных источников нет."), confidential = TRUE)
		return
	var/source_choice = tgui_input_list(user, "Какой источник?", "Redspace Source", source_choices)
	if(!source_choice)
		return
	return source_choices[source_choice]

/// Main in-round control surface for the first Redspace prototype.
ADMIN_VERB(redspace_debug_panel, R_DEBUG, "Redspace: Debug Panel", "Change the live Redspace field and run explicit test events.", ADMIN_CATEGORY_DEBUG)
	var/action = tgui_input_list(user, "Выберите операцию", "Redspace Debug", list(
		"Показать текущее состояние",
		"Установить фон раунда",
		"Изменить интенсивность особенности",
		"Установить значение ячейки",
		"Установить event-only значение",
		"Очистить значение ячейки",
		"Добавить тестовый источник",
		"Добавить горячую зону",
		"Добавить тестовую волну",
		"Изменить источник",
		"Удалить источник",
		"Локальное искажение 4-6",
		"Штормовой импульс 7-10",
		"Удар молнии редспейса",
		"Сбросить поле",
	))
	if(!action)
		return

	var/turf/current_turf = get_turf(user.mob)
	switch(action)
		if("Показать текущее состояние")
			redspace_debug_report(user, current_turf)

		if("Установить фон раунда")
			var/new_background = tgui_input_number(user, "Новое значение фона (-100..10)", "Redspace Background", SSredspace.context.background_value, REDSPACE_MAX_NORMAL_VALUE, -100)
			if(isnull(new_background))
				return
			SSredspace.set_background_value(new_background, "установлен из debug-панели")
			log_admin("[key_name(user)] set redspace background to [new_background].")
			message_admins("[key_name_admin(user)] установил фон редспейса: [new_background].")

		if("Изменить интенсивность особенности")
			var/datum/station_trait/redspace_activity/round_trait = SSredspace.get_round_trait()
			var/current_intensity = round_trait?.redspace_intensity
			var/list/intensity_choices = list(
				"Штиль" = REDSPACE_INTENSITY_CALM,
				"Возмущение" = REDSPACE_INTENSITY_DISTURBANCE,
				"Шторм" = REDSPACE_INTENSITY_STORM,
			)
			var/intensity_label = tgui_input_list(user, "Новая интенсивность (сейчас: [isnull(current_intensity) ? "не выбрана" : redspace_intensity_name(current_intensity)])", "Redspace Round Feature", intensity_choices)
			if(!intensity_label)
				return
			var/new_intensity = intensity_choices[intensity_label]
			if(SSredspace.set_round_intensity(new_intensity, "администратор изменил интенсивность редспейса"))
				to_chat(user, span_notice("Интенсивность редспейса изменена: [intensity_label]."), confidential = TRUE)
				log_admin("[key_name(user)] changed redspace round intensity to [new_intensity].")
				message_admins("[key_name_admin(user)] изменил интенсивность редспейса на [intensity_label].")

		if("Установить значение ячейки")
			redspace_debug_set_cell_value(user, current_turf)

		if("Установить event-only значение")
			redspace_debug_set_cell_value(user, current_turf, TRUE)

		if("Очистить значение ячейки")
			if(SSredspace.clear_cell_value(current_turf))
				to_chat(user, span_notice("Разреженная ячейка очищена."), confidential = TRUE)
				log_admin("[key_name(user)] cleared the redspace cell at ([current_turf?.x], [current_turf?.y], [current_turf?.z]).")
			else
				to_chat(user, span_warning("Для текущего тайла нет созданной разреженной ячейки."), confidential = TRUE)

		if("Добавить тестовый источник")
			if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
				to_chat(user, span_warning("Текущий тайл не находится на активном станционном z-уровне."), confidential = TRUE)
				return
			var/source_profile = tgui_input_list(user, "Профиль источника", "Redspace Source", list(REDSPACE_PROFILE_DEBUG, REDSPACE_PROFILE_DEMONIC))
			if(!source_profile)
				return
			var/source_strength = tgui_input_number(user, "Сила источника (-100..100)", "Redspace Source", 5, 100, -100)
			if(isnull(source_strength))
				return
			var/source_radius = tgui_input_number(user, "Радиус источника в тайлах (0..[REDSPACE_MAX_SOURCE_RADIUS])", "Redspace Source", 4, REDSPACE_MAX_SOURCE_RADIUS, 0)
			if(isnull(source_radius))
				return
			var/datum/redspace_field_source/source = SSredspace.register_source(current_turf, source_strength, source_radius, source_profile, null, "создан из debug-панели")
			if(source)
				to_chat(user, span_notice("Создан источник [source.get_debug_label()]."), confidential = TRUE)
				log_admin("[key_name(user)] registered redspace source [source.get_debug_label()].")
				message_admins("[key_name_admin(user)] создал источник редспейса [source.get_debug_label()].")

		if("Добавить горячую зону")
			if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
				to_chat(user, span_warning("Текущий тайл не находится на активном станционном z-уровне."), confidential = TRUE)
				return
			var/hotspot_profile = tgui_input_list(user, "Профиль горячей зоны", "Redspace Hotspot", list(REDSPACE_PROFILE_DEMONIC, REDSPACE_PROFILE_DEBUG))
			if(!hotspot_profile)
				return
			var/hotspot_strength = tgui_input_number(user, "Сила горячей зоны (-100..100)", "Redspace Hotspot", 6, 100, -100)
			if(isnull(hotspot_strength))
				return
			var/hotspot_radius = tgui_input_number(user, "Радиус в тайлах (0..[REDSPACE_MAX_SOURCE_RADIUS])", "Redspace Hotspot", 6, REDSPACE_MAX_SOURCE_RADIUS, 0)
			if(isnull(hotspot_radius))
				return
			var/hotspot_description = tgui_input_text(user, "Описание зоны для журнала (необязательно)", "Redspace Hotspot", "")
			var/datum/redspace_field_source/hotspot/hotspot = SSredspace.register_hotspot(current_turf, hotspot_strength, hotspot_radius, hotspot_profile, "создана из debug-панели", hotspot_description || null)
			if(hotspot)
				to_chat(user, span_notice("Создана горячая зона [hotspot.get_debug_label()]."), confidential = TRUE)
				log_admin("[key_name(user)] registered redspace hotspot [hotspot.get_debug_label()].")
				message_admins("[key_name_admin(user)] создал горячую зону редспейса [hotspot.get_debug_label()].")

		if("Добавить тестовую волну")
			if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
				to_chat(user, span_warning("Текущий тайл не находится на активном станционном z-уровне."), confidential = TRUE)
				return
			var/wave_profile = tgui_input_list(user, "Профиль волны", "Redspace Wave", list(REDSPACE_PROFILE_DEMONIC, REDSPACE_PROFILE_DEBUG))
			if(!wave_profile)
				return
			var/wave_amplitude = tgui_input_number(user, "Амплитуда волны (-10..10)", "Redspace Wave", default = 5, max_value = 10, min_value = -10)
			if(isnull(wave_amplitude))
				return
			var/wave_radius = tgui_input_number(user, "Радиус в тайлах (0..[REDSPACE_MAX_SOURCE_RADIUS])", "Redspace Wave", 4, REDSPACE_MAX_SOURCE_RADIUS, 0)
			if(isnull(wave_radius))
				return
			var/wave_direction = tgui_input_list(user, "Направление движения", "Redspace Wave", list(
				"север", "юг", "восток", "запад",
				"северо-восток", "северо-запад", "юго-восток", "юго-запад",
			))
			if(!wave_direction)
				return
			var/wave_speed = tgui_input_number(user, "Скорость в тайлах в секунду (0.1..10)", "Redspace Wave", default = 1, max_value = 10, min_value = 0.1, round_value = FALSE)
			if(isnull(wave_speed))
				return
			var/wave_lifetime = tgui_input_number(user, "Время жизни в секундах (1..600)", "Redspace Wave", 60, 600, 1)
			if(isnull(wave_lifetime))
				return
			var/list/direction_vectors = list(
				"север" = list(0, 1),
				"юг" = list(0, -1),
				"восток" = list(1, 0),
				"запад" = list(-1, 0),
				"северо-восток" = list(0.7071067811865476, 0.7071067811865476),
				"северо-запад" = list(-0.7071067811865476, 0.7071067811865476),
				"юго-восток" = list(0.7071067811865476, -0.7071067811865476),
				"юго-запад" = list(-0.7071067811865476, -0.7071067811865476),
			)
			var/list/wave_vector = direction_vectors[wave_direction]
			var/datum/redspace_field_source/wave/wave = SSredspace.register_wave_source(
				current_turf,
				wave_amplitude,
				wave_radius,
				wave_vector[1] * wave_speed,
				wave_vector[2] * wave_speed,
				wave_lifetime * (1 SECONDS),
				wave_profile,
				"создана из debug-панели",
			)
			if(wave)
				to_chat(user, span_notice("Создана волна [wave.get_debug_label()]."), confidential = TRUE)
				log_admin("[key_name(user)] registered redspace wave [wave.get_debug_label()].")
				message_admins("[key_name_admin(user)] создал волну редспейса [wave.get_debug_label()].")

		if("Изменить источник")
			var/source_id = redspace_debug_pick_source(user)
			if(isnull(source_id))
				return
			var/change_kind = tgui_input_list(user, "Что изменить?", "Redspace Source", list("Силу", "Позицию (текущий тайл)"))
			if(!change_kind)
				return
			switch(change_kind)
				if("Силу")
					var/new_strength = tgui_input_number(user, "Новая сила (-100..100)", "Redspace Source", 5, 100, -100)
					if(isnull(new_strength))
						return
					if(SSredspace.update_source_strength(source_id, new_strength, "сила изменена из debug-панели"))
						log_admin("[key_name(user)] changed redspace source #[source_id] strength to [new_strength].")
						message_admins("[key_name_admin(user)] изменил силу источника редспейса #[source_id] на [new_strength].")
					else
						to_chat(user, span_warning("Не удалось изменить силу источника."), confidential = TRUE)
				if("Позицию (текущий тайл)")
					if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
						to_chat(user, span_warning("Текущий тайл не находится на активном станционном z-уровне."), confidential = TRUE)
						return
					if(SSredspace.update_source_position(source_id, current_turf, "перемещён из debug-панели"))
						log_admin("[key_name(user)] moved redspace source #[source_id] to ([current_turf.x], [current_turf.y], [current_turf.z]).")
						message_admins("[key_name_admin(user)] переместил источник редспейса #[source_id] на ([current_turf.x], [current_turf.y], [current_turf.z]).")
					else
						to_chat(user, span_warning("Не удалось переместить источник."), confidential = TRUE)

		if("Удалить источник")
			var/source_id = redspace_debug_pick_source(user)
			if(isnull(source_id))
				return
			if(SSredspace.remove_source(source_id, "удалён из debug-панели"))
				log_admin("[key_name(user)] removed redspace source #[source_id].")
				message_admins("[key_name_admin(user)] удалил источник редспейса #[source_id].")

		if("Локальное искажение 4-6")
			if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
				to_chat(user, span_warning("Текущий тайл не находится на активном станционном z-уровне."), confidential = TRUE)
				return
			if(SSredspace.start_registered_event("local_distortion", user, current_turf))
				to_chat(user, span_notice("Локальное искажение запущено."), confidential = TRUE)
			else
				to_chat(user, span_warning("Событие недоступно: значение должно быть в диапазоне 4-6, действует cooldown или исчерпан бюджет зоны."), confidential = TRUE)

		if("Штормовой импульс 7-10")
			if(!current_turf || !SSredspace.is_supported_z(current_turf.z))
				to_chat(user, span_warning("Текущий тайл не находится на активном станционном z-уровне."), confidential = TRUE)
				return
			if(SSredspace.start_registered_event("storm_pulse", user, current_turf))
				to_chat(user, span_notice("Штормовой импульс телеграфирован: покиньте отмеченный тайл."), confidential = TRUE)
			else
				to_chat(user, span_warning("Событие недоступно: значение должно быть в диапазоне 7-10, действует cooldown или исчерпан бюджет зоны."), confidential = TRUE)

		if("Удар молнии редспейса")
			var/datum/redspace_event/lightning/event = new
			if(!event.start(user))
				qdel(event)

		if("Сбросить поле")
			if(tgui_alert(user, "Удалить фон, ячейки и все зарегистрированные источники Redspace?", "Redspace Debug", list("Да", "Нет")) != "Да")
				return
			SSredspace.reset_debug_state()
			log_admin("[key_name(user)] reset the live redspace field.")
			message_admins("[key_name_admin(user)] сбросил живое поле редспейса.")

	BLACKBOX_LOG_ADMIN_VERB("Redspace Debug Panel")

ADMIN_VERB_AND_CONTEXT_MENU(redspace_debug_set_cell_context, R_DEBUG, "Redspace: Set Cell Value", "Set the value of a selected Redspace cell.", ADMIN_CATEGORY_DEBUG, /turf)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_TURF, VERB_ARG_SOURCE_WORLD, /turf)
	redspace_debug_set_cell_value(user, target)

ADMIN_VERB_AND_CONTEXT_MENU(redspace_debug_inspect_cell_context, R_DEBUG, "Redspace: Inspect Cell", "Inspect the selected Redspace cell.", ADMIN_CATEGORY_DEBUG, /turf)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_TURF, VERB_ARG_SOURCE_WORLD, /turf)
	redspace_debug_report(user, target)
