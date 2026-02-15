// ============================================
// ДИАГНОСТИЧЕСКИЙ ТЕРМИНАЛ ДЛЯ СИНТЕТИКОВ
// ============================================

/obj/machinery/computer/operating/synthetic
	name = "synthetic diagnostic terminal"
	desc = "Специализированный терминал для диагностики синтетических организмов - IPC и андроидов."
	icon = 'icons/bandastation/mob/species/ipc/computer.dmi'
	icon_screen = "ipc_crew"
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

	// Процентные показатели урона
	patient_data["mechanical_damage_percent"] = round((patient.get_brute_loss() / patient.maxHealth) * 100, 0.1)
	patient_data["electrical_damage_percent"] = round((patient.get_fire_loss() / patient.maxHealth) * 100, 0.1)

	// Температура процессора (для IPC)
	var/datum/species/ipc/ipc_species = patient.dna.species
	if(istype(ipc_species))
		patient_data["cpu_temperature"] = round(ipc_species.cpu_temperature, 0.1)
		patient_data["cpu_temp_optimal_min"] = ipc_species.cpu_temp_optimal_min
		patient_data["cpu_temp_optimal_max"] = ipc_species.cpu_temp_optimal_max
		patient_data["cpu_temp_critical"] = ipc_species.cpu_temp_critical

		// Определяем статус температуры
		var/temp_status = "normal"
		if(ipc_species.cpu_temperature < ipc_species.cpu_temp_optimal_min)
			temp_status = "cold"
		else if(ipc_species.cpu_temperature > ipc_species.cpu_temp_optimal_max && ipc_species.cpu_temperature < 90)
			temp_status = "warm"
		else if(ipc_species.cpu_temperature >= 90 && ipc_species.cpu_temperature < 120)
			temp_status = "hot"
		else if(ipc_species.cpu_temperature >= 120)
			temp_status = "critical"

		patient_data["cpu_temp_status"] = temp_status

		// Информация о разгоне
		patient_data["overclock_active"] = ipc_species.overclock_active
		patient_data["overclock_speed_bonus"] = round(ipc_species.overclock_speed_bonus * 100)

		// Информация о шасси
		patient_data["chassis_brand"] = ipc_species.ipc_brand_key
		patient_data["chassis_visual_brand"] = ipc_species.ipc_visual_brand_key

	// Компоненты
	patient_data["components"] = get_components_data(patient)

	// Части тела
	patient_data["bodyparts"] = get_bodyparts_data(patient)

	// Импланты
	patient_data["implants"] = get_implants_data(patient)

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

	// Получаем компонент панели для проверки состояния
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)

	// Определяем доступные операции вручную на основе состояния
	var/panel_state = panel ? panel.panel_state : 0

	// Для головы и груди
	if(target_zone == BODY_ZONE_CHEST || target_zone == BODY_ZONE_HEAD)
		if(panel_state == 0) // Закрыта
			surgeries += list(list(
				"name" = "Открыть панель шасси",
				"desc" = "Открутить панель доступа к внутренним компонентам IPC.",
				"tool_rec" = "Отвёртка"
			))
		else if(panel_state == 1) // Открыта
			surgeries += list(list(
				"name" = "Подготовить электронику",
				"desc" = "Подготовьте внутреннюю электронику IPC к операции с помощью мультитула.",
				"tool_rec" = "Мультитул"
			))
			surgeries += list(list(
				"name" = "Закрыть панель шасси",
				"desc" = "Закрутить панель доступа к внутренним компонентам IPC.",
				"tool_rec" = "Отвёртка"
			))
			surgeries += list(list(
				"name" = "Закрутить панель (аварийно)",
				"desc" = "Быстро закрутить открытую панель шасси IPC гаечным ключом.",
				"tool_rec" = "Гаечный ключ"
			))
		else if(panel_state == 2) // Подготовлена
			if(target_zone == BODY_ZONE_CHEST)
				surgeries += list(list(
					"name" = "Манипуляции с компонентами",
					"desc" = "Установка или извлечение компонентов грудной клетки IPC.",
					"tool_rec" = "Орган IPC или Мультитул"
				))
			else if(target_zone == BODY_ZONE_HEAD)
				surgeries += list(list(
					"name" = "Манипуляции с сенсорами головы",
					"desc" = "Установка или извлечение сенсоров головы IPC.",
					"tool_rec" = "Орган IPC или Мультитул"
				))
			surgeries += list(list(
				"name" = "Закрутить панель (аварийно)",
				"desc" = "Быстро закрутить открытую панель шасси IPC гаечным ключом.",
				"tool_rec" = "Гаечный ключ"
			))

	// Для рук и ног
	else if(target_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(panel_state == 0) // Закрыта
			surgeries += list(list(
				"name" = "Открыть панель конечности",
				"desc" = "Открутить панель доступа на конечности IPC.",
				"tool_rec" = "Отвёртка"
			))
			surgeries += list(list(
				"name" = "Отключить конечность",
				"desc" = "Отключите электронику конечности IPC перед снятием.",
				"tool_rec" = "Мультитул"
			))
		else if(panel_state == 1) // Открыта
			if(limb.brute_dam > 0)
				surgeries += list(list(
					"name" = "Заварить механические повреждения",
					"desc" = "Используйте сварку для ремонта механических повреждений.",
					"tool_rec" = "Сварка"
				))
			if(limb.burn_dam > 0)
				surgeries += list(list(
					"name" = "Починить проводку",
					"desc" = "Используйте кабель для ремонта электрических повреждений.",
					"tool_rec" = "Кабель"
				))
			surgeries += list(list(
				"name" = "Установить имплант",
				"desc" = "Установите имплант в конечность IPC.",
				"tool_rec" = "Имплант"
			))
			surgeries += list(list(
				"name" = "Закрыть панель конечности",
				"desc" = "Закрутить панель доступа на конечности IPC.",
				"tool_rec" = "Отвёртка"
			))
		else if(panel_state == 3) // Отключена
			surgeries += list(list(
				"name" = "Открутить конечность",
				"desc" = "Открутите конечность IPC с помощью гаечного ключа.",
				"tool_rec" = "Гаечный ключ"
			))

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

/obj/machinery/computer/operating/synthetic/proc/get_implants_data(mob/living/carbon/human/patient)
	var/list/implants = list()

	// Проверяем импланты в каждой части тела
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/part = patient.get_bodypart(zone)
		if(!part)
			continue

		// Ищем все импланты в этой части
		for(var/obj/item/implant/imp in part.contents)
			// Определяем тип импланта и его статус
			var/implant_name = imp.name
			var/implant_location = part.plaintext_zone
			var/implant_status = "Активен"
			var/implant_color = "good"

			// Для IPC имплантов проверяем специфичные состояния
			if(istype(imp, /obj/item/implant/ipc))
				var/obj/item/implant/ipc/ipc_imp = imp

				// Reactive Repair
				if(istype(ipc_imp, /obj/item/implant/ipc/reactive_repair))
					var/obj/item/implant/ipc/reactive_repair/rr = ipc_imp
					if(rr.repair_active)
						implant_status = "Активно лечит"
						implant_color = "average"
					else
						implant_status = "Ожидание"

				// Magnetic Leg
				else if(istype(ipc_imp, /obj/item/implant/ipc/magnetic_leg))
					var/obj/item/implant/ipc/magnetic_leg/ml = ipc_imp
					if(ml.magboots_active)
						implant_status = "Магниты активны"
						implant_color = "average"
					else
						implant_status = "Магниты отключены"

			implants += list(list(
				"name" = implant_name,
				"location" = implant_location,
				"status" = implant_status,
				"status_color" = implant_color
			))

	if(implants.len == 0)
		implants += list(list(
			"name" = "Нет установленных имплантов",
			"location" = "—",
			"status" = "—",
			"status_color" = "average"
		))

	return implants

/obj/machinery/computer/operating/synthetic/proc/get_system_messages(mob/living/carbon/human/patient)
	var/list/system_messages = list()

	var/obj/item/organ/brain/positronic/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/ipc_battery/battery = patient.get_organ_slot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/ipc/cooling = patient.get_organ_slot(ORGAN_SLOT_LUNGS)

	// Проверка температуры процессора
	var/datum/species/ipc/ipc_species = patient.dna.species
	if(istype(ipc_species))
		if(ipc_species.cpu_temperature >= 130)
			system_messages += list(list(
				"type" = "critical",
				"message" = "КРИТИЧНО: Температура процессора [round(ipc_species.cpu_temperature)]°C! Риск расплавления! Требуется немедленное охлаждение!"
			))
		else if(ipc_species.cpu_temperature >= 120)
			system_messages += list(list(
				"type" = "critical",
				"message" = "КРИТИЧНО: Температура процессора [round(ipc_species.cpu_temperature)]°C! Критический перегрев! Требуется охлаждение!"
			))
		else if(ipc_species.cpu_temperature >= 90)
			system_messages += list(list(
				"type" = "warning",
				"message" = "ПРЕДУПРЕЖДЕНИЕ: Температура процессора [round(ipc_species.cpu_temperature)]°C. Перегрев системы."
			))
		else if(ipc_species.cpu_temperature < ipc_species.cpu_temp_optimal_min)
			system_messages += list(list(
				"type" = "warning",
				"message" = "ПРЕДУПРЕЖДЕНИЕ: Температура процессора [round(ipc_species.cpu_temperature)]°C. Ниже оптимальной."
			))

	if(!brain)
		system_messages += list(list(
			"type" = "critical",
			"message" = "КРИТИЧНО: Позитронное ядро отсутствует. Система не функциональна."
		))
	else if(brain.damage > brain.maxHealth * 0.5)
		system_messages += list(list(
			"type" = "critical",
			"message" = "КРИТИЧНО: Позитронное ядро повреждено на [round((brain.damage / brain.maxHealth) * 100)]%. Требуется ремонт."
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
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Критические механические повреждения ([round(patient.get_brute_loss())] HP). Требуется ремонт."
		))

	if(patient.get_fire_loss() > 50)
		system_messages += list(list(
			"type" = "warning",
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Критические повреждения проводки ([round(patient.get_fire_loss())] HP). Требуется ремонт."
		))

	// Проверка отсутствующих конечностей
	var/missing_limbs = 0
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!patient.get_bodypart(zone))
			missing_limbs++

	if(missing_limbs > 0)
		system_messages += list(list(
			"type" = "warning",
			"message" = "ПРЕДУПРЕЖДЕНИЕ: Отсутствует [missing_limbs] конечност[missing_limbs == 1 ? "ь" : "ей"]. Требуется установка."
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
