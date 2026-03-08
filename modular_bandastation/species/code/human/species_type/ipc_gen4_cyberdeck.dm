// ============================================
// IPC ПОКОЛЕНИЕ IV: КИБЕРДЕКА
// ============================================
// Пассивно расширяет радиус взаимодействия с дверьми (при наличии доступа)
// и консолями до CYBERDECK_SCAN_RANGE клеток.
// Если объект дальше 1 клетки — использование добавляет температуру CPU.
//
// + Увеличенный радиус взаимодействия (reach_length = CYBERDECK_SCAN_RANGE)
// + Сниженный урон от ЭМИ (emp_vulnerability = 1)
// + +20% эффективности действий
// - Удалённое использование дверей/консолей поднимает температуру CPU
// - Требует больше ресурсов (ipc_repair_cost_mod = 1.5)
// - ЭМИ временно отключает кибердеку (сбрасывает радиус)

#define IPC_GEN4_TRAIT_SOURCE "ipc_gen4"

/datum/actionspeed_modifier/ipc_gen4_bonus
	id = "ipc_gen4_bonus"
	variable = FALSE
	multiplicative_slowdown = -0.2  // +20% эффективности

// ============================================
// ПРИМЕНЕНИЕ / СНЯТИЕ
// ============================================

/datum/species/ipc/proc/apply_gen4_cyberdeck(mob/living/carbon/human/H)
	// Сниженный ЭМИ урон
	emp_vulnerability = 1
	// Повышенная стоимость ремонта
	ipc_repair_cost_mod = 1.5
	// Сброс состояния
	cyberdeck_disabled = FALSE
	cyberdeck_reenable_time = 0

	// Бонус к скорости действий +20%
	H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen4_bonus)

	// Расширяем радиус взаимодействия
	H.reach_length = CYBERDECK_SCAN_RANGE

	// Хук для добавления тепла CPU при удалённом использовании
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_cyberdeck_clickon))

/datum/species/ipc/proc/remove_gen4_cyberdeck(mob/living/carbon/human/H)
	emp_vulnerability = 2
	ipc_repair_cost_mod = 1.0
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen4_bonus)

	// Сброс радиуса взаимодействия
	H.reach_length = initial(H.reach_length)

	UnregisterSignal(H, COMSIG_MOB_CLICKON)

// ============================================
// ТИКОВАЯ ЛОГИКА
// ============================================

/datum/species/ipc/proc/handle_gen4_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	// Повторно включаем кибердеку после ЭМИ
	if(cyberdeck_disabled && world.time >= cyberdeck_reenable_time)
		cyberdeck_disabled = FALSE
		H.reach_length = CYBERDECK_SCAN_RANGE
		to_chat(H, span_notice("КИБЕРДЕКА: Системы перезагружены. Дистанционный доступ активирован."))

// ============================================
// СИГНАЛ: НАГРЕВ ПРИ УДАЛЁННОМ ИСПОЛЬЗОВАНИИ
// ============================================

/// Срабатывает при каждом клике по объекту.
/// Если КПБ кликает по двери/консоли дальше 1 клетки — добавляем тепло CPU.
/datum/species/ipc/proc/on_cyberdeck_clickon(datum/source, atom/A, list/modifiers)
	SIGNAL_HANDLER
	if(cyberdeck_disabled)
		return
	// Интересуют только двери и консоли
	if(!istype(A, /obj/machinery/door/airlock) && !istype(A, /obj/machinery/computer))
		return
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return
	// Только если дальше 1 клетки (иначе это обычное взаимодействие, без нагрева)
	if(get_dist(H, A) <= 1)
		return
	// Нагрев CPU
	var/heat_cost = istype(A, /obj/machinery/door/airlock) ? CYBERDECK_CPU_HEAT_DOOR : CYBERDECK_CPU_HEAT_CONSOLE
	cpu_temperature = min(cpu_temp_critical, cpu_temperature + heat_cost)
	playsound(H, 'sound/machines/terminal/terminal_alert.ogg', 25, FALSE)

// ============================================
// TGUI: УДАЛЁННЫЙ ДОСТУП К КОНСОЛЯМ
// ============================================
// reach_length расширяет физические клики (двери), но TGUI консолей
// использует shared_living_ui_distance с хардкодным dist <= 1.
// Переопределяем для IPC Gen 4 чтобы консоли тоже работали с расстояния.

/mob/living/carbon/human/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE, allow_tk = TRUE)
	if(istype(src_object, /obj/machinery/computer) && istype(dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = dna.species
		if(S.ipc_generation == IPC_GEN_CYBERDECK && !S.cyberdeck_disabled)
			var/dist = get_dist(src_object, src)
			if(dist <= CYBERDECK_SCAN_RANGE && (src_object in view(src)))
				return UI_INTERACTIVE
	return ..()

// ============================================
// ЭМИ: ОТКЛЮЧЕНИЕ КИБЕРДЕКИ
// ============================================

/datum/species/ipc/proc/gen4_emp_disable_cyberdeck(mob/living/carbon/human/H, severity)
	var/disable_duration
	switch(severity)
		if(EMP_HEAVY)
			disable_duration = rand(30, 60) SECONDS
			to_chat(H, span_userdanger("ЭМИ: Кибердека отключена! Дистанционный доступ заблокирован. Перезагрузка через [round(disable_duration/10)] сек."))
		if(EMP_LIGHT)
			disable_duration = rand(10, 25) SECONDS
			to_chat(H, span_danger("ЭМИ: Кибердека временно отключена. Дистанционный доступ недоступен."))
		else
			disable_duration = 15 SECONDS

	cyberdeck_disabled = TRUE
	cyberdeck_reenable_time = world.time + disable_duration

	// ЭМИ сбрасывает радиус взаимодействия
	H.reach_length = initial(H.reach_length)
	// ЭМИ нагревает CPU
	cpu_temperature = min(cpu_temp_critical, cpu_temperature + 20)
