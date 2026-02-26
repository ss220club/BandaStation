// ============================================
// СИСТЕМА ПРОИЗВОДСТВА IPC ЧЕРЕЗ ФАБРИКАТОР
// ============================================

// Создаём отдельную категорию для IPC
#define RND_CATEGORY_MECHFAB_IPC "IPC Parts"

// ============================================
// ДИЗАЙНЫ ДЛЯ ФАБРИКАТОРА
// ============================================

// 1. ДЕПЛОЕР ШАССИ
/datum/design/ipc_chassis
	name = "IPC Chassis Frame"
	desc = "Пустой корпус IPC. Разверните его, затем ПКМ на шасси чтобы выбрать мужской или женский корпус."
	id = "ipc_chassis"
	build_type = MECHFAB
	build_path = /obj/item/ipc_chassis_deployer
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
	)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 2. ГОЛОВА
/datum/design/ipc_head
	name = "IPC Head"
	desc = "Голова IPC с креплениями для оптических и аудио сенсоров."
	id = "ipc_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
	)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
// ============================================
// ПРЕДМЕТ-ДЕПЛОЕР: РАЗВОРАЧИВАЕТ ШАССИ
// ============================================


/obj/item/ipc_chassis_deployer
	name = "IPC chassis deployment kit"
	desc = "Компактный набор для развёртывания шасси IPC. Используйте в руке или положите на стол."
	icon = 'icons/bandastation/mob/species/ipc/bodyparts.dmi'
	icon_state = "ipc_chest_m"  // По умолчанию мужской
	w_class = WEIGHT_CLASS_BULKY

	var/chassis_gender = MALE  // Какой корпус будет развёрнут

// Вариант для женского корпуса
/obj/item/ipc_chassis_deployer/female
	name = "IPC chassis deployment kit (female)"
	icon_state = "ipc_chest_f"
	chassis_gender = FEMALE

/obj/item/ipc_chassis_deployer/examine(mob/user)
	. = ..()
	. += span_notice("Используйте в руке или положите на стол/пол чтобы развернуть шасси.")
	. += span_notice("После развёртывания используйте ПКМ на шасси для выбора типа корпуса.")

/obj/item/ipc_chassis_deployer/attack_self(mob/user)
	to_chat(user, span_notice("Вы начинаете разворачивать IPC шасси..."))

	if(!do_after(user, 3 SECONDS, target = user))
		return

	deploy_chassis(get_turf(user))

/obj/item/ipc_chassis_deployer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag)
		return

	// Можно положить на пол/стол
	if(isturf(target) || istype(target, /obj/structure/table))
		to_chat(user, span_notice("Вы начинаете разворачивать IPC шасси..."))

		if(!do_after(user, 3 SECONDS, target = target))
			return

		var/turf/deploy_turf = get_turf(target)
		deploy_chassis(deploy_turf)

/obj/item/ipc_chassis_deployer/proc/deploy_chassis(turf/location)

	var/mob/living/carbon/human/chassis = new(location)
	chassis.set_species(/datum/species/ipc)

	// Устанавливаем пол из деплоера
	chassis.gender = chassis_gender

	// Удаляем ВСЕ конечности кроме груди
	remove_limb(chassis, BODY_ZONE_HEAD)
	remove_limb(chassis, BODY_ZONE_L_ARM)
	remove_limb(chassis, BODY_ZONE_R_ARM)
	remove_limb(chassis, BODY_ZONE_L_LEG)
	remove_limb(chassis, BODY_ZONE_R_LEG)

	// Удаляем ВСЕ органы
	remove_all_organs(chassis)

	// "Убиваем" шасси чтобы было неподвижным
	chassis.death(FALSE)
	chassis.set_resting(TRUE, silent = TRUE)

	// Устанавливаем имя
	chassis.name = "IPC assembly"
	chassis.real_name = "IPC assembly"

	// Мужской корпус по умолчанию
	chassis.gender = MALE

	playsound(location, 'sound/items/tools/ratchet.ogg', 50, TRUE)
	do_sparks(3, TRUE, chassis)

	visible_message(span_notice("IPC шасси развёрнуто и готово к сборке!"))

	// Удаляем деплоер
	qdel(src)

/obj/item/ipc_chassis_deployer/proc/remove_limb(mob/living/carbon/human/H, zone)
	var/obj/item/bodypart/part = H.get_bodypart(zone)
	if(part)
		part.drop_limb()
		qdel(part)

/obj/item/ipc_chassis_deployer/proc/remove_all_organs(mob/living/carbon/human/H)
	for(var/obj/item/organ/O in H.organs)
		O.Remove(H)
		qdel(O)
// ============================================
// СМЕНА ПОЛА ШАССИ ЧЕРЕЗ ПКМ
// ============================================

/mob/living/carbon/human/proc/is_empty_ipc_chassis()
	if(!istype(dna?.species, /datum/species/ipc))
		return FALSE

	if(stat != DEAD)
		return FALSE

	if(name != "IPC assembly" && real_name != "IPC assembly")
		return FALSE

	// Проверяем что нет никаких конечностей кроме груди
	if(get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	if(get_bodypart(BODY_ZONE_L_ARM))
		return FALSE
	if(get_bodypart(BODY_ZONE_R_ARM))
		return FALSE
	if(get_bodypart(BODY_ZONE_L_LEG))
		return FALSE
	if(get_bodypart(BODY_ZONE_R_LEG))
		return FALSE

	// Проверяем что нет органов
	if(get_organ_slot(ORGAN_SLOT_BRAIN))
		return FALSE
	if(get_organ_slot(ORGAN_SLOT_HEART))
		return FALSE

	return TRUE

// Добавляем context menu
/mob/living/carbon/human/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(is_empty_ipc_chassis())
		context[SCREENTIP_CONTEXT_RMB] = "Выбрать тип корпуса"
		return CONTEXTUAL_SCREENTIP_SET

// Обрабатываем клик через attack_hand_secondary
/mob/living/carbon/human/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()

	if(is_empty_ipc_chassis())
		change_ipc_chassis_gender(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/mob/living/carbon/human/proc/change_ipc_chassis_gender(mob/user)
	if(!Adjacent(user))
		return

	var/list/options = list(
		"Мужской корпус" = MALE,
		"Женский корпус" = FEMALE
	)

	var/choice = tgui_input_list(user, "Выберите тип корпуса для шасси:", "Тип шасси IPC", options)

	if(!choice)
		return

	if(!is_empty_ipc_chassis())
		to_chat(user, span_warning("Нельзя менять тип корпуса после начала сборки!"))
		return

	var/new_gender = options[choice]

	if(gender == new_gender)
		to_chat(user, span_notice("Шасси уже имеет этот тип корпуса."))
		return

	gender = new_gender

	// Меняем спрайт корпуса
	var/obj/item/bodypart/chest/ipc/torso = get_bodypart(BODY_ZONE_CHEST)
	if(torso)
		// ИСПРАВЛЕНО: Меняем icon_state в зависимости от пола
		if(new_gender == MALE)
			torso.icon_state = "ipc_chest_m"
		else
			torso.icon_state = "ipc_chest_f"

		// Обновляем внешность
		torso.update_appearance()
		update_body()
		update_body_parts()

	user.visible_message(
		span_notice("[user] настраивает конфигурацию шасси [src]."),
		span_notice("Вы изменили тип корпуса на [choice].")
	)

	playsound(src, 'sound/items/tools/ratchet.ogg', 50, TRUE)

// 3. ЛЕВАЯ РУКА
/datum/design/ipc_l_arm
	name = "IPC Left Arm"
	desc = "Левая рука IPC с манипуляторами."
	id = "ipc_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 4. ПРАВАЯ РУКА
/datum/design/ipc_r_arm
	name = "IPC Right Arm"
	desc = "Правая рука IPC с манипуляторами."
	id = "ipc_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 5. ЛЕВАЯ НОГА
/datum/design/ipc_l_leg
	name = "IPC Left Leg"
	desc = "Левая нога IPC с сервоприводами."
	id = "ipc_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 6. ПРАВАЯ НОГА
/datum/design/ipc_r_leg
	name = "IPC Right Leg"
	desc = "Правая нога IPC с сервоприводами."
	id = "ipc_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// ============================================
// ДИЗАЙНЫ ОРГАНОВ
// ============================================

/// 7. ПОЗИТРОННЫЙ МОЗГ
/datum/design/ipc_brain
	name = "Positronic Brain"
	desc = "Позитронное ядро для IPC. Требует активации игроком."
	id = "ipc_brain"
	build_type = MECHFAB
	build_path = /obj/item/organ/brain/positronic
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 10 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

// 8. БАТАРЕЯ
/datum/design/ipc_battery
	name = "IPC Power Cell"
	desc = "Высокоемкая батарея для питания IPC."
	id = "ipc_battery"
	build_type = MECHFAB
	build_path = /obj/item/organ/heart/ipc_battery
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 9. СИСТЕМА ОХЛАЖДЕНИЯ
/datum/design/ipc_cooling
	name = "IPC Cooling System"
	desc = "Система охлаждения для регулирования температуры IPC."
	id = "ipc_cooling"
	build_type = MECHFAB
	build_path = /obj/item/organ/lungs/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 10. ОПТИЧЕСКИЕ СЕНСОРЫ
/datum/design/ipc_eyes
	name = "IPC Optical Sensors"
	desc = "Оптические сенсоры для зрения IPC."
	id = "ipc_eyes"
	build_type = MECHFAB
	build_path = /obj/item/organ/eyes/robotic/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
	)
	construction_time = 4 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 11. АУДИО СЕНСОРЫ
/datum/design/ipc_ears
	name = "IPC Audio Sensors"
	desc = "Аудио сенсоры для слуха IPC."
	id = "ipc_ears"
	build_type = MECHFAB
	build_path = /obj/item/organ/ears/robot/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 4 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// 12. ГОЛОСОВОЙ СИНТЕЗАТОР
/datum/design/ipc_tongue
	name = "IPC Vocal Synthesizer"
	desc = "Голосовой синтезатор для речи IPC."
	id = "ipc_tongue"
	build_type = MECHFAB
	build_path = /obj/item/organ/tongue/robot/ipc
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 4 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// ============================================
// РЕГИСТРАЦИЯ В ТЕХНОЛОГИЯХ (techweb)
// ============================================

/datum/techweb_node/ipc_construction
	id = "ipc_construction"
	display_name = "IPC Construction"
	description = "Технологии для создания и сборки синтетических организмов IPC."
	prereq_ids = list("robotics")
	design_ids = list(
		"ipc_chassis",
		"ipc_head",
		"ipc_l_arm",
		"ipc_r_arm",
		"ipc_l_leg",
		"ipc_r_leg",
		"ipc_brain",
		"ipc_battery",
		"ipc_cooling",
		"ipc_eyes",
		"ipc_ears",
		"ipc_tongue",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 100)

// ============================================
// ДИЗАЙНЫ УТИЛИТАРНЫХ ИМПЛАНТОВ IPC
// ============================================

/// Кейс с имплантом магнитных суставов
/datum/design/ipc_implant_magnetic_joints
	name = "IPC Magnetic Joints Implant Case"
	desc = "Имплант магнитных суставов для конечностей IPC. Позволяет быстро прикрепить оторванную конечность без хирургии."
	id = "ipc_implant_magnetic_joints"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/magnetic_joints
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL

/// Кейс с имплантом герметичных суставов
/datum/design/ipc_implant_sealed_joints
	name = "IPC Sealed Joints Implant Case"
	desc = "Имплант укреплённых суставов IPC. Предотвращает отрывание конечности без хирургии."
	id = "ipc_implant_sealed_joints"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/sealed_joints
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL

/// Кейс с имплантом реактивного ремонта
/datum/design/ipc_implant_reactive_repair
	name = "IPC Reactive Repair Implant Case"
	desc = "Имплант автоматического ремонта для IPC. Медленно лечит повреждения за счёт заряда батареи."
	id = "ipc_implant_reactive_repair"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/reactive_repair
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL

/// Кейс с имплантом EMP-протектора (универсальный)
/datum/design/ipc_implant_emp_protector
	name = "EMP-Protector Implant Case"
	desc = "Имплант защиты от ЭМИ. Для IPC нагревает процессор при блокировке, для органиков — прижигает ткань."
	id = "ipc_implant_emp_protector"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/emp_protector
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с имплантом магнитных ног
/datum/design/ipc_implant_magnetic_leg
	name = "IPC Magnetic Leg Implant Case"
	desc = "Встроенные магнитные ботинки для ног IPC. Позволяют удерживаться на металлических поверхностях в невесомости."
	id = "ipc_implant_magnetic_leg"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/magnetic_leg
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с имплантом био-генератора
/datum/design/ipc_implant_bio_generator
	name = "IPC Bio-Generator Implant Case"
	desc = "Имплант, позволяющий IPC переваривать органическую пищу и конвертировать её в заряд батареи."
	id = "ipc_implant_bio_generator"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/bio_generator
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL

/// Кейс импланта термостабилизатора
/datum/design/ipc_implant_cooling_system
	name = "IPC Thermal Stabilizer Implant Case"
	desc = "Улучшенная система охлаждения для IPC. Обеспечивает постоянное пассивное охлаждение процессора."
	id = "ipc_implant_cooling_system"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc_cooling_system
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

// ============================================
// ДИЗАЙНЫ ОХЛАДИТЕЛЬНЫХ ПРЕДМЕТОВ
// ============================================

/// Термопаста для IPC
/datum/design/ipc_thermalpaste
	name = "IPC Thermal Paste Applicator"
	desc = "Специализированная термопаста для снижения температуры процессора IPC. Одноразовая."
	id = "ipc_thermalpaste"
	build_type = PROTOLATHE
	build_path = /obj/item/ipc_thermalpaste
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 3 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL

/// Портативный охладительный блок
/datum/design/ipc_coolingblock
	name = "IPC Portable Cooling Block"
	desc = "Высокотехнологичное устройство активного охлаждения для IPC. Несколько зарядов."
	id = "ipc_coolingblock"
	build_type = PROTOLATHE
	build_path = /obj/item/ipc_coolingblock
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_MEDICAL

// ============================================
// ДИЗАЙНЫ БОЕВЫХ ИМПЛАНТОВ IPC
// ============================================

/// Кейс с имплантом моновайера
/datum/design/ipc_implant_arm_razor
	name = "IPC Arm Razor Implant Case"
	desc = "Моноволоконная струна, встраиваемая в предплечье. Высокий шанс отсечения конечностей."
	id = "ipc_implant_arm_razor"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/arm_razor
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 10 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с имплантом лезвий богомола (правая рука)
/datum/design/ipc_implant_mantis_r
	name = "IPC Mantis Blade Implant Case (Right)"
	desc = "Выдвижные лезвия богомола для правой руки IPC. При парной установке даёт прыжок-атаку."
	id = "ipc_implant_mantis_r"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/mantis_right
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 10 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с имплантом лезвий богомола (левая рука)
/datum/design/ipc_implant_mantis_l
	name = "IPC Mantis Blade Implant Case (Left)"
	desc = "Выдвижные лезвия богомола для левой руки IPC. При парной установке даёт прыжок-атаку."
	id = "ipc_implant_mantis_l"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/mantis_left
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 10 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с имплантом руки-дробовика
/datum/design/ipc_implant_arm_cannon
	name = "IPC Arm Cannon Implant Case"
	desc = "Встроенный дробовик в предплечье IPC. Заряжается охотничьей дробью."
	id = "ipc_implant_arm_cannon"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/arm_cannon
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 12 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

// ============================================
// ДИЗАЙНЫ ВОЕННЫХ ИМПЛАНТОВ IPC (секретные)
// ============================================

/// Кейс с военными лезвиями богомола (правая)
/datum/design/ipc_implant_military_mantis_r
	name = "IPC Military Mantis Blade Case (Right)"
	desc = "Усиленные военные лезвия богомола для правой руки IPC. Наносят значительно больше урона и яда."
	id = "ipc_implant_military_mantis_r"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/military_mantis_right
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 15 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с военными лезвиями богомола (левая)
/datum/design/ipc_implant_military_mantis_l
	name = "IPC Military Mantis Blade Case (Left)"
	desc = "Усиленные военные лезвия богомола для левой руки IPC."
	id = "ipc_implant_military_mantis_l"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/military_mantis_left
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 1,
	)
	construction_time = 15 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// Кейс с сандевистаном
/datum/design/ipc_implant_sandevistan
	name = "IPC Sandevistan Implant Case"
	desc = "Адреналиновый ускоритель реакций для IPC. Временно многократно ускоряет действия."
	id = "ipc_implant_sandevistan"
	build_type = PROTOLATHE
	build_path = /obj/item/implantcase/ipc/sandevistan
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
	)
	construction_time = 15 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

// ============================================
// ВЕТКИ ИССЛЕДОВАНИЙ
// ============================================

/// Базовые утилитарные импланты IPC
/datum/techweb_node/ipc_implants_basic
	id = "ipc_implants_basic"
	display_name = "IPC Utility Implants"
	description = "Базовые импланты для улучшения функциональности IPC: защита суставов, авторемонт, охлаждение, магнитные ботинки."
	prereq_ids = list("ipc_construction")
	design_ids = list(
		"ipc_implant_magnetic_joints",
		"ipc_implant_sealed_joints",
		"ipc_implant_reactive_repair",
		"ipc_implant_emp_protector",
		"ipc_implant_magnetic_leg",
		"ipc_implant_bio_generator",
		"ipc_implant_cooling_system",
		"ipc_thermalpaste",
		"ipc_coolingblock",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 200)

/// Боевые импланты IPC
/datum/techweb_node/ipc_implants_combat
	id = "ipc_implants_combat"
	display_name = "IPC Combat Implants"
	description = "Боевые импланты для IPC: моновайер, лезвия богомола, встроенное оружие."
	prereq_ids = list("ipc_implants_basic", TECHWEB_NODE_COMBAT_IMPLANTS)
	design_ids = list(
		"ipc_implant_arm_razor",
		"ipc_implant_mantis_r",
		"ipc_implant_mantis_l",
		"ipc_implant_arm_cannon",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 400)

/// Военные импланты IPC (высокий уровень)
/datum/techweb_node/ipc_implants_military
	id = "ipc_implants_military"
	display_name = "IPC Military Implants"
	description = "Военные модификации для IPC высшего класса: сандевистан, усиленные лезвия богомола."
	prereq_ids = list("ipc_implants_combat", TECHWEB_NODE_EXP_TOOLS)
	design_ids = list(
		"ipc_implant_military_mantis_r",
		"ipc_implant_military_mantis_l",
		"ipc_implant_sandevistan",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 600)

// ============================================
// БРЕНДИРОВАННЫЕ BODYPART: ДИЗАЙНЫ ДЛЯ MECHFAB
// ============================================
// 9 брендов × 6 частей = 54 дизайна
// Материалы: немного дороже обычных деталей IPC
// ============================================

// — MORPHEUS CYBERKINETICS —

/datum/design/ipc_morpheus_chest
	name = "Morpheus Cyberkinetics IPC Chassis"
	desc = "Корпус IPC производства Morpheus Cyberkinetics."
	id = "ipc_morpheus_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/morpheus
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_morpheus_head
	name = "Morpheus Cyberkinetics IPC Head"
	desc = "Голова IPC производства Morpheus Cyberkinetics."
	id = "ipc_morpheus_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/morpheus
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_morpheus_l_arm
	name = "Morpheus Cyberkinetics IPC Left Arm"
	desc = "Левая рука IPC производства Morpheus Cyberkinetics."
	id = "ipc_morpheus_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/morpheus
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_morpheus_r_arm
	name = "Morpheus Cyberkinetics IPC Right Arm"
	desc = "Правая рука IPC производства Morpheus Cyberkinetics."
	id = "ipc_morpheus_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/morpheus
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_morpheus_l_leg
	name = "Morpheus Cyberkinetics IPC Left Leg"
	desc = "Левая нога IPC производства Morpheus Cyberkinetics."
	id = "ipc_morpheus_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/morpheus
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_morpheus_r_leg
	name = "Morpheus Cyberkinetics IPC Right Leg"
	desc = "Правая нога IPC производства Morpheus Cyberkinetics."
	id = "ipc_morpheus_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/morpheus
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — ETAMIN INDUSTRY —

/datum/design/ipc_etamin_chest
	name = "Etamin Industry IPC Chassis"
	desc = "Корпус IPC производства Etamin Industry."
	id = "ipc_etamin_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/etamin
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_etamin_head
	name = "Etamin Industry IPC Head"
	desc = "Голова IPC производства Etamin Industry."
	id = "ipc_etamin_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/etamin
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_etamin_l_arm
	name = "Etamin Industry IPC Left Arm"
	desc = "Левая рука IPC производства Etamin Industry."
	id = "ipc_etamin_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/etamin
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_etamin_r_arm
	name = "Etamin Industry IPC Right Arm"
	desc = "Правая рука IPC производства Etamin Industry."
	id = "ipc_etamin_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/etamin
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_etamin_l_leg
	name = "Etamin Industry IPC Left Leg"
	desc = "Левая нога IPC производства Etamin Industry."
	id = "ipc_etamin_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/etamin
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_etamin_r_leg
	name = "Etamin Industry IPC Right Leg"
	desc = "Правая нога IPC производства Etamin Industry."
	id = "ipc_etamin_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/etamin
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — BISHOP CYBERNETICS —

/datum/design/ipc_bishop_chest
	name = "Bishop Cybernetics IPC Chassis"
	desc = "Корпус IPC производства Bishop Cybernetics."
	id = "ipc_bishop_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/bishop
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_bishop_head
	name = "Bishop Cybernetics IPC Head"
	desc = "Голова IPC производства Bishop Cybernetics."
	id = "ipc_bishop_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/bishop
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_bishop_l_arm
	name = "Bishop Cybernetics IPC Left Arm"
	desc = "Левая рука IPC производства Bishop Cybernetics."
	id = "ipc_bishop_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/bishop
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_bishop_r_arm
	name = "Bishop Cybernetics IPC Right Arm"
	desc = "Правая рука IPC производства Bishop Cybernetics."
	id = "ipc_bishop_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/bishop
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_bishop_l_leg
	name = "Bishop Cybernetics IPC Left Leg"
	desc = "Левая нога IPC производства Bishop Cybernetics."
	id = "ipc_bishop_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/bishop
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_bishop_r_leg
	name = "Bishop Cybernetics IPC Right Leg"
	desc = "Правая нога IPC производства Bishop Cybernetics."
	id = "ipc_bishop_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/bishop
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — HESPHIASTOS INDUSTRIES —

/datum/design/ipc_hesphiastos_chest
	name = "Hesphiastos Industries IPC Chassis"
	desc = "Корпус IPC производства Hesphiastos Industries."
	id = "ipc_hesphiastos_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/hesphiastos
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_hesphiastos_head
	name = "Hesphiastos Industries IPC Head"
	desc = "Голова IPC производства Hesphiastos Industries."
	id = "ipc_hesphiastos_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/hesphiastos
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_hesphiastos_l_arm
	name = "Hesphiastos Industries IPC Left Arm"
	desc = "Левая рука IPC производства Hesphiastos Industries."
	id = "ipc_hesphiastos_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/hesphiastos
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_hesphiastos_r_arm
	name = "Hesphiastos Industries IPC Right Arm"
	desc = "Правая рука IPC производства Hesphiastos Industries."
	id = "ipc_hesphiastos_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/hesphiastos
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_hesphiastos_l_leg
	name = "Hesphiastos Industries IPC Left Leg"
	desc = "Левая нога IPC производства Hesphiastos Industries."
	id = "ipc_hesphiastos_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/hesphiastos
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_hesphiastos_r_leg
	name = "Hesphiastos Industries IPC Right Leg"
	desc = "Правая нога IPC производства Hesphiastos Industries."
	id = "ipc_hesphiastos_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/hesphiastos
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — WARD-TAKAHASHI —

/datum/design/ipc_ward_chest
	name = "Ward-Takahashi IPC Chassis"
	desc = "Корпус IPC производства Ward-Takahashi."
	id = "ipc_ward_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/ward_takahashi
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_ward_head
	name = "Ward-Takahashi IPC Head"
	desc = "Голова IPC производства Ward-Takahashi."
	id = "ipc_ward_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/ward_takahashi
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_ward_l_arm
	name = "Ward-Takahashi IPC Left Arm"
	desc = "Левая рука IPC производства Ward-Takahashi."
	id = "ipc_ward_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/ward_takahashi
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_ward_r_arm
	name = "Ward-Takahashi IPC Right Arm"
	desc = "Правая рука IPC производства Ward-Takahashi."
	id = "ipc_ward_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/ward_takahashi
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_ward_l_leg
	name = "Ward-Takahashi IPC Left Leg"
	desc = "Левая нога IPC производства Ward-Takahashi."
	id = "ipc_ward_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/ward_takahashi
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_ward_r_leg
	name = "Ward-Takahashi IPC Right Leg"
	desc = "Правая нога IPC производства Ward-Takahashi."
	id = "ipc_ward_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/ward_takahashi
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — XION MANUFACTURING GROUP —

/datum/design/ipc_xion_chest
	name = "Xion Manufacturing Group IPC Chassis"
	desc = "Корпус IPC производства Xion Manufacturing Group."
	id = "ipc_xion_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/xion
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_xion_head
	name = "Xion Manufacturing Group IPC Head"
	desc = "Голова IPC производства Xion Manufacturing Group."
	id = "ipc_xion_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/xion
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_xion_l_arm
	name = "Xion Manufacturing Group IPC Left Arm"
	desc = "Левая рука IPC производства Xion Manufacturing Group."
	id = "ipc_xion_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/xion
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_xion_r_arm
	name = "Xion Manufacturing Group IPC Right Arm"
	desc = "Правая рука IPC производства Xion Manufacturing Group."
	id = "ipc_xion_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/xion
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_xion_l_leg
	name = "Xion Manufacturing Group IPC Left Leg"
	desc = "Левая нога IPC производства Xion Manufacturing Group."
	id = "ipc_xion_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/xion
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_xion_r_leg
	name = "Xion Manufacturing Group IPC Right Leg"
	desc = "Правая нога IPC производства Xion Manufacturing Group."
	id = "ipc_xion_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/xion
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — ZENG-HU PHARMACEUTICALS —

/datum/design/ipc_zenghu_chest
	name = "Zeng-Hu Pharmaceuticals IPC Chassis"
	desc = "Корпус IPC производства Zeng-Hu Pharmaceuticals."
	id = "ipc_zenghu_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/zeng_hu
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_zenghu_head
	name = "Zeng-Hu Pharmaceuticals IPC Head"
	desc = "Голова IPC производства Zeng-Hu Pharmaceuticals."
	id = "ipc_zenghu_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/zeng_hu
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_zenghu_l_arm
	name = "Zeng-Hu Pharmaceuticals IPC Left Arm"
	desc = "Левая рука IPC производства Zeng-Hu Pharmaceuticals."
	id = "ipc_zenghu_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/zeng_hu
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_zenghu_r_arm
	name = "Zeng-Hu Pharmaceuticals IPC Right Arm"
	desc = "Правая рука IPC производства Zeng-Hu Pharmaceuticals."
	id = "ipc_zenghu_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/zeng_hu
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_zenghu_l_leg
	name = "Zeng-Hu Pharmaceuticals IPC Left Leg"
	desc = "Левая нога IPC производства Zeng-Hu Pharmaceuticals."
	id = "ipc_zenghu_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/zeng_hu
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_zenghu_r_leg
	name = "Zeng-Hu Pharmaceuticals IPC Right Leg"
	desc = "Правая нога IPC производства Zeng-Hu Pharmaceuticals."
	id = "ipc_zenghu_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/zeng_hu
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — SHELLGUARD MUNITIONS —

/datum/design/ipc_shellguard_chest
	name = "Shellguard Munitions IPC Chassis"
	desc = "Корпус IPC производства Shellguard Munitions."
	id = "ipc_shellguard_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/shellguard
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 10 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_shellguard_head
	name = "Shellguard Munitions IPC Head"
	desc = "Голова IPC производства Shellguard Munitions."
	id = "ipc_shellguard_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/shellguard
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 7 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_shellguard_l_arm
	name = "Shellguard Munitions IPC Left Arm"
	desc = "Левая рука IPC производства Shellguard Munitions."
	id = "ipc_shellguard_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/shellguard
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_shellguard_r_arm
	name = "Shellguard Munitions IPC Right Arm"
	desc = "Правая рука IPC производства Shellguard Munitions."
	id = "ipc_shellguard_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/shellguard
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_shellguard_l_leg
	name = "Shellguard Munitions IPC Left Leg"
	desc = "Левая нога IPC производства Shellguard Munitions."
	id = "ipc_shellguard_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/shellguard
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_shellguard_r_leg
	name = "Shellguard Munitions IPC Right Leg"
	desc = "Правая нога IPC производства Shellguard Munitions."
	id = "ipc_shellguard_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/shellguard
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/titanium = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// — CYBERSUN INDUSTRIES —

/datum/design/ipc_cybersun_chest
	name = "Cybersun Industries IPC Chassis"
	desc = "Корпус IPC производства Cybersun Industries."
	id = "ipc_cybersun_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/ipc/cybersun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)
	construction_time = 8 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_cybersun_head
	name = "Cybersun Industries IPC Head"
	desc = "Голова IPC производства Cybersun Industries."
	id = "ipc_cybersun_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/ipc/cybersun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 6 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_cybersun_l_arm
	name = "Cybersun Industries IPC Left Arm"
	desc = "Левая рука IPC производства Cybersun Industries."
	id = "ipc_cybersun_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/ipc/cybersun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_cybersun_r_arm
	name = "Cybersun Industries IPC Right Arm"
	desc = "Правая рука IPC производства Cybersun Industries."
	id = "ipc_cybersun_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/ipc/cybersun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_cybersun_l_leg
	name = "Cybersun Industries IPC Left Leg"
	desc = "Левая нога IPC производства Cybersun Industries."
	id = "ipc_cybersun_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/ipc/cybersun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

/datum/design/ipc_cybersun_r_leg
	name = "Cybersun Industries IPC Right Leg"
	desc = "Правая нога IPC производства Cybersun Industries."
	id = "ipc_cybersun_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/ipc/cybersun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1)
	construction_time = 5 SECONDS
	category = list(RND_CATEGORY_MECHFAB_IPC)

// ============================================
// ВЕТКА ИССЛЕДОВАНИЙ: БРЕНДИРОВАННЫЕ ДЕТАЛИ
// ============================================

/// Брендированные части тела IPC (все бренды)
/datum/techweb_node/ipc_chassis_brands
	id = "ipc_chassis_brands"
	display_name = "IPC Branded Parts"
	description = "Производство брендированных частей тела IPC от ведущих корпораций: Morpheus, Etamin, Bishop, Hesphiastos, Ward-Takahashi, Xion, Zeng-Hu, Shellguard, Cybersun."
	prereq_ids = list("ipc_construction")
	design_ids = list(
		// Morpheus
		"ipc_morpheus_chest",
		"ipc_morpheus_head",
		"ipc_morpheus_l_arm",
		"ipc_morpheus_r_arm",
		"ipc_morpheus_l_leg",
		"ipc_morpheus_r_leg",
		// Etamin
		"ipc_etamin_chest",
		"ipc_etamin_head",
		"ipc_etamin_l_arm",
		"ipc_etamin_r_arm",
		"ipc_etamin_l_leg",
		"ipc_etamin_r_leg",
		// Bishop
		"ipc_bishop_chest",
		"ipc_bishop_head",
		"ipc_bishop_l_arm",
		"ipc_bishop_r_arm",
		"ipc_bishop_l_leg",
		"ipc_bishop_r_leg",
		// Hesphiastos
		"ipc_hesphiastos_chest",
		"ipc_hesphiastos_head",
		"ipc_hesphiastos_l_arm",
		"ipc_hesphiastos_r_arm",
		"ipc_hesphiastos_l_leg",
		"ipc_hesphiastos_r_leg",
		// Ward-Takahashi
		"ipc_ward_chest",
		"ipc_ward_head",
		"ipc_ward_l_arm",
		"ipc_ward_r_arm",
		"ipc_ward_l_leg",
		"ipc_ward_r_leg",
		// Xion
		"ipc_xion_chest",
		"ipc_xion_head",
		"ipc_xion_l_arm",
		"ipc_xion_r_arm",
		"ipc_xion_l_leg",
		"ipc_xion_r_leg",
		// Zeng-Hu
		"ipc_zenghu_chest",
		"ipc_zenghu_head",
		"ipc_zenghu_l_arm",
		"ipc_zenghu_r_arm",
		"ipc_zenghu_l_leg",
		"ipc_zenghu_r_leg",
		// Shellguard
		"ipc_shellguard_chest",
		"ipc_shellguard_head",
		"ipc_shellguard_l_arm",
		"ipc_shellguard_r_arm",
		"ipc_shellguard_l_leg",
		"ipc_shellguard_r_leg",
		// Cybersun
		"ipc_cybersun_chest",
		"ipc_cybersun_head",
		"ipc_cybersun_l_arm",
		"ipc_cybersun_r_arm",
		"ipc_cybersun_l_leg",
		"ipc_cybersun_r_leg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 300)

