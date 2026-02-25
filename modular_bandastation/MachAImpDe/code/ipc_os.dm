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
			return "Yūrei OS"
	return "GenericOS"

/// Возвращает цвет темы ОС по ключу бренда
/proc/get_ipc_os_theme_color(brand_key)
	switch(brand_key)
		if("morpheus")
			return "#9b59d9"  // Корпоративный фиолет
		if("etamin")
			return "#d94a4a"  // Военный красный
		if("bishop")
			return "#4a8fd9"  // Медицинский стальной синий
		if("hesphiastos")
			return "#4a8a3a"  // Военный зелёный
		if("ward_takahashi")
			return "#9a9aaa"  // Элегантный серый
		if("xion")
			return "#d97820"  // Инженерный оранжевый
		if("zeng_hu")
			return "#d4845a"  // Тёплый коралл
		if("shellguard")
			return "#aa1111"  // Тёмно-красный
		if("cybersun")
			return "#dd1133"  // Зловещий алый неон
		if("unbranded")
			return "#5aff5a"  // Фосфорный зелёный
		if("hef")
			return "#9060cc"  // Призрачный фиолет
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
// NET ПРИЛОЖЕНИЯ — WHITE WALL (легальные)
// ============================================

/datum/ipc_netapp
	/// Название приложения
	var/name = "Unknown App"
	/// Описание
	var/desc = ""
	/// Категория: "utility", "diagnostic", "entertainment", "pda", "exploit", "mod"
	var/category = "utility"
	/// Установлено ли
	var/installed = FALSE
	/// Размер файла в КБ (для симуляции загрузки)
	var/file_size = 256
	/// Принадлежит ли Black Wall
	var/is_blackwall = FALSE
	/// Может ли быть активировано (вкл/выкл)
	var/toggleable = FALSE
	/// Активно ли сейчас (для toggleable)
	var/active = FALSE
	/// Есть ли эффект при активации
	var/has_effect = FALSE
	/// Пассивный мод (эффект работает пока установлен)
	var/is_passive = FALSE
	/// Даёт ли абилку-кнопку на HUD при установке
	var/grants_ability = FALSE
	/// Кулдаун абилки (если grants_ability)
	var/ability_cooldown = 0
	/// Иконка абилки
	var/ability_icon_state = "default"
	/// Ссылка на выданную абилку
	var/datum/action/cooldown/ipc_app_ability/granted_action
	/// Последнее сообщение от приложения
	var/last_message = ""

/// Выполнить эффект приложения. Вызывается при активации.
/datum/ipc_netapp/proc/execute_effect(mob/living/carbon/human/user)
	return FALSE

/// Деактивировать эффект. Вызывается при выключении.
/datum/ipc_netapp/proc/deactivate_effect(mob/living/carbon/human/user)
	active = FALSE
	return TRUE

/// Применить пассивный эффект. Вызывается при установке.
/datum/ipc_netapp/proc/apply_passive(mob/living/carbon/human/user)
	return

/// Убрать пассивный эффект. Вызывается при удалении.
/datum/ipc_netapp/proc/remove_passive(mob/living/carbon/human/user)
	return

/// Вернуть данные для UI (расширенные)
/datum/ipc_netapp/proc/get_ui_data()
	return list(
		"toggleable" = toggleable,
		"active" = active,
		"has_effect" = has_effect,
		"last_message" = last_message,
	)

// ============================================
// WHITE WALL: Утилиты (аналоги КПК)
// ============================================

/datum/ipc_netapp/thermal_monitor
	name = "ThermalWatch Pro"
	desc = "Расширенный мониторинг температуры процессора и окружающей среды. Показывает CPU temp, зону комфорта и предупреждения."
	category = "diagnostic"
	file_size = 180
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 3 SECONDS

/datum/ipc_netapp/thermal_monitor/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	var/datum/species/ipc/ipc_species = user.dna?.species
	if(!istype(ipc_species))
		last_message = "ОШИБКА: Несовместимая архитектура."
		to_chat(user, span_warning("ОС [name]: [last_message]"))
		return FALSE

	var/cpu_temp = round(ipc_species.cpu_temperature, 0.1)
	var/env_temp = 0
	var/datum/gas_mixture/environment = user.loc?.return_air()
	if(environment)
		env_temp = round(environment.temperature - T0C, 0.1)

	// Определяем статус CPU
	var/cpu_status = "НОРМА"
	if(cpu_temp >= 130)
		cpu_status = "КРИТИЧНО!"
	else if(cpu_temp >= 90)
		cpu_status = "ПЕРЕГРЕВ!"
	else if(cpu_temp >= 80)
		cpu_status = "ГОРЯЧО"
	else if(cpu_temp < 20)
		cpu_status = "ХОЛОДНО"

	last_message = "CPU: [cpu_temp]°C ([cpu_status]) | Среда: [env_temp]°C"
	to_chat(user, span_notice("ОС [name]: Температура CPU: [cpu_temp]°C — [cpu_status]"))
	to_chat(user, span_notice("ОС [name]: Окружающая среда: [env_temp]°C"))
	if(ipc_species.overclock_active)
		to_chat(user, span_warning("ОС [name]: Разгон активен! Процессор нагревается."))
	return TRUE

/datum/ipc_netapp/power_optimizer
	name = "PowerSave 3.0"
	desc = "Снижает расход батареи на 30%. Пассивный мод — работает пока установлен."
	category = "utility"
	file_size = 320
	is_passive = TRUE
	/// Оригинальный charge_rate (для восстановления при удалении)
	var/original_charge_rate = 0
	/// Применён ли эффект
	var/effect_applied = FALSE

/// При установке — снижаем charge_rate батареи
/datum/ipc_netapp/power_optimizer/apply_passive(mob/living/carbon/human/user)
	if(!user || effect_applied)
		return
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery && istype(battery))
		original_charge_rate = battery.charge_rate
		battery.charge_rate = battery.charge_rate * 0.7  // -30% расход
		effect_applied = TRUE
		last_message = "Энергосбережение активно. Расход снижен на 30%."

/// При удалении — восстанавливаем charge_rate
/datum/ipc_netapp/power_optimizer/remove_passive(mob/living/carbon/human/user)
	if(!user || !effect_applied)
		return
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery && istype(battery))
		battery.charge_rate = original_charge_rate || 1
	effect_applied = FALSE
	last_message = ""

/datum/ipc_netapp/signal_booster
	name = "SignalBoost"
	desc = "Сканирует радиоэфир, показывает ближайшие радиоустройства и их частоты. Позволяет перехватывать сигналы."
	category = "utility"
	file_size = 150
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 10 SECONDS

/datum/ipc_netapp/signal_booster/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	// Сканируем ближайшие радиоустройства
	var/list/found_devices = list()
	for(var/obj/item/radio/R in range(7, user))
		if(R.is_on())
			var/freq = R.get_frequency()
			found_devices += "[R.name] ([freq / 10].[freq % 10] кГц)"
	for(var/obj/machinery/telecomms/T in range(7, user))
		found_devices += "[T.name] — телекоммуникации"

	if(!length(found_devices))
		last_message = "Радиоустройств не обнаружено в радиусе сканирования."
		to_chat(user, span_notice("ОС [name]: [last_message]"))
		return TRUE

	to_chat(user, span_notice("ОС [name]: Обнаружено [length(found_devices)] устройств:"))
	for(var/device in found_devices)
		to_chat(user, span_notice("  → [device]"))

	last_message = "Обнаружено [length(found_devices)] радиоустройств."
	return TRUE

/datum/ipc_netapp/defrag_tool
	name = "DefragMaster"
	desc = "Дефрагментация системы: снижает температуру CPU на 15°C, восстанавливает 5 HP механических повреждений и оптимизирует когнитивные процессы."
	category = "utility"
	file_size = 410
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 30 SECONDS

/datum/ipc_netapp/defrag_tool/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	var/datum/species/ipc/ipc_species = user.dna?.species

	// Снижаем температуру CPU
	if(istype(ipc_species))
		var/old_temp = ipc_species.cpu_temperature
		ipc_species.cpu_temperature = max(ipc_species.cpu_temperature - 15, 0)
		var/cooled = round(old_temp - ipc_species.cpu_temperature, 0.1)
		if(cooled > 0)
			to_chat(user, span_notice("ОС [name]: Температура CPU снижена на [cooled]°C."))

	// Лечим небольшой brute-урон
	if(user.get_brute_loss() > 0)
		user.heal_overall_damage(brute = 5, forced = TRUE)
		to_chat(user, span_notice("ОС [name]: Восстановлено 5 HP механических повреждений."))

	// Убираем головокружение и замешательство
	user.adjust_dizzy(-5 SECONDS)
	user.adjust_confusion(-3 SECONDS)

	last_message = "Дефрагментация завершена. Системы оптимизированы."
	to_chat(user, span_notice("ОС [name]: [last_message]"))
	return TRUE

/datum/ipc_netapp/firewall_plus
	name = "Firewall+"
	desc = "Пассивная защита от сетевых вирусов. Блокирует 60% попыток заражения. Работает пока установлен."
	category = "utility"
	file_size = 290
	is_passive = TRUE

/datum/ipc_netapp/sensor_calibration
	name = "SensorCal"
	desc = "Калибровка оптических сенсоров. Снимает размытие зрения."
	category = "diagnostic"
	file_size = 200
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 15 SECONDS

/datum/ipc_netapp/sensor_calibration/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	user.adjust_eye_blur(-10 SECONDS)
	last_message = "Сенсоры откалиброваны. Чёткость зрения восстановлена."
	to_chat(user, span_notice("ОС [name]: [last_message]"))
	return TRUE

// ============================================
// АБИЛКА-КНОПКА ДЛЯ УСТАНОВЛЕННЫХ ПРИЛОЖЕНИЙ
// ============================================

/// Универсальная абилка для приложений ОС — привязана к конкретному netapp
/datum/action/cooldown/ipc_app_ability
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	click_to_activate = FALSE
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	/// Ссылка на приложение
	var/datum/ipc_netapp/linked_app

/datum/action/cooldown/ipc_app_ability/New(Target, datum/ipc_netapp/app)
	linked_app = app
	if(app)
		name = app.name
		desc = app.desc
		button_icon_state = app.ability_icon_state
		cooldown_time = app.ability_cooldown
	. = ..()

/datum/action/cooldown/ipc_app_ability/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!linked_app?.installed)
		return FALSE
	return TRUE

/datum/action/cooldown/ipc_app_ability/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !linked_app)
		return FALSE

	// Для toggleable — переключаем
	if(linked_app.toggleable)
		if(linked_app.active)
			linked_app.deactivate_effect(H)
			background_icon_state = "bg_tech_blue"
		else
			linked_app.execute_effect(H)
			if(linked_app.active)
				background_icon_state = "bg_tech_blue_active"
	else
		linked_app.execute_effect(H)

	build_all_button_icons()
	StartCooldown()
	return TRUE

/datum/action/cooldown/ipc_app_ability/Remove(mob/living/remove_from)
	linked_app = null
	return ..()

// ============================================
// WHITE WALL: Виртуальный КПК
// ============================================

/// Внутренний КПК для IPC — не тратит заряд, показывает заряд батареи КПБ
/obj/item/modular_computer/pda/ipc_internal
	name = "IPC Internal PDA"

/// Не тратим заряд — питание идёт от батареи КПБ напрямую
/obj/item/modular_computer/pda/ipc_internal/check_power_override()
	return TRUE

/// Получить ID-карту — берём из слота ID владельца-КПБ
/obj/item/modular_computer/pda/ipc_internal/GetID()
	// Если вставлена карта вручную — приоритет ей
	if(stored_id)
		return stored_id
	// Иначе ищем ID карту у владельца
	var/mob/living/carbon/human/H = loc
	if(istype(H) && H.wear_id)
		return H.wear_id.GetID()
	return ..()

/// Получить доступы — через подключённую ID-карту
/obj/item/modular_computer/pda/ipc_internal/GetAccess()
	if(stored_id)
		return stored_id.GetAccess()
	var/mob/living/carbon/human/H = loc
	if(istype(H) && H.wear_id)
		var/obj/item/card/id/id = H.wear_id.GetID()
		if(id)
			return id.GetAccess()
	return ..()

/// Синхронизируем отображение заряда с батареей КПБ
/obj/item/modular_computer/pda/ipc_internal/get_header_data()
	var/list/data = ..()
	// Берём заряд из батареи КПБ владельца
	var/mob/living/carbon/human/H = loc
	if(istype(H))
		var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
		if(battery)
			var/pct = round((battery.charge / battery.maxcharge) * 100)
			data["PC_lowpower_mode"] = (battery.charge <= 0)
			data["PC_batterypercent"] = "[pct]%"
			if(pct >= 80)
				data["PC_batteryicon"] = "batt_100.gif"
			else if(pct >= 60)
				data["PC_batteryicon"] = "batt_80.gif"
			else if(pct >= 40)
				data["PC_batteryicon"] = "batt_60.gif"
			else if(pct >= 20)
				data["PC_batteryicon"] = "batt_40.gif"
			else if(pct >= 5)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
	return data

/datum/ipc_netapp/virtual_pda
	name = "КПК-эмулятор"
	desc = "Полноценный эмулятор КПК со всеми стандартными приложениями. Питание от батареи КПБ, доп. расхода нет."
	category = "pda"
	file_size = 512
	has_effect = TRUE
	/// Внутренний КПК (создаётся при установке)
	var/obj/item/modular_computer/pda/ipc_internal/internal_pda

/// Создать внутренний КПК для пользователя
/datum/ipc_netapp/virtual_pda/proc/ensure_pda(mob/living/carbon/human/user)
	if(internal_pda && !QDELETED(internal_pda))
		return internal_pda
	internal_pda = new /obj/item/modular_computer/pda/ipc_internal(user)
	internal_pda.enabled = TRUE
	internal_pda.screen_on = TRUE
	// Назначаем имя владельца
	var/pda_name = user.real_name ? user.real_name : user.name
	var/pda_job = user.job ? user.job : "IPC"
	internal_pda.imprint_id(pda_name, pda_job)
	return internal_pda

/datum/ipc_netapp/virtual_pda/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	var/obj/item/modular_computer/pda/pda = ensure_pda(user)
	if(!pda)
		last_message = "ОШИБКА: Не удалось инициализировать КПК."
		return FALSE
	if(!pda.enabled)
		pda.turn_on(user, open_ui = FALSE)
	pda.ui_interact(user)
	last_message = "КПК-эмулятор запущен."
	return TRUE

/datum/ipc_netapp/virtual_pda/Destroy()
	QDEL_NULL(internal_pda)
	return ..()

// ============================================
// NET ПРИЛОЖЕНИЯ — BLACK WALL (нелегальные)
// ============================================

/datum/ipc_netapp/blackwall
	is_blackwall = TRUE

/datum/ipc_netapp/blackwall/virus_kit
	name = "VirusKit"
	desc = "Создание и передача вирусов другим КПБ в зоне видимости."
	category = "exploit"
	file_size = 780
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 20 SECONDS

/datum/ipc_netapp/blackwall/virus_kit/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	// Выбираем тип вируса для создания
	var/list/virus_types = list(
		"DisplayGlitch.v2" = /datum/ipc_virus/display_glitch,
		"MemLeak.trojan" = /datum/ipc_virus/memory_leak,
		"SensorNoise.worm" = /datum/ipc_virus/sensor_noise,
	)
	var/choice = tgui_input_list(user, "Выберите вирус для отправки:", "VirusKit", virus_types)
	if(!choice)
		return FALSE

	// Ищем КПБ рядом
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view(7, user))
		if(H == user)
			continue
		var/datum/species/ipc/ipc_species = H.dna?.species
		if(istype(ipc_species) && ipc_species.ipc_os)
			targets += H

	if(!length(targets))
		last_message = "Нет КПБ в зоне действия."
		to_chat(user, span_warning("ОС [name]: [last_message]"))
		return FALSE

	var/mob/living/carbon/human/target = tgui_input_list(user, "Выберите цель:", "VirusKit", targets)
	if(!target)
		return FALSE

	var/datum/species/ipc/target_species = target.dna?.species
	if(!istype(target_species) || !target_species.ipc_os)
		return FALSE

	var/datum/ipc_virus/new_virus = new virus_types[choice]
	if(target_species.ipc_os.infect(new_virus))
		last_message = "Вирус [choice] отправлен → [target.name]"
		to_chat(user, span_warning("ОС [name]: Вирус успешно отправлен!"))
	else
		last_message = "Не удалось заразить [target.name]."
		to_chat(user, span_warning("ОС [name]: Заражение не удалось (дубликат или файрволл)."))
	return TRUE

/datum/ipc_netapp/blackwall/overclock
	name = "OverClock.exe"
	desc = "Пассивный мод. Усиливает абилку разгона: бонус скорости 40% → 70%, добавляет ускорение передвижения при разгоне. Работает пока установлен."
	category = "mod"
	file_size = 450
	is_passive = TRUE

/datum/ipc_netapp/blackwall/wall_breaker
	name = "WallBreaker"
	desc = "Взлом ближайшего шлюза. Работает как одноразовый электрический разряд."
	category = "exploit"
	file_size = 620
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 45 SECONDS

/datum/ipc_netapp/blackwall/wall_breaker/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	// Ищем шлюз рядом (в пределах 1 тайла)
	var/list/airlocks = list()
	for(var/obj/machinery/door/airlock/A in range(1, user))
		airlocks += A

	if(!length(airlocks))
		last_message = "Шлюзов рядом не обнаружено."
		to_chat(user, span_warning("ОС [name]: [last_message]"))
		return FALSE

	var/obj/machinery/door/airlock/target = airlocks[1]
	if(length(airlocks) > 1)
		target = tgui_input_list(user, "Выберите шлюз:", "WallBreaker", airlocks)
	if(!target)
		return FALSE

	// Пытаемся открыть
	if(target.locked)
		target.set_bolt(FALSE)
		last_message = "Болты шлюза [target.name] разблокированы."
		to_chat(user, span_warning("ОС [name]: Болты шлюза разблокированы!"))
	else if(target.density)
		target.open()
		last_message = "Шлюз [target.name] взломан и открыт."
		to_chat(user, span_warning("ОС [name]: Шлюз взломан!"))
	else
		last_message = "Шлюз уже открыт."
		to_chat(user, span_notice("ОС [name]: [last_message]"))

	// КПБ получает урон от напряжения взлома
	user.adjust_fire_loss(5)
	to_chat(user, span_danger("Обратная связь от взлома повредила проводку!"))
	return TRUE

/datum/ipc_netapp/blackwall/id_spoof
	name = "ID_Spoof v3"
	desc = "Временная подмена имени и должности в системах станции."
	category = "exploit"
	file_size = 340
	has_effect = TRUE
	toggleable = TRUE
	grants_ability = TRUE
	ability_cooldown = 5 SECONDS
	/// Оригинальное имя
	var/original_name = ""
	/// Поддельное имя
	var/fake_name = ""
	/// Поддельная должность
	var/fake_job = ""

/datum/ipc_netapp/blackwall/id_spoof/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(active)
		deactivate_effect(user)
		return TRUE

	// Запрашиваем фейковые данные
	var/new_name = tgui_input_text(user, "Введите поддельное имя:", "ID Spoof", user.real_name)
	if(!new_name)
		return FALSE
	var/new_job = tgui_input_text(user, "Введите поддельную должность:", "ID Spoof", user.job)
	if(!new_job)
		return FALSE

	original_name = user.real_name
	fake_name = new_name
	fake_job = new_job

	// Подменяем видимые данные
	user.fully_replace_character_name(user.real_name, fake_name)
	user.job = fake_job
	active = TRUE

	last_message = "Активен: [fake_name] / [fake_job]"
	to_chat(user, span_warning("ОС [name]: ID подменён на [fake_name] / [fake_job]"))
	return TRUE

/datum/ipc_netapp/blackwall/id_spoof/deactivate_effect(mob/living/carbon/human/user)
	. = ..()
	if(!user || !original_name)
		return
	user.fully_replace_character_name(user.real_name, original_name)
	original_name = ""
	fake_name = ""
	fake_job = ""
	last_message = "ID восстановлен."
	to_chat(user, span_notice("ОС [name]: Оригинальный ID восстановлен."))

/datum/ipc_netapp/blackwall/ghost_mode
	name = "GhostMode"
	desc = "Скрытие от сенсоров экипажа, медицинского HUD и манифеста. Работает пока активен."
	category = "mod"
	file_size = 550
	has_effect = TRUE
	toggleable = TRUE
	grants_ability = TRUE
	ability_cooldown = 5 SECONDS

/datum/ipc_netapp/blackwall/ghost_mode/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(active)
		deactivate_effect(user)
		return TRUE

	active = TRUE
	// Скрываем от сенсоров — неизвестная внешность и голос
	ADD_TRAIT(user, TRAIT_UNKNOWN_APPEARANCE, "ghost_mode_app")
	ADD_TRAIT(user, TRAIT_UNKNOWN_VOICE, "ghost_mode_app")
	last_message = "Режим невидимости активен. Сенсоры не обнаруживают вас."
	to_chat(user, span_warning("ОС [name]: GhostMode включён. Вы невидимы для сенсоров."))
	return TRUE

/datum/ipc_netapp/blackwall/ghost_mode/deactivate_effect(mob/living/carbon/human/user)
	. = ..()
	if(!user)
		return
	REMOVE_TRAIT(user, TRAIT_UNKNOWN_APPEARANCE, "ghost_mode_app")
	REMOVE_TRAIT(user, TRAIT_UNKNOWN_VOICE, "ghost_mode_app")
	last_message = "Режим невидимости отключён."
	to_chat(user, span_notice("ОС [name]: GhostMode отключён. Сенсоры снова вас видят."))

/datum/ipc_netapp/blackwall/neural_crack
	name = "NeuralCrack"
	desc = "Снимает оглушение, выводит из бессознательного состояния и убирает замедления. Высокая нагрузка на систему."
	category = "exploit"
	file_size = 890
	has_effect = TRUE
	grants_ability = TRUE
	ability_cooldown = 60 SECONDS

/datum/ipc_netapp/blackwall/neural_crack/execute_effect(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	// Снимаем негативные эффекты
	user.AdjustStun(-100 SECONDS)
	user.AdjustKnockdown(-100 SECONDS)
	user.AdjustImmobilized(-100 SECONDS)
	user.AdjustParalyzed(-100 SECONDS)
	user.AdjustUnconscious(-100 SECONDS)
	user.SetSleeping(0)

	// Цена — урон и нагрев процессора
	user.adjust_fire_loss(10)
	var/datum/species/ipc/ipc_species = user.dna?.species
	if(istype(ipc_species))
		ipc_species.cpu_temperature = min(ipc_species.cpu_temperature + 25, 200)

	last_message = "Блокировки сняты. ВНИМАНИЕ: нагрузка на систему критическая!"
	to_chat(user, span_boldwarning("ОС [name]: Все блокировки нейросети сняты!"))
	to_chat(user, span_danger("Температура процессора повысилась на 25°C! Системы повреждены!"))
	return TRUE

// Модификатор скорости для усиленного разгона (OverClock.exe)
/datum/movespeed_modifier/ipc_overclock_enhanced
	multiplicative_slowdown = -0.3

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
	/// Какое приложение сейчас открыто: "desktop", "diagnostics", "antivirus", "net", "installed_app"
	var/current_app = "desktop"
	/// Имя открытого установленного приложения (когда current_app == "installed_app")
	var/current_installed_app_name = ""

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

	// --- NET ---
	/// Подключён ли к сети
	var/network_connected = FALSE
	/// Выбранная стена: "white" или "black"
	var/net_wall = "white"
	/// Доступные приложения (White Wall)
	var/list/net_catalog = list()
	/// Доступные приложения (Black Wall)
	var/list/black_wall_catalog = list()
	/// Установленные приложения
	var/list/installed_apps = list()
	// --- Позиции иконок рабочего стола ---
	/// Ассоциативный список: "app_id" = list("x" = N, "y" = N)
	var/list/icon_positions = list()

	// --- Загрузка приложений ---
	/// Идёт ли загрузка
	var/downloading = FALSE
	/// Прогресс загрузки (0-100)
	var/download_progress = 0
	/// Имя загружаемого приложения
	var/download_app_name = ""
	/// Ссылка на загружаемое приложение
	var/datum/ipc_netapp/download_target = null
	/// ID таймера загрузки
	var/download_timer_id = null

	// --- Удалённый доступ (роботехник через терминал) ---
	/// Моб с удалённым доступом к ОС
	var/mob/remote_viewer = null
	/// Ожидается ли запрос на доступ
	var/pending_access_request = FALSE
	/// Кто запрашивает доступ
	var/mob/requesting_user = null
	/// Режим удалённого доступа: "password" (полный) или "permission" (каждое действие требует подтверждения)
	var/remote_access_mode = "permission"
	/// Ожидается ли подтверждение действия от владельца
	var/pending_action_approval = FALSE
	/// Описание действия, ожидающего подтверждения
	var/pending_action_desc = ""
	/// Действие, ожидающее подтверждения (action name)
	var/pending_action_name = ""
	/// Параметры ожидающего действия
	var/list/pending_action_params = list()

/datum/ipc_operating_system/New(mob/living/carbon/human/new_owner, new_brand_key)
	. = ..()
	owner = new_owner
	brand_key = new_brand_key || "unbranded"
	os_name = get_ipc_os_name(brand_key)
	theme_color = get_ipc_os_theme_color(brand_key)

	// Инициализируем каталог NET — White Wall
	net_catalog = list(
		new /datum/ipc_netapp/thermal_monitor(),
		new /datum/ipc_netapp/power_optimizer(),
		new /datum/ipc_netapp/signal_booster(),
		new /datum/ipc_netapp/defrag_tool(),
		new /datum/ipc_netapp/firewall_plus(),
		new /datum/ipc_netapp/sensor_calibration(),
		// Виртуальный КПК — все приложения КПК в одном
		new /datum/ipc_netapp/virtual_pda(),
	)
	// Позиции иконок по умолчанию (сетка 90px)
	icon_positions = list(
		"diagnostics" = list("x" = 10, "y" = 10),
		"antivirus" = list("x" = 100, "y" = 10),
		"net" = list("x" = 190, "y" = 10),
	)

	// Инициализируем каталог NET — Black Wall
	black_wall_catalog = list(
		new /datum/ipc_netapp/blackwall/virus_kit(),
		new /datum/ipc_netapp/blackwall/overclock(),
		new /datum/ipc_netapp/blackwall/wall_breaker(),
		new /datum/ipc_netapp/blackwall/id_spoof(),
		new /datum/ipc_netapp/blackwall/ghost_mode(),
		new /datum/ipc_netapp/blackwall/neural_crack(),
	)

/datum/ipc_operating_system/Destroy()
	if(remote_viewer)
		to_chat(remote_viewer, span_warning("Удалённый доступ к ОС отключён: система уничтожена."))
	// Убираем абилки у всех установленных приложений
	for(var/datum/ipc_netapp/app in installed_apps)
		if(app.granted_action)
			app.granted_action.Remove(app.granted_action.owner)
			QDEL_NULL(app.granted_action)
	owner = null
	remote_viewer = null
	requesting_user = null
	QDEL_LIST(viruses)
	QDEL_LIST(net_catalog)
	QDEL_LIST(black_wall_catalog)
	QDEL_LIST(installed_apps)
	download_target = null
	if(scan_timer_id)
		deltimer(scan_timer_id)
	if(antivirus_timer_id)
		deltimer(antivirus_timer_id)
	if(download_timer_id)
		deltimer(download_timer_id)
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
	// Проверяем Firewall+ — блокирует 60% попыток заражения
	for(var/datum/ipc_netapp/firewall_plus/fw in installed_apps)
		if(prob(60))
			if(owner)
				to_chat(owner, span_notice("ОС Firewall+: Попытка заражения заблокирована!"))
			qdel(new_virus)
			return FALSE
		break
	new_virus.infection_time = world.time
	viruses += new_virus
	if(owner)
		to_chat(owner, span_userdanger("ПРЕДУПРЕЖДЕНИЕ ОС: Обнаружена подозрительная активность в системе!"))
	return TRUE

// ============================================
// NET (СЕТЬ)
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

/// Начать загрузку приложения (имитация)
/datum/ipc_operating_system/proc/start_download(datum/ipc_netapp/app)
	if(!app || app.installed || downloading || !network_connected)
		return FALSE

	downloading = TRUE
	download_progress = 0
	download_app_name = app.name
	download_target = app

	advance_download()
	return TRUE

/// Продвижение загрузки
/datum/ipc_operating_system/proc/advance_download()
	if(!downloading || !download_target)
		downloading = FALSE
		download_target = null
		return

	// Скорость зависит от размера файла — чем больше, тем дольше
	var/step = max(8, round(100 / max(1, download_target.file_size / 100)))
	download_progress = min(download_progress + step, 100)

	if(download_progress >= 100)
		// Загрузка завершена — устанавливаем
		complete_download()
		return

	download_timer_id = addtimer(CALLBACK(src, PROC_REF(advance_download)), 0.8 SECONDS, TIMER_STOPPABLE)
	SStgui.update_uis(src)

/// Завершение загрузки
/datum/ipc_operating_system/proc/complete_download()
	if(download_target)
		download_target.installed = TRUE
		installed_apps += download_target
		// Позиция для новой иконки: ищем свободное место на рабочем столе
		var/next_x = 10 + (installed_apps.len - 1) % 7 * 90
		var/next_y = 100 + round((installed_apps.len - 1) / 7) * 90
		icon_positions["installed_[download_target.name]"] = list("x" = next_x, "y" = next_y)
		// Применяем пассивный эффект если есть
		if(download_target.is_passive && owner)
			download_target.apply_passive(owner)
		// Выдаём абилку-кнопку если приложение её даёт
		if(download_target.grants_ability && owner)
			var/datum/action/cooldown/ipc_app_ability/new_action = new(null, download_target)
			new_action.Grant(owner)
			download_target.granted_action = new_action
		if(owner)
			to_chat(owner, span_notice("ОС: Приложение \"[download_target.name]\" успешно установлено."))

	downloading = FALSE
	download_progress = 0
	download_app_name = ""
	download_target = null
	SStgui.update_uis(src)

/// Отмена загрузки
/datum/ipc_operating_system/proc/cancel_download()
	if(!downloading)
		return
	if(download_timer_id)
		deltimer(download_timer_id)
	downloading = FALSE
	download_progress = 0
	download_app_name = ""
	download_target = null
	SStgui.update_uis(src)

/datum/ipc_operating_system/proc/uninstall_net_app(datum/ipc_netapp/app)
	if(!app)
		return FALSE
	if(!app.installed)
		return FALSE

	// Деактивируем toggleable-эффект если активен
	if(app.toggleable && app.active && owner)
		app.deactivate_effect(owner)
	// Убираем пассивный эффект если есть
	if(app.is_passive && owner)
		app.remove_passive(owner)
	// Убираем абилку-кнопку если была выдана
	if(app.granted_action)
		app.granted_action.Remove(app.granted_action.owner)
		QDEL_NULL(app.granted_action)
	app.installed = FALSE
	installed_apps -= app
	return TRUE

// ============================================
// УДАЛЁННЫЙ ДОСТУП (РОБОТЕХНИК)
// ============================================

/// Запрос удалённого доступа к ОС (метод запроса)
/datum/ipc_operating_system/proc/request_remote_access(mob/requester)
	if(!owner || !requester)
		return FALSE
	if(pending_access_request)
		to_chat(requester, span_warning("Запрос доступа уже отправлен. Ожидайте ответа."))
		return FALSE
	if(remote_viewer)
		to_chat(requester, span_warning("Удалённый доступ уже активен."))
		return FALSE

	pending_access_request = TRUE
	requesting_user = requester

	// Уведомляем IPC
	to_chat(owner, span_notice("СИСТЕМА: Получен запрос на удалённый доступ к ОС от [requester.name]. Проверьте вашу ОС."))

	// Открываем ОС у IPC если не открыта
	ui_interact(owner)

	SStgui.update_uis(src)
	return TRUE

/// Одобрить запрос доступа
/datum/ipc_operating_system/proc/approve_access()
	if(!pending_access_request || !requesting_user)
		return FALSE

	var/mob/requester = requesting_user
	pending_access_request = FALSE
	requesting_user = null
	remote_viewer = requester
	remote_access_mode = "permission"  // Доступ по запросу = режим разрешений

	// Авто-логин если ещё не залогинены
	if(!logged_in)
		logged_in = TRUE

	to_chat(owner, span_notice("ОС: Удалённый доступ предоставлен [requester.name] (режим разрешений)."))
	to_chat(requester, span_notice("Удалённый доступ к ОС пациента одобрен (режим разрешений — действия требуют подтверждения)."))

	// Открываем ОС для роботехника
	ui_interact(requester)

	SStgui.update_uis(src)
	return TRUE

/// Отклонить запрос доступа
/datum/ipc_operating_system/proc/deny_access()
	if(!pending_access_request)
		return FALSE

	if(requesting_user)
		to_chat(requesting_user, span_warning("Запрос на доступ к ОС отклонён пациентом."))

	pending_access_request = FALSE
	requesting_user = null

	SStgui.update_uis(src)
	return TRUE

/// Войти удалённо по паролю (метод пароля)
/datum/ipc_operating_system/proc/remote_login(mob/requester, input_password)
	if(!requester)
		return FALSE
	if(remote_viewer)
		to_chat(requester, span_warning("Удалённый доступ уже активен."))
		return FALSE

	if(!check_password(input_password))
		to_chat(requester, span_warning("Неверный пароль ОС."))
		return FALSE

	remote_viewer = requester
	remote_access_mode = "password"  // Доступ по паролю = полный доступ

	// Авто-логин
	if(!logged_in)
		logged_in = TRUE

	to_chat(owner, span_warning("ОС: Обнаружен удалённый вход в систему по паролю от [requester.name]!"))
	to_chat(requester, span_notice("Доступ к ОС пациента получен по паролю (полный доступ)."))

	// Открываем ОС для роботехника
	ui_interact(requester)
	// Также открываем для IPC
	if(owner)
		ui_interact(owner)

	SStgui.update_uis(src)
	return TRUE

/// Получить описание действия для подтверждения
/datum/ipc_operating_system/proc/get_action_description(action_name, list/action_params)
	switch(action_name)
		if("start_scan")
			return "Запустить сканирование систем"
		if("start_antivirus")
			return "Запустить антивирусную проверку"
		if("download_app")
			return "Скачать приложение: [action_params["app_name"]]"
		if("uninstall_app")
			return "Удалить приложение: [action_params["app_name"]]"
		if("cancel_download")
			return "Отменить загрузку"
		if("console_bypass")
			return "Консоль: Blackwall-обход для [action_params["app_name"]]"
	return "Неизвестное действие"

/// Запросить подтверждение действия у владельца
/datum/ipc_operating_system/proc/request_action_approval(action_name, list/action_params, mob/requester)
	if(pending_action_approval)
		to_chat(requester, span_warning("Уже ожидается подтверждение другого действия."))
		return FALSE

	pending_action_approval = TRUE
	pending_action_name = action_name
	pending_action_params = action_params.Copy()
	pending_action_desc = get_action_description(action_name, action_params)

	if(owner)
		to_chat(owner, span_notice("СИСТЕМА: [requester.name] запрашивает разрешение: [pending_action_desc]. Проверьте вашу ОС."))

	SStgui.update_uis(src)
	return TRUE

/// Одобрить запрошенное действие
/datum/ipc_operating_system/proc/approve_pending_action()
	if(!pending_action_approval)
		return FALSE

	var/action = pending_action_name
	var/list/params = pending_action_params.Copy()

	pending_action_approval = FALSE
	pending_action_name = ""
	pending_action_desc = ""
	pending_action_params = list()

	if(remote_viewer)
		to_chat(remote_viewer, span_notice("Действие одобрено владельцем ОС."))

	// Выполняем действие
	execute_action(action, params)

	SStgui.update_uis(src)
	return TRUE

/// Отклонить запрошенное действие
/datum/ipc_operating_system/proc/deny_pending_action()
	if(!pending_action_approval)
		return FALSE

	if(remote_viewer)
		to_chat(remote_viewer, span_warning("Действие отклонено владельцем ОС: [pending_action_desc]"))

	pending_action_approval = FALSE
	pending_action_name = ""
	pending_action_desc = ""
	pending_action_params = list()

	SStgui.update_uis(src)
	return TRUE

/// Выполнить действие напрямую (после одобрения или от владельца)
/datum/ipc_operating_system/proc/execute_action(action, list/params)
	switch(action)
		if("start_scan")
			start_diagnostics_scan()
		if("start_antivirus")
			start_antivirus_scan()
		if("download_app")
			var/app_name = params["app_name"]
			var/wall = params["wall"]
			var/list/search_catalog = (wall == "black") ? black_wall_catalog : net_catalog
			for(var/datum/ipc_netapp/app in search_catalog)
				if(app.name == app_name)
					start_download(app)
					break
		if("cancel_download")
			cancel_download()
		if("uninstall_app")
			var/app_name = params["app_name"]
			for(var/datum/ipc_netapp/app in installed_apps)
				if(app.name == app_name)
					uninstall_net_app(app)
					break

/// Список действий, которые требуют подтверждения в permission-режиме
/datum/ipc_operating_system/proc/is_sensitive_action(action)
	return action in list("start_scan", "start_antivirus", "download_app", "cancel_download", "uninstall_app", "console_bypass")

/// Отключить удалённый доступ
/datum/ipc_operating_system/proc/revoke_remote_access()
	if(!remote_viewer)
		return FALSE

	to_chat(remote_viewer, span_warning("Удалённый доступ к ОС отключён."))
	var/mob/old_viewer = remote_viewer
	remote_viewer = null

	// Закрываем UI только у бывшего зрителя (не у владельца)
	if(LAZYLEN(open_uis))
		for(var/datum/tgui/ui in open_uis)
			if(ui.user == old_viewer)
				ui.close()
				break

	SStgui.update_uis(src)
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

	// NET
	check_network_connection()
	data["network_connected"] = network_connected
	data["net_wall"] = net_wall

	// Загрузка
	data["downloading"] = downloading
	data["download_progress"] = download_progress
	data["download_app_name"] = download_app_name

	// White Wall каталог
	var/list/catalog = list()
	for(var/datum/ipc_netapp/app in net_catalog)
		catalog += list(list(
			"name" = app.name,
			"desc" = app.desc,
			"category" = app.category,
			"installed" = app.installed,
			"file_size" = app.file_size,
		))
	data["net_catalog"] = catalog

	// Black Wall каталог
	var/list/black_catalog = list()
	for(var/datum/ipc_netapp/app in black_wall_catalog)
		black_catalog += list(list(
			"name" = app.name,
			"desc" = app.desc,
			"category" = app.category,
			"installed" = app.installed,
			"file_size" = app.file_size,
		))
	data["black_wall_catalog"] = black_catalog

	var/list/installed = list()
	for(var/datum/ipc_netapp/app in installed_apps)
		var/list/app_data = list(
			"name" = app.name,
			"desc" = app.desc,
			"category" = app.category,
			"is_blackwall" = app.is_blackwall,
			"toggleable" = app.toggleable,
			"active" = app.active,
			"has_effect" = app.has_effect,
			"is_passive" = app.is_passive,
			"last_message" = app.last_message,
		)
		installed += list(app_data)
	data["installed_apps"] = installed

	// Позиции иконок рабочего стола
	data["icon_positions"] = icon_positions

	// Текущее установленное приложение
	data["current_installed_app_name"] = current_installed_app_name

	// Удалённый доступ
	data["pending_access_request"] = pending_access_request
	data["requesting_user_name"] = requesting_user ? requesting_user.name : ""
	data["has_remote_viewer"] = (remote_viewer != null)
	data["remote_viewer_name"] = remote_viewer ? remote_viewer.name : ""
	data["is_remote_user"] = (user != owner)
	data["remote_access_mode"] = remote_access_mode
	data["pending_action_approval"] = pending_action_approval
	data["pending_action_desc"] = pending_action_desc

	// Виртуальный КПК — подключённая ID-карта
	var/pda_id_name = ""
	var/pda_has_id = FALSE
	for(var/datum/ipc_netapp/virtual_pda/vpda in installed_apps)
		if(vpda.internal_pda?.stored_id)
			pda_has_id = TRUE
			var/obj/item/card/id/id = vpda.internal_pda.stored_id
			pda_id_name = "[id.registered_name] — [id.assignment]"
		break
	data["pda_has_id"] = pda_has_id
	data["pda_id_name"] = pda_id_name

	return data

/datum/ipc_operating_system/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/is_remote = (ui.user != owner)

	// Удалённый пользователь в permission-режиме: чувствительные действия требуют подтверждения
	if(is_remote && remote_access_mode == "permission" && is_sensitive_action(action))
		request_action_approval(action, params, ui.user)
		return TRUE

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
			if(app_name in list("desktop", "diagnostics", "antivirus", "net", "console"))
				current_app = app_name
				current_installed_app_name = ""
			return TRUE

		if("start_scan")
			start_diagnostics_scan()
			return TRUE

		if("start_antivirus")
			start_antivirus_scan()
			return TRUE

		if("switch_wall")
			var/wall = params["wall"]
			if(wall in list("white", "black"))
				net_wall = wall
			return TRUE

		if("download_app")
			var/app_name = params["app_name"]
			var/wall = params["wall"]
			var/list/search_catalog = (wall == "black") ? black_wall_catalog : net_catalog
			for(var/datum/ipc_netapp/app in search_catalog)
				if(app.name == app_name)
					start_download(app)
					break
			return TRUE

		if("cancel_download")
			cancel_download()
			return TRUE

		if("uninstall_app")
			var/app_name = params["app_name"]
			for(var/datum/ipc_netapp/app in installed_apps)
				if(app.name == app_name)
					uninstall_net_app(app)
					break
			return TRUE

		// Обход Blackwall через консоль — мини-игра завершена успешно
		if("console_bypass")
			var/app_name = params["app_name"]
			if(!app_name || !network_connected)
				return FALSE
			for(var/datum/ipc_netapp/app in black_wall_catalog)
				if(app.name == app_name && !app.installed)
					start_download(app)
					if(owner)
						to_chat(owner, span_warning("⚡ КОНСОЛЬ: Blackwall-обход активирован — [app_name] устанавливается."))
					break
			return TRUE

		if("approve_access")
			approve_access()
			return TRUE

		if("deny_access")
			deny_access()
			return TRUE

		if("revoke_remote")
			revoke_remote_access()
			return TRUE

		if("set_icon_position")
			var/icon_id = params["icon_id"]
			if(!icon_id)
				return FALSE
			var/new_x = clamp(text2num(params["x"]), 0, 600)
			var/new_y = clamp(text2num(params["y"]), 0, 500)
			icon_positions[icon_id] = list("x" = new_x, "y" = new_y)
			return TRUE

		if("open_installed_app")
			var/app_name = params["app_name"]
			if(!app_name)
				return FALSE
			for(var/datum/ipc_netapp/app in installed_apps)
				if(app.name == app_name)
					current_app = "installed_app"
					current_installed_app_name = app.name
					return TRUE
			return FALSE

		if("close_installed_app")
			current_app = "desktop"
			current_installed_app_name = ""
			return TRUE

		if("activate_app")
			var/app_name = params["app_name"]
			if(!app_name)
				return FALSE
			for(var/datum/ipc_netapp/app in installed_apps)
				if(app.name == app_name && app.has_effect)
					app.execute_effect(owner)
					return TRUE
			return FALSE

		if("toggle_app")
			var/app_name = params["app_name"]
			if(!app_name)
				return FALSE
			for(var/datum/ipc_netapp/app in installed_apps)
				if(app.name == app_name && app.toggleable)
					if(app.active)
						app.deactivate_effect(owner)
					else
						app.execute_effect(owner)
					return TRUE
			return FALSE

		if("approve_action")
			approve_pending_action()
			return TRUE

		if("deny_action")
			deny_pending_action()
			return TRUE

		if("connect_id")
			// Подключить ID-карту из руки к виртуальному КПК
			if(!owner)
				return FALSE
			var/obj/item/held = owner.get_active_held_item()
			if(!held || !isidcard(held))
				to_chat(owner, span_warning("ОС: Возьмите ID-карту в активную руку!"))
				return FALSE
			// Ищем виртуальный КПК в установленных приложениях
			for(var/datum/ipc_netapp/virtual_pda/vpda in installed_apps)
				var/obj/item/modular_computer/pda/pda = vpda.ensure_pda(owner)
				if(pda)
					pda.insert_id(held, owner)
					to_chat(owner, span_notice("ОС: ID-карта подключена к КПК-эмулятору."))
					return TRUE
			to_chat(owner, span_warning("ОС: КПК-эмулятор не установлен!"))
			return FALSE

		if("disconnect_id")
			// Отключить ID-карту от виртуального КПК
			for(var/datum/ipc_netapp/virtual_pda/vpda in installed_apps)
				if(vpda.internal_pda?.stored_id)
					vpda.internal_pda.remove_id(owner)
					to_chat(owner, span_notice("ОС: ID-карта отключена от КПК-эмулятора."))
					return TRUE
			return FALSE

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
