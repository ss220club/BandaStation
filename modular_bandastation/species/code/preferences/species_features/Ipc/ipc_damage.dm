// ============================================
// ДОПОЛНИТЕЛЬНЫЕ ХЕЛПЕРЫ ДЛЯ УРОНА IPC
// ============================================

// Проверка является ли моб IPC
/proc/is_ipc(mob/living/carbon/human/H)
	if(!ishuman(H))
		return FALSE
	return istype(H.dna?.species, /datum/species/ipc)

// ============================================
// ВОСКРЕШЕНИЕ IPC
// ============================================

/datum/species/ipc/proc/can_revive(mob/living/carbon/human/H)
	// IPC можно воскресить если:
	// 1. Позитронный мозг цел
	// 2. Есть батарея с зарядом

	var/obj/item/organ/brain/positronic/brain = H.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!brain || brain.positronic_damage >= brain.max_damage)
		return FALSE

	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery || battery.charge <= 0)
		return FALSE

	return TRUE

/datum/species/ipc/proc/revive_ipc(mob/living/carbon/human/H)
	if(!can_revive(H))
		return FALSE

	H.revive()

	// Восстанавливаем немного HP
	H.adjustBruteLoss(-50, forced = TRUE)
	H.adjustFireLoss(-50, forced = TRUE)

	to_chat(H, span_notice("СИСТЕМНЫЙ ПЕРЕЗАПУСК: Инициализация систем... Перезагрузка завершена."))

	return TRUE

// ============================================
// ОСОБЫЕ ЭФФЕКТЫ УРОНА
// ============================================

/datum/species/ipc/proc/on_critical_damage(mob/living/carbon/human/H)
	// Специальные эффекты при критическом уроне
	if(H.health <= HEALTH_THRESHOLD_CRIT)
		// Глюки экрана
		if(prob(30))
			var/error_msg = pick(
				"Перезагрузка...",
				"Проверка целостности данных...",
				"Восстановление резервных копий..."
			)
			to_chat(H, span_danger("ОШИБКА: Критическое повреждение систем. [error_msg]"))

		// Визуальные глюки
		if(prob(20))
			var/severity = rand(1, 3)
			H.overlay_fullscreen("ipc_damage", /atom/movable/screen/fullscreen/brute, severity)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon, clear_fullscreen), "ipc_damage"), rand(1, 3) SECONDS)

/datum/species/ipc/on_death(mob/living/carbon/human/H, gibbed)
	. = ..()

	to_chat(H, span_deadsay("КРИТИЧЕСКАЯ ОШИБКА: Все системы отключены. Требуется перезапуск..."))
	H.overlay_fullscreen("ipc_death", /atom/movable/screen/fullscreen/blind)

// ============================================
// ЗАРЯДКА ОТ АПЦ
// ============================================

/obj/machinery/power/apc/proc/charge_ipc(mob/living/carbon/human/H)
	if(!is_ipc(H))
		return FALSE

	if(!cell || cell.charge <= 0)
		to_chat(H, span_warning("АПЦ не имеет заряда!"))
		return FALSE

	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		to_chat(H, span_warning("У вас нет батареи!"))
		return FALSE

	if(battery.charge >= battery.maxcharge)
		to_chat(H, span_notice("Батарея полностью заряжена."))
		return FALSE

	// Заряжаем
	var/charge_amount = min(100, cell.charge, battery.maxcharge - battery.charge)
	cell.use(charge_amount)
	battery.charge += charge_amount

	var/percent = round((battery.charge / battery.maxcharge) * 100)
	to_chat(H, span_notice("Зарядка... [percent]%"))

	return TRUE

// ============================================
// ХЕЛПЕР ДЛЯ ЭЛЕКТРОШОКА
// ============================================

/datum/species/ipc/proc/handle_shock(mob/living/carbon/human/H, power)
	// Удар током нагревает процессор
	var/heat_amount = power * 0.5
	cpu_temperature = min(cpu_temperature + heat_amount, cpu_temp_critical)

	to_chat(H, span_warning("ПРЕДУПРЕЖДЕНИЕ: Обнаружен скачок напряжения. Температура процессора повышена до [round(cpu_temperature)]°C."))

// ============================================
// ПРОВЕРКА НА КРИТИЧЕСКИЙ УРОН
// ============================================

/datum/species/ipc/proc/check_critical_status(mob/living/carbon/human/H)
	if(H.health <= HEALTH_THRESHOLD_CRIT)
		on_critical_damage(H)
