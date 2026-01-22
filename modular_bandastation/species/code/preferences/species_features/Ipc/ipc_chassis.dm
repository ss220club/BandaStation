// ============================================
// СИСТЕМА ПРОИЗВОДСТВА IPC ЧЕРЕЗ ФАБРИКАТОР
// ============================================

// ============================================
// ДИЗАЙНЫ ДЛЯ ФАБРИКАТОРА
// ============================================

// 1. БАЗОВОЕ ШАССИ (ГРУДЬ) - МЁРТВАЯ КУКЛА
/datum/design/ipc_chassis
	name = "IPC Chassis Frame"
	desc = "Пустой корпус IPC без батареи, мозга и компонентов. Требует полной сборки на столе."
	id = "ipc_chassis"
	build_type = MECHFAB
	build_path = /obj/item/ipc_chassis_assembly
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
	)
	construction_time = 8 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

// ============================================
// ДИЗАЙНЫ ОРГАНОВ
// ============================================

// 7. ПОЗИТРОННЫЙ МОЗГ
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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)
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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

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
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)

// ============================================
// НАБОР "ВСЁ В ОДНОМ" (дорогой)
// ============================================

/datum/design/ipc_full_kit
	name = "IPC Complete Assembly Kit"
	desc = "Полный набор для сборки IPC: все части тела + все органы. ДОРОГО!"
	id = "ipc_full_kit"
	build_type = MECHFAB
	build_path = /obj/item/storage/box/ipc_assembly_kit
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 45,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 30,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
	)
	construction_time = 30 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG + "IPC Parts",
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

// ============================================
// КОРОБКА С ПОЛНЫМ НАБОРОМ
// ============================================

/obj/item/storage/box/ipc_assembly_kit
	name = "IPC assembly kit"
	desc = "Содержит все необходимые части для сборки IPC. Используйте на столе."
	icon_state = "robotics"

/obj/item/storage/box/ipc_assembly_kit/PopulateContents()
	// Шасси
	new /obj/item/ipc_chassis_assembly(src)

	// Части тела
	new /obj/item/bodypart/head/ipc(src)
	new /obj/item/bodypart/arm/left/ipc(src)
	new /obj/item/bodypart/arm/right/ipc(src)
	new /obj/item/bodypart/leg/left/ipc(src)
	new /obj/item/bodypart/leg/right/ipc(src)

	// Органы
	new /obj/item/organ/brain/positronic(src)
	new /obj/item/organ/heart/ipc_battery(src)
	new /obj/item/organ/lungs/ipc(src)
	new /obj/item/organ/eyes/robotic/ipc(src)
	new /obj/item/organ/ears/robot/ipc(src)
	new /obj/item/organ/tongue/robot/ipc(src)

// ============================================
// ПРЕДМЕТ: ПУСТОЕ ШАССИ IPC
// ============================================

/obj/item/ipc_chassis_assembly
	name = "IPC chassis frame"
	desc = "Пустой корпус IPC. Используйте на столе чтобы развернуть для сборки."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "heart-c-on"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/ipc_chassis_assembly/examine(mob/user)
	. = ..()
	. += span_notice("Используйте на <b>столе</b> или <b>операционном столе</b> чтобы развернуть шасси для сборки.")
	. += span_notice("Затем устанавливайте части тела и органы прямо на шасси.")

/obj/item/ipc_chassis_assembly/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag)
		return

	// Проверяем что это стол или операционный стол
	if(!istype(target, /obj/structure/table) && !istype(target, /obj/machinery/stasis))
		return

	// Проверяем что на столе нет других мобов
	for(var/mob/living/M in target.loc)
		to_chat(user, span_warning("На [target] уже кто-то лежит!"))
		return

	to_chat(user, span_notice("Вы начинаете разворачивать IPC шасси на [target]..."))

	if(!do_after(user, 3 SECONDS, target = target))
		return

	// Создаём мёртвую куклу
	var/mob/living/carbon/human/chassis = new(get_turf(target))
	chassis.set_species(/datum/species/ipc)

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

	user.visible_message(
		span_notice("[user] разворачивает пустое IPC шасси на [target]."),
		span_notice("Вы развернули шасси. Теперь устанавливайте части тела и органы.")
	)

	playsound(target, 'sound/items/tools/ratchet.ogg', 50, TRUE)

	qdel(src)

/obj/item/ipc_chassis_assembly/proc/remove_limb(mob/living/carbon/human/H, zone)
	var/obj/item/bodypart/part = H.get_bodypart(zone)
	if(part)
		part.drop_limb()
		qdel(part)

/obj/item/ipc_chassis_assembly/proc/remove_all_organs(mob/living/carbon/human/H)
	for(var/obj/item/organ/O in H.organs)
		O.Remove(H)
		qdel(O)

// ============================================
// СИСТЕМА СБОРКИ НА СТОЛЕ
// ============================================

/mob/living/carbon/human/attackby(obj/item/I, mob/living/user, params)
	// Проверяем что это IPC шасси в процессе сборки
	if(!istype(dna?.species, /datum/species/ipc))
		return ..()

	if(stat != DEAD)
		return ..()

	if(name != "IPC assembly" && real_name != "IPC assembly")
		return ..()

	// 1. ПРИСОЕДИНЕНИЕ ЧАСТИ ТЕЛА
	if(istype(I, /obj/item/bodypart))
		var/obj/item/bodypart/new_part = I

		// Проверяем что это IPC часть
		if(!(new_part.bodytype & BODYTYPE_IPC))
			to_chat(user, span_warning("Эта часть не подходит для IPC!"))
			return

		// Проверяем что такой части еще нет
		var/obj/item/bodypart/existing = get_bodypart(new_part.body_zone)
		if(existing)
			to_chat(user, span_warning("[src] уже имеет [existing.plaintext_zone]!"))
			return

		to_chat(user, span_notice("Вы начинаете присоединять [new_part] к [src]..."))

		if(!do_after(user, 2 SECONDS, target = src))
			return

		if(!user.transferItemToLoc(new_part, src))
			return

		// Присоединяем конечность
		new_part.replace_limb(src, TRUE)

		user.visible_message(
			span_notice("[user] присоединяет [new_part] к [src]."),
			span_notice("Вы присоединили [new_part] к [src].")
		)

		playsound(src, 'sound/items/tools/screwdriver.ogg', 50, TRUE)
		do_sparks(2, TRUE, src)

		// Проверяем готовность
		check_ipc_assembly_completion()
		return

	// 2. УСТАНОВКА ОРГАНА
	if(isorgan(I))
		var/obj/item/organ/new_organ = I

		// Проверяем что это роботический орган
		if(!(new_organ.organ_flags & ORGAN_ROBOTIC))
			to_chat(user, span_warning("Этот орган не подходит для IPC!"))
			return

		// Проверяем что корпус есть
		if(!get_bodypart(BODY_ZONE_CHEST))
			to_chat(user, span_warning("[src] не имеет корпуса!"))
			return

		// Проверяем что такого органа еще нет
		if(new_organ.slot && get_organ_slot(new_organ.slot))
			to_chat(user, span_warning("[src] уже имеет этот орган!"))
			return

		to_chat(user, span_notice("Вы начинаете устанавливать [new_organ] в [src]..."))

		if(!do_after(user, 2 SECONDS, target = src))
			return

		if(!user.transferItemToLoc(new_organ, src))
			return

		new_organ.Insert(src)

		user.visible_message(
			span_notice("[user] устанавливает [new_organ] в [src]."),
			span_notice("Вы установили [new_organ] в [src].")
		)

		playsound(src, 'sound/items/electronic_assembly_empty.ogg', 50, TRUE)

		// Проверяем готовность
		check_ipc_assembly_completion()
		return

	// 3. АКТИВАЦИЯ ОТВЁРТКОЙ
	if(istype(I, /obj/item/screwdriver))
		if(!is_ipc_assembly_complete())
			to_chat(user, span_warning("IPC не полностью собран! Проверьте examine."))
			return

		to_chat(user, span_notice("Вы начинаете активировать [src]..."))

		if(!do_after(user, 5 SECONDS, target = src))
			return

		activate_ipc_assembly(user)
		return

	return ..()

// ============================================
// ПРОВЕРКА ЗАВЕРШЁННОСТИ СБОРКИ
// ============================================

/mob/living/carbon/human/proc/is_ipc_assembly_complete()
	if(!istype(dna?.species, /datum/species/ipc))
		return FALSE

	if(stat != DEAD)
		return FALSE

	// Проверяем все части тела
	var/has_all_parts = get_bodypart(BODY_ZONE_HEAD) && \
						get_bodypart(BODY_ZONE_CHEST) && \
						get_bodypart(BODY_ZONE_L_ARM) && \
						get_bodypart(BODY_ZONE_R_ARM) && \
						get_bodypart(BODY_ZONE_L_LEG) && \
						get_bodypart(BODY_ZONE_R_LEG)

	// Проверяем критичные органы
	var/has_critical = get_organ_slot(ORGAN_SLOT_BRAIN) && \
					   get_organ_slot(ORGAN_SLOT_HEART)

	return has_all_parts && has_critical

/mob/living/carbon/human/proc/check_ipc_assembly_completion()
	if(!istype(dna?.species, /datum/species/ipc))
		return

	if(stat != DEAD)
		return

	if(name != "IPC assembly" && real_name != "IPC assembly")
		return

	if(is_ipc_assembly_complete())
		visible_message(
			span_boldnotice("[src] готов к активации!"),
			span_notice("Все компоненты установлены. Используйте отвёртку для активации.")
		)
		do_sparks(3, TRUE, src)
		playsound(src, 'sound/machines/ping.ogg', 50, TRUE)

// ============================================
// АКТИВАЦИЯ IPC
// ============================================

/mob/living/carbon/human/proc/activate_ipc_assembly(mob/user)
	if(!is_ipc_assembly_complete())
		return

	visible_message(span_boldnotice("[src] начинает активироваться!"))

	do_sparks(8, TRUE, src)
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)

	addtimer(CALLBACK(src, PROC_REF(finish_ipc_activation), user), 3 SECONDS)

/mob/living/carbon/human/proc/finish_ipc_activation(mob/user)
	// Оживляем
	revive(HEAL_ALL)
	set_resting(FALSE, silent = TRUE)

	// Устанавливаем имя
	if(name == "IPC assembly")
		name = "IPC-[rand(1000, 9999)]"
		real_name = name

	visible_message(
		span_boldnotice("[src] активирован и оживает!"),
		span_boldnotice("СИСТЕМЫ ЗАГРУЖЕНЫ. Добро пожаловать в мир!")
	)

	do_sparks(8, TRUE, src)
	playsound(src, 'sound/machines/chime.ogg', 50, TRUE)

	if(user)
		to_chat(user, span_notice("Вы успешно активировали [src]!"))

// ============================================
// EXAMINE - ПОКАЗАТЬ ПРОГРЕСС СБОРКИ
// ============================================

/mob/living/carbon/human/examine(mob/user)
	. = ..()

	if(!istype(dna?.species, /datum/species/ipc))
		return

	if(stat != DEAD)
		return

	if(name != "IPC assembly" && real_name != "IPC assembly")
		return

	. += span_notice("═══════════════════════════")
	. += span_boldnotice("ПРОГРЕСС СБОРКИ IPC:")

	// Части тела
	. += span_notice("Части тела:")
	. += "  Голова: [get_bodypart(BODY_ZONE_HEAD) ? "✓" : "✗"]"
	. += "  Левая рука: [get_bodypart(BODY_ZONE_L_ARM) ? "✓" : "✗"]"
	. += "  Правая рука: [get_bodypart(BODY_ZONE_R_ARM) ? "✓" : "✗"]"
	. += "  Левая нога: [get_bodypart(BODY_ZONE_L_LEG) ? "✓" : "✗"]"
	. += "  Правая нога: [get_bodypart(BODY_ZONE_R_LEG) ? "✓" : "✗"]"

	// Органы
	. += span_notice("Критичные органы:")
	. += "  Позитронный мозг: [get_organ_slot(ORGAN_SLOT_BRAIN) ? "✓" : "✗"]"
	. += "  Батарея: [get_organ_slot(ORGAN_SLOT_HEART) ? "✓" : "✗"]"

	. += span_notice("Дополнительные органы:")
	. += "  Охлаждение: [get_organ_slot(ORGAN_SLOT_LUNGS) ? "✓" : "✗"]"
	. += "  Глаза: [get_organ_slot(ORGAN_SLOT_EYES) ? "✓" : "✗"]"
	. += "  Уши: [get_organ_slot(ORGAN_SLOT_EARS) ? "✓" : "✗"]"
	. += "  Синтезатор: [get_organ_slot(ORGAN_SLOT_TONGUE) ? "✓" : "✗"]"

	. += span_notice("═══════════════════════════")

	if(is_ipc_assembly_complete())
		. += span_boldnotice("✓ СБОРКА ЗАВЕРШЕНА! Используйте ОТВЁРТКУ для активации.")
	else
		var/list/missing = list()

		if(!get_bodypart(BODY_ZONE_HEAD)) missing += "голова"
		if(!get_bodypart(BODY_ZONE_L_ARM)) missing += "левая рука"
		if(!get_bodypart(BODY_ZONE_R_ARM)) missing += "правая рука"
		if(!get_bodypart(BODY_ZONE_L_LEG)) missing += "левая нога"
		if(!get_bodypart(BODY_ZONE_R_LEG)) missing += "правая нога"
		if(!get_organ_slot(ORGAN_SLOT_BRAIN)) missing += "позитронный мозг"
		if(!get_organ_slot(ORGAN_SLOT_HEART)) missing += "батарея"

		. += span_warning("✗ Требуется: [english_list(missing)]")

// ============================================
// РЕГИСТРАЦИЯ В ТЕХНОЛОГИЯХ (techweb)
// ============================================

/datum/techweb_node/ipc_construction
	id = "ipc_construction"
	display_name = "IPC Construction"
	description = "Технологии для создания и сборки синтетических организмов IPC."
	prereq_ids = list("robotics")  // Базовая робототехника
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/ipc_advanced
	id = "ipc_advanced"
	display_name = "Advanced IPC Assembly"
	description = "Продвинутые методы сборки IPC - полные наборы."
	prereq_ids = list("ipc_construction")
	design_ids = list(
		"ipc_full_kit",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
