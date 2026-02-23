// ============================================
// БОЕВЫЕ И СПЕЦИАЛЬНЫЕ ИМПЛАНТЫ ДЛЯ IPC
// ============================================
// arm_razor — лезвие в руке (пассивный урон)
// mantis — лезвия богомола (переключаемые)
// military_mantis — военные лезвия богомола (улучшенные)
// arm_cannon — пушка в руке (активная способность)
// sandy — Сандевистан (временное ускорение)
// mmi_core — альтернативное позитронное ядро на основе MMI
// ============================================

// ============================================
// 1. ARM RAZOR — ЛЕЗВИЕ В РУКЕ
// ============================================
// Пассивный имплант. Безоружные атаки наносят доп. brute урон.

/obj/item/implant/ipc/arm_razor
	name = "Arm Razor Implant"
	desc = "Выдвижное лезвие, встроенное в предплечье IPC. Безоружные атаки наносят дополнительный режущий урон."
	icon_state = "arm_razor"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	/// Дополнительный урон при безоружной атаке
	var/bonus_damage = 8

/obj/item/implant/ipc/arm_razor/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Arm Razor Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> +[bonus_damage] brute damage on unarmed attacks.<BR>
	<b>Integrity:</b> Active"}
	return dat

/obj/item/implant/ipc/arm_razor/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
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

	RegisterSignal(H, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

	if(!silent)
		to_chat(H, span_notice("Лезвие установлено в [installed_in_zone]. Безоружные атаки наносят дополнительный урон."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили лезвие."))
	return TRUE

/obj/item/implant/ipc/arm_razor/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!proximity || !isliving(target))
		return
	var/mob/living/victim = target
	victim.apply_damage(bonus_damage, BRUTE, source.zone_selected)

/obj/item/implant/ipc/arm_razor/removed(mob/living/source, silent = FALSE, special = FALSE)
	if(ishuman(source))
		UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Лезвие извлечено."))

/obj/item/implantcase/ipc/arm_razor
	name = "implant case - 'Arm Razor'"
	desc = "Стеклянный кейс содержащий имплант лезвия для руки IPC."
	imp_type = /obj/item/implant/ipc/arm_razor

// ============================================
// 2. MANTIS BLADES — ЛЕЗВИЯ БОГОМОЛА
// ============================================
// Переключаемый имплант. Левая/правая рука.
// В активном режиме: +15 brute, тратит батарею.

/obj/item/implant/ipc/mantis
	name = "Mantis Blade Implant"
	desc = "Выдвижные лезвия богомола для IPC. Активируются по команде. В развёрнутом состоянии наносят тяжёлый режущий урон."
	icon_state = "mantis_right"
	allowed_zones = list(BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/toggle_mantis)
	/// Дополнительный урон в активном режиме
	var/blade_damage = 15
	/// Расход батареи за атаку
	var/power_per_attack = 10
	/// Лезвия развёрнуты?
	var/blades_active = FALSE

/obj/item/implant/ipc/mantis/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Mantis Blade Implant<BR>
	<b>Life:</b> Depends on battery charge<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Deployable blades (+[blade_damage] brute, costs [power_per_attack] charge/hit).<BR>
	<b>Status:</b> [blades_active ? "DEPLOYED" : "RETRACTED"]"}
	return dat

/obj/item/implant/ipc/mantis/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
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

	RegisterSignal(H, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

	if(!silent)
		to_chat(H, span_notice("Лезвия богомола установлены в [installed_in_zone]. Используйте способность для активации."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили лезвия богомола."))
	return TRUE

/obj/item/implant/ipc/mantis/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!blades_active || !proximity || !isliving(target))
		return
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return

	// Проверяем батарею
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery || battery.charge < power_per_attack)
		to_chat(H, span_warning("Недостаточно заряда для атаки лезвиями!"))
		return

	battery.charge = max(battery.charge - power_per_attack, 0)
	var/mob/living/victim = target
	victim.apply_damage(blade_damage, BRUTE, H.zone_selected)
	playsound(H, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)

/obj/item/implant/ipc/mantis/removed(mob/living/source, silent = FALSE, special = FALSE)
	if(blades_active)
		blades_active = FALSE
	if(ishuman(source))
		UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Лезвия богомола извлечены."))

// Левая рука
/obj/item/implant/ipc/mantis/left
	name = "Mantis Blade Implant (Left)"
	desc = "Выдвижные лезвия богомола для левой руки IPC."
	icon_state = "mantis_left"
	allowed_zones = list(BODY_ZONE_L_ARM)

/obj/item/implantcase/ipc/mantis_right
	name = "implant case - 'Mantis Blade (Right)'"
	desc = "Стеклянный кейс содержащий имплант лезвий богомола для правой руки."
	imp_type = /obj/item/implant/ipc/mantis

/obj/item/implantcase/ipc/mantis_left
	name = "implant case - 'Mantis Blade (Left)'"
	desc = "Стеклянный кейс содержащий имплант лезвий богомола для левой руки."
	imp_type = /obj/item/implant/ipc/mantis/left

// Action для переключения лезвий
/datum/action/item_action/toggle_mantis
	name = "Toggle Mantis Blades"
	desc = "Развернуть/свернуть лезвия богомола."
	button_icon = 'icons/obj/items_and_weapons.dmi'
	button_icon_state = "dvs-sword-on"
	background_icon_state = "bg_tech"

/datum/action/item_action/toggle_mantis/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/implant/ipc/mantis/mantis_implant = target
	if(!istype(mantis_implant))
		return FALSE

	mantis_implant.blades_active = !mantis_implant.blades_active

	if(mantis_implant.blades_active)
		to_chat(owner, span_warning("Лезвия богомола развёрнуты!"))
		playsound(owner, 'sound/items/weapons/switchblade.ogg', 50, TRUE)
		button_icon_state = "dvs-sword-on"
	else
		to_chat(owner, span_notice("Лезвия богомола свёрнуты."))
		playsound(owner, 'sound/items/weapons/switchblade.ogg', 30, TRUE)
		button_icon_state = "dvs-sword-off"

	build_all_button_icons()
	return TRUE

// ============================================
// 3. MILITARY MANTIS — ВОЕННЫЕ ЛЕЗВИЯ БОГОМОЛА
// ============================================
// Улучшенная версия: больше урона, пробивает броню.

/obj/item/implant/ipc/military_mantis
	name = "Military Mantis Blade Implant"
	desc = "Военная модификация лезвий богомола. Увеличенный урон и способность пробивать броню."
	icon_state = "military_mantis_right"
	allowed_zones = list(BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/toggle_mantis)
	/// Урон в активном режиме
	var/blade_damage = 22
	/// Расход батареи за атаку
	var/power_per_attack = 15
	/// Лезвия развёрнуты?
	var/blades_active = FALSE

/obj/item/implant/ipc/military_mantis/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Military Mantis Blade Implant<BR>
	<b>Life:</b> Depends on battery charge<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Military-grade blades (+[blade_damage] brute, armor-piercing, costs [power_per_attack] charge/hit).<BR>
	<b>Status:</b> [blades_active ? "DEPLOYED" : "RETRACTED"]"}
	return dat

/obj/item/implant/ipc/military_mantis/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
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

	RegisterSignal(H, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

	if(!silent)
		to_chat(H, span_notice("Военные лезвия установлены в [installed_in_zone]."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили военные лезвия богомола."))
	return TRUE

/obj/item/implant/ipc/military_mantis/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!blades_active || !proximity || !isliving(target))
		return
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return

	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery || battery.charge < power_per_attack)
		to_chat(H, span_warning("Недостаточно заряда для атаки!"))
		return

	battery.charge = max(battery.charge - power_per_attack, 0)
	var/mob/living/victim = target
	// Военные лезвия игнорируют часть брони
	victim.apply_damage(blade_damage, BRUTE, H.zone_selected, wound_bonus = 10)
	playsound(H, 'sound/items/weapons/bladeslice.ogg', 60, TRUE)

/obj/item/implant/ipc/military_mantis/removed(mob/living/source, silent = FALSE, special = FALSE)
	if(blades_active)
		blades_active = FALSE
	if(ishuman(source))
		UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Военные лезвия извлечены."))

// Левая рука
/obj/item/implant/ipc/military_mantis/left
	name = "Military Mantis Blade Implant (Left)"
	desc = "Военная модификация лезвий богомола для левой руки."
	icon_state = "military_mantis_left"
	allowed_zones = list(BODY_ZONE_L_ARM)

/obj/item/implantcase/ipc/military_mantis_right
	name = "implant case - 'Military Mantis (Right)'"
	desc = "Стеклянный кейс содержащий имплант военных лезвий богомола для правой руки."
	imp_type = /obj/item/implant/ipc/military_mantis

/obj/item/implantcase/ipc/military_mantis_left
	name = "implant case - 'Military Mantis (Left)'"
	desc = "Стеклянный кейс содержащий имплант военных лезвий богомола для левой руки."
	imp_type = /obj/item/implant/ipc/military_mantis/left

// ============================================
// 4. ARM CANNON — ПУШКА В РУКЕ
// ============================================
// Активный имплант. Стреляет лазерным лучом.
// Расходует батарею и греет процессор.

/obj/item/implant/ipc/arm_cannon
	name = "Arm Cannon Implant"
	desc = "Встроенная энергетическая пушка в руке IPC. Стреляет лазерным лучом. Расходует значительный заряд батарейки и нагревает процессор."
	icon_state = "arm_cannon"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/fire_arm_cannon)
	/// Урон снаряда
	var/projectile_damage = 20
	/// Стоимость выстрела в заряде батареи
	var/power_cost = 100
	/// Нагрев CPU за выстрел
	var/heat_per_shot = 10
	/// Кулдаун между выстрелами
	var/fire_cooldown = 4 SECONDS
	/// Время последнего выстрела
	var/last_fire_time = 0

/obj/item/implant/ipc/arm_cannon/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Arm Cannon Implant<BR>
	<b>Life:</b> Depends on battery charge<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Fires energy bolt ([projectile_damage] damage, costs [power_cost] charge, +[heat_per_shot]°C).<BR>
	<b>Cooldown:</b> [fire_cooldown / 10]s"}
	return dat

/obj/item/implant/ipc/arm_cannon/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
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
	if(!silent)
		to_chat(H, span_notice("Энергетическая пушка установлена в [installed_in_zone]."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили энергетическую пушку."))
	return TRUE

/// Попытка выстрела
/obj/item/implant/ipc/arm_cannon/proc/try_fire(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	// Проверяем кулдаун
	if(world.time < last_fire_time + fire_cooldown)
		var/remaining = round((last_fire_time + fire_cooldown - world.time) / 10, 0.1)
		to_chat(user, span_warning("Пушка перезаряжается! Осталось [remaining]с."))
		return FALSE

	// Проверяем батарею
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery || battery.charge < power_cost)
		to_chat(user, span_warning("Недостаточно заряда для выстрела!"))
		return FALSE

	// Расходуем ресурсы
	battery.charge = max(battery.charge - power_cost, 0)
	last_fire_time = world.time

	// Нагреваем CPU
	var/datum/species/ipc/ipc_species = user.dna?.species
	if(istype(ipc_species))
		ipc_species.cpu_temperature = min(ipc_species.cpu_temperature + heat_per_shot, 200)

	// Стреляем в направлении взгляда
	var/turf/target_turf = get_ranged_target_turf(user, user.dir, 7)
	if(!target_turf)
		return FALSE

	var/obj/projectile/beam/laser/ipc_cannon/P = new(get_turf(user))
	P.preparePixelProjectile(target_turf, user)
	P.firer = user
	P.fired_from = user
	P.damage = projectile_damage
	P.fire()

	playsound(user, 'sound/items/weapons/laser.ogg', 50, TRUE)
	to_chat(user, span_warning("Пушка выстрелила! Батарея: [round(battery.charge)]/[battery.maxcharge]"))
	return TRUE

/obj/item/implant/ipc/arm_cannon/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Энергетическая пушка извлечена."))

/obj/item/implantcase/ipc/arm_cannon
	name = "implant case - 'Arm Cannon'"
	desc = "Стеклянный кейс содержащий имплант энергетической пушки."
	imp_type = /obj/item/implant/ipc/arm_cannon

// Снаряд пушки
/obj/projectile/beam/laser/ipc_cannon
	name = "energy bolt"
	icon_state = "laser"
	damage = 20
	damage_type = BURN

// Action для выстрела
/datum/action/item_action/fire_arm_cannon
	name = "Fire Arm Cannon"
	desc = "Выстрелить из встроенной энергетической пушки."
	button_icon = 'icons/obj/items_and_weapons.dmi'
	button_icon_state = "dvs-sword-on"
	background_icon_state = "bg_tech"

/datum/action/item_action/fire_arm_cannon/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/implant/ipc/arm_cannon/cannon = target
	if(!istype(cannon))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	cannon.try_fire(H)
	return TRUE

// ============================================
// 5. SANDEVISTAN (SANDY) — САНДЕВИСТАН
// ============================================
// Активный имплант в грудь. Временное ускорение.
// Большой расход батареи + нагрев CPU.

/obj/item/implant/ipc/sandevistan
	name = "Sandevistan Implant"
	desc = "Сандевистан — имплант рефлекторного ускорения. Временно повышает скорость перемещения IPC на 50%. Сильно расходует батарею и нагревает процессор."
	icon_state = "sandy"
	allowed_zones = list(BODY_ZONE_CHEST)
	actions_types = list(/datum/action/item_action/activate_sandevistan)
	/// Бонус скорости (отрицательное = быстрее)
	var/speed_bonus = -0.5
	/// Длительность эффекта
	var/effect_duration = 5 SECONDS
	/// Стоимость активации в заряде батареи
	var/power_cost = 250
	/// Нагрев CPU при активации
	var/heat_on_use = 20
	/// Кулдаун
	var/ability_cooldown = 30 SECONDS
	/// Время последнего использования
	var/last_use_time = 0
	/// Сейчас активен?
	var/is_active = FALSE

/obj/item/implant/ipc/sandevistan/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Sandevistan Implant<BR>
	<b>Life:</b> Depends on battery charge<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> 50% speed boost for [effect_duration / 10]s (costs [power_cost] charge, +[heat_on_use]°C).<BR>
	<b>Cooldown:</b> [ability_cooldown / 10]s<BR>
	<b>Status:</b> [is_active ? "ACTIVE" : "STANDBY"]"}
	return dat

/obj/item/implant/ipc/sandevistan/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
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
	if(!silent)
		to_chat(H, span_notice("Сандевистан установлен. Активируйте для временного ускорения."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили Сандевистан."))
	return TRUE

/// Активация сандевистана
/obj/item/implant/ipc/sandevistan/proc/activate(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(is_active)
		to_chat(user, span_warning("Сандевистан уже активен!"))
		return FALSE

	// Проверяем кулдаун
	if(world.time < last_use_time + ability_cooldown)
		var/remaining = round((last_use_time + ability_cooldown - world.time) / 10, 0.1)
		to_chat(user, span_warning("Сандевистан перезаряжается! Осталось [remaining]с."))
		return FALSE

	// Проверяем батарею
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(!battery || battery.charge < power_cost)
		to_chat(user, span_warning("Недостаточно заряда для активации Сандевистана!"))
		return FALSE

	// Расходуем ресурсы
	battery.charge = max(battery.charge - power_cost, 0)
	last_use_time = world.time
	is_active = TRUE

	// Нагреваем CPU
	var/datum/species/ipc/ipc_species = user.dna?.species
	if(istype(ipc_species))
		ipc_species.cpu_temperature = min(ipc_species.cpu_temperature + heat_on_use, 200)

	// Применяем ускорение
	var/datum/movespeed_modifier/ipc_sandevistan/mod = new()
	mod.multiplicative_slowdown = speed_bonus
	user.add_movespeed_modifier(mod, update = TRUE)

	to_chat(user, span_boldwarning("САНДЕВИСТАН АКТИВИРОВАН! Мир замедляется вокруг вас..."))
	playsound(user, 'sound/effects/magic/charge.ogg', 50, TRUE)

	// Таймер деактивации
	addtimer(CALLBACK(src, PROC_REF(deactivate), user), effect_duration)
	return TRUE

/// Деактивация сандевистана
/obj/item/implant/ipc/sandevistan/proc/deactivate(mob/living/carbon/human/user)
	if(!is_active)
		return
	is_active = FALSE

	if(!user || QDELETED(user))
		return

	// Убираем ускорение
	for(var/datum/movespeed_modifier/ipc_sandevistan/mod in user.movespeed_modification)
		user.remove_movespeed_modifier(mod)

	to_chat(user, span_notice("Сандевистан деактивирован. Нормальная скорость восстановлена."))

/obj/item/implant/ipc/sandevistan/removed(mob/living/source, silent = FALSE, special = FALSE)
	if(is_active && ishuman(source))
		deactivate(source)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Сандевистан извлечён."))

/obj/item/implantcase/ipc/sandevistan
	name = "implant case - 'Sandevistan'"
	desc = "Стеклянный кейс содержащий имплант Сандевистан — систему рефлекторного ускорения."
	imp_type = /obj/item/implant/ipc/sandevistan

// Модификатор скорости для сандевистана
/datum/movespeed_modifier/ipc_sandevistan
	variable = TRUE
	multiplicative_slowdown = 0

// Action для активации
/datum/action/item_action/activate_sandevistan
	name = "Activate Sandevistan"
	desc = "Активировать Сандевистан — временное рефлекторное ускорение."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_nanites"
	background_icon_state = "bg_tech"

/datum/action/item_action/activate_sandevistan/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/implant/ipc/sandevistan/sandy = target
	if(!istype(sandy))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	sandy.activate(H)
	return TRUE

// ============================================
// 6. MMI CORE — ПОЗИТРОННОЕ ЯДРО НА БАЗЕ MMI
// ============================================
// Альтернативное ядро с повышенной устойчивостью к повреждениям.

/obj/item/organ/brain/positronic/mmi_core
	name = "MMI positronic core"
	desc = "Усовершенствованное позитронное ядро на основе интерфейса мозг-машина. Повышенная устойчивость к повреждениям."
	icon = 'modular_bandastation/MachAImpDe/icons/organs.dmi'
	icon_state = "mmi_core"
	brain_type = "mmi_core"
	max_damage = 120

// ============================================
// ПРЕДУСТАНОВЛЕННЫЕ AUTOSURGEONS
// ============================================

/obj/item/autosurgeon/ipc/arm_razor
	desc = "Одноразовый IPC autosurgeon с имплантом лезвия. Добавляет режущий урон к безоружным атакам."
	uses = 1

/obj/item/autosurgeon/ipc/arm_razor/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/arm_razor(src))

/obj/item/autosurgeon/ipc/mantis_right
	desc = "Одноразовый IPC autosurgeon с имплантом лезвий богомола для правой руки."
	uses = 1

/obj/item/autosurgeon/ipc/mantis_right/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/mantis(src))

/obj/item/autosurgeon/ipc/mantis_left
	desc = "Одноразовый IPC autosurgeon с имплантом лезвий богомола для левой руки."
	uses = 1

/obj/item/autosurgeon/ipc/mantis_left/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/mantis/left(src))

/obj/item/autosurgeon/ipc/military_mantis_right
	desc = "Одноразовый IPC autosurgeon с имплантом военных лезвий для правой руки."
	uses = 1

/obj/item/autosurgeon/ipc/military_mantis_right/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/military_mantis(src))

/obj/item/autosurgeon/ipc/military_mantis_left
	desc = "Одноразовый IPC autosurgeon с имплантом военных лезвий для левой руки."
	uses = 1

/obj/item/autosurgeon/ipc/military_mantis_left/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/military_mantis/left(src))

/obj/item/autosurgeon/ipc/arm_cannon
	desc = "Одноразовый IPC autosurgeon с имплантом энергетической пушки."
	uses = 1

/obj/item/autosurgeon/ipc/arm_cannon/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/arm_cannon(src))

/obj/item/autosurgeon/ipc/sandevistan
	desc = "Одноразовый IPC autosurgeon с имплантом Сандевистан."
	uses = 1

/obj/item/autosurgeon/ipc/sandevistan/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/sandevistan(src))
