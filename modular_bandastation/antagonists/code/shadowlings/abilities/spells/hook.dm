/datum/action/cooldown/shadowling/hook
	parent_type = /datum/action/cooldown/shadowling

	name = "Теневой захват"
	desc = "Выпускает теневую руку. При попадании тянет задетую цель к вам."
	button_icon_state = "shadow_hook"

	cooldown_time = 10 SECONDS
	max_range = 8
	channel_time = 0
	click_to_activate = TRUE
	unset_after_click = TRUE

	var/tiles_per_second = 8
	var/sfx_fire = 'sound/effects/splat.ogg'
	var/sfx_hit = 'sound/items/weapons/shove.ogg'

/datum/action/cooldown/shadowling/hook/DoEffect(mob/living/carbon/human/H, atom/_)
	to_chat(H, span_notice("ЛКМ по направлению/цели, чтобы выпустить теневую руку."))
	return FALSE

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

	if(!istype(start_turf))
		unset_click_ability(clicker, TRUE)
		return TRUE

	if(!istype(click_turf))
		unset_click_ability(clicker, TRUE)
		return TRUE

	var/turf/end_turf = SHADOW_hook__compute_endpoint(start_turf, click_turf, max_range)

	if(!istype(end_turf))
		H.balloon_alert(H, "слишком близко")
		unset_click_ability(clicker, TRUE)
		return TRUE

	var/obj/projectile/magic/shadow_hand_sl/P = new
	P.firer = H
	P.range = max_range
	P.hitsound = sfx_hit

	var/tiles_per_tick = tiles_per_second * world.tick_lag
	if(tiles_per_tick <= 0.1)
		tiles_per_tick = 0.1
	P.speed = tiles_per_tick

	P.aim_projectile(end_turf, H)

	playsound(start_turf, sfx_fire, 55, TRUE)

	P.fire()

	StartCooldown()
	unset_click_ability(clicker, FALSE)
	return TRUE



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



/obj/projectile/magic/shadow_hand_sl
	name = "shadow hand"
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	speed = 1

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

// Перехват целей на пути — когда снаряд входит в новый турф
/obj/projectile/magic/shadow_hand_sl/Moved(atom/oldloc, dir, forced = FALSE)
	. = ..()
	if(hit_committed)
		return .

	var/turf/cur_turf = get_turf(src)
	if(!istype(cur_turf))
		return .

	// Сначала живые
	var/atom/movable/candidate = null
	for(var/mob/living/L in cur_turf)
		if(_eligible_mob(L))
			candidate = L
			break

	// Если живых нет — предмет
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
		L.balloon_alert(L, "Промах!")

	if(chain && !QDELETED(chain))
		qdel(chain)
	chain = null
	return ..()
