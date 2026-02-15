// ============================================
// ПРЕДМЕТЫ ОХЛАЖДЕНИЯ ДЛЯ IPC
// ============================================

// ============================================
// ТЕРМОПАСТА - применяемый предмет
// ============================================

/obj/item/ipc_thermalpaste
	name = "thermal paste applicator"
	desc = "Специализированная термопаста для IPC. Обеспечивает постоянное охлаждение 1°C/сек в течение 5-10 минут. Одноразовая."
	icon = 'modular_bandastation/MachAImpDe/icons/ImplantsAndItems.dmi'
	icon_state = "termapasta"
	w_class = WEIGHT_CLASS_TINY
	var/duration_min = 5 MINUTES
	var/duration_max = 10 MINUTES
	var/cooling_power = 1 // градусов охлаждения в секунду

/obj/item/ipc_thermalpaste/examine(mob/user)
	. = ..()
	. += span_notice("Обеспечивает постоянное охлаждение <b>[cooling_power]°C/сек</b> в течение <b>[duration_min/600]-[duration_max/600] минут</b>.")
	. += span_notice("Используйте на IPC для нанесения термопасты.")

/obj/item/ipc_thermalpaste/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		to_chat(user, span_warning("[H] не является IPC!"))
		return

	var/datum/species/ipc/S = H.dna.species

	// Проверяем, не активна ли уже термопаста
	if(S.thermal_paste_active)
		to_chat(user, span_warning("На процессоре [H] уже нанесена термопаста!"))
		return

	// Применяем термопасту
	user.visible_message(
		span_notice("[user] наносит термопасту на процессор [H]."),
		span_notice("Вы наносите термопасту на процессор [H].")
	)

	var/duration = rand(duration_min, duration_max)
	S.thermal_paste_active = TRUE
	S.thermal_paste_end_time = world.time + duration

	to_chat(H, span_notice("Вы чувствуете как температура вашего процессора снижается. Термопаста будет активна [duration/600] минут."))

	// Удаляем использованную пасту
	qdel(src)

// ============================================
// ОХЛАДИТЕЛЬНЫЙ БЛОК - RnD предмет
// ============================================

/obj/item/ipc_coolingblock
	name = "portable cooling block"
	desc = "Высокотехнологичное устройство активного охлаждения для IPC. Обеспечивает активное охлаждение 1°C/сек в течение 5 минут."
	icon = 'modular_bandastation/MachAImpDe/icons/ImplantsAndItems.dmi'
	icon_state = "ColdBlock"
	w_class = WEIGHT_CLASS_SMALL
	var/max_charges = 3
	var/charges = 3
	var/duration = 5 MINUTES
	var/cooling_power = 1 // градусов охлаждения в секунду

/obj/item/ipc_coolingblock/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/ipc_coolingblock/examine(mob/user)
	. = ..()
	. += span_notice("Обеспечивает активное охлаждение <b>[cooling_power]°C/сек</b> в течение <b>[duration/600] минут</b>.")
	. += span_notice("Осталось зарядов: <b>[charges]/[max_charges]</b>.")
	if(charges > 0)
		. += span_notice("Используйте на IPC для активации охлаждения.")
	else
		. += span_warning("Требуется перезарядка в RnD консоли.")

/obj/item/ipc_coolingblock/update_appearance(updates)
	. = ..()
	if(charges <= 0)
		icon_state = "[initial(icon_state)]_empty"
	else
		icon_state = initial(icon_state)

/obj/item/ipc_coolingblock/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	if(charges <= 0)
		to_chat(user, span_warning("[capitalize(src.name)] разряжен! Требуется перезарядка."))
		return

	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		to_chat(user, span_warning("[H] не является IPC!"))
		return

	var/datum/species/ipc/S = H.dna.species

	// Проверяем, не активен ли уже охладительный блок
	if(S.cooling_block_active)
		to_chat(user, span_warning("На [H] уже активирован охладительный блок!"))
		return

	// Применяем охлаждение
	user.visible_message(
		span_notice("[user] активирует охладительный блок на [H]."),
		span_notice("Вы активируете охладительный блок на [H].")
	)

	S.cooling_block_active = TRUE
	S.cooling_block_end_time = world.time + duration

	to_chat(H, span_boldnotice("Охладительный блок активирован! Активное охлаждение [cooling_power]°C/сек будет работать [duration/600] минут."))

	charges--
	update_appearance()

// Перезарядка в RnD консоли (можно добавить позже)
/obj/item/ipc_coolingblock/proc/recharge()
	charges = max_charges
	update_appearance()

// ============================================
// УЛУЧШЕННАЯ СИСТЕМА ОХЛАЖДЕНИЯ - имплант
// ============================================

/obj/item/implant/ipc_cooling_system
	name = "thermal stabilizer implant"
	desc = "Улучшенная система охлаждения для IPC. При имплантации обеспечивает постоянное охлаждение 1°C/сек навсегда."
	icon = 'modular_bandastation/MachAImpDe/icons/ImplantsAndItems.dmi'
	icon_state = "TermaStabImp"
	w_class = WEIGHT_CLASS_TINY

/obj/item/implant/ipc_cooling_system/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Thermal Stabilizer Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Provides passive cooling for IPC chassis.<BR>
	<b>Integrity:</b> Активен"}
	return dat

/obj/item/implant/ipc_cooling_system/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		if(!silent)
			to_chat(user, span_warning("Этот имплант предназначен только для IPC!"))
		return FALSE

	var/datum/species/ipc/S = H.dna.species

	if(S.improved_cooling_installed)
		if(!silent)
			to_chat(user, span_warning("У [H] уже установлена улучшенная система охлаждения!"))
		return FALSE

	S.improved_cooling_installed = TRUE

	if(!silent)
		to_chat(H, span_boldnotice("Улучшенная система охлаждения установлена и активирована!"))
		to_chat(user, span_notice("Вы успешно установили имплант термостабилизатора в [H]."))

	return TRUE

/obj/item/implant/ipc_cooling_system/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source
	if(!istype(H.dna?.species, /datum/species/ipc))
		return

	var/datum/species/ipc/S = H.dna.species
	S.improved_cooling_installed = FALSE

	if(!silent)
		to_chat(H, span_warning("Ваша улучшенная система охлаждения деактивирована!"))

/obj/item/implantcase/ipc_cooling_system
	name = "implant case - 'Thermal Stabilizer'"
	desc = "Стеклянный кейс содержащий имплант термостабилизатора для IPC."
	imp_type = /obj/item/implant/ipc_cooling_system
