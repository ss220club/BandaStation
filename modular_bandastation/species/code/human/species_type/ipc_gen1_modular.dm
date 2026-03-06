// ============================================
// IPC ПОКОЛЕНИЕ I: МОДУЛЬНОЕ
// ============================================
// + Иммунитет к оглушению
// + Меньше ресурсов на ремонт (ipc_repair_cost_mod)
// + Бонус профессии при правильном модуле
// - Без правильного модуля: -40% эффективности действий
// - Не может использовать оружие вне охранного модуля
// - Низкая скорость передвижения
// - ЭМИ оглушает 5-10 сек (вместо штатного эффекта)
// - Не может использовать Перегрузку

#define IPC_GEN1_TRAIT_SOURCE "ipc_gen1"
#define TRAIT_MEDICAL_ACES    "ipc_medical_aces"
#define TRAIT_ENGINEERING_ACES "ipc_engineering_aces"
#define TRAIT_SCIENCE_ACES    "ipc_science_aces"

/datum/movespeed_modifier/ipc_gen1_slow
	id = "ipc_gen1_slow"
	multiplicative_slowdown = 0.35  // +35% времени на тайл = медленнее

/datum/actionspeed_modifier/ipc_gen1_wrong_module
	id = "ipc_gen1_wrong_module"
	variable = FALSE
	multiplicative_slowdown = 0.4  // -40% скорости действий

/datum/actionspeed_modifier/ipc_gen1_module_bonus
	id = "ipc_gen1_module_bonus"
	variable = FALSE
	multiplicative_slowdown = -0.2  // +20% скорости действий при правильном модуле

// ============================================
// ПРИМЕНЕНИЕ / СНЯТИЕ
// ============================================

/datum/species/ipc/proc/apply_gen1_modular(mob/living/carbon/human/H)
	// Иммунитет к оглушению
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)

	// Сниженная стоимость ремонта
	ipc_repair_cost_mod = 0.7

	// Медленный ход
	H.add_movespeed_modifier(/datum/movespeed_modifier/ipc_gen1_slow)

	// Блокируем Перегрузку
	var/datum/action/cooldown/ipc_overclock/overclock = locate() in H.actions
	if(overclock)
		overclock.Remove(H)

	// Применяем модульные бонусы
	apply_gen1_module_effects(H)

	// Регистрируем перехват атаки оружием (блок вне охранного модуля)
	gen1_update_weapon_block(H)

	// Выдаём кнопку смены модуля
	var/datum/action/innate/ipc_module_swap/swap_action = new()
	swap_action.ipc_species = src
	swap_action.Grant(H)

/datum/species/ipc/proc/remove_gen1_modular(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)
	ipc_repair_cost_mod = 1.0
	H.remove_movespeed_modifier(/datum/movespeed_modifier/ipc_gen1_slow)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_wrong_module)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
	// Трейты профессиональных модулей
	REMOVE_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)
	UnregisterSignal(H, COMSIG_MOB_ATTACK_HAND)
	// Убираем кнопку смены модуля
	var/datum/action/innate/ipc_module_swap/swap_action = locate() in H.actions
	if(swap_action)
		swap_action.Remove(H)

// ============================================
// МОДУЛЬНЫЕ БОНУСЫ/ШТРАФЫ
// ============================================

/datum/species/ipc/proc/apply_gen1_module_effects(mob/living/carbon/human/H)
	// Убираем старые модификаторы и трейты
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_wrong_module)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
	REMOVE_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)
	REMOVE_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)

	switch(ipc_gen1_module)
		if(IPC_MODULE_MEDICAL)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			ADD_TRAIT(H, TRAIT_MEDICAL_ACES, IPC_GEN1_TRAIT_SOURCE)

		if(IPC_MODULE_ENGINEERING)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			ADD_TRAIT(H, TRAIT_ENGINEERING_ACES, IPC_GEN1_TRAIT_SOURCE)

		if(IPC_MODULE_SECURITY)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)

		if(IPC_MODULE_RESEARCH)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen1_module_bonus)
			ADD_TRAIT(H, TRAIT_SCIENCE_ACES, IPC_GEN1_TRAIT_SOURCE)

	// Обновляем блок оружия (зависит от текущего модуля)
	gen1_update_weapon_block(H)

/// Обновляет регистрацию блока оружия по текущему модулю.
/datum/species/ipc/proc/gen1_update_weapon_block(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_MOB_ATTACK_HAND)
	if(ipc_gen1_module != IPC_MODULE_SECURITY)
		RegisterSignal(H, COMSIG_MOB_ATTACK_HAND, PROC_REF(gen1_block_weapon_attack))

// ============================================
// ДЕЙСТВИЕ: СМЕНА МОДУЛЯ
// ============================================

/datum/action/innate/ipc_module_swap
	name = "Сменить модуль"
	desc = "Переключиться на другой профессиональный модуль. Текущий бонус будет сброшен."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_module_swap"
	/// Ссылка на вид КПБ
	var/datum/species/ipc/ipc_species = null

/datum/action/innate/ipc_module_swap/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !ipc_species)
		return

	// Описание текущего модуля
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
		"Медицинский (+20% скорости, разрешены мед. процедуры)" = IPC_MODULE_MEDICAL,
		"Инженерный (+20% скорости, разрешены инж. работы)"    = IPC_MODULE_ENGINEERING,
		"Охранный (+20% скорости, разрешено оружие)"           = IPC_MODULE_SECURITY,
		"Исследовательский (+20% скорости, разрешены научные работы)" = IPC_MODULE_RESEARCH,
	)

	var/choice_name = input(H, "Текущий модуль: [current_name]\nВыберите новый профессиональный модуль:", "Смена модуля", null) as null|anything in choices
	if(isnull(choice_name) || QDELETED(H) || !ipc_species)
		return

	var/new_module = choices[choice_name]
	if(new_module == ipc_species.ipc_gen1_module)
		H.balloon_alert(H, "модуль уже установлен")
		return

	ipc_species.ipc_gen1_module = new_module
	ipc_species.apply_gen1_module_effects(H)

	var/new_name = choice_name
	to_chat(H, span_notice("МОДУЛЬ: Переключение завершено — [new_name]"))
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
	// Блокируем только если это оружие (имеет force > 0)
	if(held.force > 0)
		source.balloon_alert(source, "охранный модуль не установлен!")
		playsound(source, 'sound/machines/buzz/buzz-two.ogg', 30, FALSE)
		return COMPONENT_CANCEL_ATTACK_CHAIN

// ============================================
// ЭМИ: ОГЛУШЕНИЕ ДЛЯ ПОКОЛЕНИЯ I
// ============================================

/// Вызывается из handle_emp. Поколение I: ЭМИ снимает иммунитет к стану и оглушает.
/datum/species/ipc/proc/gen1_handle_emp(mob/living/carbon/human/H, severity)
	// Временно снимаем иммунитет к оглушению
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

	// Восстанавливаем иммунитет через время
	addtimer(CALLBACK(src, PROC_REF(gen1_restore_stun_immunity), H), stun_duration + 1 SECONDS)

/datum/species/ipc/proc/gen1_restore_stun_immunity(mob/living/carbon/human/H)
	if(!H || !istype(H.dna?.species, /datum/species/ipc))
		return
	if(ipc_generation != IPC_GEN_MODULAR)
		return
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, IPC_GEN1_TRAIT_SOURCE)
	to_chat(H, span_notice("СИСТЕМА: Модульная шина стабилизирована. Иммунитет к оглушению восстановлен."))
