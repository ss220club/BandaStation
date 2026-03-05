// ============================================
// ИМПЛАНТЫ ДЛЯ IPC
// Устанавливаются через хирургию в конкретные части тела
// ============================================

// ============================================
// ОВЕРЛЕЙ РУКИ — DATUM
// Использует систему bodypart_overlays для
// правильного рендеринга поверх тела.
// ============================================

/datum/bodypart_overlay/ipc_implant
	layers = EXTERNAL_ADJACENT
	/// Имплант, которому принадлежит этот оверлей
	var/obj/item/implant/ipc/implant
	/// Bodypart, к которой прикреплён оверлей
	var/obj/item/bodypart/limb_ref

/datum/bodypart_overlay/ipc_implant/New(obj/item/implant/ipc/implant_ref)
	. = ..()
	src.implant = implant_ref

/datum/bodypart_overlay/ipc_implant/Destroy(force)
	var/obj/item/bodypart/saved_limb = limb_ref
	limb_ref = null
	implant = null
	if(saved_limb && !QDELETED(saved_limb))
		saved_limb.remove_bodypart_overlay(src, update = FALSE)
	return ..()

/datum/bodypart_overlay/ipc_implant/added_to_limb(obj/item/bodypart/limb)
	. = ..()
	limb_ref = limb

/datum/bodypart_overlay/ipc_implant/removed_from_limb(obj/item/bodypart/limb)
	. = ..()
	limb_ref = null

/datum/bodypart_overlay/ipc_implant/generate_icon_cache()
	. = ..()
	if(implant)
		. += implant.get_overlay_state()

/datum/bodypart_overlay/ipc_implant/get_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	if(!implant)
		return list()
	return implant.get_overlay(layer, limb)

// ============================================
// БАЗОВЫЙ КЛАСС ИМПЛАНТОВ IPC
// ============================================

// Базовый класс для IPC имплантов
/obj/item/implant/ipc
	name = "IPC implant"
	desc = "Базовый имплант для IPC."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "reactive_repair"
	w_class = WEIGHT_CLASS_TINY
	// Не даем action button по умолчанию - только нужным имплантам
	actions_types = null
	/// В какой части тела установлен
	var/installed_in_zone = null
	/// Список разрешенных зон для установки
	var/list/allowed_zones = list()
	/// Bodypart overlay datum для визуально видимых имплантов (лезвия, пушка, струна)
	var/arm_visual = null
	/// Название состояния в implants_lefthand/righthand.dmi (null = оверлей не показывается)
	var/arm_visual_state = null

/// Возвращает icon_state для bodypart overlay
/obj/item/implant/ipc/proc/get_overlay_state()
	return arm_visual_state

/// Возвращает список images для рендеринга поверх bodypart
/obj/item/implant/ipc/proc/get_overlay(image_layer, obj/item/bodypart/limb)
	. = list()
	if(!arm_visual_state || !limb)
		return
	var/dmi_file = (limb.body_zone == BODY_ZONE_L_ARM) ? \
		'modular_bandastation/MachAImpDe/icons/implants_lefthand.dmi' : \
		'modular_bandastation/MachAImpDe/icons/implants_righthand.dmi'
	var/image/overlay = image(dmi_file, icon_state = arm_visual_state, layer = image_layer)
	overlay.layer = -BODYPARTS_HIGH_LAYER
	. += overlay

/// Добавляет визуальный оверлей через bodypart overlay систему
/obj/item/implant/ipc/proc/apply_arm_visual(mob/living/carbon/human/H)
	remove_arm_visual(H)
	if(!arm_visual_state || !installed_in_zone || !(installed_in_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
		return
	var/obj/item/bodypart/limb = H.get_bodypart(installed_in_zone)
	if(!limb)
		return
	arm_visual = new /datum/bodypart_overlay/ipc_implant(src)
	limb.add_bodypart_overlay(arm_visual)

/// Убирает визуальный оверлей с руки
/obj/item/implant/ipc/proc/remove_arm_visual(mob/living/carbon/human/H)
	if(!arm_visual)
		return
	var/datum/bodypart_overlay/ipc_implant/overlay = arm_visual
	if(overlay.limb_ref)
		overlay.limb_ref.remove_bodypart_overlay(overlay)
	QDEL_NULL(arm_visual)

// Переопределяем implant() чтобы принимать body_zone
/obj/item/implant/ipc/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	if(!body_zone)
		return FALSE

	// Проверяем разрешенную зону
	if(length(allowed_zones) && !(body_zone in allowed_zones))
		if(!silent && user)
			to_chat(user, span_warning("[capitalize(src.name)] не может быть установлен в [body_zone]!"))
		return FALSE

	// Сохраняем зону установки
	installed_in_zone = body_zone

	// Вызываем стандартный implant
	. = ..(target, user, silent, force)

// ============================================
// 1. MAGNETIC JOINTS IMPLANT
// ============================================
// Позволяет прикреплять конечность обратно без хирургии

/obj/item/implant/ipc/magnetic_joints
	name = "Magnetic Joints Implant"
	desc = "Магнитные суставы для конечностей IPC. Позволяют быстро прикрепить оторванную конечность без хирургии. Устанавливается в руки или ноги."
	icon_state = "magnetic_joints"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/obj/item/implant/ipc/magnetic_joints/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Magnetic Joints Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Allows easy limb reattachment without surgery.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/ipc/magnetic_joints/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		if(!silent && user)
			to_chat(user, span_warning("Этот имплант предназначен только для IPC!"))
		return FALSE

	// Получаем bodypart и даем трейт TRAIT_EASY_ATTACH для быстрого прикрепления
	var/obj/item/bodypart/part = H.get_bodypart(installed_in_zone)
	if(part)
		ADD_TRAIT(part, TRAIT_EASY_ATTACH, "magnetic_joints")

	if(!silent)
		to_chat(H, span_notice("Магнитные суставы активированы в [installed_in_zone]. Конечность можно быстро прикрепить без операции."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили магнитные суставы."))

	return TRUE

/obj/item/implant/ipc/magnetic_joints/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Убираем трейт с bodypart
	var/obj/item/bodypart/part = H.get_bodypart(installed_in_zone)
	if(part)
		REMOVE_TRAIT(part, TRAIT_EASY_ATTACH, "magnetic_joints")

	if(!silent)
		to_chat(H, span_warning("Магнитные суставы деактивированы."))

/obj/item/implantcase/ipc/magnetic_joints
	name = "implant case - 'Magnetic Joints'"
	desc = "Стеклянный кейс содержащий имплант магнитных суставов для IPC."
	imp_type = /obj/item/implant/ipc/magnetic_joints

// ============================================
// 2. SEALED JOINTS IMPLANT
// ============================================
// Предотвращает dismemberment конечности

/obj/item/implant/ipc/sealed_joints
	name = "Sealed Joints Implant"
	desc = "Укрепленные герметичные суставы. Предотвращают отрывание конечности без операции. Устанавливается в руки или ноги."
	icon_state = "sealed_joints"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/obj/item/implant/ipc/sealed_joints/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Sealed Joints Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Prevents limb dismemberment without surgery.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/ipc/sealed_joints/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		if(!silent && user)
			to_chat(user, span_warning("Этот имплант предназначен только для IPC!"))
		return FALSE

	// Устанавливаем флаг BODYPART_UNREMOVABLE для защиты от dismemberment
	var/obj/item/bodypart/part = H.get_bodypart(installed_in_zone)
	if(part)
		part.bodypart_flags |= BODYPART_UNREMOVABLE

	if(!silent)
		to_chat(H, span_notice("Герметичные суставы установлены в [installed_in_zone]. Конечность защищена от отрывания."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили герметичные суставы."))

	return TRUE

/obj/item/implant/ipc/sealed_joints/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Убираем флаг BODYPART_UNREMOVABLE
	var/obj/item/bodypart/part = H.get_bodypart(installed_in_zone)
	if(part)
		part.bodypart_flags &= ~BODYPART_UNREMOVABLE

	if(!silent)
		to_chat(H, span_warning("Герметичные суставы удалены. Конечность больше не защищена."))

/obj/item/implantcase/ipc/sealed_joints
	name = "implant case - 'Sealed Joints'"
	desc = "Стеклянный кейс содержащий имплант укрепленных суставов."
	imp_type = /obj/item/implant/ipc/sealed_joints

// ============================================
// 3. REACTIVE REPAIR IMPLANT
// ============================================
// Автоматический ремонт всего тела, устанавливается в грудь

/obj/item/implant/ipc/reactive_repair
	name = "Reactive Repair Implant"
	desc = "Система автоматического ремонта для IPC. Чинит все тело. Устанавливается в грудную клетку и расходует заряд батарейки."
	icon_state = "reactive_repair"
	allowed_zones = list(BODY_ZONE_CHEST)
	actions_types = list(/datum/action/item_action/hands_free/toggle_repair)
	var/repair_amount = 2
	var/repair_cooldown = 30 SECONDS
	var/last_repair_time = 0
	var/repair_active = TRUE  // По умолчанию включен
	var/power_cost = 50 // Стоимость одного ремонта в единицах заряда

/obj/item/implant/ipc/reactive_repair/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Reactive Repair Implant<BR>
	<b>Life:</b> Depends on battery charge<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Auto-repair (2 HP/30s for all body, costs [power_cost] charge).<BR>
	<b>Status:</b> [repair_active ? "ACTIVE" : "INACTIVE"]"}
	return dat

/obj/item/implant/ipc/reactive_repair/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		if(!silent && user)
			to_chat(user, span_warning("Этот имплант предназначен только для IPC!"))
		return FALSE

	// Регистрируем процесс ремонта
	START_PROCESSING(SSobj, src)

	if(!silent)
		to_chat(H, span_notice("Система реактивного ремонта активирована. Чинит все тело, расходует заряд батарейки."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили имплант реактивного ремонта."))

	return TRUE

/obj/item/implant/ipc/reactive_repair/process(seconds_per_tick)
	if(!imp_in || !repair_active)
		return

	// Проверяем кулдаун
	if(world.time < last_repair_time + repair_cooldown)
		return

	if(!ishuman(imp_in))
		return

	var/mob/living/carbon/human/H = imp_in

	// Проверяем батарейку
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery || battery.charge < power_cost)
		to_chat(H, span_warning("Реактивный ремонт деактивирован: недостаточно заряда батарейки!"))
		repair_active = FALSE
		return

	// Ищем поврежденные части тела
	var/obj/item/bodypart/damaged_part = null
	var/max_damage = 0
	for(var/obj/item/bodypart/part in H.bodyparts)
		var/total_damage = part.brute_dam + part.burn_dam
		if(total_damage > max_damage)
			max_damage = total_damage
			damaged_part = part

	if(!damaged_part || max_damage <= 0)
		return

	// Расходуем заряд
	battery.charge = max(battery.charge - power_cost, 0)

	// Чиним наиболее поврежденную часть
	if(damaged_part.brute_dam > damaged_part.burn_dam)
		damaged_part.heal_damage(repair_amount, 0)
		to_chat(H, span_notice("Реактивный ремонт устраняет механические повреждения [damaged_part.plaintext_zone]. Батарея: [round(battery.charge)]/[battery.maxcharge]"))
	else
		damaged_part.heal_damage(0, repair_amount)
		to_chat(H, span_notice("Реактивный ремонт устраняет термические повреждения [damaged_part.plaintext_zone]. Батарея: [round(battery.charge)]/[battery.maxcharge]"))

	last_repair_time = world.time

/obj/item/implant/ipc/reactive_repair/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	STOP_PROCESSING(SSobj, src)

	if(!silent)
		to_chat(source, span_warning("Система реактивного ремонта деактивирована."))

/datum/action/item_action/hands_free/toggle_repair
	name = "Toggle Reactive Repair"
	desc = "Включить/выключить систему реактивного ремонта."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_repair"
	background_icon_state = "bg_tech"

/datum/action/item_action/hands_free/toggle_repair/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/implant/ipc/reactive_repair/repair_implant = target
	if(!istype(repair_implant))
		return FALSE

	repair_implant.repair_active = !repair_implant.repair_active

	if(repair_implant.repair_active)
		to_chat(owner, span_notice("Реактивный ремонт активирован."))
	else
		to_chat(owner, span_notice("Реактивный ремонт деактивирован."))

	build_all_button_icons()
	return TRUE

/obj/item/implantcase/ipc/reactive_repair
	name = "implant case - 'Reactive Repair'"
	desc = "Стеклянный кейс содержащий имплант реактивного ремонта."
	imp_type = /obj/item/implant/ipc/reactive_repair

// ============================================
// 4. EMP-PROTECTOR (УНИВЕРСАЛЬНЫЙ)
// ============================================
// Защита от ЕМП для ВСЕХ РАС, устанавливается в грудь

/obj/item/implant/emp_protector
	name = "EMP-Protector Implant"
	desc = "Защита от ЕМП ударов. Устанавливается в грудную клетку. Для IPC - нагревает процессор при блокировке, для других - наносит burn урон."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "emp_protector"
	w_class = WEIGHT_CLASS_TINY
	actions_types = null  // Нет action button
	var/heat_per_use = 15 // Нагрев для IPC
	var/burn_damage = 10 // Урон для органиков
	var/installed_in_zone = null

/obj/item/implant/emp_protector/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> EMP-Protector Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Blocks EMP damage (IPC: +[heat_per_use]°C, Others: [burn_damage] burn).<BR>
	<b>Status:</b> ACTIVE"}
	return dat

/obj/item/implant/emp_protector/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	// Можно установить только в грудь
	if(body_zone && body_zone != BODY_ZONE_CHEST)
		if(!silent && user)
			to_chat(user, span_warning("[capitalize(src.name)] может быть установлен только в грудную клетку!"))
		return FALSE

	installed_in_zone = body_zone

	// Регистрируем обработку ЕМП
	. = ..(target, user, silent, force)
	if(!.)
		return FALSE

	RegisterSignal(imp_in, COMSIG_ATOM_PRE_EMP_ACT, PROC_REF(on_emp))

	if(!silent && ishuman(imp_in))
		to_chat(imp_in, span_notice("EMP-протектор активирован."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили EMP-протектор."))

	return TRUE

/obj/item/implant/emp_protector/proc/on_emp(atom/source, severity)
	SIGNAL_HANDLER

	if(!ishuman(imp_in))
		return EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS

	var/mob/living/carbon/human/H = imp_in

	// Для IPC - нагрев процессора
	if(istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		S.cpu_temperature = min(S.cpu_temperature + heat_per_use, 200)
		to_chat(H, span_warning("EMP-протектор блокировал удар! Процессор нагрелся на [heat_per_use]°C."))

	// Для других рас - burn урон в грудь
	else
		var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
		if(chest)
			chest.receive_damage(0, burn_damage)
			to_chat(H, span_warning("EMP-протектор блокировал удар, но перегрелся и обжег вас!"))

	// Блокируем ЕМП урон
	return EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS

/obj/item/implant/emp_protector/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	UnregisterSignal(imp_in, COMSIG_ATOM_PRE_EMP_ACT)

	if(!silent && ishuman(source))
		to_chat(source, span_warning("EMP-протектор деактивирован."))

/obj/item/implantcase/emp_protector
	name = "implant case - 'EMP-Protector'"
	desc = "Стеклянный кейс содержащий имплант защиты от ЕМП."
	imp_type = /obj/item/implant/emp_protector

// ============================================
// 5. MAGNETIC LEG
// ============================================
// Встроенные магбуты - только в ноги

/obj/item/implant/ipc/magnetic_leg
	name = "Magnetic Leg Implant"
	desc = "Магнитные модули для ног IPC. Функционируют как встроенные магнитные ботинки."
	icon_state = "magnetic_leg"
	allowed_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/magboots_active = FALSE

/obj/item/implant/ipc/magnetic_leg/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Magnetic Leg Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Built-in magboots (toggle-able).<BR>
	<b>Status:</b> [magboots_active ? "ACTIVE" : "INACTIVE"]"}
	return dat

/obj/item/implant/ipc/magnetic_leg/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		if(!silent && user)
			to_chat(user, span_warning("Этот имплант предназначен только для IPC!"))
		return FALSE

	// Даем абилку переключения магбутов только если это первая нога
	var/datum/action/toggle_magboots/existing = locate() in H.actions
	if(!existing)
		var/datum/action/toggle_magboots/toggle = new()
		toggle.Grant(H)

	if(!silent)
		to_chat(H, span_notice("Магнитные модули установлены в [installed_in_zone]."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили магнитные модули."))

	return TRUE

/obj/item/implant/ipc/magnetic_leg/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Проверяем есть ли еще magnetic_leg импланты
	var/has_other_mag_legs = FALSE
	for(var/obj/item/implant/ipc/magnetic_leg/other in H.implants)
		if(other != src)
			has_other_mag_legs = TRUE
			break

	// Если нет других магнитных ног - убираем абилку
	if(!has_other_mag_legs)
		// Отключаем магбуты если активны
		if(magboots_active)
			REMOVE_TRAIT(H, TRAIT_NO_SLIP_ALL, "magnetic_leg")
			REMOVE_TRAIT(H, TRAIT_NEGATES_GRAVITY, "magnetic_leg")

		var/datum/action/toggle_magboots/action = locate() in H.actions
		if(action)
			action.Remove(H)

	if(!silent)
		to_chat(H, span_warning("Магнитные модули удалены из [installed_in_zone]."))

/obj/item/implantcase/ipc/magnetic_leg
	name = "implant case - 'Magnetic Leg'"
	desc = "Стеклянный кейс содержащий имплант встроенных магнитных ботинок для IPC."
	imp_type = /obj/item/implant/ipc/magnetic_leg

// Абилка переключения магбутов
/datum/action/toggle_magboots
	name = "Toggle Magnetic Boots"
	desc = "Активировать/деактивировать встроенные магнитные ботинки."
	button_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
	background_icon_state = "bg_tech"

/datum/action/toggle_magboots/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	// Находим любой magnetic_leg имплант
	var/obj/item/implant/ipc/magnetic_leg/mag_implant = locate() in H.implants
	if(!mag_implant)
		return FALSE

	mag_implant.magboots_active = !mag_implant.magboots_active

	if(mag_implant.magboots_active)
		ADD_TRAIT(H, TRAIT_NO_SLIP_ALL, "magnetic_leg")
		ADD_TRAIT(H, TRAIT_NEGATES_GRAVITY, "magnetic_leg")
		to_chat(H, span_notice("Магнитные ботинки активированы."))
		button_icon_state = "magboots1"
	else
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_ALL, "magnetic_leg")
		REMOVE_TRAIT(H, TRAIT_NEGATES_GRAVITY, "magnetic_leg")
		to_chat(H, span_notice("Магнитные ботинки деактивированы."))
		button_icon_state = "magboots0"

	build_all_button_icons()
	return TRUE
// ============================================
// 6. BIO-GENERATOR
// ============================================
// Позволяет IPC переваривать еду - устанавливается в грудь

/obj/item/implant/ipc/bio_generator
	name = "Bio-Generator Implant"
	desc = "Биологический генератор для IPC. Позволяет перерабатывать органическую пищу в энергию. Устанавливается в грудную клетку."
	icon_state = "bio_generator"
	allowed_zones = list(BODY_ZONE_CHEST)

/obj/item/implant/ipc/bio_generator/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Bio-Generator Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Allows food digestion for energy.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/ipc/bio_generator/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target
	if(!istype(H.dna?.species, /datum/species/ipc))
		if(!silent && user)
			to_chat(user, span_warning("Этот имплант предназначен только для IPC!"))
		return FALSE

	// Убираем трейт NOHUNGER чтобы можно было есть
	REMOVE_TRAIT(H, TRAIT_NOHUNGER, SPECIES_TRAIT)

	// Вставляем виртуальный stomach organ чтобы IPC мог есть еду
	var/obj/item/organ/stomach/ipc_bio/bio_stomach = new()
	bio_stomach.Insert(H)

	// Регистрируем обработку еды - используем COMSIG_LIVING_EAT_FOOD
	RegisterSignal(H, COMSIG_LIVING_EAT_FOOD, PROC_REF(on_food_eaten))

	if(!silent)
		to_chat(H, span_notice("Био-генератор активирован. Вы можете употреблять органическую пищу для зарядки батарейки."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили био-генератор."))

	return TRUE

/obj/item/implant/ipc/bio_generator/proc/on_food_eaten(mob/living/carbon/human/source, atom/food)
	SIGNAL_HANDLER

	if(!istype(source.dna?.species, /datum/species/ipc))
		return

	// Получаем батарею IPC
	var/obj/item/organ/heart/ipc_battery/battery = source.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		return

	// Получаем reagents из еды
	if(!food.reagents)
		return

	// Считаем nutrition value на основе всех consumable reagents в еде
	var/total_nutrition = 0
	for(var/datum/reagent/consumable/R in food.reagents.reagent_list)
		// nutriment_factor * объем * коэффициент
		var/nutrition_value = R.get_nutriment_factor(source) * R.volume
		total_nutrition += nutrition_value

	if(total_nutrition <= 0)
		return

	// Конвертируем nutrition в заряд батарейки
	// 1 nutrition ≈ 2 charge (можно регулировать коэффициент)
	var/energy_gain = total_nutrition * 2

	var/old_charge = battery.charge
	battery.charge = min(battery.charge + energy_gain, battery.maxcharge)
	var/actual_gain = battery.charge - old_charge

	to_chat(source, span_notice("Био-генератор переработал пищу и зарядил батарейку на [round(actual_gain)] единиц. Батарея: [round(battery.charge)]/[battery.maxcharge]"))

/obj/item/implant/ipc/bio_generator/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Возвращаем трейт NOHUNGER
	if(istype(H.dna?.species, /datum/species/ipc))
		ADD_TRAIT(H, TRAIT_NOHUNGER, SPECIES_TRAIT)

	// Удаляем виртуальный stomach organ
	var/obj/item/organ/stomach/ipc_bio/bio_stomach = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(bio_stomach)
		bio_stomach.Remove(H)
		qdel(bio_stomach)

	UnregisterSignal(H, COMSIG_LIVING_EAT_FOOD)

	if(!silent)
		to_chat(H, span_warning("Био-генератор деактивирован."))

/obj/item/implantcase/ipc/bio_generator
	name = "implant case - 'Bio-Generator'"
	desc = "Стеклянный кейс содержащий имплант био-генератора для IPC."
	imp_type = /obj/item/implant/ipc/bio_generator

// ============================================
// 7. CHARGER IMPLANT (ROUNDSTART)
// ============================================
// Встроенный зарядный порт — позволяет зарядиться от настенных устройств
// (АРС, переговорников, экранов и т.п.).
// Кабель всегда в руке. Нажать кабелем на устройство — подключиться.
// Движение — автоотключение.

/// Кабель зарядника, постоянно находящийся в руке.
/// Правая рука — стандартный вариант.
/obj/item/ipc_charging_cable
	name = "charging cable"
	desc = "Встроенный зарядный кабель КПБ. Нажмите на АРС или настенное устройство для подключения."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "coil"
	inhand_icon_state = "coil_yellow"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_flags = HAND_ITEM | ABSTRACT
	force = 0
	throwforce = 0
	throw_range = 0
	w_class = WEIGHT_CLASS_TINY
	/// Имплант-источник этого кабеля
	var/obj/item/implant/ipc/charger/charger_implant = null
	/// Подключённое устройство (APC, переговорник и т.п.)
	var/obj/machinery/connected_device = null

/// Левая рука — зеркалит те же спрайты.
/obj/item/ipc_charging_cable/left
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

/obj/item/ipc_charging_cable/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!istype(target, /obj/machinery))
		return
	if(!charger_implant || QDELETED(charger_implant))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	// Отключаемся если нажали на уже подключённое устройство
	if(connected_device == target)
		disconnect_from_device(H)
		return
	// Если уже подключены к другому — сначала отключаемся
	if(connected_device)
		disconnect_from_device(H)
	var/obj/machinery/M = target
	connected_device = M
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		to_chat(H, span_warning("Батарея не обнаружена!"))
		connected_device = null
		return
	battery.charging = TRUE
	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	to_chat(H, span_notice("Кабель подключён к [M.name]. Начинается зарядка..."))
	H.visible_message(span_notice("[H] подключает зарядный кабель к [M.name]."))

/obj/item/ipc_charging_cable/proc/disconnect_from_device(mob/living/carbon/human/H)
	if(!connected_device)
		return
	var/obj/machinery/old_device = connected_device
	connected_device = null
	if(!H || QDELETED(H))
		return
	UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		battery.charging = FALSE
	to_chat(H, span_notice("Зарядный кабель отключён от [old_device.name]."))

/obj/item/ipc_charging_cable/proc/on_owner_moved(mob/living/carbon/human/H, old_loc, movement_dir, forced, old_locs, momentum_change)
	SIGNAL_HANDLER
	disconnect_from_device(H)

/obj/item/implant/ipc/charger
	name = "Integrated Charging Port"
	desc = "Встроенный зарядный порт. Позволяет IPC заряждаться от настенных источников питания: АРС, переговорников, экранов. Достаньте кабель кнопкой действия, затем нажмите им на устройство."
	icon_state = "reactive_repair"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/hands_free/ipc_charge)
	/// Кабель в слоте руки (null если убран)
	var/obj/item/ipc_charging_cable/cable_item = null
	/// Заряд батареи в единицах за секунду при подключении
	var/charge_per_second = 20

/obj/item/implant/ipc/charger/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Integrated Charging Port<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Charges IPC battery ([charge_per_second] units/s) when cable connected to wall power device.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/ipc/charger/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/implant/ipc/charger/process(seconds_per_tick)
	if(!imp_in || !cable_item || !cable_item.connected_device)
		return
	if(!ishuman(imp_in))
		return
	var/mob/living/carbon/human/H = imp_in
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		return
	// Если устройство удалено или слишком далеко — отключаемся
	var/obj/machinery/device = cable_item.connected_device
	if(QDELETED(device) || get_dist(H, device) > 2)
		cable_item.disconnect_from_device(H)
		return
	// Начисляем заряд
	battery.charge_from_apc(charge_per_second * seconds_per_tick)

/obj/item/implant/ipc/charger/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	if(cable_item)
		if(cable_item.connected_device)
			cable_item.disconnect_from_device(H)
		REMOVE_TRAIT(cable_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
		QDEL_NULL(cable_item)

// Кнопка достать/убрать зарядный кабель
/datum/action/item_action/hands_free/ipc_charge
	name = "Зарядный кабель"
	desc = "Достать/убрать встроенный зарядный кабель. Нажмите кабелем на АРС или настенное устройство для зарядки."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_charger"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/item_action/hands_free/ipc_charge/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/implant/ipc/charger/charger_implant = target
	if(!istype(charger_implant))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(charger_implant.cable_item)
		// Убираем кабель (и отключаемся если были подключены)
		if(charger_implant.cable_item.connected_device)
			charger_implant.cable_item.disconnect_from_device(H)
		REMOVE_TRAIT(charger_implant.cable_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
		QDEL_NULL(charger_implant.cable_item)
		to_chat(H, span_notice("Зарядный кабель убран."))
	else
		// Достаём кабель и помещаем в нужную руку
		var/cable_type = (charger_implant.installed_in_zone == BODY_ZONE_R_ARM) ? /obj/item/ipc_charging_cable : /obj/item/ipc_charging_cable/left
		var/obj/item/ipc_charging_cable/cable = new cable_type(null)
		cable.charger_implant = charger_implant
		ADD_TRAIT(cable, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
		charger_implant.cable_item = cable
		var/side = (charger_implant.installed_in_zone == BODY_ZONE_R_ARM) ? RIGHT_HANDS : LEFT_HANDS
		var/hand = H.get_empty_held_index_for_side(side)
		if(hand)
			H.put_in_hand(cable, hand)
		else
			var/list/hand_items = H.get_held_items_for_side(side, all = TRUE)
			for(var/i in 1 to length(hand_items))
				var/obj/item/hand_item = hand_items[i]
				if(!H.dropItemToGround(hand_item))
					continue
				to_chat(H, span_notice("Вы роняете [hand_item], чтобы достать зарядный кабель."))
				H.put_in_hand(cable, H.get_empty_held_index_for_side(side))
				break
		to_chat(H, span_notice("Зарядный кабель извлечён. Нажмите им на АРС или настенное устройство для зарядки."))
	build_all_button_icons()
	return TRUE

// ============================================
// 8. FORCE SHIELD IMPLANT (SHELLGUARD ROUNDSTART)
// ============================================
// Встроенный силовой щит. Выдаётся Shellguard IPC в руку,
// противоположную зарядному порту. Снижает входящий урон когда активен.

/obj/item/implant/ipc/force_shield
	name = "Force Shield Emitter"
	desc = "Встроенный генератор силового щита. В активном состоянии действует как раскладываемый щит — блокирует атаки с определённым шансом, но каждый блок немного повреждает руку с имплантом."
	icon_state = "reactive_repair"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	arm_visual_state = "ipc_shield"
	actions_types = list(/datum/action/item_action/hands_free/ipc_force_shield)
	var/shield_active = FALSE
	/// Шанс полного блока атаки (0–100)
	var/shield_block_chance = 60
	/// Урон по руке за каждый успешный блок
	var/arm_damage_per_block = 2
	/// Стоимость активного щита в заряде батареи за секунду
	var/shield_power_cost = 3

/obj/item/implant/ipc/force_shield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Force Shield Emitter<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> [shield_block_chance]% chance to fully block incoming brute/burn damage; each block deals [arm_damage_per_block] brute to the arm.<BR>
	<b>Status:</b> [shield_active ? "ACTIVE" : "STANDBY"]"}
	return dat

/obj/item/implant/ipc/force_shield/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target))
		apply_arm_visual(target)
		RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_damage_modifiers))
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/implant/ipc/force_shield/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	shield_active = FALSE
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	remove_arm_visual(H)
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/obj/item/implant/ipc/force_shield/proc/on_damage_modifiers(mob/living/carbon/human/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER
	if(!shield_active)
		return
	if(damagetype != BRUTE && damagetype != BURN)
		return
	if(damage_amount <= 0)
		return
	if(!prob(shield_block_chance))
		return
	// Успешный блок — полностью поглощаем удар
	damage_mods += 0
	// Рука с имплантом получает небольшой урон от нагрузки на щит
	var/obj/item/bodypart/arm = source.get_bodypart(installed_in_zone)
	if(arm)
		arm.receive_damage(arm_damage_per_block, 0)
	source.visible_message(
		span_warning("[source] блокирует удар встроенным силовым щитом!"),
		span_warning("Вы блокируете удар силовым щитом! ([round(damage_amount)] ур. поглощено, рука повреждена на [arm_damage_per_block])."),
	)

/obj/item/implant/ipc/force_shield/process(seconds_per_tick)
	if(!imp_in || !shield_active)
		return
	if(!ishuman(imp_in))
		return
	var/mob/living/carbon/human/H = imp_in
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		return
	// Расходуем заряд батареи
	if(battery.charge < shield_power_cost * seconds_per_tick)
		shield_active = FALSE
		to_chat(H, span_warning("Силовой щит отключён: недостаточно заряда батареи!"))
		return
	battery.charge = max(0, battery.charge - (shield_power_cost * seconds_per_tick))

// Кнопка переключения силового щита
/datum/action/item_action/hands_free/ipc_force_shield
	name = "Силовой щит"
	desc = "Активировать/деактивировать встроенный силовой щит."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_shield"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/item_action/hands_free/ipc_force_shield/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/implant/ipc/force_shield/shield_implant = target
	if(!istype(shield_implant))
		return FALSE

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	shield_implant.shield_active = !shield_implant.shield_active

	if(shield_implant.shield_active)
		to_chat(H, span_notice("Силовой щит развёрнут. Шанс блока: [shield_implant.shield_block_chance]%. Каждый блок наносит [shield_implant.arm_damage_per_block] ур. руке."))
	else
		to_chat(H, span_notice("Силовой щит сложен."))

	build_all_button_icons()
	return TRUE

// ============================================
// 9. KEBAB IMPLANT
// ============================================
// При активных клинках богомола позволяет за 3 секунды приготовить кебаб.
// Кулдаун 30 секунд.

/obj/item/implant/ipc/kebab
	name = "Integrated Kebab Module"
	desc = "Встроенный кебаб-модуль. При развёрнутых клинках богомола позволяет насаживать мясо на лезвия и готовить кебаб (3 сек, кулдаун 30 сек)."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "kebab"
	allowed_zones = list(BODY_ZONE_CHEST)
	actions_types = list(/datum/action/item_action/hands_free/ipc_make_kebab)
	/// Кулдаун между приготовлениями
	var/kebab_cooldown = 30 SECONDS
	/// Время последнего приготовления
	var/last_kebab_time = 0

/obj/item/implant/ipc/kebab/get_data()
	return {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Integrated Kebab Module<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Produces kebab using deployed mantis blades (3s cast, 30s cooldown).<BR>
	<b>Integrity:</b> Active"}

/obj/item/implant/ipc/kebab/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!silent)
		to_chat(target, span_notice("Кебаб-модуль активирован. Используйте клинки богомола для приготовления еды."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили кебаб-модуль."))
	return TRUE

/obj/item/implant/ipc/kebab/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Кебаб-модуль деактивирован."))

/obj/item/implantcase/ipc/kebab
	name = "implant case - 'Kebab Module'"
	desc = "Стеклянный кейс содержащий встроенный кебаб-модуль для IPC."
	imp_type = /obj/item/implant/ipc/kebab

// Кнопка приготовления кебаба
/datum/action/item_action/hands_free/ipc_make_kebab
	name = "Приготовить кебаб"
	desc = "Насадить мясо на клинки богомола и приготовить кебаб (3 сек, кулдаун 30 сек)."
	button_icon = 'modular_bandastation/species/icons/hud/ipc_ui.dmi'
	button_icon_state = "ipc_kebab"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/item_action/hands_free/ipc_make_kebab/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/implant/ipc/kebab/kebab_implant = target
	if(!istype(kebab_implant))
		return FALSE

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	// Проверяем кулдаун
	if(world.time < kebab_implant.last_kebab_time + kebab_implant.kebab_cooldown)
		var/remaining = round((kebab_implant.last_kebab_time + kebab_implant.kebab_cooldown - world.time) / 10)
		to_chat(H, span_warning("Кебаб-модуль перезаряжается. Осталось: [remaining] сек."))
		return FALSE

	// Нужны активные (развёрнутые) клинки богомола
	var/has_active_mantis = FALSE
	for(var/obj/item/implant/ipc/mantis/blade in H.implants)
		if(blade.blades_active)
			has_active_mantis = TRUE
			break

	if(!has_active_mantis)
		to_chat(H, span_warning("Разверните клинки богомола для приготовления кебаба!"))
		return FALSE

	// Процесс готовки требует времени — запускаем асинхронно
	INVOKE_ASYNC(src, PROC_REF(do_make_kebab), H, kebab_implant)
	return TRUE

/datum/action/item_action/hands_free/ipc_make_kebab/proc/do_make_kebab(mob/living/carbon/human/H, obj/item/implant/ipc/kebab/kebab_implant)
	to_chat(H, span_notice("Начинаю нанизывать мясо на лезвия..."))

	if(!do_after(H, 3 SECONDS, target = H, timed_action_flags = IGNORE_HELD_ITEM))
		to_chat(H, span_warning("Приготовление прервано!"))
		return

	// После паузы проверяем что лезвия всё ещё развёрнуты
	var/still_active = FALSE
	for(var/obj/item/implant/ipc/mantis/blade in H.implants)
		if(blade.blades_active)
			still_active = TRUE
			break

	if(!still_active)
		to_chat(H, span_warning("Клинки убраны — кебаб не удалось приготовить!"))
		return

	// Ставим кулдаун и создаём кебаб
	kebab_implant.last_kebab_time = world.time
	var/obj/item/food/kebab/monkey/kebab = new(H.drop_location())
	kebab.name = "кебаб КПБ"
	if(!H.put_in_hands(kebab))
		kebab.forceMove(H.drop_location())

	H.visible_message(
		span_notice("[H] нанизывает куски мяса на лезвия богомола и подаёт готовый кебаб!"),
		span_notice("Кебаб готов!"),
	)
