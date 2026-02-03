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

