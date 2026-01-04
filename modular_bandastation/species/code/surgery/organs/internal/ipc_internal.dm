// ============================================
// ПОЗИТРОННЫЙ МОЗГ
// ============================================

/obj/item/organ/brain/positronic
	name = "positronic brain"
	desc = "Комплексный позитронный блок, содержащий искусственное сознание. Основа любого IPC."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "posibrain"
	zone = BODY_ZONE_CHEST // Мозг в груди, как у роботов
	slot = ORGAN_SLOT_BRAIN

	var/brain_type = "positronic" // Типы: "positronic", "mmi", "borg_module"
	var/positronic_damage = 0
	var/max_damage = 100

	// Для выбора типа ядра (MMI, позитронка, плата борга)
	var/obj/item/mmi/linked_mmi = null

/obj/item/organ/brain/positronic/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='notice'>Позитронное ядро активировано.</span>")

/obj/item/organ/brain/positronic/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='danger'>КРИТИЧЕСКАЯ ОШИБКА: Позитронное ядро отключено!</span>")

/obj/item/organ/brain/positronic/on_life()
	. = ..()

	// Проверка повреждений
	if(positronic_damage >= max_damage)
		// Мозг уничтожен
		owner.death()

/obj/item/organ/brain/positronic/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			positronic_damage += rand(20, 40)
			to_chat(owner, "<span class='userdanger'>ОШИБКА ПАМЯТИ: Критическое повреждение позитронного ядра!</span>")
		if(2)
			positronic_damage += rand(10, 20)
			to_chat(owner, "<span class='danger'>Предупреждение: Обнаружено повреждение данных.</span>")

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
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cell"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART

	var/charge = 5000 // Текущий заряд
	var/maxcharge = 5000 // Максимальный заряд
	var/charge_rate = 1 // Скорость разряда в тик
	var/charging = FALSE
	var/charge_efficiency = 1.0 // Эффективность зарядки

/obj/item/organ/heart/ipc_battery/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE,movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='notice'>Источник питания подключен. Заряд: [charge]/[maxcharge].</span>")

/obj/item/organ/heart/ipc_battery/Remove(mob/living/carbon/M, special = FALSE,  movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='userdanger'>КРИТИЧЕСКАЯ ОШИБКА: Источник питания отключен!</span>")

/obj/item/organ/heart/ipc_battery/on_life()
	. = ..()

	if(!owner)
		return

	// Разряжаем батарею
	if(!charging)
		charge = max(0, charge - charge_rate)

	// Проверяем уровень заряда
	if(charge <= 0)
		owner.Unconscious(20)
		to_chat(owner, "<span class='danger'>ПРЕДУПРЕЖДЕНИЕ: Критически низкий заряд батареи!</span>")
	else if(charge < maxcharge * 0.1)
		to_chat(owner, "<span class='warning'>Предупреждение: Заряд батареи ниже 10%.</span>")

/obj/item/organ/heart/ipc_battery/proc/charge_from_apc(amount)
	if(charge >= maxcharge)
		return FALSE

	var/charge_amount = min(amount * charge_efficiency, maxcharge - charge)
	charge += charge_amount
	return charge_amount

/obj/item/organ/heart/ipc_battery/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			charge = max(0, charge - (maxcharge * 0.5))
			to_chat(owner, "<span class='userdanger'>КРИТИЧЕСКАЯ ОШИБКА: Батарея разряжена на 50%!</span>")
		if(2)
			charge = max(0, charge - (maxcharge * 0.25))
			to_chat(owner, "<span class='danger'>Предупреждение: Батарея разряжена на 25%.</span>")

// ============================================
// ЛЕГКИЕ (СИСТЕМА ОХЛАЖДЕНИЯ)
// ============================================

/obj/item/organ/lungs/ipc
	name = "cooling system"
	desc = "Система охлаждения IPC. Регулирует температуру вычислительных блоков."
	icon = 'icons/bandastation/mob/species/ipc/surgery.dmi'
	icon_state = "heat_sink"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS

	var/cooling_power = 1.0 // Мощность охлаждения
	var/cooling_efficiency = 1.0 // Эффективность
	var/damaged = FALSE

/obj/item/organ/lungs/ipc/Insert(mob/living/carbon/M, special = FALSE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='notice'>Система охлаждения активирована.</span>")

/obj/item/organ/lungs/ipc/Remove(mob/living/carbon/M, special = FALSE, movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='danger'>ПРЕДУПРЕЖДЕНИЕ: Система охлаждения отключена!</span>")

/obj/item/organ/lungs/ipc/on_life()
	. = ..()

	if(!owner)
		return

	// Пассивное охлаждение (будет использоваться в температурной системе)
	var/datum/species/ipc/S = owner.dna.species
	if(istype(S))
		// Применяем охлаждение к температуре процессора
		S.cpu_temperature = max(S.cpu_temp_optimal_min, S.cpu_temperature - (cooling_power * cooling_efficiency))

/obj/item/organ/lungs/ipc/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			cooling_efficiency = max(0.1, cooling_efficiency - 0.5)
			damaged = TRUE
			to_chat(owner, "<span class='danger'>ОШИБКА: Система охлаждения повреждена!</span>")
		if(2)
			cooling_efficiency = max(0.5, cooling_efficiency - 0.2)
			to_chat(owner, "<span class='warning'>Предупреждение: Эффективность охлаждения снижена.</span>")

// ============================================
// ГЛАЗА
// ============================================

/obj/item/organ/eyes/robotic/ipc
	name = "IPC optical sensors"
	desc = "Оптические сенсоры IPC. Позволяют видеть в различных спектрах."
	eye_icon_state = "eyes"
	icon = 'icons/bandastation/mob/species/ipc/surgery.dmi'
	icon_state = "cybernetic_eyeballs"

	sight_flags = SEE_MOBS // Базовое зрение

/obj/item/organ/eyes/robotic/ipc/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE,movement_flags)
	. = ..()
	if(.)
		to_chat(M, "<span class='notice'>Оптические сенсоры активированы.</span>")

// ============================================
// УШИ
// ============================================

/obj/item/organ/ears/robot/ipc
	name = "IPC audio sensors"
	desc = "Аудио сенсоры IPC."
	icon = 'icons/bandastation/mob/species/ipc/surgery.dmi'
	icon_state = "ears"

// ============================================
// ЯЗЫК
// ============================================

/obj/item/organ/tongue/robot/ipc
	name = "IPC vocal synthesizer"
	desc = "Голосовой синтезатор IPC."
	icon = 'icons/bandastation/mob/species/ipc/surgery.dmi'
	icon_state = "tonguerobot"

	modifies_speech = TRUE

/obj/item/organ/tongue/robot/ipc/handle_speech(datum/source, list/speech_args)
	// Можно добавить роботический фильтр речи
	return
