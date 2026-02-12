// ============================================
// ИМПЛАНТЫ ДЛЯ IPC
// ============================================

// ============================================
// 1. ETAMIN INDUSTRY PREMIUM UPDATE
// ============================================
// Шасси upgrade - позволяет использовать одноразовую спец абилку шасси

/obj/item/implant/etamin_chassis_upgrade
	name = "Etamin Industry Premium Update"
	desc = "Улучшение прошивки от Etamin Industry. Позволяет использовать уникальную способность шасси один раз."
	icon = 'icons/obj/medical/implants.dmi' // Временная иконка
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY
	var/ability_used = FALSE

/obj/item/implant/etamin_chassis_upgrade/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Etamin Industry Premium Update<BR>
	<b>Life:</b> Single Use<BR>
	<b>Function:</b> Unlocks chassis special ability (one-time use).<BR>
	<b>Status:</b> [ability_used ? "USED" : "READY"]"}
	return dat

/obj/item/implant/etamin_chassis_upgrade/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
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

	// Даем абилку использования спец способности шасси
	var/datum/action/cooldown/chassis_special/special = new()
	special.Grant(H)

	if(!silent)
		to_chat(H, span_notice("Обновление прошивки установлено. Доступна специальная способность шасси."))
		to_chat(user, span_notice("Вы успешно установили имплант улучшения прошивки."))

	return TRUE

/obj/item/implant/etamin_chassis_upgrade/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Удаляем абилку
	var/datum/action/cooldown/chassis_special/action = locate() in H.actions
	if(action)
		action.Remove(H)

	if(!silent)
		to_chat(H, span_warning("Обновление прошивки удалено."))

/obj/item/implantcase/etamin_chassis_upgrade
	name = "implant case - 'Etamin Premium Update'"
	desc = "Стеклянный кейс содержащий имплант обновления прошивки."
	imp_type = /obj/item/implant/etamin_chassis_upgrade

// Абилка для спец способности шасси (одноразовая)
/datum/action/cooldown/chassis_special
	name = "Chassis Special Ability"
	desc = "Активирует уникальную способность вашего шасси. Одноразовое использование!"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "upgrade"
	background_icon_state = "bg_tech"
	cooldown_time = 0 // Одноразовая
	var/used = FALSE

/datum/action/cooldown/chassis_special/IsAvailable(feedback = FALSE)
	if(used)
		return FALSE
	return ..()

/datum/action/cooldown/chassis_special/Activate(atom/target)
	if(used)
		return FALSE

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	// TODO: Здесь будет логика активации спец способности в зависимости от бренда шасси
	// Пока просто placeholder
	to_chat(H, span_boldnotice("SPECIAL ABILITY ACTIVATED! (Placeholder - будет зависеть от бренда шасси)"))

	used = TRUE
	Remove(H)
	return TRUE

// ============================================
// 2. MAGNETIC JOINTS IMPLANT
// ============================================
// Магнитные суставы - защита от падений/толчков

/obj/item/implant/magnetic_joints
	name = "Magnetic Joints Implant"
	desc = "Магнитные суставы для IPC. Обеспечивают стабильность и защиту от падений."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY

/obj/item/implant/magnetic_joints/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Magnetic Joints Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Provides stability and prevents slipping.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/magnetic_joints/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
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

	// Даем трейт защиты от скольжения
	ADD_TRAIT(H, TRAIT_NO_SLIP_WATER, "magnetic_joints")
	ADD_TRAIT(H, TRAIT_HARDLY_WOUNDED, "magnetic_joints")

	if(!silent)
		to_chat(H, span_notice("Магнитные суставы активированы. Вы чувствуете повышенную стабильность."))
		to_chat(user, span_notice("Вы успешно установили имплант магнитных суставов."))

	return TRUE

/obj/item/implant/magnetic_joints/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	REMOVE_TRAIT(H, TRAIT_NO_SLIP_WATER, "magnetic_joints")
	REMOVE_TRAIT(H, TRAIT_HARDLY_WOUNDED, "magnetic_joints")

	if(!silent)
		to_chat(H, span_warning("Магнитные суставы деактивированы."))

/obj/item/implantcase/magnetic_joints
	name = "implant case - 'Magnetic Joints'"
	desc = "Стеклянный кейс содержащий имплант магнитных суставов."
	imp_type = /obj/item/implant/magnetic_joints

// ============================================
// 3. SEALED JOINTS IMPLANT
// ============================================
// Укрепленные суставы - больше HP частям тела

/obj/item/implant/sealed_joints
	name = "Sealed Joints Implant"
	desc = "Укрепленные герметичные суставы для IPC. Увеличивают прочность частей тела."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY

/obj/item/implant/sealed_joints/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Sealed Joints Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Reinforces body parts, increasing max damage.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/sealed_joints/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
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

	// Увеличиваем max_damage всех частей тела на 20%
	for(var/obj/item/bodypart/part in H.bodyparts)
		part.max_damage *= 1.2

	if(!silent)
		to_chat(H, span_notice("Герметичные суставы установлены. Ваша конструкция усилена."))
		to_chat(user, span_notice("Вы успешно установили имплант укрепленных суставов."))

	return TRUE

/obj/item/implant/sealed_joints/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Возвращаем max_damage к норме
	for(var/obj/item/bodypart/part in H.bodyparts)
		part.max_damage /= 1.2

	if(!silent)
		to_chat(H, span_warning("Герметичные суставы удалены."))

/obj/item/implantcase/sealed_joints
	name = "implant case - 'Sealed Joints'"
	desc = "Стеклянный кейс содержащий имплант укрепленных суставов."
	imp_type = /obj/item/implant/sealed_joints

// ============================================
// 4. REACTIVE REPAIR IMPLANT
// ============================================
// Реактивный ремонт - автоматически чинит повреждения

/obj/item/implant/reactive_repair
	name = "Reactive Repair Implant"
	desc = "Система автоматического ремонта для IPC. Активируется при получении повреждений."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY
	var/repair_amount = 2 // Сколько HP чинит за раз
	var/repair_cooldown = 30 SECONDS
	var/last_repair_time = 0

/obj/item/implant/reactive_repair/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Reactive Repair Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Automatic repair on damage (2 HP every 30 seconds).<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/reactive_repair/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
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

	// Регистрируем сигнал на получение урона
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))

	if(!silent)
		to_chat(H, span_notice("Система реактивного ремонта активирована."))
		to_chat(user, span_notice("Вы успешно установили имплант реактивного ремонта."))

	return TRUE

/obj/item/implant/reactive_repair/proc/on_damage(mob/living/carbon/human/source, damage, damagetype)
	SIGNAL_HANDLER

	// Проверяем кулдаун
	if(world.time < last_repair_time + repair_cooldown)
		return

	// Чиним случайную поврежденную часть тела
	var/list/damaged_parts = list()
	for(var/obj/item/bodypart/part in source.bodyparts)
		if(part.brute_dam > 0 || part.burn_dam > 0)
			damaged_parts += part

	if(!length(damaged_parts))
		return

	var/obj/item/bodypart/part = pick(damaged_parts)

	if(part.brute_dam > part.burn_dam)
		part.heal_damage(repair_amount, 0)
		to_chat(source, span_notice("Система реактивного ремонта устраняет механические повреждения [part.plaintext_zone]."))
	else
		part.heal_damage(0, repair_amount)
		to_chat(source, span_notice("Система реактивного ремонта устраняет термические повреждения [part.plaintext_zone]."))

	last_repair_time = world.time

/obj/item/implant/reactive_repair/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE)

	if(!silent)
		to_chat(H, span_warning("Система реактивного ремонта деактивирована."))

/obj/item/implantcase/reactive_repair
	name = "implant case - 'Reactive Repair'"
	desc = "Стеклянный кейс содержащий имплант реактивного ремонта."
	imp_type = /obj/item/implant/reactive_repair

// ============================================
// 5. EMP-PROTECTOR
// ============================================
// Защита от ЕМП с ограниченными зарядами, но греет

/obj/item/implant/emp_protector
	name = "EMP-Protector Implant"
	desc = "Защита от ЕМП ударов для синтетиков. Имеет ограниченные заряды и нагревает процессор при активации."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY
	var/max_charges = 3
	var/charges = 3
	var/heat_per_use = 15 // Градусов нагрева при активации

/obj/item/implant/emp_protector/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> EMP-Protector Implant<BR>
	<b>Life:</b> Limited charges ([charges]/[max_charges])<BR>
	<b>Function:</b> Blocks EMP damage (heats CPU by +[heat_per_use]°C per use).<BR>
	<b>Status:</b> [charges > 0 ? "ACTIVE" : "DEPLETED"]"}
	return dat

/obj/item/implant/emp_protector/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	// Регистрируем обработку ЕМП
	RegisterSignal(imp_in, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

	if(!silent && ishuman(imp_in))
		to_chat(imp_in, span_notice("EMP-протектор активирован. Зарядов: [charges]/[max_charges]"))
		to_chat(user, span_notice("Вы успешно установили EMP-протектор."))

	return TRUE

/obj/item/implant/emp_protector/proc/on_emp(atom/source, severity)
	SIGNAL_HANDLER

	if(charges <= 0)
		return

	if(!ishuman(imp_in))
		return

	var/mob/living/carbon/human/H = imp_in

	// Используем заряд
	charges--

	// Нагреваем процессор если это IPC
	if(istype(H.dna?.species, /datum/species/ipc))
		var/datum/species/ipc/S = H.dna.species
		S.cpu_temperature = min(S.cpu_temperature + heat_per_use, 200)
		to_chat(H, span_warning("EMP-протектор блокировал удар! Процессор нагрелся на [heat_per_use]°C. Осталось зарядов: [charges]/[max_charges]"))
	else
		to_chat(H, span_notice("EMP-протектор блокировал удар! Осталось зарядов: [charges]/[max_charges]"))

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
// 6. MAGNETIC LEG
// ============================================
// Магнитные ботинки встроенные в ноги

/obj/item/implant/magnetic_leg
	name = "Magnetic Leg Implant"
	desc = "Магнитные модули для ног. Функционируют как встроенные магнитные ботинки."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY
	var/magboots_active = FALSE

/obj/item/implant/magnetic_leg/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Magnetic Leg Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Built-in magboots (toggle-able).<BR>
	<b>Status:</b> [magboots_active ? "ACTIVE" : "INACTIVE"]"}
	return dat

/obj/item/implant/magnetic_leg/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target

	// Даем абилку переключения магбутов
	var/datum/action/toggle_magboots/toggle = new()
	toggle.Grant(H)
	toggle.implant = src

	if(!silent)
		to_chat(H, span_notice("Магнитные модули ног установлены. Используйте абилку для активации."))
		to_chat(user, span_notice("Вы успешно установили имплант магнитных ног."))

	return TRUE

/obj/item/implant/magnetic_leg/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Отключаем магбуты если активны
	if(magboots_active)
		REMOVE_TRAIT(H, TRAIT_NO_SLIP_ALL, "magnetic_leg")
		H.add_movespeed_modifier(/datum/movespeed_modifier/magboots/negate)

	// Удаляем абилку
	var/datum/action/toggle_magboots/action = locate() in H.actions
	if(action)
		action.Remove(H)

	if(!silent)
		to_chat(H, span_warning("Магнитные модули ног удалены."))

// Абилка переключения магбутов
/datum/action/toggle_magboots
	name = "Toggle Magnetic Boots"
	desc = "Активировать/деактивировать встроенные магнитные ботинки."
	button_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
	background_icon_state = "bg_tech"
	var/obj/item/implant/magnetic_leg/implant

/datum/action/toggle_magboots/Activate(atom/target)
	if(!implant)
		return

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	implant.magboots_active = !implant.magboots_active

	if(implant.magboots_active)
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

/obj/item/implantcase/magnetic_leg
	name = "implant case - 'Magnetic Leg'"
	desc = "Стеклянный кейс содержащий имплант магнитных ног."
	imp_type = /obj/item/implant/magnetic_leg

// ============================================
// 7. A.R.S.T.M (Advanced Reagent Scanner and Tracking Module)
// ============================================
// Для парамедиков - встроенный экран экипажа в мозг

/obj/item/implant/crew_monitor
	name = "A.R.S.T.M Implant"
	desc = "Advanced Reagent Scanner and Tracking Module. Встроенный в мозг экран мониторинга экипажа для парамедиков. Частота обновления ниже чем у портативного устройства."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY

/obj/item/implant/crew_monitor/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> A.R.S.T.M Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Built-in crew monitor (lower refresh rate).<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/crew_monitor/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target

	// Даем абилку открытия crew monitor
	var/datum/action/open_crew_monitor/monitor = new()
	monitor.Grant(H)

	if(!silent)
		to_chat(H, span_notice("A.R.S.T.M имплант активирован. Доступен мониторинг экипажа."))
		to_chat(user, span_notice("Вы успешно установили A.R.S.T.M имплант."))

	return TRUE

/obj/item/implant/crew_monitor/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/H = source

	// Удаляем абилку
	var/datum/action/open_crew_monitor/action = locate() in H.actions
	if(action)
		action.Remove(H)

	if(!silent)
		to_chat(H, span_warning("A.R.S.T.M имплант деактивирован."))

// Абилка открытия crew monitor
/datum/action/open_crew_monitor
	name = "Open Crew Monitor"
	desc = "Открыть встроенный монитор состояния экипажа."
	button_icon = 'icons/mob/actions/actions_medical.dmi'
	button_icon_state = "health_analyzer"
	background_icon_state = "bg_tech"

/datum/action/open_crew_monitor/Activate(atom/target)
	// TODO: Открыть UI crew monitor
	// Пока просто placeholder
	to_chat(owner, span_notice("Crew monitor interface (TODO: implement UI)"))

/obj/item/implantcase/crew_monitor
	name = "implant case - 'A.R.S.T.M'"
	desc = "Стеклянный кейс содержащий A.R.S.T.M имплант."
	imp_type = /obj/item/implant/crew_monitor

// ============================================
// 8. БИО-ГЕНЕРАТОР
// ============================================
// Позволяет IPC переваривать еду

/obj/item/implant/bio_generator
	name = "Bio-Generator Implant"
	desc = "Биологический генератор для IPC. Позволяет перерабатывать органическую пищу в энергию."
	icon = 'icons/obj/medical/implants.dmi'
	icon_state = "implant_default"
	w_class = WEIGHT_CLASS_TINY

/obj/item/implant/bio_generator/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Bio-Generator Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Function:</b> Allows IPC to digest organic food for energy.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/bio_generator/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
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

	// Убираем трейт NOHUNGER и добавляем возможность есть
	REMOVE_TRAIT(H, TRAIT_NOHUNGER, SPECIES_TRAIT)

	// Регистрируем обработку еды
	RegisterSignal(H, COMSIG_FOOD_EATEN, PROC_REF(on_food_eaten))

	if(!silent)
		to_chat(H, span_notice("Био-генератор активирован. Вы можете употреблять органическую пищу."))
		to_chat(user, span_notice("Вы успешно установили био-генератор."))

	return TRUE

/obj/item/implant/bio_generator/proc/on_food_eaten(mob/living/carbon/human/source, atom/food, mob/feeder)
	SIGNAL_HANDLER

	if(!istype(source.dna?.species, /datum/species/ipc))
		return

	var/datum/species/ipc/S = source.dna.species

	// Получаем батарею IPC
	var/obj/item/organ/heart/ipc_battery/battery = source.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery)
		return

	// Преобразуем еду в энергию (10% от nutrition как заряд)
	// Предполагаем что еда дает ~5-10 nutrition
	var/energy_gain = 50 // Примерно 50 единиц заряда за прием пищи

	battery.charge = min(battery.charge + energy_gain, battery.maxcharge)
	to_chat(source, span_notice("Био-генератор переработал пищу в [energy_gain] единиц энергии."))

/obj/item/implant/bio_generator/removed(mob/living/source, silent = FALSE, special = FALSE)
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

/obj/item/implantcase/bio_generator
	name = "implant case - 'Bio-Generator'"
	desc = "Стеклянный кейс содержащий имплант био-генератора."
	imp_type = /obj/item/implant/bio_generator
