// ============================================
// ИМПЛАНТЫ ДЛЯ IPC
// Устанавливаются через хирургию в конкретные части тела
// ============================================

// Базовый класс для IPC имплантов
/obj/item/implant/ipc
	name = "IPC implant"
	desc = "Базовый имплант для IPC."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "imp_jetpack-on"
	w_class = WEIGHT_CLASS_TINY
	/// В какой части тела установлен
	var/installed_in_zone = null
	/// Список разрешенных зон для установки
	var/list/allowed_zones = list()

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
// Автоматический ремонт конкретной части тела

/obj/item/implant/ipc/reactive_repair
	name = "Reactive Repair Implant"
	desc = "Система автоматического ремонта для конечности IPC. Чинит часть тела в которую установлена."
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/repair_amount = 2
	var/repair_cooldown = 30 SECONDS
	var/last_repair_time = 0

/obj/item/implant/ipc/reactive_repair/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Reactive Repair Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Auto-repair (2 HP/30s for this bodypart).<BR>
	<b>Integrity:</b> Active"}
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

	// Регистрируем сигнал на получение урона
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))

	if(!silent)
		to_chat(H, span_notice("Система реактивного ремонта активирована для [installed_in_zone]."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили имплант реактивного ремонта."))

	return TRUE

/obj/item/implant/ipc/reactive_repair/proc/on_damage(mob/living/carbon/human/source, damage, damagetype)
	SIGNAL_HANDLER

	// Проверяем кулдаун
	if(world.time < last_repair_time + repair_cooldown)
		return

	// Чиним только конкретную часть тела
	var/obj/item/bodypart/part = source.get_bodypart(installed_in_zone)
	if(!part)
		return

	if(part.brute_dam <= 0 && part.burn_dam <= 0)
		return

	if(part.brute_dam > part.burn_dam)
		part.heal_damage(repair_amount, 0)
		to_chat(source, span_notice("Реактивный ремонт устраняет механические повреждения [part.plaintext_zone]."))
	else
		part.heal_damage(0, repair_amount)
		to_chat(source, span_notice("Реактивный ремонт устраняет термические повреждения [part.plaintext_zone]."))

	last_repair_time = world.time

/obj/item/implant/ipc/reactive_repair/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE)

	if(!silent)
		to_chat(H, span_warning("Система реактивного ремонта деактивирована."))

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
	icon_state = "implant-reinforcers"
	w_class = WEIGHT_CLASS_TINY
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

	RegisterSignal(imp_in, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

	if(!silent && ishuman(imp_in))
		to_chat(imp_in, span_notice("EMP-протектор активирован."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили EMP-протектор."))

	return TRUE

/obj/item/implant/emp_protector/proc/on_emp(atom/source, severity)
	SIGNAL_HANDLER

	if(!ishuman(imp_in))
		return

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
	return COMPONENT_EMP_PREVENT

/obj/item/implant/emp_protector/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	UnregisterSignal(imp_in, COMSIG_ATOM_EMP_ACT)

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
			H.remove_movespeed_modifier(/datum/movespeed_modifier/magboots)

		var/datum/action/toggle_magboots/action = locate() in H.actions
		if(action)
			action.Remove(H)

	if(!silent)
		to_chat(H, span_warning("Магнитные модули удалены из [installed_in_zone]."))

// Абилка переключения магбутов
/datum/action/toggle_magboots
	name = "Toggle Magnetic Boots"
	desc = "Активировать/деактивировать встроенные магнитные ботинки."
	button_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
	background_icon_state = "bg_tech"

/datum/action/toggle_magboots/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	// Находим любой magnetic_leg имплант
	var/obj/item/implant/ipc/magnetic_leg/mag_implant = locate() in H.implants
	if(!mag_implant)
		return

	mag_implant.magboots_active = !mag_implant.magboots_active

	if(mag_implant.magboots_active)
		ADD_TRAIT(H, TRAIT_NO_SLIP_ALL, "magnetic_leg")
		H.add_movespeed_modifier(/datum/movespeed_modifier/magboots)
		to_chat(H, span_notice("Магнитные ботинки активированы."))
		button_icon_state = "magboots1"
	else
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_ALL, "magnetic_leg")
		H.remove_movespeed_modifier(/datum/movespeed_modifier/magboots)
		to_chat(H, span_notice("Магнитные ботинки деактивированы."))
		button_icon_state = "magboots0"

	build_all_button_icons()

/obj/item/implantcase/ipc/magnetic_leg
	name = "implant case - 'Magnetic Leg'"
	desc = "Стеклянный кейс содержащий имплант магнитных ног."
	imp_type = /obj/item/implant/ipc/magnetic_leg

// ============================================
// 6. BIO-GENERATOR
// ============================================
// Позволяет IPC переваривать еду - устанавливается в грудь

/obj/item/implant/ipc/bio_generator
	name = "Bio-Generator Implant"
	desc = "Биологический генератор для IPC. Позволяет перерабатывать органическую пищу в энергию. Устанавливается в грудную клетку."
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

	// Убираем трейт NOHUNGER
	REMOVE_TRAIT(H, TRAIT_NOHUNGER, SPECIES_TRAIT)

	// Регистрируем обработку еды
	RegisterSignal(H, COMSIG_FOOD_EATEN, PROC_REF(on_food_eaten))

	if(!silent)
		to_chat(H, span_notice("Био-генератор активирован. Вы можете употреблять органическую пищу."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили био-генератор."))

	return TRUE

/obj/item/implant/ipc/bio_generator/proc/on_food_eaten(mob/living/carbon/human/source, atom/food, mob/feeder)
	SIGNAL_HANDLER

	if(!istype(source.dna?.species, /datum/species/ipc))
		return

	// Получаем батарею IPC
	var/obj/item/organ/heart/ipc_battery/battery = source.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		return

	// Преобразуем еду в энергию
	var/energy_gain = 50

	battery.charge = min(battery.charge + energy_gain, battery.maxcharge)
	to_chat(source, span_notice("Био-генератор переработал пищу в [energy_gain] единиц энергии."))

/obj/item/implant/ipc/bio_generator/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Возвращаем трейт NOHUNGER
	if(istype(H.dna?.species, /datum/species/ipc))
		ADD_TRAIT(H, TRAIT_NOHUNGER, SPECIES_TRAIT)

	UnregisterSignal(H, COMSIG_FOOD_EATEN)

	if(!silent)
		to_chat(H, span_warning("Био-генератор деактивирован."))

/obj/item/implantcase/ipc/bio_generator
	name = "implant case - 'Bio-Generator'"
	desc = "Стеклянный кейс содержащий имплант био-генератора."
	imp_type = /obj/item/implant/ipc/bio_generator
