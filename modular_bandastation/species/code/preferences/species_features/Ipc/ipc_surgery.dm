
// ============================================
// ОПЕРАЦИИ ДЛЯ IPC - ПОЛНАЯ ВЕРСИЯ
// ============================================

// Константы состояний панели
#define IPC_PANEL_CLOSED 0
#define IPC_PANEL_OPEN 1
#define IPC_ELECTRONICS_PREPARED 2
#define IPC_LIMB_DISCONNECTED 3
#define IPC_SELECTED_ORGAN "ipc_selected_organ"


// ============================================
// КОМПОНЕНТ ПАНЕЛИ IPC
// ============================================

/datum/component/ipc_panel
	var/panel_state = IPC_PANEL_CLOSED
	var/limb_connected = TRUE

/datum/component/ipc_panel/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/bodypart))
		return COMPONENT_INCOMPATIBLE

/datum/component/ipc_panel/proc/is_panel_open()
	return panel_state >= IPC_PANEL_OPEN

/datum/component/ipc_panel/proc/is_electronics_prepared()
	return panel_state >= IPC_ELECTRONICS_PREPARED

/datum/component/ipc_panel/proc/is_limb_disconnected()
	return panel_state == IPC_LIMB_DISCONNECTED

// ============================================
// ВСПОМОГАТЕЛЬНЫЕ ПРОКИ
// ============================================

/obj/item/bodypart/proc/get_ipc_panel()
	return GetComponent(/datum/component/ipc_panel)

/obj/item/bodypart/proc/ensure_ipc_panel()
	var/datum/component/ipc_panel/panel = get_ipc_panel()
	if(!panel)
		panel = AddComponent(/datum/component/ipc_panel)
	return panel

/datum/surgery_operation/proc/is_ipc_compatible(obj/item/bodypart/limb)
	if(!limb?.owner?.dna?.species)
		return FALSE

	// Проверяем что это IPC bodypart с правильным bodytype
	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	return istype(limb.owner.dna.species, /datum/species/ipc)

// ============================================
// 1. ОТКРЫТИЕ ПАНЕЛИ ШАССИ
// ============================================

/datum/surgery_operation/limb/ipc_open_panel
	name = "Открыть панель шасси"
	desc = "Открутить панель доступа к внутренним компонентам IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

	implements = list(
		TOOL_SCREWDRIVER = 1,
		/obj/item/screwdriver = 1
	)

/datum/surgery_operation/limb/ipc_open_panel/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!is_ipc_compatible(limb))
		return FALSE

	if(limb.body_zone != BODY_ZONE_CHEST && limb.body_zone != BODY_ZONE_HEAD)
		return FALSE

	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(panel && panel.is_panel_open())
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_open_panel/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете откручивать панель на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает откручивать панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_open_panel/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.ensure_ipc_panel()
	panel.panel_state = IPC_PANEL_OPEN

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы открутили панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] открутил панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Панель доступа открыта."))
	do_sparks(2, TRUE, limb.owner)

// ============================================
// 2. ЗАКРЫТИЕ ПАНЕЛИ ШАССИ
// ============================================

/datum/surgery_operation/limb/ipc_close_panel
	name = "Закрыть панель шасси"
	desc = "Закрутить панель доступа к внутренним компонентам IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

	implements = list(
		TOOL_SCREWDRIVER = 1,
		/obj/item/screwdriver = 1
	)

/datum/surgery_operation/limb/ipc_close_panel/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!is_ipc_compatible(limb))
		return FALSE

	if(limb.body_zone != BODY_ZONE_CHEST && limb.body_zone != BODY_ZONE_HEAD)
		return FALSE

	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(!panel || !panel.is_panel_open())
		return FALSE

	if(panel.is_electronics_prepared())
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_close_panel/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете закручивать панель на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает закручивать панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_close_panel/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(panel)
		panel.panel_state = IPC_PANEL_CLOSED

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы закрутили панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закрутил панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Панель доступа закрыта."))

// ============================================
// 3. ПОДГОТОВКА ЭЛЕКТРОНИКИ
// ============================================

/datum/surgery_operation/limb/ipc_prepare_electronics
	name = "Подготовить электронику"
	desc = "Подготовьте внутреннюю электронику IPC к операции с помощью мультитула."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC | OPERATION_SELF_OPERABLE
	time = 2.4 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

	implements = list(
		TOOL_MULTITOOL = 1,
		/obj/item/multitool = 1
	)

/datum/surgery_operation/limb/ipc_prepare_electronics/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!is_ipc_compatible(limb))
		return FALSE

	if(limb.body_zone != BODY_ZONE_CHEST && limb.body_zone != BODY_ZONE_HEAD)
		return FALSE

	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(!panel || !panel.is_panel_open())
		return FALSE

	if(panel.is_electronics_prepared())
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_prepare_electronics/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете подготавливать электронику в [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает подготавливать электронику в [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_prepare_electronics/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.ensure_ipc_panel()
	panel.panel_state = IPC_ELECTRONICS_PREPARED

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы подготовили электронику в [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] подготовил электронику в [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Электроника готова к манипуляциям."))
	do_sparks(2, TRUE, limb.owner)

// ============================================
// 4. МАНИПУЛЯЦИИ С ОРГАНАМИ ГРУДНОЙ КЛЕТКИ
// ============================================

/datum/surgery_operation/limb/ipc_organ_manipulation
	name = "Манипуляции с компонентами"
	desc = "Установка или извлечение компонентов грудной клетки IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC | OPERATION_NOTABLE
	time = 2.4 SECONDS
	preop_sound = 'sound/items/electronic_assembly_empty.ogg'
	success_sound = 'sound/items/deconstruct.ogg'

/datum/surgery_operation/limb/ipc_organ_manipulation/New()
	. = ..()
	implements = list(
		/obj/item/organ = 1,
		/obj/item/multitool = 1
	)

/datum/surgery_operation/limb/ipc_organ_manipulation/proc/is_ipc_chest_organ(obj/item/organ/organ)
	return istype(organ, /obj/item/organ/brain/positronic) || \
		   istype(organ, /obj/item/organ/heart/ipc_battery) || \
		   istype(organ, /obj/item/organ/lungs/ipc)

/datum/surgery_operation/limb/ipc_organ_manipulation/proc/get_removable_organs(obj/item/bodypart/limb)
	if(!limb.owner)
		return list()

	var/list/removable = list()
	for(var/slot in list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS))
		var/obj/item/organ/organ = limb.owner.get_organ_slot(slot)
		if(organ && is_ipc_chest_organ(organ))
			removable += organ

	return removable

/datum/surgery_operation/limb/ipc_organ_manipulation/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!is_ipc_compatible(limb))
		return FALSE

	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE

	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(!panel || !panel.is_electronics_prepared())
		return FALSE

	if(isorgan(tool))
		var/obj/item/organ/organ = tool
		if(!is_ipc_chest_organ(organ))
			return FALSE
		if(organ.slot && limb.owner.get_organ_slot(organ.slot))
			return FALSE
		return TRUE

	if(istype(tool, /obj/item/multitool))
		return length(get_removable_organs(limb)) > 0

	return FALSE

/datum/surgery_operation/limb/ipc_organ_manipulation/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	if(isorgan(tool))
		var/obj/item/organ/organ = tool
		var/datum/radial_menu_choice/option = new()
		option.image = image(icon = organ.icon, icon_state = organ.icon_state)
		option.name = "Установить [organ.name]"
		option.info = "Установить [organ.name] в [limb.owner]."
		return list(option = list(OPERATION_ACTION = "insert"))

	var/list/options = list()
	for(var/obj/item/organ/organ as anything in get_removable_organs(limb))
		var/datum/radial_menu_choice/option = new()
		option.image = image(icon = organ.icon, icon_state = organ.icon_state)
		option.name = "Извлечь [organ.name]"
		option.info = "Извлечь [organ.name] из [limb.owner]."
		options[option] = list(OPERATION_ACTION = "remove", IPC_SELECTED_ORGAN = organ)

	return options

/datum/surgery_operation/limb/ipc_organ_manipulation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(operation_args[OPERATION_ACTION] == "remove")
		var/obj/item/organ/organ = operation_args[IPC_SELECTED_ORGAN]
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы начинаете извлекать [organ.name] из [limb.owner]..."),
			span_notice("[surgeon] начинает извлекать компонент из [limb.owner]."),
			span_notice("[surgeon] начинает работать с [limb.owner].")
		)
	else
		var/obj/item/organ/organ = tool
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы начинаете устанавливать [organ.name] в [limb.owner]..."),
			span_notice("[surgeon] начинает устанавливать компонент в [limb.owner]."),
			span_notice("[surgeon] начинает работать с [limb.owner].")
		)

/datum/surgery_operation/limb/ipc_organ_manipulation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(operation_args[OPERATION_ACTION] == "remove")
		on_success_remove(limb, surgeon, operation_args[IPC_SELECTED_ORGAN], tool)
	else
		on_success_insert(limb, surgeon, tool)

/datum/surgery_operation/limb/ipc_organ_manipulation/proc/on_success_remove(obj/item/bodypart/limb, mob/living/surgeon, obj/item/organ/organ, obj/item/tool)
	var/organ_slot = organ.slot
	var/organ_name = organ.name
	var/patient_health = limb.owner.health

	organ.Remove(limb.owner)
	organ.forceMove(limb.owner.drop_location())

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно извлекли [organ_name] из [limb.owner]."),
		span_notice("[surgeon] извлёк [organ_name] из [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	do_sparks(5, TRUE, limb.owner)

	if(organ_slot == ORGAN_SLOT_BRAIN)
		to_chat(limb.owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Позитронное ядро отключено!"))
		if(patient_health > HEALTH_THRESHOLD_DEAD)
			limb.owner.Unconscious(999 SECONDS)
			limb.owner.set_stat(UNCONSCIOUS)
			to_chat(limb.owner, span_notice("Вы остаётесь в позитронном ядре, но не можете контролировать тело..."))
		else
			addtimer(CALLBACK(limb.owner, TYPE_PROC_REF(/mob/living/carbon, death)), 1 SECONDS)

	else if(organ_slot == ORGAN_SLOT_HEART)
		to_chat(limb.owner, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Источник питания отключён!"))
		if(limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
			limb.owner.set_stat(DEAD)
			to_chat(limb.owner, span_notice("Ваши системы полностью отключены, но сознание сохранено в позитронном ядре..."))
		else
			limb.owner.death()

	else if(organ_slot == ORGAN_SLOT_LUNGS)
		to_chat(limb.owner, span_danger("ПРЕДУПРЕЖДЕНИЕ: Система охлаждения отключена!"))

/datum/surgery_operation/limb/ipc_organ_manipulation/proc/on_success_insert(obj/item/bodypart/limb, mob/living/surgeon, obj/item/organ/organ)
	if(!limb || !surgeon || !organ || !limb.owner)
		return

	var/was_dead = (limb.owner.stat == DEAD)

	if(organ.loc != surgeon)
		to_chat(surgeon, span_warning("[organ] больше не у вас в руках!"))
		return

	surgeon.temporarilyRemoveItemFromInventory(organ, TRUE)

	if(!organ)
		return

	organ.Insert(limb.owner)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно установили [organ.name] в [limb.owner]."),
		span_notice("[surgeon] установил [organ.name] в [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Новый компонент подключён."))
	do_sparks(4, TRUE, limb.owner)

	if(was_dead)
		var/has_brain = limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN)
		var/has_heart = limb.owner.get_organ_slot(ORGAN_SLOT_HEART)

		if(has_brain && has_heart)
			limb.owner.set_stat(CONSCIOUS)
			limb.owner.SetUnconscious(0, FALSE)
			limb.owner.losebreath = 0
			limb.owner.failed_last_breath = FALSE
			limb.owner.update_damage_hud()
			limb.owner.updatehealth()
			limb.owner.reload_fullscreen()

			to_chat(limb.owner, span_boldnotice("СИСТЕМЫ ВОССТАНОВЛЕНЫ: Питание возобновлено!"))

// ============================================
// 5. МАНИПУЛЯЦИИ С СЕНСОРАМИ ГОЛОВЫ
// ============================================

/datum/surgery_operation/limb/ipc_head_manipulation
	name = "Манипуляции с сенсорами головы"
	desc = "Установка или извлечение сенсоров головы IPC (глаза, уши, речь)."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC | OPERATION_NOTABLE
	time = 2.4 SECONDS
	preop_sound = 'sound/items/electronic_assembly_empty.ogg'
	success_sound = 'sound/items/deconstruct.ogg'

/datum/surgery_operation/limb/ipc_head_manipulation/New()
	. = ..()
	implements = list(
		/obj/item/organ = 1,
		/obj/item/multitool = 1
	)

/datum/surgery_operation/limb/ipc_head_manipulation/proc/is_ipc_head_organ(obj/item/organ/organ)
	return istype(organ, /obj/item/organ/eyes/robotic/ipc) || \
		   istype(organ, /obj/item/organ/ears/robot/ipc) || \
		   istype(organ, /obj/item/organ/tongue/robot/ipc)

/datum/surgery_operation/limb/ipc_head_manipulation/proc/get_removable_organs(obj/item/bodypart/limb)
	if(!limb.owner)
		return list()

	var/list/removable = list()
	for(var/slot in list(ORGAN_SLOT_EYES, ORGAN_SLOT_EARS, ORGAN_SLOT_TONGUE))
		var/obj/item/organ/organ = limb.owner.get_organ_slot(slot)
		if(organ && is_ipc_head_organ(organ))
			removable += organ

	return removable

/datum/surgery_operation/limb/ipc_head_manipulation/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!limb?.owner?.dna?.species)
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	if(limb.body_zone != BODY_ZONE_HEAD)
		return FALSE

	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel || panel.panel_state != IPC_ELECTRONICS_PREPARED)
		return FALSE

	if(isorgan(tool))
		var/obj/item/organ/organ = tool
		if(!is_ipc_head_organ(organ))
			return FALSE
		if(organ.slot && limb.owner.get_organ_slot(organ.slot))
			return FALSE
		return TRUE

	if(istype(tool, /obj/item/multitool))
		return length(get_removable_organs(limb)) > 0

	return FALSE

/datum/surgery_operation/limb/ipc_head_manipulation/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	if(isorgan(tool))
		var/obj/item/organ/organ = tool
		var/datum/radial_menu_choice/option = new()
		option.image = image(icon = organ.icon, icon_state = organ.icon_state)
		option.name = "Установить [organ.name]"
		option.info = "Установить [organ.name] в [limb.owner]."
		return list(option = list(OPERATION_ACTION = "insert"))

	var/list/options = list()
	for(var/obj/item/organ/organ as anything in get_removable_organs(limb))
		var/datum/radial_menu_choice/option = new()
		option.image = image(icon = organ.icon, icon_state = organ.icon_state)
		option.name = "Извлечь [organ.name]"
		option.info = "Извлечь [organ.name] из [limb.owner]."
		options[option] = list(OPERATION_ACTION = "remove", IPC_SELECTED_ORGAN = organ)

	return options

/datum/surgery_operation/limb/ipc_head_manipulation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(operation_args[OPERATION_ACTION] == "remove")
		var/obj/item/organ/organ = operation_args[IPC_SELECTED_ORGAN]
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы начинаете извлекать [organ.name] из головы [limb.owner]..."),
			span_notice("[surgeon] начинает извлекать сенсор из головы [limb.owner]."),
			span_notice("[surgeon] начинает работать с [limb.owner].")
		)
	else
		var/obj/item/organ/organ = tool
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы начинаете устанавливать [organ.name] в голову [limb.owner]..."),
			span_notice("[surgeon] начинает устанавливать сенсор в голову [limb.owner]."),
			span_notice("[surgeon] начинает работать с [limb.owner].")
		)

/datum/surgery_operation/limb/ipc_head_manipulation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(operation_args[OPERATION_ACTION] == "remove")
		var/obj/item/organ/organ = operation_args[IPC_SELECTED_ORGAN]
		var/organ_name = organ.name
		var/organ_slot = organ.slot

		organ.Remove(limb.owner)
		organ.forceMove(limb.owner.drop_location())

		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы успешно извлекли [organ_name] из [limb.owner]."),
			span_notice("[surgeon] извлёк [organ_name] из [limb.owner]."),
			span_notice("[surgeon] закончил работу с [limb.owner].")
		)
		do_sparks(3, TRUE, limb.owner)

		switch(organ_slot)
			if(ORGAN_SLOT_EYES)
				to_chat(limb.owner, span_danger("ОШИБКА: Оптические сенсоры отключены!"))
			if(ORGAN_SLOT_EARS)
				to_chat(limb.owner, span_danger("ОШИБКА: Аудио сенсоры отключены!"))
			if(ORGAN_SLOT_TONGUE)
				to_chat(limb.owner, span_danger("ОШИБКА: Голосовой синтезатор отключён!"))

	else
		var/obj/item/organ/organ = tool
		var/organ_slot = organ.slot

		surgeon.temporarilyRemoveItemFromInventory(organ, TRUE)
		organ.Insert(limb.owner)

		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы успешно установили [organ.name] в голову [limb.owner]."),
			span_notice("[surgeon] установил [organ.name] в голову [limb.owner]."),
			span_notice("[surgeon] закончил работу с [limb.owner].")
		)
		to_chat(limb.owner, span_notice("Системная диагностика: Новый сенсор подключён."))
		do_sparks(4, TRUE, limb.owner)

		switch(organ_slot)
			if(ORGAN_SLOT_EYES)
				to_chat(limb.owner, span_notice("Оптические сенсоры активированы!"))
			if(ORGAN_SLOT_EARS)
				to_chat(limb.owner, span_notice("Аудио сенсоры активированы!"))
				if(HAS_TRAIT(limb.owner, TRAIT_DEAF))
					REMOVE_TRAIT(limb.owner, TRAIT_DEAF, TRAIT_GENERIC)
			if(ORGAN_SLOT_TONGUE)
				to_chat(limb.owner, span_notice("Голосовой синтезатор активирован!"))

// ============================================
// 6. ОТКЛЮЧЕНИЕ И СНЯТИЕ КОНЕЧНОСТЕЙ
// ============================================

/datum/surgery_operation/limb/ipc_disconnect_limb
	name = "Отключить конечность"
	desc = "Отключите электронику конечности IPC перед снятием."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC
	time = 2 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

	implements = list(
		TOOL_MULTITOOL = 1,
		/obj/item/multitool = 1
	)


/datum/surgery_operation/limb/ipc_disconnect_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!is_ipc_compatible(limb))
		return FALSE

	if(limb.body_zone == BODY_ZONE_CHEST)
		return FALSE

	// Проверяем что конечность подключена
	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(panel && panel.is_limb_disconnected())
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_disconnect_limb/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.ensure_ipc_panel()
	panel.panel_state = IPC_LIMB_DISCONNECTED
	panel.limb_connected = FALSE

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы отключили электронику [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] отключил электронику [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_warning("ПРЕДУПРЕЖДЕНИЕ: Потеря связи с [limb.plaintext_zone]!"))
	do_sparks(2, TRUE, limb.owner)

/datum/surgery_operation/limb/ipc_detach_limb
	name = "Открутить конечность"
	desc = "Открутите конечность IPC с помощью гаечного ключа."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC | OPERATION_NOTABLE
	time = 3 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/tools/ratchet.ogg'

	implements = list(
		TOOL_WRENCH = 1,
		/obj/item/wrench = 1
	)

/datum/surgery_operation/limb/ipc_detach_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!is_ipc_compatible(limb))
		return FALSE

	if(limb.body_zone == BODY_ZONE_CHEST)
		return FALSE

	// Нужна отключенная конечность
	var/datum/component/ipc_panel/panel = limb.get_ipc_panel()
	if(!panel || !panel.is_limb_disconnected())
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_detach_limb/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы успешно открутили [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] открутил [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_warning("СИСТЕМНОЕ СООБЩЕНИЕ: Конечность отсоединена."))
	do_sparks(3, TRUE, limb.owner)

	limb.drop_limb()

// ============================================
// 1. ОТКРЫТИЕ ПАНЕЛИ НА КОНЕЧНОСТИ
// ============================================

/datum/surgery_operation/limb/ipc_open_limb_panel
	name = "Открыть панель конечности"
	desc = "Открутить панель доступа на конечности IPC для ремонта или установки имплантов."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

	implements = list(
		TOOL_SCREWDRIVER = 1,
		/obj/item/screwdriver = 1
	)

/datum/surgery_operation/limb/ipc_open_limb_panel/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!limb?.owner?.dna?.species)
		return FALSE

	// Проверяем что это IPC bodypart
	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Только руки и ноги
	if(limb.body_zone != BODY_ZONE_L_ARM && limb.body_zone != BODY_ZONE_R_ARM && \
	   limb.body_zone != BODY_ZONE_L_LEG && limb.body_zone != BODY_ZONE_R_LEG)
		return FALSE

	// Проверяем что панель закрыта
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(panel && panel.panel_state != IPC_PANEL_CLOSED)
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_open_limb_panel/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете откручивать панель на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает откручивать панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_open_limb_panel/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel)
		panel = limb.AddComponent(/datum/component/ipc_panel)

	panel.panel_state = IPC_PANEL_OPEN

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы открутили панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] открутил панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Панель [limb.plaintext_zone] открыта."))
	do_sparks(2, TRUE, limb.owner)

// ============================================
// 2. ЗАКРЫТИЕ ПАНЕЛИ НА КОНЕЧНОСТИ
// ============================================

/datum/surgery_operation/limb/ipc_close_limb_panel
	name = "Закрыть панель конечности"
	desc = "Закрутить панель доступа на конечности IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

	implements = list(
		TOOL_SCREWDRIVER = 1,
		/obj/item/screwdriver = 1
	)

/datum/surgery_operation/limb/ipc_close_limb_panel/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!limb?.owner?.dna?.species)
		return FALSE

	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Только руки и ноги
	if(limb.body_zone != BODY_ZONE_L_ARM && limb.body_zone != BODY_ZONE_R_ARM && \
	   limb.body_zone != BODY_ZONE_L_LEG && limb.body_zone != BODY_ZONE_R_LEG)
		return FALSE

	// Проверяем что панель открыта
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel || panel.panel_state != IPC_PANEL_OPEN)
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_close_limb_panel/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете закручивать панель на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает закручивать панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_close_limb_panel/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(panel)
		panel.panel_state = IPC_PANEL_CLOSED

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы закрутили панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закрутил панель на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Панель [limb.plaintext_zone] закрыта."))

// ============================================
// 3. РЕМОНТ МЕХАНИЧЕСКИХ ПОВРЕЖДЕНИЙ (СВАРКОЙ)
// ============================================

/datum/surgery_operation/limb/ipc_repair_brute
	name = "Заварить механические повреждения"
	desc = "Используйте сварку для ремонта механических повреждений конечности IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 3 SECONDS
	preop_sound = 'sound/items/tools/welder.ogg'
	success_sound = 'sound/items/tools/welder2.ogg'

	implements = list(
		TOOL_WELDER = 1,
		/obj/item/weldingtool = 1
	)

/datum/surgery_operation/limb/ipc_repair_brute/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!limb?.owner?.dna?.species)
		return FALSE

	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Нужна открытая панель
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel || panel.panel_state != IPC_PANEL_OPEN)
		return FALSE

	// Должен быть brute урон
	if(limb.brute_dam <= 0)
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_repair_brute/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете заваривать повреждения на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает заваривать повреждения на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_repair_brute/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/heal_amount = rand(15, 25)
	limb.heal_damage(heal_amount, 0)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы заварили повреждения на [limb.plaintext_zone] [limb.owner]. Восстановлено [heal_amount] HP."),
		span_notice("[surgeon] заварил повреждения на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Механические повреждения [limb.plaintext_zone] частично восстановлены."))
	do_sparks(3, TRUE, limb.owner)

// ============================================
// 4. РЕМОНТ ЭЛЕКТРИЧЕСКИХ ПОВРЕЖДЕНИЙ (КАБЕЛЕМ)
// ============================================

/datum/surgery_operation/limb/ipc_repair_burn
	name = "Починить проводку"
	desc = "Используйте кабель для ремонта электрических повреждений конечности IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 3 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/deconstruct.ogg'

	implements = list(
		/obj/item/stack/cable_coil = 1
	)

/datum/surgery_operation/limb/ipc_repair_burn/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!limb?.owner?.dna?.species)
		return FALSE

	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Нужна открытая панель
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel || panel.panel_state != IPC_PANEL_OPEN)
		return FALSE

	// Должен быть burn урон
	if(limb.burn_dam <= 0)
		return FALSE

	// Проверяем что есть кабель
	if(istype(tool, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cable = tool
		if(cable.get_amount() < 1)
			return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_repair_burn/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете чинить проводку на [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает чинить проводку на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_repair_burn/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	// Используем кабель
	if(istype(tool, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cable = tool
		cable.use(1)

	var/heal_amount = rand(10, 20)
	limb.heal_damage(0, heal_amount)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы починили проводку на [limb.plaintext_zone] [limb.owner]. Восстановлено [heal_amount] HP."),
		span_notice("[surgeon] починил проводку на [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)
	to_chat(limb.owner, span_notice("Системная диагностика: Электрические системы [limb.plaintext_zone] частично восстановлены."))
	do_sparks(3, TRUE, limb.owner)

// ============================================
// 5. УСТАНОВКА ИМПЛАНТОВ
// ============================================

/datum/surgery_operation/limb/ipc_insert_implant
	name = "Установить имплант"
	desc = "Установите имплант в конечность IPC."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC
	time = 3 SECONDS
	preop_sound = 'sound/items/deconstruct.ogg'
	success_sound = 'sound/items/deconstruct.ogg'

	implements = list(
		/obj/item/implant = 1,
		/obj/item/implantcase = 1
	)

/datum/surgery_operation/limb/ipc_insert_implant/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!limb?.owner?.dna?.species)
		return FALSE

	if(!(limb.bodytype & BODYTYPE_IPC))
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Нужна открытая панель
	var/datum/component/ipc_panel/panel = limb.GetComponent(/datum/component/ipc_panel)
	if(!panel || panel.panel_state != IPC_PANEL_OPEN)
		return FALSE

	// Проверяем что это имплант
	var/obj/item/implant/imp = null
	if(istype(tool, /obj/item/implant))
		imp = tool
	else if(istype(tool, /obj/item/implantcase))
		var/obj/item/implantcase/case = tool
		imp = case.imp

	if(!imp)
		return FALSE

	// Имплант валиден для установки
	return TRUE

/datum/surgery_operation/limb/ipc_insert_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/implant_name = "имплант"
	if(istype(tool, /obj/item/implant))
		implant_name = tool.name
	else if(istype(tool, /obj/item/implantcase))
		var/obj/item/implantcase/case = tool
		if(case.imp)
			implant_name = case.imp.name

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете устанавливать [implant_name] в [limb.plaintext_zone] [limb.owner]..."),
		span_notice("[surgeon] начинает устанавливать имплант в [limb.plaintext_zone] [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_insert_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/implant/imp = null

	if(istype(tool, /obj/item/implant))
		imp = tool
		surgeon.temporarilyRemoveItemFromInventory(imp, TRUE)
	else if(istype(tool, /obj/item/implantcase))
		var/obj/item/implantcase/case = tool
		imp = case.imp
		if(imp)
			case.imp = null
			case.update_appearance()

	if(!imp)
		return

	if(imp.implant(limb.owner, limb.body_zone, surgeon))
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы успешно установили [imp.name] в [limb.plaintext_zone] [limb.owner]."),
			span_notice("[surgeon] установил имплант в [limb.plaintext_zone] [limb.owner]."),
			span_notice("[surgeon] закончил работу с [limb.owner].")
		)
		to_chat(limb.owner, span_notice("Системная диагностика: Новый имплант обнаружен в [limb.plaintext_zone]."))
		do_sparks(2, TRUE, limb.owner)
	else
		display_results(
			surgeon,
			limb.owner,
			span_warning("Вы не смогли установить [imp.name] в [limb.plaintext_zone] [limb.owner]."),
			span_warning("[surgeon] не смог установить имплант."),
			""
		)
		imp.forceMove(limb.owner.drop_location())

// ============================================
// СБОРКА IPC - ОПЕРАЦИИ
// ============================================

// ОПЕРАЦИЯ 1: Установка части тела на шасси
/datum/surgery_operation/limb/ipc_attach_bodypart
	name = "Присоединить часть тела"
	desc = "Присоедините часть тела к шасси IPC с помощью отвёртки."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC
	time = 3 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/deconstruct.ogg'

/datum/surgery_operation/limb/ipc_attach_bodypart/New()
	. = ..()
	implements = list(
		TOOL_SCREWDRIVER = 1,
		/obj/item/screwdriver = 1
	)

/datum/surgery_operation/limb/ipc_attach_bodypart/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	// Проверяем что пациент - это шасси в сборке (грудь на столе)
	if(!limb?.owner)
		return FALSE

	if(!istype(limb.owner.dna?.species, /datum/species/ipc))
		return FALSE

	// Проверяем что это мёртвое шасси
	if(limb.owner.stat != DEAD)
		return FALSE

	// Проверяем что это грудная клетка (основа для сборки)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_attach_bodypart/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/list/options = list()

	// Показываем какие части можно присоединить
	var/list/missing_parts = list()

	if(!limb.owner.get_bodypart(BODY_ZONE_HEAD))
		missing_parts["Присоединить голову"] = BODY_ZONE_HEAD
	if(!limb.owner.get_bodypart(BODY_ZONE_L_ARM))
		missing_parts["Присоединить левую руку"] = BODY_ZONE_L_ARM
	if(!limb.owner.get_bodypart(BODY_ZONE_R_ARM))
		missing_parts["Присоединить правую руку"] = BODY_ZONE_R_ARM
	if(!limb.owner.get_bodypart(BODY_ZONE_L_LEG))
		missing_parts["Присоединить левую ногу"] = BODY_ZONE_L_LEG
	if(!limb.owner.get_bodypart(BODY_ZONE_R_LEG))
		missing_parts["Присоединить правую ногу"] = BODY_ZONE_R_LEG

	for(var/part_name in missing_parts)
		var/datum/radial_menu_choice/option = new()
		option.name = part_name
		option.info = "Присоединить эту часть к шасси."
		options[option] = list(OPERATION_ACTION = "attach", "target_zone" = missing_parts[part_name])

	return options

/datum/surgery_operation/limb/ipc_attach_bodypart/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете присоединять часть тела к [limb.owner]..."),
		span_notice("[surgeon] начинает присоединять часть тела к [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_attach_bodypart/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/target_zone = operation_args["target_zone"]

	// Просим хирурга выбрать часть из инвентаря
	var/obj/item/bodypart/new_part = null
	for(var/obj/item/bodypart/part in surgeon.get_all_contents())
		if(part.body_zone == target_zone && (part.bodytype & BODYTYPE_IPC))
			new_part = part
			break

	if(!new_part)
		to_chat(surgeon, span_warning("У вас нет подходящей части тела!"))
		return

	surgeon.temporarilyRemoveItemFromInventory(new_part, TRUE)
	new_part.replace_limb(limb.owner, TRUE)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы присоединили [new_part.plaintext_zone] к [limb.owner]."),
		span_notice("[surgeon] присоединил часть тела к [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)

	playsound(limb.owner, 'sound/items/tools/screwdriver.ogg', 50, TRUE)
	do_sparks(2, TRUE, limb.owner)

	// Проверяем завершённость сборки
	check_ipc_assembly_completion(limb.owner)

// Проверка завершённости сборки
/proc/check_ipc_assembly_completion(mob/living/carbon/human/H)
	if(!istype(H.dna?.species, /datum/species/ipc))
		return

	if(H.stat != DEAD)
		return

	// Проверяем все части тела
	var/has_all_parts = H.get_bodypart(BODY_ZONE_HEAD) && \
						H.get_bodypart(BODY_ZONE_CHEST) && \
						H.get_bodypart(BODY_ZONE_L_ARM) && \
						H.get_bodypart(BODY_ZONE_R_ARM) && \
						H.get_bodypart(BODY_ZONE_L_LEG) && \
						H.get_bodypart(BODY_ZONE_R_LEG)

	// Проверяем критичные органы
	var/has_critical = H.get_organ_slot(ORGAN_SLOT_BRAIN) && \
					   H.get_organ_slot(ORGAN_SLOT_HEART)

	if(has_all_parts && has_critical)
		H.visible_message(
			span_boldnotice("[H] готов к активации!"),
			span_notice("Все компоненты установлены.")
		)
		do_sparks(3, TRUE, H)
		playsound(H, 'sound/machines/ping.ogg', 50, TRUE)

		// Автоматически активируем IPC
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(activate_assembled_ipc), H), 2 SECONDS)

// Активация собранного IPC
/proc/activate_assembled_ipc(mob/living/carbon/human/H)
	if(!H || H.stat != DEAD)
		return

	H.visible_message(span_boldnotice("[H] активируется!"))

	do_sparks(8, TRUE, H)
	playsound(H, 'sound/machines/chime.ogg', 50, TRUE)

	// Оживляем
	H.revive(HEAL_ALL)
	H.set_resting(FALSE, silent = TRUE)

	// Устанавливаем имя
	H.name = "IPC-[rand(1000, 9999)]"
	H.real_name = H.name

	to_chat(H, span_boldnotice("СИСТЕМЫ ЗАГРУЖЕНЫ. Добро пожаловать в мир!"))

// ============================================
// ОПЕРАЦИЯ: СМЕНА ТИПА ШАССИ (МУЖСКОЙ/ЖЕНСКИЙ)
// ============================================

/datum/surgery_operation/limb/ipc_change_chassis_type
	name = "Изменить тип корпуса"
	desc = "Измените конфигурацию шасси IPC (мужской/женский корпус)."
	required_bodytype = BODYTYPE_IPC
	operation_flags = OPERATION_MECHANIC
	time = 2 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/tools/ratchet.ogg'

	implements = list(
		TOOL_WRENCH = 1,
		/obj/item/wrench = 1
	)

/datum/surgery_operation/limb/ipc_change_chassis_type/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	// Проверяем что пациент - IPC
	if(!limb?.owner?.dna?.species)
		return FALSE

	if(!istype(limb.owner.dna.species, /datum/species/ipc))
		return FALSE

	// Проверяем что это мёртвое шасси в сборке
	if(limb.owner.stat != DEAD)
		return FALSE

	// Только для грудной клетки
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE

	// Проверяем что нет других частей кроме груди (пустое шасси)
	if(limb.owner.get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	if(limb.owner.get_bodypart(BODY_ZONE_L_ARM))
		return FALSE
	if(limb.owner.get_bodypart(BODY_ZONE_R_ARM))
		return FALSE
	if(limb.owner.get_bodypart(BODY_ZONE_L_LEG))
		return FALSE
	if(limb.owner.get_bodypart(BODY_ZONE_R_LEG))
		return FALSE

	// Проверяем что нет органов
	if(limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return FALSE
	if(limb.owner.get_organ_slot(ORGAN_SLOT_HEART))
		return FALSE

	return TRUE

/datum/surgery_operation/limb/ipc_change_chassis_type/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/list/options = list()

	// Мужской корпус
	var/datum/radial_menu_choice/male = new()
	male.image = image(icon = 'icons/mob/human/bodyparts_greyscale.dmi', icon_state = "human_chest_m")
	male.name = "Мужской корпус"
	male.info = "Установить мужскую конфигурацию шасси."
	options[male] = list(OPERATION_ACTION = "change_gender", "new_gender" = MALE)

	// Женский корпус
	var/datum/radial_menu_choice/female = new()
	female.image = image(icon = 'icons/mob/human/bodyparts_greyscale.dmi', icon_state = "human_chest_f")
	female.name = "Женский корпус"
	female.info = "Установить женскую конфигурацию шасси."
	options[female] = list(OPERATION_ACTION = "change_gender", "new_gender" = FEMALE)

	return options

/datum/surgery_operation/limb/ipc_change_chassis_type/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/new_gender = operation_args["new_gender"]
	var/gender_name = (new_gender == MALE) ? "мужской" : "женский"

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете настраивать шасси на [gender_name] корпус..."),
		span_notice("[surgeon] начинает настраивать конфигурацию шасси [limb.owner]."),
		span_notice("[surgeon] начинает работать с [limb.owner].")
	)

/datum/surgery_operation/limb/ipc_change_chassis_type/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/new_gender = operation_args["new_gender"]
	var/gender_name = (new_gender == MALE) ? "мужской" : "женский"

	// Проверяем что шасси всё ещё пустое
	if(limb.owner.get_bodypart(BODY_ZONE_HEAD) || limb.owner.get_bodypart(BODY_ZONE_L_ARM))
		to_chat(surgeon, span_warning("Нельзя менять тип корпуса после начала сборки!"))
		return

	// Меняем пол
	limb.owner.gender = new_gender

	// Меняем спрайт грудной клетки
	var/obj/item/bodypart/chest/ipc/torso = limb
	if(torso)
		if(new_gender == MALE)
			torso.icon_state = "ipc_chest_m"
		else
			torso.icon_state = "ipc_chest_f"

		// Обновляем внешность
		torso.update_appearance()
		limb.owner.update_body()
		limb.owner.update_body_parts()

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы настроили шасси на [gender_name] корпус."),
		span_notice("[surgeon] настроил конфигурацию шасси [limb.owner]."),
		span_notice("[surgeon] закончил работу с [limb.owner].")
	)

	playsound(limb.owner, 'sound/items/tools/ratchet.ogg', 50, TRUE)
	do_sparks(2, TRUE, limb.owner)

#undef IPC_SELECTED_ORGAN
#undef IPC_PANEL_CLOSED
#undef IPC_PANEL_OPEN
#undef IPC_ELECTRONICS_PREPARED
#undef IPC_LIMB_DISCONNECTED
