/datum/action/cooldown/shadowling/shadow_strike
	name = "Теневой удар"
	desc = "Материализуясь из тени рядом с ближайшей целью в 2 тайлах, наносит быстрый удар."
	button_icon_state = "shadow_strike"
	cooldown_time = 0

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 2
	channel_time = 0

/datum/action/cooldown/shadowling/shadow_strike/CanUse(mob/living/carbon/human/H)
	if(!..())
		return FALSE
	if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
		return TRUE
	if(H.has_status_effect(/datum/status_effect/shadow/phase))
		return TRUE
	owner.balloon_alert(owner, "Вы должны быть нематериальны")
	return FALSE

/datum/action/cooldown/shadowling/shadow_strike/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	if(!CanUse(H))
		return

	var/mob/living/target_mob = find_closest_target(H)
	if(!target_mob)
		owner.balloon_alert(owner, "Нет доступных целей")
		return

	if(DoEffect(H, target_mob))
		StartCooldown()

/datum/action/cooldown/shadowling/shadow_strike/proc/find_closest_target(mob/living/carbon/human/H)
	var/datum/shadow_hive/hive = get_shadow_hive()
	var/turf/center = get_turf(H)
	if(!center)
		return null

	var/mob/living/best
	var/best_dist = 999

	for(var/mob/living/L in range(max_range, center))
		if(L == H) continue
		if(L.stat == DEAD) continue

		if(hive)
			if(L in hive.lings)
				continue
			if(L in hive.thralls)
				continue

		var/d = get_dist(H, L)
		if(d < best_dist)
			best = L
			best_dist = d

	return best

/datum/action/cooldown/shadowling/shadow_strike/DoEffect(mob/living/carbon/human/H, atom/target)
	if(!istype(H))
		return FALSE

	var/mob/living/carbon/human/T = null
	if(istype(target, /mob/living/carbon/human))
		T = target
	else
		T = find_closest_target(H)

	if(!istype(T))
		owner.balloon_alert(owner, "Нет доступных целей")
		return FALSE

	var/obj/effect/dummy/phased_mob/shadowling/P = istype(H.loc, /obj/effect/dummy/phased_mob/shadowling) ? H.loc : null
	if(P)
		var/turf/nearby = pick_adjacent_open_turf(get_turf(T))
		if(nearby)
			P.forceMove(nearby)
		P.eject_jaunter(FALSE)
	else
		H.remove_status_effect(/datum/status_effect/shadow/phase)

	if(get_dist(H, T) > 1)
		step_towards(H, T)

	if(QDELETED(H) || QDELETED(T) || get_dist(H, T) > 1)
		owner.balloon_alert(owner, "Слишком далеко для удара")
		return FALSE

	T.apply_damage(20, BRUTE, null, sharpness = SHARP_POINTY)
	H.do_attack_animation(T)
	return TRUE
