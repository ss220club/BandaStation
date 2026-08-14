/// Sends a diagnostic report for one canonical map tile to an administrator.
/proc/redspace_debug_report(client/user, turf/target)
	if(!user || !target || !SSredspace.is_supported_z(target.z))
		return

	var/value = SSredspace.get_value(target)
	var/state = redspace_state_from_value(value)
	var/datum/redspace_field_cell/cell = SSredspace.get_cell(target)
	var/list/report = list(
		"Редспейс на ([target.x], [target.y], [target.z])",
		"Значение: [round(value, 0.1)] ([redspace_state_name(state)])",
		"Фон: [round(SSredspace.background_value, 0.1)]",
	)

	if(cell)
		report += "Ячейка: [cell.key], q=[cell.q], r=[cell.r]"
		report += "Кеш: [round(cell.value, 0.1)], предыдущее: [round(cell.previous_value, 0.1)]"
		report += "Последнее обновление: [cell.last_updated ? "[world.time - cell.last_updated] тиков назад" : "нет"]"
		if(!isnull(cell.forced_value))
			report += "Принудительное значение: [round(cell.forced_value, 0.1)] ([cell.forced_value_allows_invasion ? "event override" : "обычный override"])"
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
/proc/redspace_debug_set_cell_value(client/user, turf/target, allow_invasion = FALSE)
	if(!user || !target || !SSredspace.is_supported_z(target.z))
		if(user)
			to_chat(user, span_warning("Этот тайл не находится на активном станционном z-уровне редспейса."), confidential = TRUE)
		return

	var/current_value = SSredspace.get_value(target)
	var/min_value = allow_invasion ? 10.1 : -100
	var/max_value = allow_invasion ? 100 : REDSPACE_MAX_NORMAL_VALUE
	var/default_value = allow_invasion ? max(11, current_value) : clamp(current_value, min_value, max_value)
	var/new_value = tgui_input_number(
		user,
		allow_invasion ? "Новое event-only значение для текущей ячейки" : "Новое обычное значение для текущей ячейки",
		"Redspace Cell",
		default_value,
		max_value,
		min_value,
	)
	if(isnull(new_value))
		return

	SSredspace.set_cell_value(target, new_value, allow_invasion)
	var/override_kind = allow_invasion ? "event override" : "обычное значение"
	to_chat(user, span_notice("Значение ячейки установлено: [round(new_value, 0.1)] ([override_kind])."), confidential = TRUE)
	log_admin("[key_name(user)] set redspace [override_kind] to [new_value] at ([target.x], [target.y], [target.z]).")
	message_admins("[key_name_admin(user)] установил [override_kind] редспейса [new_value] на ([target.x], [target.y], [target.z]).")

/// Main in-round control surface for the first Redspace prototype.
ADMIN_VERB(redspace_debug_panel, R_DEBUG, "Redspace: Debug Panel", "Change the live Redspace field and run explicit test events.", ADMIN_CATEGORY_DEBUG)
	var/action = tgui_input_list(user, "Выберите операцию", "Redspace Debug", list(
		"Показать текущее состояние",
		"Установить фон раунда",
		"Установить значение ячейки",
		"Установить event-only значение",
		"Очистить значение ячейки",
		"Добавить тестовый источник",
		"Удалить тестовый источник",
		"Удар редспейсной молнии",
		"Сбросить поле",
	))
	if(!action)
		return

	var/turf/current_turf = get_turf(user.mob)
	switch(action)
		if("Показать текущее состояние")
			redspace_debug_report(user, current_turf)

		if("Установить фон раунда")
			var/new_background = tgui_input_number(user, "Новое значение фона (-100..10)", "Redspace Background", SSredspace.background_value, REDSPACE_MAX_NORMAL_VALUE, -100)
			if(isnull(new_background))
				return
			SSredspace.set_background_value(new_background)
			log_admin("[key_name(user)] set redspace background to [new_background].")
			message_admins("[key_name_admin(user)] установил фон редспейса: [new_background].")

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
			var/source_profile = tgui_input_list(user, "Профиль источника", "Redspace Source", list("debug", "demonic"))
			if(!source_profile)
				return
			var/source_strength = tgui_input_number(user, "Сила источника (-100..100)", "Redspace Source", 5, 100, -100)
			if(isnull(source_strength))
				return
			var/source_radius = tgui_input_number(user, "Радиус источника в тайлах (0..[REDSPACE_MAX_SOURCE_RADIUS])", "Redspace Source", 4, REDSPACE_MAX_SOURCE_RADIUS, 0)
			if(isnull(source_radius))
				return
			var/datum/redspace_field_source/source = SSredspace.register_source(current_turf, source_strength, source_radius, source_profile)
			if(source)
				to_chat(user, span_notice("Создан источник [source.get_debug_label()]."), confidential = TRUE)
				log_admin("[key_name(user)] registered redspace source [source.get_debug_label()].")
				message_admins("[key_name_admin(user)] создал источник редспейса [source.get_debug_label()].")

		if("Удалить тестовый источник")
			var/list/source_choices = list()
			for(var/source_key in SSredspace.field_sources)
				var/datum/redspace_field_source/source = SSredspace.field_sources[source_key]
				if(source)
					source_choices[source.get_debug_label()] = source.source_id
			if(!length(source_choices))
				to_chat(user, span_warning("Активных источников нет."), confidential = TRUE)
				return
			var/source_choice = tgui_input_list(user, "Какой источник удалить?", "Redspace Source", source_choices)
			if(!source_choice)
				return
			var/source_id = source_choices[source_choice]
			if(SSredspace.remove_source(source_id))
				log_admin("[key_name(user)] removed redspace source #[source_id].")
				message_admins("[key_name_admin(user)] удалил источник редспейса #[source_id].")

		if("Удар редспейсной молнии")
			var/lightning_damage = tgui_input_number(user, "Урон огнём", "Redspace Lightning", 10, 200, 0)
			if(isnull(lightning_damage))
				return
			var/lightning_stun = tgui_input_number(user, "Оглушение в секундах", "Redspace Lightning", 0, 30, 0)
			if(isnull(lightning_stun))
				return
			var/datum/redspace_event/lightning/event = new(lightning_damage, lightning_stun * SECONDS)
			event.start(user)
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
