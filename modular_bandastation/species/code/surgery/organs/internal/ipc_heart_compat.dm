// ============================================
// IPC: СОВМЕСТИМОСТЬ СО СТОРОННИМИ СЕРДЦАМИ
// ============================================
// Позволяет устанавливать кибернетические сердца и Сердце Свободы
// в КПБ вместо стандартной батареи.
//
// Характеристики по типам:
//   Tier 1 (base cybernetic):  ёмкость 2500, разряд x1.5  — хуже батарейки
//   Tier 2 (cybernetic):       ёмкость 5000, разряд x1.0  — равно батарейке
//   Tier 3 (upgraded):         ёмкость 8000, разряд x0.8  — лучше батарейки
//   Heart of Freedom:          ёмкость 8000, разряд x0.8  — как tier 3 + адреналин
//   Anomalock + flux core:     ёмкость 5000, разряд x1.0  — самозарядка +1.5/сек
//   Surplus:                   несовместимо (ipc_max_charge = 0)
// ============================================

// ============================================
// БАЗОВЫЙ ИНТЕРФЕЙС — добавляем к /obj/item/organ/heart
// ============================================

/obj/item/organ/heart
	/// Максимальный заряд при использовании как ИП КПБ. 0 = несовместимо.
	var/ipc_max_charge = 0
	/// Множитель скорости разряда (единиц в секунду)
	var/ipc_charge_rate_mod = 1.0
	/// Эффективность зарядки от кабеля/АРС
	var/ipc_charge_efficiency = 1.0

/// Возвращает текущий заряд КПБ.
/obj/item/organ/heart/proc/get_ipc_charge()
	return 0

/// Устанавливает текущий заряд КПБ.
/obj/item/organ/heart/proc/set_ipc_charge(val)
	return

/// Зарядка от внешнего источника (кабель / АРС).
/obj/item/organ/heart/proc/ipc_charge_from(amount)
	return

/// Возвращает флаг «сейчас заряжается через кабель».
/obj/item/organ/heart/proc/get_ipc_charging()
	return FALSE

/// Устанавливает флаг зарядки через кабель.
/obj/item/organ/heart/proc/set_ipc_charging(val)
	return

// ============================================
// IPC BATTERY — реализуем интерфейс поверх существующих vars
// ============================================

/obj/item/organ/heart/ipc_battery
	ipc_max_charge = 5000
	ipc_charge_rate_mod = 1.0
	ipc_charge_efficiency = 1.0

/obj/item/organ/heart/ipc_battery/get_ipc_charge()
	return charge

/obj/item/organ/heart/ipc_battery/set_ipc_charge(val)
	charge = val

/obj/item/organ/heart/ipc_battery/ipc_charge_from(amount)
	charge_from_apc(amount)

/obj/item/organ/heart/ipc_battery/get_ipc_charging()
	return charging

/obj/item/organ/heart/ipc_battery/set_ipc_charging(val)
	charging = val

// ============================================
// КИБЕРНЕТИЧЕСКИЕ СЕРДЦА — stats + интерфейс
// ============================================

/obj/item/organ/heart/cybernetic
	ipc_max_charge = 2500
	ipc_charge_rate_mod = 1.5
	ipc_charge_efficiency = 0.7
	var/ipc_charge = 0
	var/ipc_charging_flag = FALSE

/obj/item/organ/heart/cybernetic/tier2
	ipc_max_charge = 5000
	ipc_charge_rate_mod = 1.0
	ipc_charge_efficiency = 1.0

/obj/item/organ/heart/cybernetic/tier3
	ipc_max_charge = 8000
	ipc_charge_rate_mod = 0.8
	ipc_charge_efficiency = 1.3

/obj/item/organ/heart/cybernetic/surplus
	ipc_max_charge = 0  // Несовместим с КПБ

/obj/item/organ/heart/cybernetic/anomalock
	ipc_max_charge = 5000
	ipc_charge_rate_mod = 1.0
	ipc_charge_efficiency = 1.0

// Интерфейс для всех кибернетических сердец

/obj/item/organ/heart/cybernetic/get_ipc_charge()
	return ipc_charge

/obj/item/organ/heart/cybernetic/set_ipc_charge(val)
	ipc_charge = val

/obj/item/organ/heart/cybernetic/ipc_charge_from(amount)
	if(!ipc_max_charge)
		return
	ipc_charge = min(ipc_max_charge, ipc_charge + amount * ipc_charge_efficiency)

/obj/item/organ/heart/cybernetic/get_ipc_charging()
	return ipc_charging_flag

/obj/item/organ/heart/cybernetic/set_ipc_charging(val)
	ipc_charging_flag = val

// ============================================
// HEART OF FREEDOM — stats + интерфейс
// ============================================

/obj/item/organ/heart/freedom
	ipc_max_charge = 8000
	ipc_charge_rate_mod = 0.8
	ipc_charge_efficiency = 1.3
	var/ipc_charge = 0
	var/ipc_charging_flag = FALSE

/obj/item/organ/heart/freedom/get_ipc_charge()
	return ipc_charge

/obj/item/organ/heart/freedom/set_ipc_charge(val)
	ipc_charge = val

/obj/item/organ/heart/freedom/ipc_charge_from(amount)
	ipc_charge = min(ipc_max_charge, ipc_charge + amount * ipc_charge_efficiency)

/obj/item/organ/heart/freedom/get_ipc_charging()
	return ipc_charging_flag

/obj/item/organ/heart/freedom/set_ipc_charging(val)
	ipc_charging_flag = val

// ============================================
// ИНИЦИАЛИЗАЦИЯ ЗАРЯДА И СОБЫТИЯ ПРИ УСТАНОВКЕ / СНЯТИИ
// ============================================

/// Возвращает TRUE если у КПБ есть совместимый источник питания.
/proc/ipc_has_power_source(mob/living/carbon/human/H)
	var/obj/item/organ/heart/heart = H.get_organ_slot(ORGAN_SLOT_HEART)
	return heart && heart.ipc_max_charge > 0

/// Автооживление КПБ при наличии позитронного мозга и нового источника питания.
/proc/ipc_heart_check_revive(mob/living/carbon/human/M)
	var/obj/item/organ/brain/positronic/brain = M.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!brain || !istype(brain))
		return
	if(M.stat == DEAD || M.stat == UNCONSCIOUS)
		M.set_stat(CONSCIOUS)
		M.SetUnconscious(0, FALSE)
		M.losebreath = 0
		M.failed_last_breath = FALSE
		M.update_damage_hud()
		M.updatehealth()
		M.reload_fullscreen()
		to_chat(M, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Питание возобновлено!"))
		do_sparks(8, TRUE, M)

/obj/item/organ/heart/cybernetic/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(!istype(receiver.dna?.species, /datum/species/ipc) || !ipc_max_charge)
		return
	if(ipc_charge <= 0)
		ipc_charge = ipc_max_charge
	to_chat(receiver, span_notice("Источник питания подключён. Заряд: [ipc_charge]/[ipc_max_charge]."))
	ipc_heart_check_revive(receiver)

/obj/item/organ/heart/cybernetic/on_mob_remove(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(istype(receiver.dna?.species, /datum/species/ipc) && ipc_max_charge)
		to_chat(receiver, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания отключён! Аварийное отключение..."))
		ipc_charging_flag = FALSE

/obj/item/organ/heart/freedom/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(!istype(receiver.dna?.species, /datum/species/ipc))
		return
	if(ipc_charge <= 0)
		ipc_charge = ipc_max_charge
	to_chat(receiver, span_notice("Источник питания подключён. Заряд: [ipc_charge]/[ipc_max_charge]."))
	ipc_heart_check_revive(receiver)

/obj/item/organ/heart/freedom/on_mob_remove(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(istype(receiver.dna?.species, /datum/species/ipc))
		to_chat(receiver, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания отключён! Аварийное отключение..."))
		ipc_charging_flag = FALSE

// ============================================
// РАЗРЯД В ТИКЕ + АНОМАЛОК САМОЗАРЯДКА
// ============================================

/obj/item/organ/heart/cybernetic/on_life(seconds_per_tick)
	. = ..()
	if(!owner || !istype(owner.dna?.species, /datum/species/ipc) || !ipc_max_charge)
		return

	// Разряд
	if(!ipc_charging_flag)
		ipc_charge = max(0, ipc_charge - (ipc_charge_rate_mod * seconds_per_tick))

	// Аномалок: самозарядка от аномального ядра
	if(istype(src, /obj/item/organ/heart/cybernetic/anomalock))
		var/obj/item/organ/heart/cybernetic/anomalock/anomalock = src
		if(anomalock.core)
			// Пассивная генерация 1.5/сек: итого нетто +0.5/сек vs разряда 1.0/сек
			ipc_charge = min(ipc_max_charge, ipc_charge + (1.5 * seconds_per_tick))

	// Предупреждение о низком заряде
	if(ipc_charge <= 0 && prob(10))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критически низкий заряд источника питания!"))

	// Обновляем HUD
	var/datum/species/ipc/S = owner.dna.species
	S.update_ipc_battery_icon(owner)

/obj/item/organ/heart/freedom/on_life(seconds_per_tick)
	. = ..()
	if(!owner || !istype(owner.dna?.species, /datum/species/ipc))
		return

	if(!ipc_charging_flag)
		ipc_charge = max(0, ipc_charge - (ipc_charge_rate_mod * seconds_per_tick))

	if(ipc_charge <= 0 && prob(10))
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критически низкий заряд источника питания!"))

	var/datum/species/ipc/S = owner.dna.species
	S.update_ipc_battery_icon(owner)

// ============================================
// EXAMINE — показываем заряд владельцу-КПБ
// ============================================

/obj/item/organ/heart/cybernetic/examine(mob/user)
	. = ..()
	if(owner && istype(owner.dna?.species, /datum/species/ipc) && ipc_max_charge)
		. += span_notice("Заряд КПБ: [ipc_charge]/[ipc_max_charge] ([round((ipc_charge/ipc_max_charge) * 100)]%)")

/obj/item/organ/heart/freedom/examine(mob/user)
	. = ..()
	if(owner && istype(owner.dna?.species, /datum/species/ipc))
		. += span_notice("Заряд КПБ: [ipc_charge]/[ipc_max_charge] ([round((ipc_charge/ipc_max_charge) * 100)]%)")
