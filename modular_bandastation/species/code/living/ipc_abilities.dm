// ============================================
// IPC ABILITIES
// ============================================
// Абилки для IPC: разгон системы, взлом дверей.

// Добавляем переменную режима взлома к datum вида IPC
/datum/species/ipc
	var/hack_mode_active = FALSE

/// Абилка разгона системы - увеличивает скорость действий за счет нагрева процессора
/datum/action/cooldown/ipc_overclock
	name = "Разгон системы"
	desc = "Переключает режим разгона процессора."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_overload_off"
	background_icon_state = null
	overlay_icon_state = null
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	cooldown_time = 2 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/ipc_overclock/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	// Доступна только для IPC
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

/datum/action/cooldown/ipc_overclock/Remove(mob/living/remove_from)
	var/mob/living/carbon/human/H = owner
	if(istype(H) && istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		if(S.overclock_active)
			deactivate_overclock(H, S)
	return ..()

/datum/action/cooldown/ipc_overclock/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE

	var/datum/species/ipc/S = H.dna.species

	// Toggle
	if(S.overclock_active)
		deactivate_overclock(H, S)
	else
		activate_overclock(H, S)

	StartCooldown()
	return TRUE

/datum/action/cooldown/ipc_overclock/proc/activate_overclock(mob/living/carbon/human/H, datum/species/ipc/S)
	S.overclock_active = TRUE
	button_icon_state = "ipc_overload_on"
	background_icon_state = null

	// Проверяем установлен ли OverClock.exe — усиливает разгон
	var/has_overclock_mod = FALSE
	if(S.ipc_os)
		for(var/datum/ipc_netapp/blackwall/overclock/oc_app in S.ipc_os.installed_apps)
			has_overclock_mod = TRUE
			break

	if(has_overclock_mod)
		S.overclock_speed_bonus = 0.7  // 70% вместо стандартных 40%
		H.add_movespeed_modifier(/datum/movespeed_modifier/ipc_overclock_enhanced)
		to_chat(H, span_boldwarning("УСИЛЕННЫЙ разгон активирован! Скорость +[S.overclock_speed_bonus * 100]% + ускорение движения! (OverClock.exe)"))
	else
		to_chat(H, span_notice("Разгон системы активирован! Скорость взаимодействия увеличена на [S.overclock_speed_bonus * 100]%."))

	to_chat(H, span_warning("ПРЕДУПРЕЖДЕНИЕ: Температура процессора будет повышаться!"))
	build_all_button_icons()

/datum/action/cooldown/ipc_overclock/proc/deactivate_overclock(mob/living/carbon/human/H, datum/species/ipc/S)
	S.overclock_active = FALSE
	button_icon_state = "ipc_overload_off"
	background_icon_state = null

	// Убираем бонусы от OverClock.exe
	S.overclock_speed_bonus = initial(S.overclock_speed_bonus)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/ipc_overclock_enhanced)

	to_chat(H, span_notice("Разгон системы отключен. Процессор вернулся к нормальной работе."))
	build_all_button_icons()

// ============================================
// ВЗЛОМ ДВЕРЕЙ
// ============================================
// Переключаемая абилка. Если активна и КПБ кликает на дверь без доступа —
// вместо "Access denied" запускается 10-секундный взлом (нужно оставаться рядом).
// При успехе: дверь открывается на 5 секунд + тратится заряд батареи.
// Не работает на забальтованных и заваренных дверях.

#define IPC_HACK_BATTERY_COST  250   // заряд за успешный взлом
#define IPC_HACK_DURATION      20 SECONDS

/// Абилка взлома дверей
/datum/action/cooldown/ipc_hack
	name = "Взлом"
	desc = "Переключает режим взлома дверей."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_hack"
	background_icon_state = null
	overlay_icon_state = null
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	cooldown_time = 1 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/ipc_hack/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE
	return TRUE

/datum/action/cooldown/ipc_hack/Remove(mob/living/remove_from)
	var/mob/living/carbon/human/H = owner
	if(istype(H) && istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		if(S.hack_mode_active)
			deactivate_hack(H, S)
	return ..()

/datum/action/cooldown/ipc_hack/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		return FALSE
	var/datum/species/ipc/S = H.dna.species
	if(S.hack_mode_active)
		deactivate_hack(H, S)
	else
		activate_hack(H, S)
	StartCooldown()
	return TRUE

/datum/action/cooldown/ipc_hack/proc/activate_hack(mob/living/carbon/human/H, datum/species/ipc/S)
	S.hack_mode_active = TRUE
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_hack_clickon))
	to_chat(H, span_boldwarning("ВЗЛОМ: Режим активен. Нажмите на дверь без доступа для взлома."))
	build_all_button_icons()

/datum/action/cooldown/ipc_hack/proc/deactivate_hack(mob/living/carbon/human/H, datum/species/ipc/S)
	S.hack_mode_active = FALSE
	UnregisterSignal(H, COMSIG_MOB_CLICKON)
	to_chat(H, span_notice("ВЗЛОМ: Режим отключен."))
	build_all_button_icons()

/// Перехватывает клики на двери пока режим взлома активен.
/datum/action/cooldown/ipc_hack/proc/on_hack_clickon(datum/source, atom/A, list/modifiers)
	SIGNAL_HANDLER
	if(!istype(A, /obj/machinery/door/airlock))
		return

	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return

	var/datum/species/ipc/S = H.dna?.species
	if(!istype(S) || !S.hack_mode_active)
		return

	var/obj/machinery/door/airlock/door = A

	// Если у КПБ уже есть доступ — пропускаем, пусть нормально открывается
	if(door.allowed(H))
		return

	// Дверь заблокирована физически — взлом кибервзломом не поможет
	if(door.welded)
		to_chat(H, span_warning("ВЗЛОМ: Дверь заварена. Электронный взлом невозможен."))
		return COMSIG_MOB_CANCEL_CLICKON

	if(door.locked)
		to_chat(H, span_warning("ВЗЛОМ: Дверь забальтована. Электронный взлом невозможен."))
		return COMSIG_MOB_CANCEL_CLICKON

	// Нет заряда?
	var/obj/item/organ/heart/heart = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.get_ipc_charge() < IPC_HACK_BATTERY_COST)
		to_chat(H, span_warning("ВЗЛОМ: Недостаточно заряда батареи! Требуется [IPC_HACK_BATTERY_COST] ед."))
		return COMSIG_MOB_CANCEL_CLICKON

	// Запускаем взлом (асинхронно, чтобы не блокировать сигнал)
	INVOKE_ASYNC(src, PROC_REF(attempt_hack), H, door)
	return COMSIG_MOB_CANCEL_CLICKON

/// Асинхронный 10-секундный процесс взлома двери.
/datum/action/cooldown/ipc_hack/proc/attempt_hack(mob/living/carbon/human/H, obj/machinery/door/airlock/door)
	var/datum/species/ipc/S = H.dna?.species
	if(!istype(S))
		return

	// Визуальное сообщение: другие видят что кто-то взламывает
	H.visible_message(
		span_warning("[H] начинает взламывать [door]..."),
		span_boldwarning("ВЗЛОМ: Начинается электронный взлом [door]. Не двигайтесь!"),
	)
	playsound(H, 'sound/machines/terminal/terminal_alert.ogg', 40, FALSE)

	// Нагрев CPU во время взлома
	S.cpu_temperature = min(S.cpu_temp_critical, S.cpu_temperature + 10)

	if(!do_after(H, IPC_HACK_DURATION, target = door))
		to_chat(H, span_warning("ВЗЛОМ: Прервано."))
		return

	// Проверяем что дверь и КПБ всё ещё существуют и в порядке
	if(QDELETED(door) || QDELETED(H))
		return
	if(!istype(H.dna?.species, /datum/species/ipc) || !S.hack_mode_active)
		return

	// Снова проверяем физические блокировки — за 10 секунд их могли навесить
	if(door.welded || door.locked)
		to_chat(H, span_warning("ВЗЛОМ: Дверь была заблокирована в процессе взлома."))
		return

	// Проверяем заряд ещё раз (мог разрядиться за время взлома)
	var/obj/item/organ/heart/heart = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.get_ipc_charge() < IPC_HACK_BATTERY_COST)
		to_chat(H, span_warning("ВЗЛОМ: Заряд разрядился в процессе взлома."))
		return

	// Успех — тратим батарею и открываем дверь
	heart.set_ipc_charge(max(0, heart.get_ipc_charge() - IPC_HACK_BATTERY_COST))
	S.cpu_temperature = min(S.cpu_temp_critical, S.cpu_temperature + 15)

	H.visible_message(
		span_warning("[H] вскрывает [door]!"),
		span_boldnotice("ВЗЛОМ: Успех! Система безопасности обойдена."),
	)
	playsound(door, 'sound/machines/terminal/terminal_processing.ogg', 50, FALSE)

	door.open(BYPASS_DOOR_CHECKS)
	// Дверь автоматически закрывается через 5 секунд
	addtimer(CALLBACK(door, TYPE_PROC_REF(/obj/machinery/door/airlock, close)), 5 SECONDS)

#undef IPC_HACK_BATTERY_COST
#undef IPC_HACK_DURATION
