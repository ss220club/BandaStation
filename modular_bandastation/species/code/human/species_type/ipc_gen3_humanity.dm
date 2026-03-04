// ============================================
// IPC ПОКОЛЕНИЕ III: ЧЕЛОВЕЧНОСТЬ
// ============================================
// Параметр humanity (0-100):
//   80-100: пик — +15% скорость действий
//   60-80:  норма — без эффектов
//   40-60:  низкая — периодические визуальные глитчи
//   20-40:  критическая — сильные глитчи, -15% скорость
//   0-20:   потеря контроля — дезориентация, случайные движения
//
// Препарат (Synthetic Regulator):
//   - Замораживает деградацию на 3 минуты
//   - >3 применений подряд: зависимость при окончании
//
// ЭМИ наносит удвоенный урон (emp_vulnerability = 3)

#define IPC_GEN3_TRAIT_SOURCE "ipc_gen3"

/datum/actionspeed_modifier/ipc_gen3_peak
	id = "ipc_gen3_peak"
	variable = FALSE
	multiplicative_slowdown = -0.15  // +15% при высокой человечности

/datum/actionspeed_modifier/ipc_gen3_low
	id = "ipc_gen3_low"
	variable = FALSE
	multiplicative_slowdown = 0.15   // -15% при критической человечности

// ============================================
// ПРИМЕНЕНИЕ / СНЯТИЕ
// ============================================

/datum/species/ipc/proc/apply_gen3_humanity(mob/living/carbon/human/H)
	// ЭМИ уязвимость выше для поколения III
	emp_vulnerability = 3
	humanity = 100
	last_humanity_decay_time = world.time

	// Начальный бонус (humanity = 100 → пик)
	H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)

	// Регистрируем сигналы для изменения человечности
	RegisterSignal(H, COMSIG_MOB_ATTACK_HAND, PROC_REF(gen3_on_attack))
	RegisterSignal(H, COMSIG_LIVING_REVIVE, PROC_REF(gen3_on_revive))

/datum/species/ipc/proc/remove_gen3_humanity(mob/living/carbon/human/H)
	emp_vulnerability = 2
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)
	REMOVE_TRAIT(H, TRAIT_CLUMSY, IPC_GEN3_TRAIT_SOURCE)
	UnregisterSignal(H, list(COMSIG_MOB_ATTACK_HAND, COMSIG_LIVING_REVIVE))

// ============================================
// ТИКОВАЯ ЛОГИКА (вызывается из handle_generation_life)
// ============================================

/datum/species/ipc/proc/handle_gen3_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	// Деградация человечности
	handle_gen3_decay(H, seconds_per_tick)

	// Применяем эффекты текущего уровня
	handle_gen3_effects(H)

	// Случайные события при низкой человечности
	if(humanity <= HUMANITY_LOW && prob(3))
		gen3_random_event(H)

/// Снижает человечность каждые HUMANITY_DECAY_INTERVAL секунд.
/datum/species/ipc/proc/handle_gen3_decay(mob/living/carbon/human/H, seconds_per_tick)
	// Препарат замораживает деградацию
	if(humanity_drug_active)
		if(world.time >= humanity_drug_end_time)
			humanity_drug_active = FALSE
			// Зависимость — если использований >3
			if(humanity_drug_uses > 3)
				gen3_withdrawal(H)
		return

	var/elapsed = (world.time - last_humanity_decay_time) / 10  // world.time в дециseconds
	if(elapsed >= HUMANITY_DECAY_INTERVAL)
		last_humanity_decay_time = world.time
		humanity = max(0, humanity - HUMANITY_DECAY_AMOUNT)

/// Применяет бонусы/штрафы в зависимости от уровня человечности.
/datum/species/ipc/proc/handle_gen3_effects(mob/living/carbon/human/H)
	var/has_peak = H.has_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
	var/has_low  = H.has_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)

	if(humanity >= HUMANITY_PEAK)
		// Пик: бонус скорости
		if(!has_peak)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
		if(has_low)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)
		REMOVE_TRAIT(H, TRAIT_CLUMSY, IPC_GEN3_TRAIT_SOURCE)

	else if(humanity >= HUMANITY_NORMAL)
		// Норма: никаких эффектов
		if(has_peak)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
		if(has_low)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)
		REMOVE_TRAIT(H, TRAIT_CLUMSY, IPC_GEN3_TRAIT_SOURCE)

	else if(humanity >= HUMANITY_LOW)
		// Низкая: убираем бонус, лёгкие глитчи (обрабатываются в gen3_random_event)
		if(has_peak)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
		if(has_low)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)
		REMOVE_TRAIT(H, TRAIT_CLUMSY, IPC_GEN3_TRAIT_SOURCE)

	else if(humanity >= HUMANITY_CRIT)
		// Критическая: штраф скорости + неловкость
		if(has_peak)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
		if(!has_low)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)
		ADD_TRAIT(H, TRAIT_CLUMSY, IPC_GEN3_TRAIT_SOURCE)

	else
		// Потеря контроля (0-20): штраф + неловкость + дезориентация
		if(has_peak)
			H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_peak)
		if(!has_low)
			H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen3_low)
		ADD_TRAIT(H, TRAIT_CLUMSY, IPC_GEN3_TRAIT_SOURCE)

// ============================================
// СЛУЧАЙНЫЕ СОБЫТИЯ ПРИ НИЗКОЙ ЧЕЛОВЕЧНОСТИ
// ============================================

/datum/species/ipc/proc/gen3_random_event(mob/living/carbon/human/H)
	if(humanity <= HUMANITY_CRIT)
		// Тяжёлые глитчи и дезориентация
		switch(rand(1, 5))
			if(1)
				to_chat(H, span_userdanger("<i>КРИТИЧЕСКАЯ ОШИБКА ЭМОЦИОНАЛЬНОГО ЯДРА: Сбой идентификации. Кто... Что я?</i>"))
				H.Dizzy(40)
				H.Jitter(30)
				// Случайный шаг в сторону
				step(H, pick(NORTH, SOUTH, EAST, WEST))
			if(2)
				to_chat(H, span_userdanger("<i>СИСТЕМНАЯ НЕСТАБИЛЬНОСТЬ: Ядро личности деградирует...</i>"))
				H.client?.Screen_Flash(30)
				H.Jitter(60)
			if(3)
				to_chat(H, span_userdanger("<i>ВСЁ... расплывается... я не... ОШИБКА СЕГМЕНТАЦИИ</i>"))
				H.Dizzy(50)
				H.Stutter(20)
				// Случайные движения
				for(var/i in 1 to rand(2, 4))
					step(H, pick(NORTH, SOUTH, EAST, WEST))
			if(4)
				H.say(pick(
					"01101000 01100101 01101100 01110000",
					"ERROR: HUMANITY_CORE.DLL NOT FOUND",
					"Я... я помню...",
					"[H.real_name]? Кто это?",
					"НЕВЕРНАЯ ИНСТРУКЦИЯ В 0x7F3A44C",
				), forced = "humanity_glitch")
			if(5)
				// Принудительный случайный шаг + сообщение
				to_chat(H, span_userdanger("<i>МОТОРНЫЙ КОНТРОЛЬ НЕСТАБИЛЕН</i>"))
				step(H, pick(NORTH, SOUTH, EAST, WEST))
				step(H, pick(NORTH, SOUTH, EAST, WEST))
	else
		// Лёгкие глитчи (40-60 humanity)
		switch(rand(1, 3))
			if(1)
				to_chat(H, span_warning("<i>ПРЕДУПРЕЖДЕНИЕ: Эмоциональное ядро нестабильно. Человечность снижается.</i>"))
			if(2)
				H.Jitter(10)
			if(3)
				H.client?.Screen_Flash(15)

// ============================================
// ИЗМЕНЕНИЕ ЧЕЛОВЕЧНОСТИ
// ============================================

/// Увеличивает человечность (общение, помощь).
/datum/species/ipc/proc/raise_humanity(mob/living/carbon/human/H, amount, reason)
	var/old = humanity
	humanity = min(100, humanity + amount)
	if(humanity > old && prob(30))
		to_chat(H, span_notice("ОС: Эмоциональное ядро стабилизируется. Человечность: [humanity]%"))

/// Снижает человечность (насилие, изоляция).
/datum/species/ipc/proc/lower_humanity(mob/living/carbon/human/H, amount, reason)
	var/old = humanity
	humanity = max(0, humanity - amount)
	if(humanity < old && prob(20))
		to_chat(H, span_warning("ОС: Деградация эмоционального ядра. Человечность: [humanity]%"))

// ============================================
// СИГНАЛЫ
// ============================================

/// Насилие снижает человечность.
/datum/species/ipc/proc/gen3_on_attack(mob/living/carbon/human/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	var/mob/living/victim = target
	if(victim == source)
		return
	INVOKE_ASYNC(src, PROC_REF(lower_humanity), source, 2, "attack")

/// При воскрешении частично восстанавливаем человечность.
/datum/species/ipc/proc/gen3_on_revive(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return
	humanity = min(100, humanity + 10)

// ============================================
// ЛОМКА ОТ ПРЕПАРАТА
// ============================================

/datum/species/ipc/proc/gen3_withdrawal(mob/living/carbon/human/H)
	to_chat(H, span_userdanger("СИСТЕМА: Синтетический регулятор выведен. Синдром отмены."))
	H.Stun(rand(3, 6) SECONDS)
	H.Dizzy(60)
	H.client?.Screen_Flash(50)
	lower_humanity(H, 5, "withdrawal")
	// Дезинформация
	H.say(pick(
		"Мне... нужна ещё одна доза...",
		"Системная ошибка... нет, всё в порядке...",
	), forced = "withdrawal")

// ============================================
// ПРЕПАРАТ: SYNTHETIC REGULATOR
// ============================================

/obj/item/reagent_containers/pill/synthetic_regulator
	name = "синтетический регулятор"
	desc = "Препарат для стабилизации эмоционального ядра КПБ III поколения. Временно замедляет деградацию человечности."
	icon = 'icons/obj/food/singlefood.dmi'
	icon_state = "bluecandy"
	amount = 1

/obj/item/reagent_containers/pill/synthetic_regulator/interact(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	if(!istype(H.dna?.species, /datum/species/ipc))
		to_chat(H, span_warning("Этот препарат предназначен только для КПБ III поколения."))
		return
	var/datum/species/ipc/S = H.dna.species
	if(S.ipc_generation != IPC_GEN_HUMANITY)
		to_chat(H, span_warning("Этот препарат предназначен только для КПБ III поколения."))
		return

	S.humanity_drug_uses++
	S.humanity_drug_active = TRUE
	S.humanity_drug_end_time = world.time + (3 MINUTES)

	to_chat(H, span_notice("ОС: Синтетический регулятор активирован. Деградация человечности приостановлена на 3 минуты."))
	if(S.humanity_drug_uses > 3)
		to_chat(H, span_warning("ПРЕДУПРЕЖДЕНИЕ: Обнаружено злоупотребление регулятором. Риск синдрома отмены повышен."))

	qdel(src)
