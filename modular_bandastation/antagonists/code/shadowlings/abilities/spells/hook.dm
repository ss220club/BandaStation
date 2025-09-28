// MARK: Global procedure
/proc/SHADOW_hook__compute_endpoint(turf/start_turf, turf/aim_turf, max_steps)
	if(!istype(start_turf))
		return null

	if(!istype(aim_turf))
		return null

	var/turf/current = start_turf
	var/step_i = 1
	while(step_i <= max_steps)
		var/turf/next_step = get_step_towards(current, aim_turf)
		if(!istype(next_step))
			break

		if(next_step == current)
			break

		if(next_step.density)
			break

		current = next_step
		step_i += 1

	if(current == start_turf)
		return null

	return current

// MARK: Hook projectile
/obj/projectile/magic/shadow_hand_sl
	name = "shadow hand"
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadow_hand"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	speed = 0.8

	var/hit_committed = FALSE
	var/obj/effect/beam/chain

/obj/projectile/magic/shadow_hand_sl/fire(setAngle)
	if(firer)
		chain = firer.Beam(
			BeamTarget = src,
			icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi',
			icon_state = "shadow_grabber",
			time = INFINITY,
			maxdistance = INFINITY,
			emissive = FALSE
		)
	return ..()

/obj/projectile/magic/shadow_hand_sl/Moved(atom/oldloc, dir, forced = FALSE, list/old_locs, momentum_change = FALSE)
	. = ..()
	if(hit_committed)
		return .

	var/turf/cur_turf = get_turf(src)
	if(!istype(cur_turf))
		return .

	var/atom/movable/candidate = null

	for(var/mob/living/L in cur_turf)
		if(_eligible_mob(L))
			candidate = L
			break

	if(!candidate)
		for(var/obj/item/I in cur_turf)
			if(_eligible_item(I))
				candidate = I
				break

	if(candidate)
		Bump(candidate)

	return .

/obj/projectile/magic/shadow_hand_sl/proc/_eligible_mob(mob/living/L)
	if(!istype(L))
		return FALSE
	if(L == firer)
		return FALSE
	if(L.stat == DEAD)
		return FALSE
	if(L.anchored)
		return FALSE
	if(L.throwing)
		return FALSE
	return TRUE

/obj/projectile/magic/shadow_hand_sl/proc/_eligible_item(obj/item/I)
	if(!istype(I))
		return FALSE
	if(I.anchored)
		return FALSE
	if(!isturf(I.loc))
		return FALSE
	return TRUE

/obj/projectile/magic/shadow_hand_sl/on_hit(atom/movable/target, blocked = 0, pierce_hit)
	. = ..()
	if(hit_committed)
		return BULLET_ACT_BLOCK

	hit_committed = TRUE

	if(!isliving(firer))
		return BULLET_ACT_HIT

	var/mob/living/caster = firer

	var/turf/caster_turf = get_turf(caster)
	var/turf/hit_turf = get_turf(target)

	if(!istype(caster_turf))
		return BULLET_ACT_HIT

	if(!istype(hit_turf))
		return BULLET_ACT_HIT

	if(!ismovable(target))
		return BULLET_ACT_HIT

	var/atom/movable/mov = target

	if(mov.anchored)
		return BULLET_ACT_HIT

	if(isliving(mov))
		var/mob/living/victim = mov
		if(victim.throwing)
			return BULLET_ACT_HIT

	var/turf/dest_turf = get_step(caster, get_dir(caster, mov))
	if(!istype(dest_turf))
		dest_turf = caster_turf

	mov.throw_at(
		target = dest_turf,
		range = 8,
		speed = 2,
		thrower = caster,
		diagonals_first = TRUE,
		gentle = TRUE
	)

	playsound(caster_turf, hitsound, 70, TRUE)

	return BULLET_ACT_HIT

/obj/projectile/magic/shadow_hand_sl/Destroy()
	if(!hit_committed && istype(firer))
		var/mob/living/L = firer
		L.balloon_alert(L, "промах!")

	if(chain && !QDELETED(chain))
		qdel(chain)
	chain = null
	return ..()

// MARK: Ability
/datum/action/cooldown/shadowling/hook
	parent_type = /datum/action/cooldown/shadowling

	name = "Хук"
	desc = "Выпускает теневую руку. При попадании тянет задетую цель к вам."
	button_icon_state = "shadow_hook"

	cooldown_time = 10 SECONDS
	max_range = 8
	channel_time = 0
	click_to_activate = TRUE
	unset_after_click = TRUE

	var/targeting = FALSE
	var/static/sfx_fire = 'sound/effects/splat.ogg'
	var/static/sfx_hit = 'sound/items/weapons/shove.ogg'

/datum/action/cooldown/shadowling/hook/DoEffect(mob/living/carbon/human/H, atom/target)
	to_chat(H, span_notice("ЛКМ по направлению/цели, чтобы выпустить теневую руку."))
	return FALSE

/datum/action/cooldown/shadowling/hook/is_action_active(atom/movable/screen/movable/action_button/_btn)
	return targeting

/datum/action/cooldown/shadowling/hook/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	targeting = FALSE
	apply_button_overlay()

/datum/action/cooldown/shadowling/hook/set_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	targeting = TRUE
	apply_button_overlay()

/datum/action/cooldown/shadowling/hook/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!istype(clicker))
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(!IsAvailable(TRUE))
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(!CanUse(clicker))
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/mob/living/carbon/human/H = clicker
	var/turf/start_turf = get_turf(H)
	var/turf/click_turf = get_turf(target)
	if(!istype(start_turf) || !istype(click_turf))
		unset_click_ability(clicker, TRUE)
		return TRUE

	var/turf/end_turf = SHADOW_hook__compute_endpoint(start_turf, click_turf, max_range)
	if(!istype(end_turf))
		H.balloon_alert(H, "слишком близко")
		unset_click_ability(clicker, TRUE)
		return TRUE

	// IMPORTANT: spawn projectile in start turf
	var/obj/projectile/magic/shadow_hand_sl/P = new(start_turf)
	P.firer = H
	P.range = max_range
	P.hitsound = sfx_hit

	// Now navigate - loc is already known, angle is calculated correctly
	P.aim_projectile(end_turf, H)

	playsound(start_turf, sfx_fire, 55, TRUE)
	P.fire()

	StartCooldown()
	unset_click_ability(clicker, FALSE)
	return TRUE
