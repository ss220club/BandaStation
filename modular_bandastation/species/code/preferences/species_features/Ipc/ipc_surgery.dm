
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

	// Проверяем что это синтетическая часть с флагом
	if(!(limb.bodypart_flags))
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

	// Проверяем флаг синтетической части
	if(!(limb.bodypart_flags ))
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

	if(!(limb.bodypart_flags ))
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

	if(!(limb.bodypart_flags ))
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

	if(!(limb.bodypart_flags ))
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

	if(!(limb.bodypart_flags))
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

#undef IPC_PANEL_CLOSED
#undef IPC_PANEL_OPEN
#undef IPC_ELECTRONICS_PREPARED
#undef IPC_LIMB_DISCONNECTED
