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
// НАНОПАСТА ДЛЯ ПРОТЕЗОВ И IPC
// Лечит роботизированные части тела от brute и burn урона.
// Работает на протезах и любом IPC шасси.
// ============================================

/obj/item/stack/medical/nanopaste
	name = "нанопаста"
	singular_name = "нанопаста"
	desc = "Универсальная нанопаста для ремонта роботизированных частей тела. Восстанавливает механические и термические повреждения протезов, а также КПБ любого бренда."
	icon = 'modular_bandastation/MachAImpDe/icons/stack_medical.dmi'
	icon_state = "nanopaste_tube_3"
	worn_icon_state = "nanopaste_tube_1"
	novariants = TRUE
	amount = 5
	max_amount = 5
	w_class = WEIGHT_CLASS_TINY
	heal_brute = 30
	heal_burn = 30
	self_delay = 4 SECONDS
	other_delay = 2 SECONDS
	repeating = TRUE
	apply_verb = "ремонтируем"
	merge_type = /obj/item/stack/medical/nanopaste

/obj/item/stack/medical/nanopaste/update_icon_state()
	if(amount >= 4)
		icon_state = "nanopaste_tube_3"
	else if(amount >= 2)
		icon_state = "nanopaste_tube_2"
	else
		icon_state = "nanopaste_tube_1"
	return ..()

/// Нанопаста работает только на роботизированных конечностях
/obj/item/stack/medical/nanopaste/can_heal(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	if(!iscarbon(patient))
		return FALSE
	var/mob/living/carbon/C = patient
	var/obj/item/bodypart/affecting = C.get_bodypart(healed_zone)
	if(!affecting)
		if(!silent)
			patient.balloon_alert(user, "нет конечности!")
		return FALSE
	if(IS_ORGANIC_LIMB(affecting))
		if(!silent)
			patient.balloon_alert(user, "только для роботизированных частей!")
		return FALSE
	return TRUE

/// Переопределяем try_heal_checks чтобы принимать роботизированные конечности
/obj/item/stack/medical/nanopaste/try_heal_checks(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	if(!(healed_zone in patient.get_all_limbs()))
		healed_zone = BODY_ZONE_CHEST

	if(!can_heal(patient, user, healed_zone, silent))
		return FALSE

	if(!works_on_dead && patient.stat == DEAD)
		if(!silent)
			patient.balloon_alert(user, "мёртв!")
		return FALSE

	if(!iscarbon(patient))
		return FALSE

	var/mob/living/carbon/C = patient
	var/obj/item/bodypart/affecting = C.get_bodypart(healed_zone)
	if(!affecting)
		if(!silent)
			C.balloon_alert(user, "отсутствует [parse_zone(healed_zone, NOMINATIVE)]!")
		return FALSE

	// Роботизированная конечность должна быть повреждена
	if(affecting.brute_dam <= 0 && affecting.burn_dam <= 0)
		if(!silent)
			C.balloon_alert(user, "[affecting.plaintext_zone] не повреждена!")
		return FALSE

	return TRUE

/// Лечение роботизированной конечности нанопастой
/obj/item/stack/medical/nanopaste/heal_carbon(mob/living/carbon/patient, mob/living/user, healed_zone)
	var/obj/item/bodypart/affecting = patient.get_bodypart(healed_zone)
	user.visible_message(
		span_green("[user] наносит [src.declent_ru(ACCUSATIVE)] на [affecting.plaintext_zone] у [patient.declent_ru(GENITIVE)]."),
		span_green("Вы наносите [src.declent_ru(ACCUSATIVE)] на [affecting.plaintext_zone] у [patient.declent_ru(GENITIVE)]."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
	if(affecting.heal_damage(heal_brute, heal_burn))
		patient.update_damage_overlays()
	post_heal_effects(0, patient, user)
	return TRUE

/// Не работает на простых мобах (только на частях тела)
/obj/item/stack/medical/nanopaste/heal_simplemob(mob/living/patient, mob/living/user)
	patient.balloon_alert(user, "только для роботизированных частей тела!")
	return FALSE

// ============================================
// MMI CORE
// Ядро сознания, хранящееся внутри MMI.
// Является мозговым органом — работает со
// стандартной логикой MMI:
//   - Вставка: кликнуть MMI с mmi_core в руке
//   - Извлечение: attack_self() на MMI (ПКМ по себе)
// ============================================

/obj/item/organ/brain/mmi_core
	name = "MMI core"
	desc = "Компактный носитель оцифрованного сознания, извлечённый из MMI. Содержит загруженный разум существа. Может быть вставлен в MMI или установлен в подходящий корпус."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "mmi_core"
	w_class = WEIGHT_CLASS_SMALL
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/brain/mmi_core/Initialize(mapload)
	. = ..()
	icon_state = "mmi_core"
