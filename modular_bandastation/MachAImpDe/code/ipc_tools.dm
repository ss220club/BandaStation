// ============================================
// ИНСТРУМЕНТЫ И УСТРОЙСТВА ДЛЯ IPC
// ============================================
// Autosurgeon — устройство для установки имплантов.
// Термопаста, охладительный блок — расходники для охлаждения CPU.
// Имплант улучшенного охлаждения — пассивный кулинг.
// ============================================

// ============================================
// AUTOSURGEON ДЛЯ IPC ИМПЛАНТОВ
// ============================================
// Специальный autosurgeon для установки IPC имплантов
// Работает с /obj/item/implant вместо /obj/item/organ

/obj/item/autosurgeon/ipc
	name = "IPC autosurgeon"
	desc = "Специализированное устройство для автоматической установки IPC имплантов. Работает только с имплантами для синтетиков. \
		У него есть гнездо для установки импланта, и гнездо для отвертки, чтобы доставать случайно вставленные вещи."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "autosurgeon"
	uses = INFINITY
	/// The implant currently loaded in the autosurgeon
	var/obj/item/implant/stored_implant

/obj/item/autosurgeon/ipc/update_overlays()
	. = ..()
	if(stored_implant)
		. += loaded_overlay
		. += emissive_appearance(icon, loaded_overlay, src)

/obj/item/autosurgeon/ipc/proc/load_implant(obj/item/implant/loaded_implant, mob/living/user)
	if(user)
		if(stored_implant)
			to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] уже содержит имплант."))
			return

		if(uses <= 0)
			to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] достигает предела использования и не может загружать новые импланты."))
			return

		// Проверяем что это IPC имплант
		if(!istype(loaded_implant, /obj/item/implant/ipc) && !istype(loaded_implant, /obj/item/implant/emp_protector))
			to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] несовместим[genderize_decode(name, "", "а", "о", "ы")] с [loaded_implant.declent_ru(INSTRUMENTAL)]. Требуется IPC имплант."))
			return

		if(!user.transferItemToLoc(loaded_implant, src))
			to_chat(user, span_alert("[capitalize(loaded_implant.declent_ru(NOMINATIVE))] застревает в вашей руке!"))
			return

	stored_implant = loaded_implant
	loaded_implant.forceMove(src)

	name = "[initial(name)] ([stored_implant.name])"
	update_appearance()

/obj/item/autosurgeon/ipc/proc/use_ipc_autosurgeon(mob/living/target, mob/living/user, implant_time)
	if(!stored_implant)
		to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] в данный момент не хранит имплантов."))
		return

	if(uses <= 0)
		to_chat(user, span_alert("[capitalize(declent_ru(NOMINATIVE))] не имеет больше зарядов. Устройства сложены и не могут быть реактивированны."))
		return

	// Проверяем что цель - человек
	if(!ishuman(target))
		to_chat(user, span_alert("Этот autosurgeon работает только с гуманоидами!"))
		return

	var/mob/living/carbon/human/H = target

	if(implant_time)
		user.visible_message(
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] собирается использовать [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
			span_notice("Вы собираетесь использовать [declent_ru(ACCUSATIVE)] на [target.declent_ru(PREPOSITIONAL)]."),
		)
		if(!do_after(user, (implant_time * surgery_speed), target))
			return

	if(target != user)
		log_combat(user, target, "autosurgeon implanted [stored_implant] into", "[src]", "in [AREACOORD(target)]")
		user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] нажимает на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в тело [target.declent_ru(GENITIVE)]."), span_notice("Вы нажимаете на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в тело [target.declent_ru(GENITIVE)]."))
	else
		user.visible_message(
			span_notice("[capitalize(user.declent_ru(NOMINATIVE))] нажимает на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в [user.ru_p_theirs()] тело."),
			span_notice("Вы нажимаете на кнопку на [declent_ru(PREPOSITIONAL)], и тот врезается в ваше тело."),
		)

	// Определяем body_zone для установки
	var/body_zone
	if(istype(stored_implant, /obj/item/implant/ipc))
		var/obj/item/implant/ipc/ipc_imp = stored_implant
		if(length(ipc_imp.allowed_zones) == 1)
			// Единственная зона — берём её автоматически по типу импланта
			body_zone = ipc_imp.allowed_zones[1]
		else if(length(ipc_imp.allowed_zones) > 1)
			// Несколько зон — пользователь выбирает через zone_selected
			body_zone = user.zone_selected
			if(!(body_zone in ipc_imp.allowed_zones))
				body_zone = ipc_imp.allowed_zones[1]
				to_chat(user, span_warning("Выбранная зона недоступна для этого импланта. Используется: [body_zone]."))
		else
			body_zone = user.zone_selected
	else if(istype(stored_implant, /obj/item/implant/emp_protector))
		body_zone = BODY_ZONE_CHEST
	else
		body_zone = user.zone_selected

	// Пытаемся установить имплант
	var/success = FALSE
	if(istype(stored_implant, /obj/item/implant/ipc))
		var/obj/item/implant/ipc/ipc_imp = stored_implant
		success = ipc_imp.implant(H, body_zone, user)
	else if(istype(stored_implant, /obj/item/implant/emp_protector))
		var/obj/item/implant/emp_protector/emp_imp = stored_implant
		success = emp_imp.implant(H, body_zone, user)

	if(!success)
		balloon_alert(user, "insertion failed!")
		return

	stored_implant = null
	name = initial(name)
	playsound(target.loc, 'sound/items/weapons/circsawhit.ogg', 50, vary = TRUE)
	update_appearance()

	uses--
	if(uses <= 0)
		desc = "[initial(desc)] Выглядит, словно не имеет больше зарядов."

/obj/item/autosurgeon/ipc/attack_self(mob/user)
	use_ipc_autosurgeon(user, user)

/obj/item/autosurgeon/ipc/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	use_ipc_autosurgeon(target, user, 8 SECONDS)

/obj/item/autosurgeon/ipc/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/implant/ipc) || istype(attacking_item, /obj/item/implant/emp_protector))
		load_implant(attacking_item, user)
	else
		return ..()

/obj/item/autosurgeon/ipc/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(..())
		return TRUE
	if(!stored_implant)
		to_chat(user, span_warning("Внутри [declent_ru(GENITIVE)] нет имплантов!"))
	else
		var/atom/drop_loc = user.drop_location()
		to_chat(user, span_notice("Вы убираете [stored_implant.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
		stored_implant.forceMove(drop_loc)
		stored_implant = null

		screwtool.play_tool_sound(src)
		uses--
		if(uses <= 0)
			desc = "[initial(desc)] Выглядит, словно не имеет больше зарядов."
		update_appearance(UPDATE_ICON)
	return TRUE

// ============================================
// ПРЕДУСТАНОВЛЕННЫЕ AUTOSURGEONS
// ============================================
// Для быстрого тестирования и админских нужд

/obj/item/autosurgeon/ipc/magnetic_joints
	desc = "Одноразовый IPC autosurgeon с имплантом магнитных суставов. Позволяет быстро прикреплять оторванные конечности."
	uses = 1

/obj/item/autosurgeon/ipc/magnetic_joints/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/magnetic_joints(src))

/obj/item/autosurgeon/ipc/sealed_joints
	desc = "Одноразовый IPC autosurgeon с имплантом герметичных суставов. Защищает конечности от отрывания."
	uses = 1

/obj/item/autosurgeon/ipc/sealed_joints/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/sealed_joints(src))

/obj/item/autosurgeon/ipc/reactive_repair
	desc = "Одноразовый IPC autosurgeon с имплантом реактивного ремонта. Автоматически чинит конечность."
	uses = 1

/obj/item/autosurgeon/ipc/reactive_repair/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/reactive_repair(src))

/obj/item/autosurgeon/ipc/emp_protector
	desc = "Одноразовый IPC autosurgeon с имплантом EMP-протектора. Защищает от ЕМП ударов."
	uses = 1

/obj/item/autosurgeon/ipc/emp_protector/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/emp_protector(src))

/obj/item/autosurgeon/ipc/magnetic_leg
	desc = "Одноразовый IPC autosurgeon с имплантом магнитных ног. Встроенные магнитные ботинки."
	uses = 1

/obj/item/autosurgeon/ipc/magnetic_leg/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/magnetic_leg(src))

/obj/item/autosurgeon/ipc/bio_generator
	desc = "Одноразовый IPC autosurgeon с имплантом био-генератора. Позволяет переваривать пищу для энергии."
	uses = 1

/obj/item/autosurgeon/ipc/bio_generator/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/bio_generator(src))

// ============================================
// ПРЕДМЕТЫ ОХЛАЖДЕНИЯ ДЛЯ IPC
// ============================================

// ============================================
// ТЕРМОПАСТА - применяемый предмет
// ============================================

/obj/item/ipc_thermalpaste
	name = "thermal paste applicator"
	desc = "Специализированная термопаста для IPC. Обеспечивает постоянное охлаждение 1°C/сек в течение 5-10 минут. Одноразовая."
	icon = 'modular_bandastation/MachAImpDe/icons/stack_medical.dmi'
	icon_state = "termopaste_tube"
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
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "ipc_cooler"
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
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "ipc_cooler"
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
