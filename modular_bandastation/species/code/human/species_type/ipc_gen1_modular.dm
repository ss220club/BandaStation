// ============================================
// IPC ПОКОЛЕНИЕ I: МОДУЛЬНОЕ
// ============================================
// + Иммунитет к оглушению
// + Меньше ресурсов на ремонт (базово)
// + Профессиональные перки выбранного модуля
// - Не может использовать оружие вне охранного модуля
// - Низкая скорость передвижения
// - ЭМИ оглушает 5-10 сек (вместо штатного эффекта)
// - Не может использовать Перегрузку
// - Смена модуля занимает 2.5 минуты
//
// ПЕРКИ ПО МОДУЛЮ:
//   Медицинский:       +20% действий, саморемонт x3, ускоренный ремонт интервал
//   Инженерный:        +20% действий, -50% стоимость ремонта, лучше бронирование от брута
//   Охранный:          +20% действий, оружие разрешено, emp_vulnerability снижена, лучшая защита от брута
//   Исследовательский: +20% действий, выше порог оптимальной температуры, повышенный крит-порог нагрева

#define IPC_GEN1_TRAIT_SOURCE  "ipc_gen1"
#define TRAIT_MEDICAL_ACES     "ipc_medical_aces"
#define TRAIT_ENGINEERING_ACES "ipc_engineering_aces"
#define TRAIT_SCIENCE_ACES     "ipc_science_aces"

/// Длительность переконфигурации модуля (в тиках world.time)
#define MODULE_SWITCH_DURATION (150 SECONDS)

/datum/movespeed_modifier/ipc_gen1_slow
	id = "ipc_gen1_slow"
	multiplicative_slowdown = 0.35  // +35% времени на тайл = медленнее

/datum/actionspeed_modifier/ipc_gen1_wrong_module
	id = "ipc_gen1_wrong_module"
	variable = FALSE
	multiplicative_slowdown = 0.4  // -40% во время переконфигурации

/datum/actionspeed_modifier/ipc_gen1_module_bonus
	id = "ipc_gen1_module_bonus"
	variable = FALSE
	multiplicative_slowdown = -0.2  // +20% скорости действий

// ============================================
// ПРИМЕНЕНИЕ / СНЯТИЕ
// ============================================

/datum/species/ipc/proc/apply_gen1_modular(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)
	H.add_movespeed_modifier(/datum/movespeed_modifier/ipc_gen1_slow)

	// Блокируем Перегрузку — у Gen I нет разгона
	var/datum/action/cooldown/ipc_overclock/overclock = locate() in H.actions
	if(overclock)
		overclock.Remove(H)

	// Базовая стоимость ремонта — перки модуля изменяют дополнительно
	ipc_repair_cost_mod = 0.7

	apply_gen1_module_effects(H)
	gen1_update_weapon_block(H)

	// Выдаём кнопку смены модуля
	var/datum/action/innate/ipc_module_swap/swap_action = new()
	swap_action.ipc_species = src
	swap_action.Grant(H)

/datum/species/ipc/proc/remove_gen1_modular(mob/living/carbon/human/H)
	// Отменяем переконфигурацию если шла
	if(module_switch_target)
		module_switch_target = ""

	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)
	ipc_repair_cost_mod = 1.0

	// Возвращаем базовые температурные параметры
	cpu_temp_optimal_max = 40
	cpu_temp_critical = 130
	brute_mod = 0.8
	emp_vulnerability = 2
	self_repair_amount = 0.5
	self_repair_delay = 100

	H.remove_movespeed_modifier(/datum/movespeed_modifier/ipc_gen1_slow)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_wrong_module)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
	REMOVE_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)
	UnregisterSignal(H, COMSIG_MOB_ATTACK_HAND)

	var/datum/action/innate/ipc_module_swap/swap_action = locate() in H.actions
	if(swap_action)
		swap_action.Remove(H)

// ============================================
// ПЕРКИ МОДУЛЕЙ
// ============================================

/datum/species/ipc/proc/apply_gen1_module_effects(mob/living/carbon/human/H)
	// Убираем старые модификаторы и трейты
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_wrong_module)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
	REMOVE_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)

	// Возвращаем базовые значения перед применением нового модуля
	brute_mod = 0.8
	emp_vulnerability = 2
	cpu_temp_optimal_max = 40
	cpu_temp_critical = 130
	self_repair_amount = 0.5
	self_repair_delay = 100
	ipc_repair_cost_mod = 0.7

	switch(ipc_gen1_module)
		if(IPC_MODULE_MEDICAL)
			// Медицинский: максимальная скорость саморемонта
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			ADD_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)
			self_repair_amount = 1.5   // 3x от базового (0.5)
			self_repair_delay = 50     // Чинится вдвое быстрее

		if(IPC_MODULE_ENGINEERING)
			// Инженерный: дешевле ремонт, лучше переносит физический урон
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			ADD_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)
			ipc_repair_cost_mod = 0.4  // На 60% дешевле чинить
			brute_mod = 0.65           // Упрочнённый корпус

		if(IPC_MODULE_SECURITY)
			// Охранный: оружие + военное укрепление
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			brute_mod = 0.6            // Бронированный корпус
			emp_vulnerability = 1.5    // Военная защита от ЭМИ

		if(IPC_MODULE_RESEARCH)
			// Исследовательский: термостойкость + ЭМИ-защита
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			ADD_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)
			cpu_temp_optimal_max = 60  // Работает эффективно до 60°C вместо 40°C
			cpu_temp_critical = 160    // Критический перегрев позже
			emp_vulnerability = 1.5    // Экранированная лабораторная электроника

	gen1_update_weapon_block(H)

/// Обновляет регистрацию блока оружия по текущему модулю.
/datum/species/ipc/proc/gen1_update_weapon_block(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_MOB_ATTACK_HAND)
	if(ipc_gen1_module != IPC_MODULE_SECURITY)
		RegisterSignal(H, COMSIG_MOB_ATTACK_HAND, PROC_REF(gen1_block_weapon_attack))

// ============================================
// ТИКОВАЯ ЛОГИКА GEN 1
// ============================================

/datum/species/ipc/proc/handle_gen1_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(!module_switch_target)
		return

	// Отменяем переконфигурацию если персонаж оглушён или мёртв
	if(H.stat == DEAD || H.IsStunned())
		cancel_module_switch(H)
		return

	var/elapsed = world.time - module_switch_start_time
	var/remaining_sec = round((MODULE_SWITCH_DURATION - elapsed) / 10)

	// Сообщения на ключевых отметках (показываем один раз за порог)
	for(var/threshold in list(120, 90, 60, 30, 10))
		if(remaining_sec <= threshold && module_switch_last_threshold > threshold)
			module_switch_last_threshold = threshold
			to_chat(H, span_notice("МОДУЛЬ: Переконфигурация... [remaining_sec] сек до завершения."))
			break

	// Завершение
	if(elapsed >= MODULE_SWITCH_DURATION)
		complete_module_switch(H)

/// Начинает процесс переключения модуля.
/datum/species/ipc/proc/start_module_switch(mob/living/carbon/human/H, new_module)
	module_switch_target = new_module
	module_switch_start_time = world.time
	module_switch_last_threshold = 999

	// Сбрасываем текущие перки модуля, оставляем только базовые Gen 1
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_wrong_module)
	REMOVE_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)
	// Сброс статов до базового значения
	brute_mod = 0.8
	emp_vulnerability = 2
	cpu_temp_optimal_max = 40
	cpu_temp_critical = 130
	self_repair_amount = 0.5
	self_repair_delay = 100
	ipc_repair_cost_mod = 0.7
	// Штраф скорости действий во время переконфигурации
	H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_wrong_module)
	// Снимаем блок оружия пока идёт переконфигурация (нет активного модуля)
	UnregisterSignal(H, COMSIG_MOB_ATTACK_HAND)

/// Завершает переконфигурацию.
/datum/species/ipc/proc/complete_module_switch(mob/living/carbon/human/H)
	var/new_module = module_switch_target
	module_switch_target = ""

	ipc_gen1_module = new_module
	apply_gen1_module_effects(H)

	var/new_name
	switch(new_module)
		if(IPC_MODULE_MEDICAL)
			new_name = "Медицинский"
		if(IPC_MODULE_ENGINEERING)
			new_name = "Инженерный"
		if(IPC_MODULE_SECURITY)
			new_name = "Охранный"
		if(IPC_MODULE_RESEARCH)
			new_name = "Исследовательский"

	to_chat(H, span_notice("МОДУЛЬ: Переконфигурация завершена. Активирован модуль: [new_name]."))
	playsound(H, 'sound/machines/terminal/terminal_alert.ogg', 50, FALSE)

/// Отменяет переконфигурацию (стан, смерть).
/datum/species/ipc/proc/cancel_module_switch(mob/living/carbon/human/H)
	if(!module_switch_target)
		return
	module_switch_target = ""
	// Возвращаем перки текущего модуля (ipc_gen1_module не менялся во время переконфигурации)
	apply_gen1_module_effects(H)
	to_chat(H, span_warning("МОДУЛЬ: Переконфигурация прервана! Восстановлен предыдущий модуль."))
	playsound(H, 'sound/machines/buzz/buzz-two.ogg', 40, FALSE)

// ============================================
// ДЕЙСТВИЕ: СМЕНА МОДУЛЯ
// ============================================

/datum/action/innate/ipc_module_swap
	name = "Сменить модуль"
	desc = "Начать переконфигурацию профессионального модуля. Занимает 2.5 минуты. Прерывается при оглушении."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_module_swap"
	var/datum/species/ipc/ipc_species = null

/datum/action/innate/ipc_module_swap/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !ipc_species)
		return

	// Уже идёт переконфигурация?
	if(ipc_species.module_switch_target)
		var/elapsed = world.time - ipc_species.module_switch_start_time
		var/remaining = round((MODULE_SWITCH_DURATION - elapsed) / 10)
		H.balloon_alert(H, "переконфигурация идёт ([remaining] сек)")
		return

	var/current_name
	switch(ipc_species.ipc_gen1_module)
		if(IPC_MODULE_MEDICAL)
			current_name = "Медицинский"
		if(IPC_MODULE_ENGINEERING)
			current_name = "Инженерный"
		if(IPC_MODULE_SECURITY)
			current_name = "Охранный"
		if(IPC_MODULE_RESEARCH)
			current_name = "Исследовательский"

	var/list/choices = list(
		"Медицинский — саморемонт x3, ускоренное лечение"                   = IPC_MODULE_MEDICAL,
		"Инженерный — ремонт -60% дешевле, укреплённый корпус"              = IPC_MODULE_ENGINEERING,
		"Охранный — оружие разрешено, броня, защита от ЭМИ"                 = IPC_MODULE_SECURITY,
		"Исследовательский — выше порог тепла, ЭМИ-экран, науч. работы"     = IPC_MODULE_RESEARCH,
	)

	var/choice_name = input(H,
		"Текущий модуль: [current_name]\n\nПереконфигурация займёт 2.5 минуты.\nВо время процесса скорость действий снижена.\nПрерывается при оглушении.\n\nВыберите новый модуль:",
		"Смена модуля", null
	) as null|anything in choices

	if(isnull(choice_name) || QDELETED(H) || !ipc_species)
		return
	if(ipc_species.module_switch_target)
		return  // Пока выбирал — другой процесс начался

	var/new_module = choices[choice_name]
	if(new_module == ipc_species.ipc_gen1_module)
		H.balloon_alert(H, "модуль уже установлен")
		return

	ipc_species.start_module_switch(H, new_module)

	to_chat(H, span_notice("МОДУЛЬ: Начата переконфигурация → [choice_name]. Время: 150 сек."))
	to_chat(H, span_warning("Предупреждение: оглушение прервёт процесс!"))
	playsound(H, 'sound/machines/terminal/terminal_alert.ogg', 40, FALSE)

/datum/action/innate/ipc_module_swap/Remove(mob/M)
	. = ..()
	ipc_species = null

// ============================================
// БЛОК ОРУЖИЯ (вне охранного модуля)
// ============================================

/// Перехватываем атаку. Если в руке оружие — блокируем.
/datum/species/ipc/proc/gen1_block_weapon_attack(mob/living/carbon/human/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	var/obj/item/held = source.get_active_held_item()
	if(!held)
		return
	if(held.force > 0)
		source.balloon_alert(source, "охранный модуль не установлен!")
		playsound(source, 'sound/machines/buzz/buzz-two.ogg', 30, FALSE)
		return COMPONENT_CANCEL_ATTACK_CHAIN

// ============================================
// ЭМИ: ОГЛУШЕНИЕ ДЛЯ ПОКОЛЕНИЯ I
// ============================================

/// Вызывается из handle_emp. Поколение I: ЭМИ снимает иммунитет к стану и оглушает.
/datum/species/ipc/proc/gen1_handle_emp(mob/living/carbon/human/H, severity)
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)

	var/stun_duration
	switch(severity)
		if(EMP_HEAVY)
			stun_duration = rand(8, 12) SECONDS
			to_chat(H, span_userdanger("КРИТИЧЕСКИЙ ЭМИ: Модульная шина нарушена! Оглушение систем!"))
		if(EMP_LIGHT)
			stun_duration = rand(4, 7) SECONDS
			to_chat(H, span_danger("ЭМИ: Модульная шина нестабильна!"))
		else
			stun_duration = 5 SECONDS

	H.Stun(stun_duration)
	addtimer(CALLBACK(src, PROC_REF(gen1_restore_stun_immunity), H), stun_duration + 1 SECONDS)

/datum/species/ipc/proc/gen1_restore_stun_immunity(mob/living/carbon/human/H)
	if(!H || !istype(H.dna?.species, /datum/species/ipc))
		return
	if(ipc_generation != IPC_GEN_MODULAR)
		return
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)
	to_chat(H, span_notice("СИСТЕМА: Модульная шина стабилизирована. Иммунитет к оглушению восстановлен."))
