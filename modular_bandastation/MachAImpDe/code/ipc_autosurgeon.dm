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
	var/body_zone = user.zone_selected

	// Для IPC имплантов проверяем allowed_zones
	if(istype(stored_implant, /obj/item/implant/ipc))
		var/obj/item/implant/ipc/ipc_imp = stored_implant
		if(length(ipc_imp.allowed_zones))
			// Проверяем что выбранная зона разрешена
			if(!(body_zone in ipc_imp.allowed_zones))
				// Если нет - берем первую разрешенную зону
				body_zone = ipc_imp.allowed_zones[1]
				to_chat(user, span_warning("Выбранная зона недоступна для этого импланта. Используется зона: [body_zone]."))

	// Для EMP-protector проверяем что это грудь
	else if(istype(stored_implant, /obj/item/implant/emp_protector))
		if(body_zone != BODY_ZONE_CHEST)
			body_zone = BODY_ZONE_CHEST
			to_chat(user, span_warning("EMP-протектор может быть установлен только в грудную клетку."))

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
		for(var/atom/movable/stored_imp as anything in src)
			stored_imp.forceMove(drop_loc)
			to_chat(user, span_notice("Вы убираете [stored_implant.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
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
