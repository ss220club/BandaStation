/datum/action/cooldown/shadowling/labyrinth
	name = "Лабиринт"
	desc = "Захватывает ближайшую цель в тени (≤6 тайлов, в видимости), затем кликом выбери тёмную точку для телепорта."
	button_icon_state = "shadow_labyrinth"
	cooldown_time = 20 SECONDS
	click_to_activate = TRUE
	unset_after_click = TRUE
	var/selection_range = 6
	var/mob/living/carbon/human/stored_target

/datum/action/cooldown/shadowling/labyrinth/Remove(mob/remove_from)
	. = ..()
	stored_target = null
	if(istype(remove_from) && remove_from.click_intercept == src)
		unset_click_ability(remove_from, refund_cooldown = TRUE)

/datum/action/cooldown/shadowling/labyrinth/Trigger(mob/clicker, trigger_flags, atom/target)
	if(!istype(clicker) || !IsAvailable(TRUE) || !CanUse(clicker))
		return FALSE
	if(!stored_target)
		var/mob/living/carbon/human/T = find_target(clicker)
		if(!T)
			owner.balloon_alert(owner, "Нет доступных целей")
			return FALSE
		stored_target = T
		clicker.balloon_alert(clicker, "цель зафиксирована")
		to_chat(clicker, span_notice("Укажи тёмную точку в пределах видимости."))
		set_click_ability(clicker)
		return TRUE
	set_click_ability(clicker)
	return TRUE

/datum/action/cooldown/shadowling/labyrinth/proc/find_target(mob/living/carbon/human/H)
	var/datum/shadow_hive/hive = get_shadow_hive()
	var/mob/living/carbon/human/best
	var/best_d = 1e9
	for(var/mob/living/carbon/human/T in view(selection_range, H))
		if(T == H || T.stat == DEAD)
			continue
		if(hive && ((T in hive.lings) || (T in hive.thralls)))
			continue
		if(!is_dark(T))
			continue
		var/d = get_dist(H, T)
		if(d < best_d)
			best_d = d
			best = T
	return best

/datum/action/cooldown/shadowling/labyrinth/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!stored_target || QDELETED(stored_target))
		unset_click_ability(owner, TRUE)
		stored_target = null
		return FALSE

	var/turf/T = get_turf(target)
	if(!istype(T))
		owner.balloon_alert(owner, "нужен тайл")
		return FALSE
	if(!is_dark(T))
		owner.balloon_alert(owner, "слишком светло")
		return FALSE
	if(!(T in view(selection_range, clicker)))
		owner.balloon_alert(owner, "слишком далеко")
		return FALSE

	var/mob/living/carbon/human/V = stored_target
	if(QDELETED(V))
		unset_click_ability(clicker, TRUE)
		stored_target = null
		return FALSE

	var/turf/src_turf = get_turf(V)
	playsound(src_turf, 'sound/effects/smoke.ogg', 40, TRUE, -3)
	do_smoke(1, amount = DIAMOND_AREA(1), holder = owner, location = src_turf, smoke_type = /obj/effect/particle_effect/fluid/smoke/quick)

	V.forceMove(T)

	playsound(T, 'sound/effects/smoke.ogg', 40, TRUE, -3)
	do_smoke(1, amount = DIAMOND_AREA(1), holder = owner, location = T, smoke_type = /obj/effect/particle_effect/fluid/smoke/quick)

	to_chat(owner, span_notice("[V.real_name] исчезает в дымке и возникает в новом месте."))
	to_chat(V, span_danger("Тени искажают пространство!"))

	unset_click_ability(clicker, FALSE)
	stored_target = null
	StartCooldown()
	return TRUE
