// shadowling_action_base.dm

/datum/action/cooldown/shadowling
	name = "Shadowling Ability"
	desc = "Innate power of the brood."
	background_icon_state = "shadow_demon_bg"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "shadow_generic"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 10 SECONDS

	/// Минимальный тир роя для активации
	var/required_thralls = 0
	/// Требуется ли темнота на кастере
	var/requires_dark_user = FALSE
	/// Требуется ли темнота на цели (если используется цель)
	var/requires_dark_target = FALSE
	/// Максимальная дистанция до цели (0 = не проверять)
	var/max_range = 0
	/// Время канала (0 = без канала)
	var/channel_time = 0
	/// Прерывать канал, если кастер выходит в яркое место
	var/cancel_on_bright = TRUE

/***********************
 * Проверки
 ***********************/

/datum/action/cooldown/shadowling/proc/CanUse(mob/living/carbon/human/H)
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	if(requires_dark_user && !is_dark(H))
		return FALSE

	return TRUE

/datum/action/cooldown/shadowling/proc/AcquireTarget(mob/living/carbon/human/H)
	return H

/datum/action/cooldown/shadowling/proc/ValidateTarget(mob/living/carbon/human/H, atom/target)
	return TRUE

/***********************
 * Канал
 ***********************/

/datum/action/cooldown/shadowling/proc/PerformChannel(mob/living/carbon/human/H, atom/target)
	if(cancel_on_bright && !is_dark(H))
		return FALSE

	if(!do_after(H, channel_time, target))
		return FALSE

	if(cancel_on_bright && !is_dark(H))
		return FALSE

	return TRUE

/***********************
 * Утилиты (локальные)
 ***********************/

/datum/action/cooldown/shadowling/proc/is_dark(atom/A)
	var/turf/T = get_turf(A)
	if(!T)
		return FALSE
	return (T.get_lumcount() < L_DIM)

/***********************
 * Реальный эффект
 * (переопределяется наследниками; вернуть TRUE при успехе)
 ***********************/

/datum/action/cooldown/shadowling/proc/DoEffect(mob/living/carbon/human/H, atom/target)
	return FALSE

/datum/action/cooldown/shadowling/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	if(!CanUse(H))
		to_chat(H, span_warning("Сейчас нельзя."))
		return

	var/list/targets = CollectTargets(H, target)
	if(!ValidateTargets(H, targets))
		to_chat(H, span_warning("Нет доступных целей."))
		return

	if(channel_time > 0)
		if(!PerformChannel(H, null)) // канал не привязываем к конкретной цели
			return

	if(DoEffectOnTargets(H, targets))
		StartCooldown()

/***********************
 * Таргетинг (НОВОЕ)
 ***********************/

/// Собрать цели. По умолчанию — одна: explicit или self.
/datum/action/cooldown/shadowling/proc/CollectTargets(mob/living/carbon/human/H, atom/explicit)
	if(explicit)
		return list(explicit)
	return list(H)

/// Валидировать список целей (дистанция/тьма + пользовательская ValidateTarget)
/datum/action/cooldown/shadowling/proc/ValidateTargets(mob/living/carbon/human/H, list/targets)
	if(!islist(targets) || !length(targets))
		// некоторые сплеши могут работать и без списка (например, чисто self)
		return TRUE

	for(var/atom/T in targets)
		if(max_range > 0)
			if(get_dist(H, T) > max_range)
				return FALSE
		if(requires_dark_target && !is_dark(T))
			return FALSE
		if(!ValidateTarget(H, T)) // хук для наследников (по умолчанию TRUE)
			return FALSE
	return TRUE

/// Применить эффект ко всем целям. По умолчанию — совместимость со старым DoEffect.
/datum/action/cooldown/shadowling/proc/DoEffectOnTargets(mob/living/carbon/human/H, list/targets)
	if(!islist(targets) || !length(targets))
		return DoEffect(H, null)
	var/success = FALSE
	// дефолт — работаем по ПЕРВОЙ цели, как раньше
	success = DoEffect(H, targets[1]) || success
	return success

/***********************
 * Утилиты конуса (НОВОЕ)
 ***********************/

/// В конусе относительно взгляда H? full_angle: 90, 135, 180 (дискретные 8-напр. допуски)
/datum/action/cooldown/shadowling/proc/in_front_cone(mob/living/carbon/human/H, atom/A, full_angle = 90)
	if(!H.dir) // нет направления — считаем валидным
		return TRUE
	var/tdir = get_dir(H, A)
	if(!tdir)
		return FALSE

	var/list/allowed = list(H.dir)
	if(full_angle >= 90)
		allowed += list(turn(H.dir, 45), turn(H.dir, -45))
	if(full_angle >= 135)
		allowed += list(turn(H.dir, 90), turn(H.dir, -90))
	if(full_angle >= 180)
		allowed = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

	return (tdir in allowed)

/// Собрать людей в радиусе r в конусе full_angle° по направлению H
/datum/action/cooldown/shadowling/proc/collect_cone_targets(mob/living/carbon/human/H, r = 2, full_angle = 90)
	var/list/res = list()
	for(var/mob/living/carbon/human/T in range(r, H))
		if(T == H)
			continue
		if(!in_front_cone(H, T, full_angle))
			continue
		res += T
	return res
