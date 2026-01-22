// ============================================
// ДИАГНОСТИЧЕСКИЙ ТЕРМИНАЛ ДЛЯ СИНТЕТИКОВ
// ============================================

/obj/machinery/computer/operating/synthetic
	name = "synthetic diagnostic terminal"
	desc = "Специализированный терминал для диагностики синтетических организмов - IPC и андроидов."
	icon_screen = "crew"
	icon_keyboard = "tech_key"
	light_color = COLOR_BLUE_LIGHT

/obj/machinery/computer/operating/synthetic/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SyntheticDiagnostic")
		ui.open()
	return ..()

/obj/machinery/computer/operating/synthetic/ui_static_data(mob/user)
	var/list/data = list()

	// Статические данные которые не меняются
	data["zones"] = list(
		list("id" = BODY_ZONE_HEAD, "name" = "Голова"),
		list("id" = BODY_ZONE_CHEST, "name" = "Корпус"),
		list("id" = BODY_ZONE_L_ARM, "name" = "Л. Рука"),
		list("id" = BODY_ZONE_R_ARM, "name" = "П. Рука"),
		list("id" = BODY_ZONE_L_LEG, "name" = "Л. Нога"),
		list("id" = BODY_ZONE_R_LEG, "name" = "П. Нога")
	)

	return data

/obj/machinery/computer/operating/synthetic/ui_data(mob/user)
	var/list/data = list()

	// Проверка стола
	if(!table)
		data["patient"] = null
		data["error"] = "Диагностический стол не подключён"
		data["has_table"] = FALSE
		return data

	data["has_table"] = TRUE

	// Поиск пациента
	if(!table.patient)
		data["patient"] = null
		data["error"] = "Пациент не обнаружен на столе"
		return data

	var/mob/living/carbon/human/patient = table.patient

	// Проверка что это синтетик
	if(!patient.dna?.species || !istype(patient.dna.species, /datum/species/ipc))
		data["patient"] = null
		data["error"] = "ОШИБКА: Пациент не является синтетическим организмом"
		data["patient_name"] = patient.name
		data["patient_species"] = patient.dna?.species?.name || "Unknown"
		return data

	// Собираем данные о пациенте
	data["patient"] = get_patient_data(patient)
	data["target_zone"] = target_zone

	// Добавляем список ДОСТУПНЫХ СЕЙЧАС операций для текущей зоны
	data["surgeries"] = get_available_surgeries_now(patient)

	return data

/obj/machinery/computer/operating/synthetic/proc/get_patient_data(mob/living/carbon/human/patient)
	var/list/patient_data = list()

	// Базовая информация
	patient_data["name"] = patient.name
	patient_data["type"] = "IPC"
	patient_data["id"] = patient.real_name

	// Статус системы
	switch(patient.stat)
		if(CONSCIOUS)
			patient_data["status"] = "АКТИВЕН"
			patient_data["status_color"] = "good"
		if(UNCONSCIOUS)
			patient_data["status"] = "РЕЖИМ ОЖИДАНИЯ"
			patient_data["status_color"] = "average"
		if(DEAD)
			patient_data["status"] = "ОТКЛЮЧЁН"
			patient_data["status_color"] = "bad"

	// Целостность корпуса
	patient_data["integrity"] = round(patient.health, 0.1)
	patient_data["integrity_max"] = patient.maxHealth
	patient_data["integrity_percent"] = round((patient.health / patient.maxHealth) * 100)

	// Урон
	patient_data["mechanical_damage"] = round(patient.get_brute_loss(), 0.1)
	patient_data["electrical_damage"] = round(patient.get_fire_loss(), 0.1)
	patient_data["system_damage"] = round(patient.get_tox_loss(), 0.1)
	patient_data["cooling_damage"] = round(patient.get_oxy_loss(), 0.1)

	// Компоненты
	patient_data["components"] = get_components_data(patient)

	// Части тела
	patient_data["bodyparts"] = get_bodyparts_data(patient)

	// Системные сообщения
	patient_data["system_messages"] = get_system_messages(patient)

	// Информация об ОС
	patient_data["os_version"] = "IPC-OS v2.4.1"
	patient_data["os_manufacturer"] = "Generic Systems"

	return patient_data

// Список ВСЕХ IPC операций
GLOBAL_LIST_INIT(ipc_all_operations, list(
	/datum/surgery_operation/limb/ipc_open_panel,
	/datum/surgery_operation/limb/ipc_close_panel,
	/datum/surgery_operation/limb/ipc_emergency_close_panel,
	/datum/surgery_operation/limb/ipc_prepare_electronics,
	/datum/surgery_operation/limb/ipc_organ_manipulation,
	/datum/surgery_operation/limb/ipc_head_manipulation,
	/datum/surgery_operation/limb/ipc_open_limb_panel,
	/datum/surgery_operation/limb/ipc_close_limb_panel,
	/datum/surgery_operation/limb/ipc_repair_brute,
	/datum/surgery_operation/limb/ipc_repair_burn,
	/datum/surgery_operation/limb/ipc_insert_implant,
	/datum/surgery_operation/limb/ipc_disconnect_limb,
	/datum/surgery_operation/limb/ipc_detach_limb
))

// Получаем операции которые ДОСТУПНЫ ПРЯМО СЕЙЧАС
/obj/machinery/computer/operating/synthetic/proc/get_available_surgeries_now(mob/living/carbon/human/patient)
	var/list/surgeries = list()

	if(!target_zone)
		return surgeries

	// Получаем конечность текущей зоны
	var/obj/item/bodypart/limb = patient.get_bodypart(target_zone)
	if(!limb)
		return surgeries

	// Проверяем каждую операцию - доступна ли она СЕЙЧАС
	for(var/op_type in GLOB.ipc_all_operations)
		var/datum/surgery_operation/op = new op_type()

		// Проверяем с РАЗНЫМИ инструментами
		var/is_available = FALSE
		var/best_tool_name = "Неизвестно"

		for(var/tool_type in op.implements)
			var/obj/item/tool

			// Создаём временный инструмент для проверки
			if(ispath(tool_type, /obj/item))
				tool = new tool_type()
			else
				// Если это текстовая константа - пропускаем
				continue

			// Проверяем доступность с этим инструментом
			if(hascall(op, "snowflake_check_availability"))
				if(op.snowflake_check_availability(limb, null, tool, target_zone))
					is_available = TRUE
					best_tool_name = get_tool_display_name(tool_type)
					qdel(tool)
					break

			qdel(tool)

		if(is_available)
			surgeries += list(list(
				"name" = op.name,
				"desc" = op.desc,
				"tool_rec" = best_tool_name
			))

		qdel(op)

	return surgeries

// Получаем красивое название инструмента
/obj/machinery/computer/operating/synthetic/proc/get_tool_display_name(tool_path)
	// Константы инструментов
	if(istext(tool_path))
		switch(tool_path)
			if(TOOL_SCREWDRIVER)
				return "Отвёртка"
			if(TOOL_MULTITOOL)
				return "Мультитул"
			if(TOOL_WRENCH)
				return "Гаечный ключ"
			if(TOOL_WELDER)
				return "Сварка"
			else
				return tool_path

	// Пути к предметам
	if(ispath(tool_path, /obj/item/screwdriver))
		return "Отвёртка"
	if(ispath(tool_path, /obj/item/multitool))
		return "Мультитул"
	if(ispath(tool_path, /obj/item/wrench))
		return "Гаечный ключ"
	if(ispath(tool_path, /obj/item/weldingtool))
		return "Сварка"
	if(ispath(tool_path, /obj/item/stack/cable_coil))
		return "Кабель"
	if(ispath(tool_path, /obj/item/organ))
		return "Орган IPC"
	if(ispath(tool_path, /obj/item/implant) || ispath(tool_path, /obj/item/implantcase))
		return "Имплант"

	// По умолчанию - создаём объект и берём имя
	var/obj/item/temp = new tool_path()
	var/name = temp.name
	qdel(temp)
	return name

/obj/machinery/computer/operating/synthetic/proc/get_components_data(mob/living/carbon/human/patient)
	var/list/components = list()

	// Позитронное ядро
	var/obj/item/organ/brain/positronic/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		components += list(list(
			"name" = "Позитронное ядро",
			"status" = "Установлено",
			"status_color" = "good",
			"damage" = brain.damage,
			"details" = "Тип: positronic"
		))
	else
		components += list(list(
			"name" = "Позитронное ядро",
			"status" = "ОТСУТСТВУЕТ",
			"status_color" = "bad",
			"damage" = 0,
			"details" = "КРИТИЧНО: Требуется установка"
		))

	// Источник питания
	var/obj/item/organ/heart/ipc_battery/battery = patient.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		var/charge_percent = round((battery.charge / battery.maxcharge) * 100)
		var/status_color = "good"
		if(charge_percent < 30)
			status_color = "bad"
		else if(charge_percent < 60)
			status_color = "average"

		components += list(list(
			"name" = "Источник питания",
			"status" = "Установлен",
			"status_color" = status_color,
			"damage" = 0,
			"details" = "Заряд: [charge_percent]% ([battery.charge]/[battery.maxcharge] units)"
		))
	else
		components += list(list(
			"name" = "Источник питания",
			"status" = "ОТСУТСТВУЕТ",
			"status_color" = "bad",
			"damage" = 0,
			"details" = "КРИТИЧНО: Требуется установка"
		))

	// Система охлаждения
	var/obj/item/organ/lungs/ipc/cooling = patient.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(cooling)
		var/efficiency_percent = round(cooling.cooling_efficiency * 100)
		var/status_color = "good"
		if(efficiency_percent < 50)
			status_color = "bad"
		else if(efficiency_percent < 80)
			status_color = "average"

		components += list(list(
			"name" = "Система охлаждения",
			"status" = "Установлена",
			"status_color" = status_color,
			"damage" = cooling.damage,
			"details" = "Эффективность: [efficiency_percent]%"
		))
	else
		components += list(list(
			"name" = "Система охлаждения",
			"status" = "ОТСУТСТВУЕТ",
			"status_color" = "average",
			"damage" = 0,
			"details" = "ПРЕДУПРЕЖДЕНИЕ: Риск перегрева"
		))

	// Оптические сенсоры
	var/obj/item/organ/eyes/robotic/ipc/eyes = patient.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		components += list(list(
			"name" = "Оптические сенсоры",
			"status" = "Установлены",
			"status_color" = "good",
			"damage" = eyes.damage,
			"details" = "Визуальный ввод активен"
		))
	else
		components += list(list(
			"name" = "Оптические сенсоры",
			"status" = "ОТСУТСТВУЮТ",
			"status_color" = "average",
			"damage" = 0,
			"details" = "Потеря визуального ввода"
		))

	// Аудио сенсоры
	var/obj/item/organ/ears/robot/ipc/ears = patient.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		components += list(list(
			"name" = "Аудио сенсоры",
			"status" = "Установлены",
			"status_color" = "good",
			"damage" = ears.damage,
			"details" = "Звуковой ввод активен"
		))
	else
		components += list(list(
			"name" = "Аудио сенсоры",
			"status" = "ОТСУТСТВУЮТ",
			"status_color" = "average",
			"damage" = 0,
			"details" = "Потеря звукового ввода"
		))

	// Голосовой синтезатор
	var/obj/item/organ/tongue/robot/ipc/tongue = patient.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		components += list(list(
			"name" = "Голосовой синтезатор",
			"status" = "Установлен",
			"status_color" = "good",
			"damage" = tongue.damage,
			"details" = "Речевой вывод активен"
		))
	else
		components += list(list(
			"name" = "Голосовой синтезатор",
			"status" = "ОТСУТСТВУЕТ",
			"status_color" = "average",
			"damage" = 0,
			"details" = "Потеря речевого вывода"
		))

	return components

/obj/machinery/computer/operating/synthetic/proc/get_bodyparts_data(mob/living/carbon/human/patient)
	var/list/bodyparts = list()

	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/part = patient.get_bodypart(zone)

		if(part)
			// Получаем состояние панели
			var/datum/component/ipc_panel/panel = part.GetComponent(/datum/component/ipc_panel)
			var/panel_status = "Закрыта"
			if(panel)
				switch(panel.panel_state)
					if(1) // IPC_PANEL_OPEN
						panel_status = "Открыта"
					if(2) // IPC_ELECTRONICS_PREPARED
						panel_status = "Подготовлена"
					if(3) // IPC_LIMB_DISCONNECTED
						panel_status = "Отключена"

			bodyparts += list(list(
				"name" = part.plaintext_zone,
				"status" = "Подключена",
				"damage" = round(part.get_damage(), 0.1),
				"max_damage" = part.max_damage,
				"brute" = round(part.brute_dam, 0.1),
				"burn" = round(part.burn_dam, 0.1),
				"panel_status" = panel_status
			))
		else
			var/zone_name = "Неизвестно"
			switch(zone)
				if(BODY_ZONE_HEAD)
					zone_name = "Голова"
				if(BODY_ZONE_CHEST)
					zone_name = "Корпус"
				if(BODY_ZONE_L_ARM)
					zone_name = "Левая рука"
				if(BODY_ZONE_R_ARM)
					zone_name = "Правая рука"
				if(BODY_ZONE_L_LEG)
					zone_name = "Левая нога"
				if(BODY_ZONE_R_LEG)
					zone_name = "Правая нога"

			bodyparts += list(list(
				"name" = zone_name,
				"status" = "ОТСУТСТВУЕТ",
				"damage" = 0,
				"max_damage" = 0,
				"brute" = 0,
				"burn" = 0,
				"panel_status" = "—"
			))

	return bodyparts

/obj/machinery/computer/operating/synthetic/proc/get_system_messages(mob/living/carbon/human/patient)
	var/list/system_messages = list()

	var/obj/item/organ/brain/positronic/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/ipc_battery/battery = patient.get_organ_slot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/ipc/cooling = patient.get_organ_slot(ORGAN_SLOT_LUNGS)

	if(!brain)
		system_messages += list(list(
			"type" = "critical",
			"message" = "КРИТИЧНО: Позитронное ядро отсутствует. Система не функциональна."
		))

	if(!battery)
		system_messages += list(list(
			"type" = "critical",
			"message" = "КРИТИЧНО: Источник питания отсутствует. Система не функциональна."
		))
	else if(battery.charge < battery.maxcharge * 0.1)
		system_messages += list(list(
			"type" = "critical",
			"message" = "КРИТИЧНО: Заряд батареи ниже 10%. Требуется немедленная подзарядка."
		))
	else if(battery.charge < battery.maxcharge * 0.3)
		system_messages += list(list(
			"type" = "warning",
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Заряд батареи ниже 30%."
		))

	if(!cooling)
		system_messages += list(list(
			"type" = "warning",
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Система охлаждения отсутствует. Риск перегрева."
		))

	if(patient.get_brute_loss() > 50)
		system_messages += list(list(
			"type" = "warning",
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Критические механические повреждения. Требуется ремонт."
		))

	if(patient.get_fire_loss() > 50)
		system_messages += list(list(
			"type" = "warning",
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Критические повреждения проводки. Требуется ремонт."
		))

	if(system_messages.len == 0)
		system_messages += list(list(
			"type" = "ok",
			"message" = "Все системы функционируют нормально."
		))

	return system_messages

/obj/machinery/computer/operating/synthetic/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_zone")
			if(params["new_zone"] in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
				target_zone = params["new_zone"]
			return TRUE

// ============================================
// БЛОКИРОВКА ОБЫЧНОГО ТЕРМИНАЛА ДЛЯ IPC
// ============================================

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = ..()

	// Если пациент - IPC, не показываем данные
	if(table?.patient)
		var/mob/living/carbon/human/H = table.patient
		if(istype(H.dna?.species, /datum/species/ipc))
			data = list()
			data["error"] = "ОШИБКА: Для диагностики синтетических организмов используйте специализированный терминал."
			data["patient"] = null
			return data

	return data
