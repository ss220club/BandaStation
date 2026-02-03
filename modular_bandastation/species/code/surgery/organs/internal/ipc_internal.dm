// ============================================
// ПОЗИТРОННЫЙ МОЗГ
// ============================================

/obj/item/organ/brain/positronic
	name = "positronic brain"
	desc = "Комплексный позитронный блок, содержащий искусственное сознание. Основа любого IPC."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "posibrain"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BRAIN

	// КРИТИЧНО: Указываем что это роботический орган
	organ_flags = ORGAN_ROBOTIC

	var/brain_type = "positronic"
	var/positronic_damage = 0
	var/max_damage = 100
	var/obj/item/mmi/linked_mmi = null

/obj/item/organ/brain/positronic/Initialize(mapload)
	. = ..()
	// Убедимся что иконка правильная
	if(!icon_state)
		icon_state = "posibrain"

/obj/item/organ/brain/positronic/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, span_notice("Позитронное ядро активировано."))

		// АВТОМАТИЧЕСКОЕ ОЖИВЛЕНИЕ: Если были без сознания и есть батарея
		if(M.stat == UNCONSCIOUS)
			var/obj/item/organ/heart/ipc_battery/battery = M.get_organ_slot(ORGAN_SLOT_HEART)
			if(battery && istype(battery))
				M.set_stat(CONSCIOUS)
				M.SetUnconscious(0)
				to_chat(M, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Контроль над телом возвращён!"))

		// Если были мертвы и есть батарея - тоже оживаем
		else if(M.stat == DEAD)
			var/obj/item/organ/heart/ipc_battery/battery = M.get_organ_slot(ORGAN_SLOT_HEART)
			if(battery && istype(battery))
				M.set_stat(CONSCIOUS)
				M.SetUnconscious(0, FALSE)
				M.losebreath = 0
				M.failed_last_breath = FALSE
				M.update_damage_hud()
				M.updatehealth()
				M.reload_fullscreen()

				to_chat(M, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Позитронное ядро онлайн!"))
				do_sparks(8, TRUE, M)

/obj/item/organ/brain/positronic/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	if(owner)
		to_chat(owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Позитронное ядро отключено! Сознание угасает..."))
	. = ..()

/obj/item/organ/brain/positronic/on_life(seconds_per_tick, times_fired)
	. = ..()

	if(!owner)
		return

	// Проверка повреждений
	if(positronic_damage >= max_damage)
		owner.death()

/obj/item/organ/brain/positronic/emp_act(severity)
	. = ..()
	if(!owner)
		return

	switch(severity)
		if(1) // EMP_HEAVY
			positronic_damage += rand(20, 40)
			to_chat(owner, span_userdanger("ОШИБКА ПАМЯТИ: Критическое повреждение позитронного ядра!"))
		if(2) // EMP_LIGHT
			positronic_damage += rand(10, 20)
			to_chat(owner, span_danger("Предупреждение: Обнаружено повреждение данных."))

// Вариант с MMI
/obj/item/organ/brain/positronic/mmi
	name = "MMI-based positronic core"
	desc = "Позитронный блок с установленным MMI. Содержит оцифрованное органическое сознание."
	brain_type = "mmi"

// Вариант с платой борга
/obj/item/organ/brain/positronic/borg
	name = "borg module positronic core"
	desc = "Позитронный блок с платой из киборга. Содержит ИИ-личность."
	brain_type = "borg_module"

// ============================================
// БАТАРЕЯ (СЕРДЦЕ)
// ============================================

/obj/item/organ/heart/ipc_battery
	name = "IPC power cell"
	desc = "Высокоемкая батарея, обеспечивающая питание всех систем IPC."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "heart-c-on"
	base_icon_state = "heart-c-on"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART

	// КРИТИЧНО: Указываем что это роботический орган
	organ_flags = ORGAN_ROBOTIC

	var/charge = 5000
	var/maxcharge = 5000
	var/charge_rate = 1
	var/charging = FALSE
	var/charge_efficiency = 1.0

/obj/item/organ/heart/ipc_battery/Initialize(mapload)
	. = ..()
	// НЕ вызываем update_appearance() чтобы не ломать иконку
	icon_state = "heart-c-on"

/obj/item/organ/heart/ipc_battery/examine(mob/user)
	. = ..()
	. += span_notice("Заряд: [charge]/[maxcharge] ([round((charge/maxcharge)*100)]%)")

/obj/item/organ/heart/ipc_battery/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, span_notice("Источник питания подключен. Заряд: [charge]/[maxcharge]."))

		// АВТОМАТИЧЕСКОЕ ОЖИВЛЕНИЕ: Если есть и мозг и батарея
		if(M.stat == DEAD)
			var/obj/item/organ/brain/positronic/brain = M.get_organ_slot(ORGAN_SLOT_BRAIN)
			if(brain && istype(brain))
				// Оживляем без лечения урона
				M.set_stat(CONSCIOUS)
				M.SetUnconscious(0, FALSE)
				M.losebreath = 0
				M.failed_last_breath = FALSE
				M.update_damage_hud()
				M.updatehealth()
				M.reload_fullscreen()

				to_chat(M, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Питание возобновлено. Инициализация..."))
				do_sparks(8, TRUE, M)

/obj/item/organ/heart/ipc_battery/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	if(owner)
		to_chat(owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания отключён! Аварийное отключение..."))
	. = ..()

/obj/item/organ/heart/ipc_battery/on_life(seconds_per_tick, times_fired)
	. = ..()

	if(!owner)
		return

	// Разряжаем батарею
	if(!charging)
		charge = max(0, charge - (charge_rate * seconds_per_tick))

	// Проверяем уровень заряда
	if(charge <= 0)
		owner.Unconscious(2 SECONDS)
		if(prob(10))
			to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Критически низкий заряд батареи!"))
	else if(charge < maxcharge * 0.1 && prob(5))
		to_chat(owner, span_warning("Предупреждение: Заряд батареи ниже 10%."))

/obj/item/organ/heart/ipc_battery/proc/charge_from_apc(amount)
	if(charge >= maxcharge)
		return FALSE

	var/charge_amount = min(amount * charge_efficiency, maxcharge - charge)
	charge += charge_amount
	return charge_amount

/obj/item/organ/heart/ipc_battery/emp_act(severity)
	. = ..()
	if(!owner)
		return

	switch(severity)
		if(1) // EMP_HEAVY
			charge = max(0, charge - (maxcharge * 0.5))
			to_chat(owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Батарея разряжена на 50%!"))
		if(2) // EMP_LIGHT
			charge = max(0, charge - (maxcharge * 0.25))
			to_chat(owner, span_danger("Предупреждение: Батарея разряжена на 25%."))

// ============================================
// ЛЕГКИЕ (СИСТЕМА ОХЛАЖДЕНИЯ)
// ============================================

/obj/item/organ/lungs/ipc
	name = "cooling system"
	desc = "Система охлаждения IPC. Регулирует температуру вычислительных блоков."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "lungs-c"
	base_icon_state = "lungs-c"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS

	// КРИТИЧНО: Указываем что это роботический орган
	organ_flags = ORGAN_ROBOTIC

	var/cooling_power = 1.0
	var/cooling_efficiency = 1.0
	var/damaged = FALSE

/obj/item/organ/lungs/ipc/Initialize(mapload)
	. = ..()
	// Убедимся что иконка правильная
	if(!icon_state)
		icon_state = "lungs-c"
	update_appearance()

/obj/item/organ/lungs/ipc/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, span_notice("Система охлаждения активирована."))

/obj/item/organ/lungs/ipc/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	if(owner)
		to_chat(owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Система охлаждения отключена! Риск перегрева!"))
	. = ..()

/obj/item/organ/lungs/ipc/on_life(seconds_per_tick, times_fired)
	. = ..()

	if(!owner)
		return

	// Пассивное охлаждение
	if(istype(owner.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = owner.dna.species
		S.cpu_temperature = max(S.cpu_temp_optimal_min, S.cpu_temperature - (cooling_power * cooling_efficiency * seconds_per_tick))

/obj/item/organ/lungs/ipc/emp_act(severity)
	. = ..()
	if(!owner)
		return

	switch(severity)
		if(1) // EMP_HEAVY
			cooling_efficiency = max(0.1, cooling_efficiency - 0.5)
			damaged = TRUE
			to_chat(owner, span_danger("ОШИБКА: Система охлаждения повреждена!"))
		if(2) // EMP_LIGHT
			cooling_efficiency = max(0.5, cooling_efficiency - 0.2)
			to_chat(owner, span_warning("Предупреждение: Эффективность охлаждения снижена."))

// ============================================
// ГЛАЗА
// ============================================

/obj/item/organ/eyes/robotic/ipc
	name = "IPC optical sensors"
	desc = "Оптические сенсоры IPC. Позволяют видеть в различных спектрах."
	icon = 'icons/bandastation/mob/species/ipc/surgery.dmi'
	icon_state = "cybernetic_eyeballs"
	// КРИТИЧНО: Указываем что это роботический орган
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/eyes/robotic/ipc/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "cybernetic_eyeballs"
	update_appearance()

/obj/item/organ/eyes/robotic/ipc/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, span_notice("Оптические сенсоры активированы."))

// ============================================
// УШИ
// ============================================

/obj/item/organ/ears/robot/ipc
	name = "IPC audio sensors"
	desc = "Аудио сенсоры IPC."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "ears-c"
	base_icon_state = "ears-c"

	// КРИТИЧНО: Указываем что это роботический орган
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/ears/robot/ipc/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "ears-c"
	update_appearance()

// ============================================
// ЯЗЫК
// ============================================

/obj/item/organ/tongue/robot/ipc
	name = "IPC vocal synthesizer"
	desc = "Голосовой синтезатор IPC."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "tonguerobot"
	base_icon_state = "tonguerobot"

	// КРИТИЧНО: Указываем что это роботический орган
	organ_flags = ORGAN_ROBOTIC

	modifies_speech = TRUE

/obj/item/organ/tongue/robot/ipc/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "tonguerobot"
	update_appearance()

/obj/item/organ/tongue/robot/ipc/handle_speech(datum/source, list/speech_args)
	// Можно добавить роботический фильтр речи
	return
