// ============================================
// IPC ОПЕРАЦИОННАЯ СИСТЕМА
// ============================================
// Внутренняя ОС каждого IPC — доступна через кнопку действия.
// Включает рабочий стол, приложения (самодиагностика, антивирус, NET-door),
// систему паролей, тем и вирусов.
// ============================================

// ============================================
// ТЕМЫ ОС (привязаны к бренду шасси)
// ============================================

/// Возвращает название ОС по ключу бренда
/proc/get_ipc_os_name(brand_key)
	switch(brand_key)
		if("morpheus")
			return "MorphOS"
		if("etamin")
			return "EtaminOS"
		if("bishop")
			return "BishopNet"
		if("hesphiastos")
			return "HephForge"
		if("ward_takahashi")
			return "WardLink"
		if("xion")
			return "XionShell"
		if("zeng_hu")
			return "ZengMed"
		if("shellguard")
			return "ShellGuardOS"
		if("cybersun")
			return "NightSun"
		if("unbranded")
			return "FreeOS"
		if("hef")
			return "PatchworkOS"
	return "GenericOS"

/// Возвращает цвет темы ОС по ключу бренда
/proc/get_ipc_os_theme_color(brand_key)
	switch(brand_key)
		if("morpheus")
			return "#4a90d9"
		if("etamin")
			return "#d94a4a"
		if("bishop")
			return "#4ad9a5"
		if("hesphiastos")
			return "#d98f4a"
		if("ward_takahashi")
			return "#8f4ad9"
		if("xion")
			return "#4ad9d9"
		if("zeng_hu")
			return "#a5d94a"
		if("shellguard")
			return "#7a7a7a"
		if("cybersun")
			return "#d94a8f"
		if("unbranded")
			return "#5a8a5a"
		if("hef")
			return "#8a8a5a"
	return "#6a6a6a"

// ============================================
// ВИРУСЫ IPC
// ============================================

/datum/ipc_virus
	/// Название вируса
	var/name = "Unknown Virus"
	/// Описание эффекта
	var/desc = "Неизвестный вирус."
	/// Уровень опасности: "low", "medium", "high"
	var/severity = "low"
	/// Может ли антивирус удалить этот вирус (FALSE = только роботехник)
	var/removable_by_antivirus = TRUE
	/// Вирус активен
	var/active = TRUE
	/// Время заражения
	var/infection_time = 0

/datum/ipc_virus/display_glitch
	name = "DisplayGlitch.v2"
	desc = "Периодические артефакты на визуальном выводе."
	severity = "low"
	removable_by_antivirus = TRUE

/datum/ipc_virus/memory_leak
	name = "MemLeak.trojan"
	desc = "Утечка памяти, замедляет обработку данных."
	severity = "medium"
	removable_by_antivirus = TRUE

/datum/ipc_virus/sensor_noise
	name = "SensorNoise.worm"
	desc = "Шум в сенсорных данных, ложные показания."
	severity = "medium"
	removable_by_antivirus = TRUE

/datum/ipc_virus/core_corruption
	name = "CoreRot.rootkit"
	desc = "Глубокое повреждение ядра ОС. Требуется вмешательство роботехника."
	severity = "high"
	removable_by_antivirus = FALSE

/datum/ipc_virus/neural_hijack
	name = "NeuralHijack.exploit"
	desc = "Перехват нейронных паттернов. Требуется вмешательство роботехника."
	severity = "high"
	removable_by_antivirus = FALSE

// ============================================
// NET-DOOR ПРИЛОЖЕНИЯ (каталог)
// ============================================

/datum/ipc_netapp
	/// Название приложения
	var/name = "Unknown App"
	/// Описание
	var/desc = ""
	/// Категория: "utility", "diagnostic", "entertainment"
	var/category = "utility"
	/// Установлено ли
	var/installed = FALSE

/datum/ipc_netapp/thermal_monitor
	name = "ThermalWatch Pro"
	desc = "Расширенный мониторинг температуры с историей показаний."
	category = "diagnostic"

/datum/ipc_netapp/power_optimizer
	name = "PowerSave 3.0"
	desc = "Оптимизация расхода энергии батареи."
	category = "utility"

/datum/ipc_netapp/signal_booster
	name = "SignalBoost"
	desc = "Улучшение качества радиосигнала."
	category = "utility"

/datum/ipc_netapp/defrag_tool
	name = "DefragMaster"
	desc = "Дефрагментация позитронной памяти для ускорения работы."
	category = "utility"

/datum/ipc_netapp/firewall_plus
	name = "Firewall+"
	desc = "Дополнительная защита от сетевых вирусов."
	category = "utility"

/datum/ipc_netapp/sensor_calibration
	name = "SensorCal"
	desc = "Автоматическая калибровка оптических и аудио сенсоров."
	category = "diagnostic"

// ============================================
// ОСНОВНОЙ DATUM ОС IPC
// ============================================

/datum/ipc_operating_system
	/// Ссылка на владельца
	var/mob/living/carbon/human/owner
	/// Название ОС (из бренда)
	var/os_name = "GenericOS"
	/// Версия
	var/os_version = "2.4.1"
	/// Цвет темы
	var/theme_color = "#6a6a6a"
	/// Ключ бренда
	var/brand_key = "unbranded"

	// --- Безопасность ---
	/// Пароль (пустой = не установлен)
	var/password = ""
	/// Залогинен ли пользователь в текущей сессии
	var/logged_in = FALSE

	// --- Приложения ---
	/// Какое приложение сейчас открыто: "desktop", "diagnostics", "antivirus", "netdoor"
	var/current_app = "desktop"

	// --- Самодиагностика ---
	/// Идёт ли сканирование
	var/scan_in_progress = FALSE
	/// Прогресс сканирования (0-100)
	var/scan_progress = 0
	/// Результаты последнего сканирования
	var/list/scan_results = list()
	/// Время последнего сканирования
	var/last_scan_time = 0
	/// ID таймера сканирования
	var/scan_timer_id = null

	// --- Антивирус ---
	/// Список вирусов
	var/list/viruses = list()
	/// Идёт ли проверка антивирусом
	var/antivirus_scanning = FALSE
	/// Прогресс антивирусной проверки (0-100)
	var/antivirus_progress = 0
	/// Результаты антивирусной проверки
	var/list/antivirus_results = list()
	/// ID таймера антивируса
	var/antivirus_timer_id = null

	// --- NET-door ---
	/// Подключён ли к сети
	var/network_connected = FALSE
	/// Доступные приложения в каталоге
	var/list/net_catalog = list()
	/// Установленные приложения
	var/list/installed_apps = list()

/datum/ipc_operating_system/New(mob/living/carbon/human/new_owner, new_brand_key)
	. = ..()
	owner = new_owner
	brand_key = new_brand_key || "unbranded"
	os_name = get_ipc_os_name(brand_key)
	theme_color = get_ipc_os_theme_color(brand_key)

	// Инициализируем каталог NET-door
	net_catalog = list(
		new /datum/ipc_netapp/thermal_monitor(),
		new /datum/ipc_netapp/power_optimizer(),
		new /datum/ipc_netapp/signal_booster(),
		new /datum/ipc_netapp/defrag_tool(),
		new /datum/ipc_netapp/firewall_plus(),
		new /datum/ipc_netapp/sensor_calibration(),
	)

/datum/ipc_operating_system/Destroy()
	owner = null
	QDEL_LIST(viruses)
	QDEL_LIST(net_catalog)
	QDEL_LIST(installed_apps)
	if(scan_timer_id)
		deltimer(scan_timer_id)
	if(antivirus_timer_id)
		deltimer(antivirus_timer_id)
	return ..()

// ============================================
// ПАРОЛЬ И АВТОРИЗАЦИЯ
// ============================================

/datum/ipc_operating_system/proc/set_password(new_password)
	if(!new_password || length(new_password) < 1)
		return FALSE
	if(length(new_password) > 32)
		return FALSE
	password = new_password
	return TRUE

/datum/ipc_operating_system/proc/check_password(input_password)
	if(!password || password == "")
		return TRUE // Пароль не установлен — вход свободный
	return input_password == password

/datum/ipc_operating_system/proc/try_login(input_password)
	if(check_password(input_password))
		logged_in = TRUE
		return TRUE
	return FALSE

/datum/ipc_operating_system/proc/logout()
	logged_in = FALSE
	current_app = "desktop"

// ============================================
// САМОДИАГНОСТИКА
// ============================================

/datum/ipc_operating_system/proc/start_diagnostics_scan()
	if(scan_in_progress)
		return FALSE
	if(!owner)
		return FALSE

	scan_in_progress = TRUE
	scan_progress = 0
	scan_results = list()

	// Сканирование поэтапное — через таймер
	advance_scan()
	return TRUE

/datum/ipc_operating_system/proc/advance_scan()
	if(!scan_in_progress || !owner)
		scan_in_progress = FALSE
		return

	scan_progress = min(scan_progress + 20, 100)

	if(scan_progress >= 100)
		// Сканирование завершено
		scan_in_progress = FALSE
		last_scan_time = world.time
		compile_scan_results()
		SStgui.update_uis(src)
		return

	// Следующий шаг через 1 секунду
	scan_timer_id = addtimer(CALLBACK(src, PROC_REF(advance_scan)), 1 SECONDS, TIMER_STOPPABLE)
	SStgui.update_uis(src)

/datum/ipc_operating_system/proc/compile_scan_results()
	scan_results = list()
	if(!owner)
		return

	var/datum/species/ipc/ipc_species = owner.dna?.species
	if(!istype(ipc_species))
		return

	// Оценка шасси
	var/chassis_integrity = round((owner.health / owner.maxHealth) * 100)
	var/chassis_status = "OK"
	var/chassis_color = "good"
	if(chassis_integrity < 30)
		chassis_status = "КРИТИЧНО"
		chassis_color = "bad"
	else if(chassis_integrity < 70)
		chassis_status = "ПОВРЕЖДЁН"
		chassis_color = "average"

	scan_results += list(list(
		"category" = "Шасси",
		"item" = "Общая целостность",
		"value" = "[chassis_integrity]%",
		"status" = chassis_status,
		"color" = chassis_color,
	))

	// Механические повреждения
	var/brute = round(owner.get_brute_loss(), 0.1)
	scan_results += list(list(
		"category" = "Шасси",
		"item" = "Механические повреждения",
		"value" = "[brute] HP",
		"status" = brute > 50 ? "КРИТИЧНО" : (brute > 20 ? "ОБНАРУЖЕНЫ" : "МИНИМАЛЬНЫ"),
		"color" = brute > 50 ? "bad" : (brute > 20 ? "average" : "good"),
	))

	// Электрические повреждения
	var/burn = round(owner.get_fire_loss(), 0.1)
	scan_results += list(list(
		"category" = "Шасси",
		"item" = "Повреждения проводки",
		"value" = "[burn] HP",
		"status" = burn > 50 ? "КРИТИЧНО" : (burn > 20 ? "ОБНАРУЖЕНЫ" : "МИНИМАЛЬНЫ"),
		"color" = burn > 50 ? "bad" : (burn > 20 ? "average" : "good"),
	))

	// Температура процессора
	var/temp = round(ipc_species.cpu_temperature, 0.1)
	var/temp_status = "НОРМА"
	var/temp_color = "good"
	if(temp >= 120)
		temp_status = "КРИТИЧНО"
		temp_color = "bad"
	else if(temp >= 80)
		temp_status = "ПЕРЕГРЕВ"
		temp_color = "average"
	else if(temp < 20)
		temp_status = "ХОЛОДНО"
		temp_color = "average"

	scan_results += list(list(
		"category" = "Процессор",
		"item" = "Температура CPU",
		"value" = "[temp]°C",
		"status" = temp_status,
		"color" = temp_color,
	))

	// Батарея
	var/obj/item/organ/heart/ipc_battery/battery = owner.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		var/charge_pct = round((battery.charge / battery.maxcharge) * 100)
		scan_results += list(list(
			"category" = "Питание",
			"item" = "Заряд батареи",
			"value" = "[charge_pct]%",
			"status" = charge_pct < 15 ? "КРИТИЧНО" : (charge_pct < 40 ? "НИЗКИЙ" : "НОРМА"),
			"color" = charge_pct < 15 ? "bad" : (charge_pct < 40 ? "average" : "good"),
		))
	else
		scan_results += list(list(
			"category" = "Питание",
			"item" = "Источник питания",
			"value" = "НЕТ",
			"status" = "ОТСУТСТВУЕТ",
			"color" = "bad",
		))

	// Система охлаждения
	var/obj/item/organ/lungs/ipc/cooling = owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(cooling)
		var/eff = round(cooling.cooling_efficiency * 100)
		scan_results += list(list(
			"category" = "Охлаждение",
			"item" = "Система охлаждения",
			"value" = "[eff]%",
			"status" = eff < 50 ? "ДЕГРАДАЦИЯ" : (eff < 80 ? "СНИЖЕНА" : "НОРМА"),
			"color" = eff < 50 ? "bad" : (eff < 80 ? "average" : "good"),
		))
	else
		scan_results += list(list(
			"category" = "Охлаждение",
			"item" = "Система охлаждения",
			"value" = "НЕТ",
			"status" = "ОТСУТСТВУЕТ",
			"color" = "bad",
		))

	// Позитронное ядро
	var/obj/item/organ/brain/positronic/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		var/brain_health = round((1 - brain.damage / brain.maxHealth) * 100)
		scan_results += list(list(
			"category" = "Ядро",
			"item" = "Позитронное ядро",
			"value" = "[brain_health]%",
			"status" = brain_health < 30 ? "КРИТИЧНО" : (brain_health < 70 ? "ПОВРЕЖДЕНО" : "НОРМА"),
			"color" = brain_health < 30 ? "bad" : (brain_health < 70 ? "average" : "good"),
		))

	// Отсутствующие конечности
	var/missing = 0
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!owner.get_bodypart(zone))
			missing++

	if(missing > 0)
		scan_results += list(list(
			"category" = "Шасси",
			"item" = "Отсутствующие конечности",
			"value" = "[missing]",
			"status" = "ТРЕБУЕТСЯ УСТАНОВКА",
			"color" = "bad",
		))

	// ОС
	var/os_status = "СТАБИЛЬНА"
	var/os_color = "good"
	if(viruses.len > 0)
		var/high_count = 0
		for(var/datum/ipc_virus/v in viruses)
			if(v.severity == "high")
				high_count++
		if(high_count > 0)
			os_status = "ЗАРАЖЕНА (КРИТИЧНО)"
			os_color = "bad"
		else
			os_status = "ЗАРАЖЕНА"
			os_color = "average"

	scan_results += list(list(
		"category" = "ОС",
		"item" = "[os_name] v[os_version]",
		"value" = "",
		"status" = os_status,
		"color" = os_color,
	))

// ============================================
// АНТИВИРУС
// ============================================

/datum/ipc_operating_system/proc/start_antivirus_scan()
	if(antivirus_scanning)
		return FALSE

	antivirus_scanning = TRUE
	antivirus_progress = 0
	antivirus_results = list()

	advance_antivirus()
	return TRUE

/datum/ipc_operating_system/proc/advance_antivirus()
	if(!antivirus_scanning)
		return

	antivirus_progress = min(antivirus_progress + 15, 100)

	if(antivirus_progress >= 100)
		antivirus_scanning = FALSE
		compile_antivirus_results()
		SStgui.update_uis(src)
		return

	antivirus_timer_id = addtimer(CALLBACK(src, PROC_REF(advance_antivirus)), 1.5 SECONDS, TIMER_STOPPABLE)
	SStgui.update_uis(src)

/datum/ipc_operating_system/proc/compile_antivirus_results()
	antivirus_results = list()

	if(viruses.len == 0)
		antivirus_results += list(list(
			"message" = "Вирусов не обнаружено. Система чиста.",
			"type" = "ok",
		))
		return

	// Удаляем те, которые можно удалить
	var/removed = 0
	var/list/remaining = list()
	for(var/datum/ipc_virus/v in viruses)
		if(v.removable_by_antivirus)
			antivirus_results += list(list(
				"message" = "Удалён: [v.name] — [v.desc]",
				"type" = "ok",
			))
			qdel(v)
			removed++
		else
			antivirus_results += list(list(
				"message" = "НЕ УДАЛОСЬ УДАЛИТЬ: [v.name] — [v.desc] (Требуется роботехник)",
				"type" = "critical",
			))
			remaining += v

	viruses = remaining

	if(removed > 0)
		antivirus_results += list(list(
			"message" = "Успешно удалено вирусов: [removed]",
			"type" = "ok",
		))

	if(remaining.len > 0)
		antivirus_results += list(list(
			"message" = "Не удалось удалить: [remaining.len]. Обратитесь к роботехнику.",
			"type" = "warning",
		))

/// Удаление конкретного вируса роботехником (через диагностический терминал)
/datum/ipc_operating_system/proc/remove_virus_by_roboticist(datum/ipc_virus/target_virus)
	if(!(target_virus in viruses))
		return FALSE
	viruses -= target_virus
	qdel(target_virus)
	return TRUE

/// Заразить вирусом (вызывается из внешних систем — ЭМП, сетевые атаки и т.д.)
/datum/ipc_operating_system/proc/infect(datum/ipc_virus/new_virus)
	if(!new_virus)
		return FALSE
	// Не добавляем дубликат
	for(var/datum/ipc_virus/v in viruses)
		if(v.type == new_virus.type)
			qdel(new_virus)
			return FALSE
	new_virus.infection_time = world.time
	viruses += new_virus
	if(owner)
		to_chat(owner, span_userdanger("ПРЕДУПРЕЖДЕНИЕ ОС: Обнаружена подозрительная активность в системе!"))
	return TRUE

// ============================================
// NET-DOOR (СЕТЬ)
// ============================================

/// Проверка подключения к сети (нужен сетевой кабель рядом)
/datum/ipc_operating_system/proc/check_network_connection()
	if(!owner)
		network_connected = FALSE
		return FALSE

	// Ищем сетевой кабель под IPC или рядом
	var/turf/T = get_turf(owner)
	if(!T)
		network_connected = FALSE
		return FALSE

	// Ищем кабель на тайле где стоит IPC
	for(var/obj/structure/cable/C in T)
		network_connected = TRUE
		return TRUE

	network_connected = FALSE
	return FALSE

/datum/ipc_operating_system/proc/install_net_app(datum/ipc_netapp/app)
	if(!app)
		return FALSE
	if(app.installed)
		return FALSE
	if(!network_connected)
		return FALSE

	app.installed = TRUE
	installed_apps += app
	return TRUE

/datum/ipc_operating_system/proc/uninstall_net_app(datum/ipc_netapp/app)
	if(!app)
		return FALSE
	if(!app.installed)
		return FALSE

	app.installed = FALSE
	installed_apps -= app
	return TRUE

// ============================================
// TGUI DATA
// ============================================

/// Внутренняя ОС — доступна всегда, без проверки mobility
/datum/ipc_operating_system/ui_state(mob/user)
	return GLOB.always_state

/datum/ipc_operating_system/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IpcOperatingSystem")
		ui.open()

/datum/ipc_operating_system/ui_data(mob/user)
	var/list/data = list()

	data["os_name"] = os_name
	data["os_version"] = os_version
	data["theme_color"] = theme_color
	data["brand_key"] = brand_key

	// Безопасность
	data["has_password"] = (password != "")
	data["logged_in"] = logged_in
	data["current_app"] = current_app

	// Диагностика
	data["scan_in_progress"] = scan_in_progress
	data["scan_progress"] = scan_progress
	data["scan_results"] = scan_results
	data["last_scan_time"] = last_scan_time ? "Данные актуальны" : "Сканирование не проводилось"

	// Антивирус
	data["antivirus_scanning"] = antivirus_scanning
	data["antivirus_progress"] = antivirus_progress
	data["antivirus_results"] = antivirus_results
	data["virus_count"] = viruses.len
	data["has_serious_viruses"] = FALSE
	for(var/datum/ipc_virus/v in viruses)
		if(v.severity == "high")
			data["has_serious_viruses"] = TRUE
			break

	// Вирусы (показываем для антивируса)
	var/list/virus_list = list()
	for(var/datum/ipc_virus/v in viruses)
		virus_list += list(list(
			"name" = v.name,
			"desc" = v.desc,
			"severity" = v.severity,
			"removable" = v.removable_by_antivirus,
		))
	data["viruses"] = virus_list

	// NET-door
	check_network_connection()
	data["network_connected"] = network_connected

	var/list/catalog = list()
	for(var/datum/ipc_netapp/app in net_catalog)
		catalog += list(list(
			"name" = app.name,
			"desc" = app.desc,
			"category" = app.category,
			"installed" = app.installed,
		))
	data["net_catalog"] = catalog

	var/list/installed = list()
	for(var/datum/ipc_netapp/app in installed_apps)
		installed += list(list(
			"name" = app.name,
			"desc" = app.desc,
			"category" = app.category,
		))
	data["installed_apps"] = installed

	return data

/datum/ipc_operating_system/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_password")
			var/new_pass = params["password"]
			if(set_password(new_pass))
				logged_in = TRUE
			return TRUE

		if("login")
			var/input_pass = params["password"]
			if(try_login(input_pass))
				return TRUE
			if(owner)
				to_chat(owner, span_warning("Неверный пароль!"))
			return TRUE

		if("logout")
			logout()
			return TRUE

		if("open_app")
			var/app_name = params["app"]
			if(app_name in list("desktop", "diagnostics", "antivirus", "netdoor"))
				current_app = app_name
			return TRUE

		if("start_scan")
			start_diagnostics_scan()
			return TRUE

		if("start_antivirus")
			start_antivirus_scan()
			return TRUE

		if("install_app")
			var/app_name = params["app_name"]
			for(var/datum/ipc_netapp/app in net_catalog)
				if(app.name == app_name)
					install_net_app(app)
					break
			return TRUE

		if("uninstall_app")
			var/app_name = params["app_name"]
			for(var/datum/ipc_netapp/app in installed_apps)
				if(app.name == app_name)
					uninstall_net_app(app)
					break
			return TRUE

// ============================================
// КНОПКА ДЕЙСТВИЯ (ОТКРЫТЬ ОС)
// ============================================

/datum/action/innate/ipc_open_os
	name = "Открыть ОС"
	desc = "Открыть операционную систему IPC."
	button_icon_state = "yourface"
	background_icon_state = "bg_default"
	/// Ссылка на ОС
	var/datum/ipc_operating_system/os_system

/datum/action/innate/ipc_open_os/Activate()
	if(!os_system)
		return
	os_system.ui_interact(owner)

/datum/action/innate/ipc_open_os/Remove(mob/M)
	os_system = null
	return ..()
