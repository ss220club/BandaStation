/datum/action/cooldown/shadowling
	name = "Shadowling Ability"
	desc = "Innate power of the brood."
	button_icon = 'modular_bandastation/antagonists/icons/shadowlings_actions.dmi'
	button_icon_state = ""
	background_icon = 'modular_bandastation/antagonists/icons/shadowlings_actions.dmi'
	background_icon_state = "bg_shadowling"
	overlay_icon = 'modular_bandastation/antagonists/icons/shadowlings_actions.dmi'
	overlay_icon_state = "bg_shadowling_border"
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

/datum/action/cooldown/shadowling/proc/CanUse(mob/living/carbon/human/H)
	var/datum/shadow_hive/hive = get_shadow_hive()
	if(!hive)
		return FALSE

	if(requires_dark_user && !is_dark(H))
		return FALSE

	if(!IsAvailable(TRUE))
		return FALSE

	return TRUE

/datum/action/cooldown/shadowling/proc/AcquireTarget(mob/living/carbon/human/H)
	return H

/datum/action/cooldown/shadowling/proc/ValidateTarget(mob/living/carbon/human/H, atom/target)
	return TRUE

/datum/action/cooldown/shadowling/proc/PerformChannel(mob/living/carbon/human/H, atom/target)
	if(cancel_on_bright && !is_dark(H))
		return FALSE

	if(!do_after(H, channel_time, target))
		return FALSE

	if(cancel_on_bright && !is_dark(H))
		return FALSE

	if(!IsAvailable(TRUE))
		return FALSE

	return TRUE

/datum/action/cooldown/shadowling/proc/is_dark(atom/A)
	var/turf/T = get_turf(A)
	if(!T)
		return FALSE
	return (T.get_lumcount() < SHADOWLING_DIM_THRESHOLD)

/datum/action/cooldown/shadowling/proc/DoEffect(mob/living/carbon/human/H, atom/target)
	return FALSE

/datum/action/cooldown/shadowling/Trigger(mob/clicker, trigger_flags, atom/target)
	if(click_to_activate)
		return ..()

	if(!istype(owner))
		return

	if(!CanUse(owner))
		enable()
		owner.balloon_alert(owner, "Сейчас нельзя")
		return

	var/list/targets = CollectTargets(owner, target)
	if(!ValidateTargets(owner, targets))
		enable()
		owner.balloon_alert(owner, "Нет доступных целей")
		return

	if(channel_time > 0)
		if(!PerformChannel(owner, null))
			return

	disable()

	var/success = DoEffectOnTargets(owner, targets)
	if(success)
		StartCooldown()
	else
		enable()


/datum/action/cooldown/shadowling/proc/CollectTargets(mob/living/carbon/human/H, atom/explicit)
	if(explicit)
		return list(explicit)
	return list(H)

/datum/action/cooldown/shadowling/proc/ValidateTargets(mob/living/carbon/human/H, list/targets)
	if(!islist(targets) || !length(targets))
		return TRUE

	for(var/atom/T in targets)
		if(max_range > 0)
			if(get_dist(H, T) > max_range)
				return FALSE
		if(requires_dark_target && !is_dark(T))
			return FALSE
		if(!ValidateTarget(H, T))
			return FALSE
	return TRUE

/datum/action/cooldown/shadowling/proc/DoEffectOnTargets(mob/living/carbon/human/H, list/targets)
	if(!islist(targets) || !length(targets))
		return DoEffect(H, null)
	var/success = FALSE
	for(var/atom/A in targets)
		success = DoEffect(H, targets[1])
	return success

/datum/action/cooldown/shadowling/proc/glare_angle_diff(a, b)
	var/d = abs(a - b) % 360
	if(d > 180)
		d = 360 - d
	return d

/datum/action/cooldown/shadowling/proc/in_front_cone(mob/living/carbon/human/H, atom/A, full_angle = 90)
	if(!istype(H) || !A)
		return FALSE

	var/turf/from_turf = get_turf(H)
	var/turf/to_turf = get_turf(A)
	if(!from_turf || !to_turf)
		return FALSE

	if(!H.dir) // без направления — считаем, что попадает
		return TRUE

	var/ang_forward = dir2angle(H.dir)
	var/ang_to = get_angle(from_turf, to_turf)
	var/half = full_angle * 0.5

	if(glare_angle_diff(ang_forward, ang_to) <= half)
		return TRUE

	return FALSE

/datum/action/cooldown/shadowling/proc/collect_cone_targets(mob/living/carbon/human/H, r = 2, full_angle = 90)
	var/list/res = list()
	for(var/mob/living/carbon/human/T in range(r, H))
		if(T == H)
			continue
		if(!in_front_cone(H, T, full_angle))
			continue
		res += T
	return res


/datum/action/cooldown/shadowling/proc/find_nearest_target(range)
	var/datum/shadow_hive/hive = get_shadow_hive()
	var/min_d = 999
	var/mob/living/carbon/human/best = null
	var/list/candidates = range(range, get_turf(owner))
	for(var/mob/living/carbon/human/candidate in candidates)
		if(candidate == owner || QDELETED(candidate) || candidate.stat == DEAD)
			continue
		if(hive && ((candidate in hive.lings) || (candidate in hive.thralls)))
			continue
		var/d = get_dist(owner, candidate)
		if(d < min_d)
			min_d = d
			best = candidate
	return best

/datum/action/cooldown/shadowling/proc/pick_adjacent_open_turf(turf/center)
	if(!istype(center))
		return null
	var/list/cands = list()
	for(var/turf/T in get_adjacent_open_turfs(center))
		if(T && !T.density)
			cands += T
	return length(cands) ? pick(cands) : null

/datum/action/cooldown/shadowling/process()
	. = ..()
	if(!owner || (next_use_time - world.time) <= 0)
		enable()
