// ============================================
// ПРЕДМЕТЫ ОХЛАЖДЕНИЯ ДЛЯ IPC
// ============================================

// ============================================
// ТЕРМОПАСТА - применяемый предмет
// ============================================

/obj/item/ipc_thermalpaste
	name = "thermal paste applicator"
	desc = "Специализированная термопаста для IPC. При нанесении на процессор снижает температуру на 10°C в течение 30-60 минут. Одноразовая."
	icon = 'modular_bandastation/MachAImpDe/icons/ImplantsAndItems.dmi'
	icon_state = "termapasta"
	w_class = WEIGHT_CLASS_TINY
	var/duration_min = 30 MINUTES
	var/duration_max = 60 MINUTES
	var/cooling_power = 10 // градусов охлаждения

/obj/item/ipc_thermalpaste/examine(mob/user)
	. = ..()
	. += span_notice("Обеспечивает пассивное охлаждение на <b>[cooling_power]°C</b> в течение <b>[duration_min/600]-[duration_max/600] минут</b>.")
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
	desc = "Высокотехнологичное устройство активного охлаждения для IPC. Обеспечивает мощное охлаждение на 30°C, но имеет ограниченное время работы."
	icon = 'modular_bandastation/MachAImpDe/icons/ImplantsAndItems.dmi'
	icon_state = "ColdBlock"
	w_class = WEIGHT_CLASS_SMALL
	var/max_charges = 3
	var/charges = 3
	var/duration = 5 MINUTES
	var/cooling_power = 30 // градусов охлаждения

/obj/item/ipc_coolingblock/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/ipc_coolingblock/examine(mob/user)
	. = ..()
	. += span_notice("Обеспечивает активное охлаждение на <b>[cooling_power]°C</b> в течение <b>[duration/600] минут</b>.")
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

	to_chat(H, span_boldnotice("Охладительный блок активирован! Мощное охлаждение будет активно [duration/600] минут."))

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
	desc = "Улучшенная система охлаждения для IPC. При имплантации обеспечивает постоянное пассивное охлаждение на 10°C."
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

// ============================================
// БАЛЛОН С ГАЗОМ - носимая система охлаждения
// ============================================

/obj/item/ipc_gas_cooling
	name = "gas cooling system"
	desc = "Портативная система охлаждения на основе сжатого газа. Надевается на спину IPC и использует холодный газ для охлаждения процессора. Требует баллон с газом."
	icon = 'icons/obj/device.dmi' // Временная иконка, можно заменить
	icon_state = "batterer"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

	var/obj/item/tank/internals/attached_tank = null
	var/active = FALSE
	var/cooling_rate = 0 // Рассчитывается на основе температуры газа

/obj/item/ipc_gas_cooling/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/ipc_gas_cooling/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/ipc_gas_cooling/examine(mob/user)
	. = ..()
	. += span_notice("Система охлаждения на основе сжатого газа. Надевается на спину.")
	if(attached_tank)
		. += span_notice("Подключенный баллон: <b>[attached_tank.name]</b>")
		. += span_notice("Давление газа: <b>[round(attached_tank.return_pressure())] kPa</b>")
		var/datum/gas_mixture/gas = attached_tank.return_air()
		if(gas)
			. += span_notice("Температура газа: <b>[round(gas.temperature - T0C)]°C</b>")
	else
		. += span_warning("Баллон не подключен. Используйте баллон с газом на системе для подключения.")

	if(active)
		. += span_notice("Система <b>активна</b>. Alt+Click для деактивации.")
		if(cooling_rate > 0)
			. += span_notice("Эффективность охлаждения: <b>[cooling_rate]°C/сек</b>")
	else
		. += span_notice("Система <b>неактивна</b>. Alt+Click для активации.")

/obj/item/ipc_gas_cooling/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/internals))
		if(attached_tank)
			to_chat(user, span_warning("К системе уже подключен баллон!"))
			return

		if(!user.transferItemToLoc(I, src))
			return

		attached_tank = I
		to_chat(user, span_notice("Вы подключаете [I] к системе охлаждения."))
		update_cooling_rate()
		return

	return ..()

/obj/item/ipc_gas_cooling/AltClick(mob/user)
	. = ..()
	if(!isliving(user))
		return

	var/mob/living/L = user

	// Проверяем что система надета на IPC
	if(L.get_item_by_slot(ITEM_SLOT_BACK) != src)
		to_chat(user, span_warning("Сначала наденьте систему на спину!"))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.dna?.species, /datum/species/ipc))
		to_chat(user, span_warning("Эта система предназначена только для IPC!"))
		return

	if(!attached_tank)
		to_chat(user, span_warning("К системе не подключен баллон с газом!"))
		return

	active = !active

	if(active)
		update_cooling_rate()
		to_chat(user, span_notice("Вы активируете газовую систему охлаждения. Эффективность: [cooling_rate]°C/сек"))
	else
		to_chat(user, span_notice("Вы деактивируете газовую систему охлаждения."))

/obj/item/ipc_gas_cooling/dropped(mob/user)
	. = ..()
	if(active)
		active = FALSE
		to_chat(user, span_warning("Газовая система охлаждения деактивирована."))

// Извлечение баллона
/obj/item/ipc_gas_cooling/attack_hand(mob/user)
	if(loc == user && attached_tank)
		to_chat(user, span_notice("Вы начинаете отключать баллон от системы..."))
		if(do_after(user, 2 SECONDS, target = src))
			attached_tank.forceMove(get_turf(user))
			user.put_in_hands(attached_tank)
			to_chat(user, span_notice("Вы отключаете [attached_tank] от системы охлаждения."))
			attached_tank = null
			active = FALSE
			cooling_rate = 0
		return

	return ..()

/obj/item/ipc_gas_cooling/proc/update_cooling_rate()
	if(!attached_tank)
		cooling_rate = 0
		return

	var/datum/gas_mixture/gas = attached_tank.return_air()
	if(!gas)
		cooling_rate = 0
		return

	// Охлаждение зависит от температуры газа
	// Чем холоднее газ, тем лучше охлаждение
	var/gas_temp = gas.temperature - T0C

	if(gas_temp < 0)
		// Очень холодный газ (ниже 0°C)
		cooling_rate = min(abs(gas_temp) * 0.1, 20) // Максимум 20°C/сек
	else if(gas_temp < 20)
		// Холодный газ (0-20°C)
		cooling_rate = (20 - gas_temp) * 0.3 // До 6°C/сек
	else
		// Теплый или горячий газ - не охлаждает
		cooling_rate = 0

/obj/item/ipc_gas_cooling/process(seconds_per_tick)
	if(!active)
		return

	// Находим владельца
	var/mob/living/carbon/human/H = loc
	if(!ishuman(H) || H.get_item_by_slot(ITEM_SLOT_BACK) != src)
		return

	if(!istype(H.dna?.species, /datum/species/ipc))
		return

	if(!attached_tank)
		active = FALSE
		return

	// Проверяем давление в баллоне
	if(attached_tank.return_pressure() < 10)
		to_chat(H, span_warning("Давление в баллоне слишком низкое! Система охлаждения деактивирована."))
		active = FALSE
		return

	// Обновляем эффективность охлаждения
	update_cooling_rate()

	if(cooling_rate <= 0)
		to_chat(H, span_warning("Газ в баллоне слишком теплый для охлаждения!"))
		active = FALSE
		return

	// Применяем охлаждение
	var/datum/species/ipc/S = H.dna.species
	S.cpu_temperature = max(S.cpu_temperature - (cooling_rate * seconds_per_tick), 0)

	// Расходуем газ (очень медленно)
	var/datum/gas_mixture/gas = attached_tank.return_air()
	if(gas && gas.total_moles() > 0.1)
		gas.remove(0.1 * seconds_per_tick) // Убираем 0.1 моль в секунду
