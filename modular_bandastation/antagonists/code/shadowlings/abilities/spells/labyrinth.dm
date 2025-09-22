/datum/action/cooldown/shadowling/labyrinth
	name = "Лабиринт"
	desc = "Захватывает ближайшую цель в тени (≤6 тайлов, в видимости), затем кликом выбери тёмную точку для телепорта. Окутывает область чёрным дымом."
	button_icon_state = "shadow_labyrinth"
	cooldown_time = 20 SECONDS
	click_to_activate = TRUE
	unset_after_click = TRUE
	var/selection_range = 6
	var/mob/living/carbon/human/stored_target
	var/selection_timer
	min_req = 6
	max_req = 30
	required_thralls = 60

/datum/action/cooldown/shadowling/labyrinth/Remove(mob/remove_from)
	. = ..()
	_cancel_selection(remove_from, refund = TRUE)

/datum/action/cooldown/shadowling/labyrinth/is_action_active(atom/movable/screen/movable/action_button/_btn)
	return stored_target

/datum/action/cooldown/shadowling/root/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	apply_button_overlay()

/datum/action/cooldown/shadowling/root/set_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	apply_button_overlay()

/datum/action/cooldown/shadowling/labyrinth/Trigger(mob/clicker, trigger_flags, atom/target)
	apply_button_overlay()
	if(!istype(clicker) || !IsAvailable(TRUE) || !CanUse(clicker))
		return FALSE
	if(stored_target && clicker.click_intercept == src)
		owner.balloon_alert(owner, "отменено")
		_cancel_selection(clicker, refund = TRUE)
		return TRUE
	if(!stored_target)
		var/mob/living/carbon/human/T = find_target(clicker)
		if(!T)
			owner.balloon_alert(owner, "Нет доступных целей")
			return FALSE
		stored_target = T
		clicker.balloon_alert(clicker, "цель зафиксирована")
		to_chat(clicker, span_notice("Укажи тёмную точку в пределах видимости. ПКМ — отмена."))
		set_click_ability(clicker)
		_start_timeout(clicker)
		return TRUE
	set_click_ability(clicker)
	_start_timeout(clicker)
	return TRUE

/datum/action/cooldown/shadowling/labyrinth/proc/find_target(mob/living/carbon/human/H)
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	var/mob/living/carbon/human/best
	var/best_d = 1e9
	for(var/mob/living/carbon/human/T in view(selection_range, H))
		if(T == H || T.stat == DEAD)
			continue
		if(hive)
			if(T in hive.lings)
				continue
			if(T in hive.thralls)
				continue
		if(!is_dark(T))
			continue
		if(!in_front_cone(H, T, 90))
			continue
		var/d = get_dist(H, T)
		if(d < best_d)
			best_d = d
			best = T
	return best

/datum/action/cooldown/shadowling/labyrinth/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!stored_target || QDELETED(stored_target))
		_cancel_selection(owner, refund = TRUE)
		return FALSE
	var/list/p = params2list(params)
	if(p && ("right" in p))
		owner.balloon_alert(owner, "отменено")
		_cancel_selection(clicker, refund = TRUE)
		return TRUE
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
		_cancel_selection(clicker, refund = TRUE)
		return FALSE
	var/turf/src_turf = get_turf(V)
	playsound(src_turf, 'sound/effects/smoke.ogg', 40, TRUE, -3)
	shadow_spawn_smoke(src_turf, owner, 2, 3, 6, 3 SECONDS, 20, 1 SECONDS)
	V.forceMove(T)
	playsound(T, 'sound/effects/smoke.ogg', 40, TRUE, -3)
	shadow_spawn_smoke(T, owner, 2, 3, 6, 3 SECONDS, 20, 1 SECONDS)
	to_chat(owner, span_notice("[V.real_name] исчезает в дымке и возникает в новом месте."))
	to_chat(V, span_danger("Тени искажают пространство!"))
	_cancel_selection(clicker, refund = FALSE)
	StartCooldown()
	return TRUE

/datum/action/cooldown/shadowling/labyrinth/proc/_start_timeout(mob/living/carbon/human/H)
	deltimer(selection_timer)
	selection_timer = addtimer(CALLBACK(src, PROC_REF(_on_timeout), H), 8 SECONDS, TIMER_STOPPABLE)

/datum/action/cooldown/shadowling/labyrinth/proc/_on_timeout(mob/living/carbon/human/H)
	if(H?.click_intercept == src)
		owner.balloon_alert(owner, "время вышло")
	_cancel_selection(H, refund = TRUE)

/datum/action/cooldown/shadowling/labyrinth/proc/_cancel_selection(mob/living/carbon/human/H, refund)
	deltimer(selection_timer)
	selection_timer = null
	stored_target = null
	if(istype(H) && H.click_intercept == src)
		unset_click_ability(H, refund_cooldown = refund)
