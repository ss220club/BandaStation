// ============================================
// БОЕВЫЕ И СПЕЦИАЛЬНЫЕ ИМПЛАНТЫ
// ============================================
// arm_razor — моновайер/струна (активная атака на 1 тайл, dismember)
// mantis — лезвия богомола (переключаемые, dismember, прыжок при парных)
// military_mantis — военные лезвия богомола (улучшенные)
// arm_cannon — дробовик в руке (заряжается дробью)
// sandy — Сандевистан (временное ускорение)
// Работают как для IPC, так и для органиков.
// У IPC расходуют заряд батареи и/или греют CPU.
// ============================================

// ============================================
// 1. ARM RAZOR — СТРУНА / МОНОВАЙЕР
// ============================================
// Активный имплант. Атака на 1 тайл вперёд.
// Высокий шанс dismember (отрезание конечности).

/obj/item/implant/ipc/arm_razor
	name = "Arm Razor Implant"
	desc = "Моноволоконная струна, встроенная в предплечье. Выдвигается для режущей атаки на ближнюю дистанцию. Способна отрезать конечности."
	icon_state = "arm_razor"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/activate_arm_razor)
	/// Урон за удар
	var/slash_damage = 20
	/// Бонус к ранам (для dismember)
	var/slash_wound_bonus = 30
	/// Кулдаун между атаками
	var/slash_cooldown = 2 SECONDS
	/// Время последней атаки
	var/last_slash_time = 0

/obj/item/implant/ipc/arm_razor/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Arm Razor Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Monofilament slash ([slash_damage] brute, high dismember chance).<BR>
	<b>Cooldown:</b> [slash_cooldown / 10]s"}
	return dat

/obj/item/implant/ipc/arm_razor/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/H = target

	if(!silent)
		to_chat(H, span_notice("Моноволоконная струна установлена в [installed_in_zone]. Используйте способность для атаки."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили струну."))
	return TRUE

/// Активация атаки струной — бьёт моба на 1 тайл вперёд
/obj/item/implant/ipc/arm_razor/proc/do_slash(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	// Кулдаун
	if(world.time < last_slash_time + slash_cooldown)
		to_chat(user, span_warning("Струна ещё не готова!"))
		return FALSE

	// Ищем живую цель на 1 тайл вперёд
	var/turf/target_turf = get_step(user, user.dir)
	if(!target_turf)
		return FALSE

	var/mob/living/victim = locate(/mob/living) in target_turf
	if(!victim)
		to_chat(user, span_warning("Нет цели перед вами."))
		return FALSE

	last_slash_time = world.time

	// Анимация атаки
	user.do_attack_animation(victim)
	playsound(user, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)

	// Наносим урон с высоким wound_bonus и sharpness для dismember
	victim.apply_damage(slash_damage, BRUTE, user.zone_selected, wound_bonus = slash_wound_bonus, sharpness = SHARP_EDGED)

	// Попытка dismember выбранной зоны
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/bodypart/target_part = H.get_bodypart(user.zone_selected)
		if(target_part && target_part.body_zone != BODY_ZONE_CHEST && target_part.body_zone != BODY_ZONE_HEAD)
			target_part.try_dismember(WOUND_SLASH, slash_damage, slash_wound_bonus)

	victim.visible_message(
		span_danger("[user] полоснул [victim] моноволоконной струной!"),
		span_userdanger("[user] полоснул вас моноволоконной струной!"))

	return TRUE

/obj/item/implant/ipc/arm_razor/removed(mob/living/source, silent = FALSE, special = FALSE)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Струна извлечена."))

/obj/item/implantcase/ipc/arm_razor
	name = "implant case - 'Arm Razor'"
	desc = "Стеклянный кейс содержащий имплант моноволоконной струны."
	imp_type = /obj/item/implant/ipc/arm_razor

// Action для атаки струной
/datum/action/item_action/activate_arm_razor
	name = "Razor Slash"
	desc = "Атаковать струной цель перед собой."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_nanites"
	background_icon_state = "bg_tech"

/datum/action/item_action/activate_arm_razor/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/implant/ipc/arm_razor/razor = target
	if(!istype(razor))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	razor.do_slash(H)
	return TRUE

// ============================================
// 2. MANTIS BLADES — ЛЕЗВИЯ БОГОМОЛА
// ============================================
// Переключаемый имплант. Левая/правая рука.
// В активном режиме: доп. brute урон + dismember.
// При парных лезвиях (L+R) — способность прыжка.

/obj/item/implant/ipc/mantis
	name = "Mantis Blade Implant"
	desc = "Выдвижные лезвия богомола. В развёрнутом состоянии наносят тяжёлый режущий урон и могут отрезать конечности."
	icon_state = "mantis_right"
	allowed_zones = list(BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/toggle_mantis)
	/// Урон в активном режиме
	var/blade_damage = 15
	/// Бонус к ранам для dismember
	var/blade_wound_bonus = 20
	/// Расход батареи за атаку (только IPC)
	var/power_per_attack = 10
	/// Лезвия развёрнуты?
	var/blades_active = FALSE
	/// Прыжок на кулдауне?
	var/leap_cooldown_time = 15 SECONDS
	/// Время последнего прыжка
	var/last_leap_time = 0
	/// Дальность прыжка
	var/leap_range = 5
	/// Сейчас в прыжке?
	var/leaping = FALSE

/obj/item/implant/ipc/mantis/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Mantis Blade Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Deployable blades (+[blade_damage] brute, dismember capable).<BR>
	<b>Status:</b> [blades_active ? "DEPLOYED" : "RETRACTED"]"}
	return dat

/obj/item/implant/ipc/mantis/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/H = target

	RegisterSignal(H, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

	// Проверяем парные лезвия — если есть оба, даём прыжок
	check_paired_mantis(H)

	if(!silent)
		to_chat(H, span_notice("Лезвия богомола установлены в [installed_in_zone]. Используйте способность для активации."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили лезвия богомола."))
	return TRUE

/// Проверяем наличие парных мантисов и выдаём/убираем прыжок
/obj/item/implant/ipc/mantis/proc/check_paired_mantis(mob/living/carbon/human/H)
	var/has_left = FALSE
	var/has_right = FALSE
	for(var/obj/item/implant/ipc/mantis/M in H.implants)
		if(BODY_ZONE_L_ARM in M.allowed_zones)
			has_left = TRUE
		if(BODY_ZONE_R_ARM in M.allowed_zones)
			has_right = TRUE

	var/datum/action/item_action/mantis_leap/existing_leap = locate() in H.actions
	if(has_left && has_right)
		if(!existing_leap)
			var/datum/action/item_action/mantis_leap/leap_action = new(src)
			leap_action.Grant(H)
	else
		if(existing_leap)
			existing_leap.Remove(H)

/obj/item/implant/ipc/mantis/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!blades_active || !proximity || !isliving(target))
		return
	var/mob/living/carbon/human/H = source
	if(!istype(H))
		return

	// Расход батареи только для IPC
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		if(battery.charge < power_per_attack)
			to_chat(H, span_warning("Недостаточно заряда для атаки лезвиями!"))
			return
		battery.charge = max(battery.charge - power_per_attack, 0)

	var/mob/living/victim = target
	// Урон с wound_bonus и sharpness для dismember
	victim.apply_damage(blade_damage, BRUTE, H.zone_selected, wound_bonus = blade_wound_bonus, sharpness = SHARP_EDGED)

	// Попытка dismember
	if(ishuman(victim))
		var/mob/living/carbon/human/V = victim
		var/obj/item/bodypart/target_part = V.get_bodypart(H.zone_selected)
		if(target_part && target_part.body_zone != BODY_ZONE_CHEST && target_part.body_zone != BODY_ZONE_HEAD)
			target_part.try_dismember(WOUND_SLASH, blade_damage, blade_wound_bonus)

	playsound(H, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)

/// Прыжок мантиса — прыжок в направлении взгляда
/obj/item/implant/ipc/mantis/proc/do_leap(mob/living/carbon/human/user)
	if(!istype(user) || leaping)
		return FALSE

	if(!blades_active)
		to_chat(user, span_warning("Сначала разверните лезвия!"))
		return FALSE

	// Кулдаун
	if(world.time < last_leap_time + leap_cooldown_time)
		var/remaining = round((last_leap_time + leap_cooldown_time - world.time) / 10, 0.1)
		to_chat(user, span_warning("Прыжок перезаряжается! Осталось [remaining]с."))
		return FALSE

	if(user.body_position == LYING_DOWN)
		to_chat(user, span_warning("Вы не можете прыгнуть лёжа!"))
		return FALSE

	// Расход батареи для IPC
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		if(battery.charge < 50)
			to_chat(user, span_warning("Недостаточно заряда для прыжка!"))
			return FALSE
		battery.charge = max(battery.charge - 50, 0)

	last_leap_time = world.time
	leaping = TRUE

	// Цель прыжка — тайл в направлении взгляда на макс. дистанцию
	var/turf/target_turf = get_ranged_target_turf(user, user.dir, leap_range)
	if(!target_turf)
		leaping = FALSE
		return FALSE

	// Регистрируем сигнал удара при приземлении
	RegisterSignal(user, COMSIG_MOVABLE_IMPACT, PROC_REF(on_leap_impact))

	to_chat(user, span_warning("Вы совершаете прыжок!"))
	playsound(user, 'sound/items/weapons/bladeslice.ogg', 60, TRUE)

	user.throw_at(target_turf, leap_range, 2, user, spin = FALSE, callback = CALLBACK(src, PROC_REF(leap_end), user))
	return TRUE

/// Обработка удара при прыжке
/obj/item/implant/ipc/mantis/proc/on_leap_impact(mob/living/source, atom/hit_atom)
	SIGNAL_HANDLER
	if(!leaping)
		return
	if(!isliving(hit_atom) || hit_atom == source)
		return

	var/mob/living/victim = hit_atom
	var/mob/living/carbon/human/user = source
	if(!istype(user))
		return

	// Урон при приземлении на врага
	victim.apply_damage(blade_damage * 1.5, BRUTE, user.zone_selected, wound_bonus = blade_wound_bonus + 10, sharpness = SHARP_EDGED)
	victim.Knockdown(2 SECONDS)

	victim.visible_message(
		span_danger("[user] прыгнул на [victim] с лезвиями богомола!"),
		span_userdanger("[user] обрушился на вас с лезвиями!"))

	playsound(victim, 'sound/items/weapons/bladeslice.ogg', 70, TRUE)

/// Конец прыжка
/obj/item/implant/ipc/mantis/proc/leap_end(mob/living/carbon/human/user)
	leaping = FALSE
	if(user && !QDELETED(user))
		UnregisterSignal(user, COMSIG_MOVABLE_IMPACT)

/obj/item/implant/ipc/mantis/removed(mob/living/source, silent = FALSE, special = FALSE)
	if(blades_active)
		blades_active = FALSE
	if(leaping && ishuman(source))
		leaping = FALSE
		UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(ishuman(source))
		UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)
		// Убираем прыжок если больше нет пары
		var/mob/living/carbon/human/H = source
		// Ждём удаления из списка имплантов перед проверкой
		addtimer(CALLBACK(src, PROC_REF(check_paired_mantis), H), 1)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Лезвия богомола извлечены."))

// Левая рука
/obj/item/implant/ipc/mantis/left
	name = "Mantis Blade Implant (Left)"
	desc = "Выдвижные лезвия богомола для левой руки."
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
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_nanites"
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
		playsound(owner, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)
		button_icon_state = "deploy_nanites"
	else
		to_chat(owner, span_notice("Лезвия богомола свёрнуты."))
		playsound(owner, 'sound/items/weapons/bladeslice.ogg', 30, TRUE)
		button_icon_state = "recall_nanites"

	build_all_button_icons()
	return TRUE

// Action для прыжка (выдаётся при парных лезвиях)
/datum/action/item_action/mantis_leap
	name = "Mantis Leap"
	desc = "Прыжок на врага с лезвиями богомола. Требуются парные лезвия."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "yourinjectors"
	background_icon_state = "bg_tech"

/datum/action/item_action/mantis_leap/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/implant/ipc/mantis/mantis_implant = target
	if(!istype(mantis_implant))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	mantis_implant.do_leap(H)
	return TRUE

// ============================================
// 3. MILITARY MANTIS — ВОЕННЫЕ ЛЕЗВИЯ БОГОМОЛА
// ============================================
// Улучшенная версия: больше урона, больше dismember.

/obj/item/implant/ipc/military_mantis
	name = "Military Mantis Blade Implant"
	desc = "Военная модификация лезвий богомола. Увеличенный урон и способность пробивать броню. Высокий шанс отрезания конечностей."
	icon_state = "military_mantis_right"
	allowed_zones = list(BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/toggle_mantis)
	/// Урон в активном режиме
	var/blade_damage = 22
	/// Бонус к ранам для dismember
	var/blade_wound_bonus = 35
	/// Расход батареи за атаку (только IPC)
	var/power_per_attack = 15
	/// Лезвия развёрнуты?
	var/blades_active = FALSE

/obj/item/implant/ipc/military_mantis/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Military Mantis Blade Implant<BR>
	<b>Life:</b> Permanent<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Military-grade blades (+[blade_damage] brute, armor-piercing, high dismember).<BR>
	<b>Status:</b> [blades_active ? "DEPLOYED" : "RETRACTED"]"}
	return dat

/obj/item/implant/ipc/military_mantis/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/H = target

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

	// Расход батареи только для IPC
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		if(battery.charge < power_per_attack)
			to_chat(H, span_warning("Недостаточно заряда для атаки!"))
			return
		battery.charge = max(battery.charge - power_per_attack, 0)

	var/mob/living/victim = target
	// Военные лезвия — высокий wound_bonus + sharpness + пробитие
	victim.apply_damage(blade_damage, BRUTE, H.zone_selected, wound_bonus = blade_wound_bonus, sharpness = SHARP_EDGED)

	// Попытка dismember
	if(ishuman(victim))
		var/mob/living/carbon/human/V = victim
		var/obj/item/bodypart/target_part = V.get_bodypart(H.zone_selected)
		if(target_part && target_part.body_zone != BODY_ZONE_CHEST && target_part.body_zone != BODY_ZONE_HEAD)
			target_part.try_dismember(WOUND_SLASH, blade_damage, blade_wound_bonus)

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
// 4. ARM CANNON — ДРОБОВИК В РУКЕ
// ============================================
// Заряжается дробовыми патронами. Стреляет пеллетами.
// У IPC дополнительно расходует батарею.

/obj/item/implant/ipc/arm_cannon
	name = "Arm Cannon Implant"
	desc = "Встроенный дробовик в руке. Заряжается дробовыми патронами. Выстрел рассеивает пеллеты по площади."
	icon_state = "arm_cannon"
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	actions_types = list(/datum/action/item_action/fire_arm_cannon)
	/// Макс. количество патронов
	var/max_shells = 4
	/// Текущее количество патронов
	var/loaded_shells = 0
	/// Количество пеллетов за выстрел
	var/pellet_count = 6
	/// Урон каждого пеллета
	var/pellet_damage = 5
	/// Разброс пеллетов (градусы)
	var/pellet_spread = 15
	/// Расход батареи за выстрел (только IPC)
	var/power_cost = 30
	/// Кулдаун между выстрелами
	var/fire_cooldown = 3 SECONDS
	/// Время последнего выстрела
	var/last_fire_time = 0

/obj/item/implant/ipc/arm_cannon/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
	<b>Name:</b> Arm Cannon Implant<BR>
	<b>Life:</b> Requires ammo<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> Fires [pellet_count] pellets ([pellet_damage] damage each).<BR>
	<b>Ammo:</b> [loaded_shells]/[max_shells] shells<BR>
	<b>Cooldown:</b> [fire_cooldown / 10]s"}
	return dat

/obj/item/implant/ipc/arm_cannon/implant(mob/living/target, body_zone, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/H = target

	// Регистрируем сигнал для зарядки — когда патрон используют на владельце
	RegisterSignal(H, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

	if(!silent)
		to_chat(H, span_notice("Дробовик установлен в [installed_in_zone]. Заряжайте дробовыми патронами, используя их на себе."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили дробовик. Патронов: [loaded_shells]/[max_shells]."))
	return TRUE

/// Зарядка — когда патрон используют на владельце импланта
/obj/item/implant/ipc/arm_cannon/proc/on_attackby(atom/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(attacking_item, /obj/item/ammo_casing/shotgun))
		return
	if(loaded_shells >= max_shells)
		to_chat(user, span_warning("Дробовик полностью заряжен! ([loaded_shells]/[max_shells])"))
		return
	// Заряжаем
	loaded_shells++
	qdel(attacking_item)
	playsound(source, 'sound/items/weapons/gun/shotgun/insert_shell.ogg', 40, TRUE)
	to_chat(user, span_notice("Патрон заряжен. ([loaded_shells]/[max_shells])"))

/// Попытка выстрела
/obj/item/implant/ipc/arm_cannon/proc/try_fire(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	// Кулдаун
	if(world.time < last_fire_time + fire_cooldown)
		var/remaining = round((last_fire_time + fire_cooldown - world.time) / 10, 0.1)
		to_chat(user, span_warning("Дробовик перезаряжается! Осталось [remaining]с."))
		return FALSE

	// Проверяем наличие патронов
	if(loaded_shells <= 0)
		to_chat(user, span_warning("Нет заряженных патронов! Используйте дробовые патроны на себе для зарядки."))
		playsound(user, 'sound/items/weapons/gun/shotgun/rack.ogg', 40, TRUE)
		return FALSE

	// Расход батареи только для IPC
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		if(battery.charge < power_cost)
			to_chat(user, span_warning("Недостаточно заряда!"))
			return FALSE
		battery.charge = max(battery.charge - power_cost, 0)

	loaded_shells--
	last_fire_time = world.time

	// Стреляем в направлении взгляда
	var/turf/target_turf = get_ranged_target_turf(user, user.dir, 7)
	if(!target_turf)
		return FALSE

	// Выпускаем пеллеты с разбросом
	for(var/i in 1 to pellet_count)
		var/obj/projectile/bullet/pellet/arm_cannon_pellet/P = new(get_turf(user))
		P.firer = user
		P.fired_from = user
		P.damage = pellet_damage
		P.aim_projectile(target_turf, user)
		// Добавляем разброс
		var/spread_angle = rand(-pellet_spread, pellet_spread)
		P.set_angle(P.angle + spread_angle)
		P.fire()

	playsound(user, 'sound/items/weapons/gun/shotgun/shot.ogg', 60, TRUE)
	to_chat(user, span_warning("Дробовик выстрелил! Патронов: [loaded_shells]/[max_shells]"))
	return TRUE

/obj/item/implant/ipc/arm_cannon/removed(mob/living/source, silent = FALSE, special = FALSE)
	if(ishuman(source))
		UnregisterSignal(source, COMSIG_ATOM_ATTACKBY)
	. = ..()
	if(!silent)
		to_chat(source, span_warning("Дробовик извлечён."))

/obj/item/implantcase/ipc/arm_cannon
	name = "implant case - 'Arm Cannon'"
	desc = "Стеклянный кейс содержащий имплант дробовика."
	imp_type = /obj/item/implant/ipc/arm_cannon

// Пеллет дробовика
/obj/projectile/bullet/pellet/arm_cannon_pellet
	name = "buckshot pellet"
	damage = 5
	wound_bonus = 5
	exposed_wound_bonus = 5
	speed = 1.1
	wound_falloff_tile = -0.5
	sharpness = SHARP_EDGED

// Action для выстрела
/datum/action/item_action/fire_arm_cannon
	name = "Fire Arm Cannon"
	desc = "Выстрелить из встроенного дробовика."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_nanites"
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
// У IPC: расход батареи + нагрев CPU.

/obj/item/implant/ipc/sandevistan
	name = "Sandevistan Implant"
	desc = "Сандевистан — имплант рефлекторного ускорения. Временно повышает скорость перемещения на 50%. У IPC расходует батарею и нагревает процессор."
	icon_state = "sandy"
	allowed_zones = list(BODY_ZONE_CHEST)
	actions_types = list(/datum/action/item_action/activate_sandevistan)
	/// Бонус скорости (отрицательное = быстрее)
	var/speed_bonus = -0.5
	/// Длительность эффекта
	var/effect_duration = 5 SECONDS
	/// Стоимость активации в заряде батареи (только IPC)
	var/power_cost = 250
	/// Нагрев CPU при активации (только IPC)
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
	<b>Life:</b> Permanent (IPC: uses battery)<BR>
	<b>Installed in:</b> [installed_in_zone ? installed_in_zone : "Not installed"]<BR>
	<b>Function:</b> 50% speed boost for [effect_duration / 10]s (IPC: costs [power_cost] charge, +[heat_on_use]°C).<BR>
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
	if(!silent)
		to_chat(H, span_notice("Сандевистан установлен. Активируйте для временного ускорения."))
		if(user)
			to_chat(user, span_notice("Вы успешно установили Сандевистан."))
	return TRUE

/// Активация сандевистана
/obj/item/implant/ipc/sandevistan/proc/activate_sandevistan(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(is_active)
		to_chat(user, span_warning("Сандевистан уже активен!"))
		return FALSE

	// Кулдаун
	if(world.time < last_use_time + ability_cooldown)
		var/remaining = round((last_use_time + ability_cooldown - world.time) / 10, 0.1)
		to_chat(user, span_warning("Сандевистан перезаряжается! Осталось [remaining]с."))
		return FALSE

	// Расход батареи только для IPC
	var/obj/item/organ/heart/ipc_battery/battery = user.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery)
		if(battery.charge < power_cost)
			to_chat(user, span_warning("Недостаточно заряда для активации Сандевистана!"))
			return FALSE
		battery.charge = max(battery.charge - power_cost, 0)

	last_use_time = world.time
	is_active = TRUE

	// Нагрев CPU только для IPC
	var/datum/species/ipc/ipc_species = user.dna?.species
	if(istype(ipc_species))
		ipc_species.cpu_temperature = min(ipc_species.cpu_temperature + heat_on_use, 200)

	// Ускорение
	user.add_movespeed_modifier(/datum/movespeed_modifier/ipc_sandevistan)

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

	user.remove_movespeed_modifier(/datum/movespeed_modifier/ipc_sandevistan)
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
	multiplicative_slowdown = -0.5

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
	sandy.activate_sandevistan(H)
	return TRUE

// ============================================
// ПРЕДУСТАНОВЛЕННЫЕ AUTOSURGEONS
// ============================================

/obj/item/autosurgeon/ipc/arm_razor
	desc = "Одноразовый autosurgeon с имплантом моноволоконной струны."
	uses = 1

/obj/item/autosurgeon/ipc/arm_razor/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/arm_razor(src))

/obj/item/autosurgeon/ipc/mantis_right
	desc = "Одноразовый autosurgeon с имплантом лезвий богомола для правой руки."
	uses = 1

/obj/item/autosurgeon/ipc/mantis_right/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/mantis(src))

/obj/item/autosurgeon/ipc/mantis_left
	desc = "Одноразовый autosurgeon с имплантом лезвий богомола для левой руки."
	uses = 1

/obj/item/autosurgeon/ipc/mantis_left/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/mantis/left(src))

/obj/item/autosurgeon/ipc/military_mantis_right
	desc = "Одноразовый autosurgeon с имплантом военных лезвий для правой руки."
	uses = 1

/obj/item/autosurgeon/ipc/military_mantis_right/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/military_mantis(src))

/obj/item/autosurgeon/ipc/military_mantis_left
	desc = "Одноразовый autosurgeon с имплантом военных лезвий для левой руки."
	uses = 1

/obj/item/autosurgeon/ipc/military_mantis_left/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/military_mantis/left(src))

/obj/item/autosurgeon/ipc/arm_cannon
	desc = "Одноразовый autosurgeon с имплантом дробовика."
	uses = 1

/obj/item/autosurgeon/ipc/arm_cannon/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/arm_cannon(src))

/obj/item/autosurgeon/ipc/sandevistan
	desc = "Одноразовый autosurgeon с имплантом Сандевистан."
	uses = 1

/obj/item/autosurgeon/ipc/sandevistan/Initialize(mapload)
	. = ..()
	load_implant(new /obj/item/implant/ipc/sandevistan(src))
