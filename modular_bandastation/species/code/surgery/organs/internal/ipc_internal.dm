
/proc/ipc_heart_check_revive(mob/living/carbon/human/M)
	var/obj/item/organ/brain/positronic/brain = M.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return FALSE
	if(M.stat != DEAD && M.stat != UNCONSCIOUS)
		return FALSE
	M.set_stat(CONSCIOUS)
	M.SetUnconscious(0, FALSE)
	M.losebreath = 0
	M.failed_last_breath = FALSE
	M.update_damage_hud()
	M.updatehealth()
	M.reload_fullscreen()
	do_sparks(8, TRUE, M)
	return TRUE

// ПОЗИТРОННЫЙ МОЗГ


/obj/item/organ/brain/positronic
	name = "positronic brain"
	desc = "Комплексный позитронный блок, содержащий искусственное сознание. Основа любого IPC."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "posibrain"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BRAIN
	organ_flags = ORGAN_ROBOTIC
	var/positronic_damage = 0
	var/max_damage = 100

/obj/item/organ/brain/positronic/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, span_notice("Позитронное ядро активировано."))
		if(M.stat == DEAD || M.stat == UNCONSCIOUS)
			if(istype(M.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/ipc_battery))
				if(ipc_heart_check_revive(M))
					to_chat(M, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Позитронное ядро онлайн!"))

/obj/item/organ/brain/positronic/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	if(owner)
		to_chat(owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Позитронное ядро отключено! Сознание угасает..."))
	. = ..()

/obj/item/organ/brain/positronic/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner && positronic_damage >= max_damage)
		owner.death()

/obj/item/organ/brain/positronic/emp_act(severity)
	. = ..()
	if(!owner)
		return
	switch(severity)
		if(EMP_HEAVY)
			positronic_damage += rand(20, 40)
			to_chat(owner, span_userdanger("ОШИБКА ПАМЯТИ: Критическое повреждение позитронного ядра!"))
		if(EMP_LIGHT)
			positronic_damage += rand(10, 20)
			to_chat(owner, span_danger("Предупреждение: Обнаружено повреждение данных."))

// Вариант с MMI
/obj/item/organ/brain/positronic/mmi
	name = "MMI-based positronic core"
	desc = "Позитронный блок с установленным MMI. Содержит оцифрованное органическое сознание."

// Вариант с платой борга
/obj/item/organ/brain/positronic/borg
	name = "borg module positronic core"
	desc = "Позитронный блок с платой из киборга. Содержит ИИ-личность."

//  Борг зарядка

/obj/item/stock_parts/power_store/ipc_battery_proxy
	/// Батарея-владелец
	var/obj/item/organ/heart/ipc_battery/battery_ref

/obj/item/stock_parts/power_store/ipc_battery_proxy/used_charge()
	if(!battery_ref)
		return 0
	return battery_ref.maxcharge - battery_ref.charge

/obj/item/stock_parts/power_store/ipc_battery_proxy/give(amount)
	if(!battery_ref || !amount)
		return 0
	var/power_used = min(battery_ref.maxcharge - battery_ref.charge, amount)
	battery_ref.charge += power_used
	return power_used

// БАТАРЕЯ (СЕРДЦЕ)

/obj/item/organ/heart/ipc_battery
	name = "IPC power cell"
	desc = "Высокоемкая батарея, обеспечивающая питание всех систем IPC."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "ipc_cell"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART
	organ_flags = ORGAN_ROBOTIC

	var/charge = 5000
	var/maxcharge = 5000
	/// Прокси для зарядной станции (создаётся при Initialize)
	var/obj/item/stock_parts/power_store/ipc_battery_proxy/proxy_cell

/obj/item/organ/heart/ipc_battery/Initialize(mapload)
	. = ..()
	proxy_cell = new(src)
	proxy_cell.battery_ref = src
	proxy_cell.maxcharge = maxcharge

/obj/item/organ/heart/ipc_battery/examine(mob/user)
	. = ..()
	. += span_notice("Заряд: [charge]/[maxcharge] ([round((charge/maxcharge)*100)]%)")

/obj/item/organ/heart/ipc_battery/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, span_notice("Источник питания подключен. Заряд: [charge]/[maxcharge]."))
		if(M.stat == DEAD || M.stat == UNCONSCIOUS)
			if(ipc_heart_check_revive(M))
				to_chat(M, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Питание возобновлено. Инициализация..."))

/obj/item/organ/heart/ipc_battery/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	if(owner)
		to_chat(owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания отключён! Аварийное отключение..."))
	. = ..()

/obj/item/organ/heart/ipc_battery/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!owner)
		return
	charge = max(0, charge - 2.78 * seconds_per_tick)
	SEND_SIGNAL(owner, COMSIG_IPC_BATTERY_UPDATED)

/obj/item/organ/heart/ipc_battery/emp_act(severity)
	. = ..()
	if(!owner)
		return
	switch(severity)
		if(EMP_HEAVY)
			charge = max(0, charge - (maxcharge * 0.5))
			to_chat(owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Батарея разряжена на 50%!"))
		if(EMP_LIGHT)
			charge = max(0, charge - (maxcharge * 0.25))
			to_chat(owner, span_danger("Предупреждение: Батарея разряжена на 25%."))

// ЛЕГКИЕ (СИСТЕМА ОХЛАЖДЕНИЯ)

/obj/item/organ/lungs/ipc
	name = "cooling system"
	desc = "Система охлаждения IPC. Регулирует температуру вычислительных блоков."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "ipc_cooler"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	organ_flags = ORGAN_ROBOTIC

// ГЛАЗА

/obj/item/organ/eyes/robotic/ipc
	name = "IPC optical sensors"
	desc = "Оптические сенсоры IPC. Позволяют видеть в различных спектрах."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "ipc_eyes"
	organ_flags = ORGAN_ROBOTIC


// УШИ

/obj/item/organ/ears/robot/ipc
	name = "IPC audio sensors"
	desc = "Аудио сенсоры IPC."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "ears-c"
	base_icon_state = "ears-c"
	organ_flags = ORGAN_ROBOTIC


// ЯЗЫК

/obj/item/organ/tongue/robot/ipc
	name = "IPC vocal synthesizer"
	desc = "Голосовой синтезатор IPC."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "ipc_voicebox"
	organ_flags = ORGAN_ROBOTIC
	modifies_speech = TRUE
