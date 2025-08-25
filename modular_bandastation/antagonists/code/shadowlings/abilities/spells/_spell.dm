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
	var/required_tier = TIER_T0
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
 * Активатор
 ***********************/

/datum/action/cooldown/shadowling/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	if(!CanUse(H))
		to_chat(H, span_warning("Сейчас нельзя."))
		return

	if(!ValidateTarget(H, target))
		to_chat(H, span_warning("Цель недоступна."))
		return

	if(channel_time > 0)
		if(!PerformChannel(H, target))
			return

	if(DoEffect(H, target))
		StartCooldown()

/***********************
 * Проверки
 ***********************/

/datum/action/cooldown/shadowling/proc/CanUse(mob/living/carbon/human/H)
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	if(!(H in hive.lings) && !(H in hive.thralls))
		return FALSE

	if(hive.current_tier <= required_tier)
		return FALSE

	if(requires_dark_user && !is_dark(H))
		return FALSE

	return TRUE

/datum/action/cooldown/shadowling/proc/AcquireTarget(mob/living/carbon/human/H)
	return H

/datum/action/cooldown/shadowling/proc/ValidateTarget(mob/living/carbon/human/H, atom/target)
	if(!target)
		return FALSE

	if(max_range > 0)
		if(get_dist(H, target) > max_range)
			return FALSE

	if(requires_dark_target && !is_dark(target))
		return FALSE

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
