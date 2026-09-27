/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling
	id = "nyxosynthesis_shadowling"
	tick_interval = 1 SECONDS
	var/applied_speed = FALSE
	var/next_burn_sfx_time = 0
	var/static/sfx_burn = 'sound/items/weapons/sear.ogg'

/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling/tick(seconds_between_ticks)
	var/turf/T = owner?.loc
	if(!isturf(T))
		return

	var/light = T.get_lumcount()
	var/coef = GET_BODYPART_COEFFICIENT(bodyparts)

	if(light >= SHADOWLING_LIGHT_THRESHOLD)
		if(coef > 0 && owner.stat != DEAD)
			owner.take_overall_damage(
				brute = SHADOWLING_BRIGHT_BRUTE_PER_LIMB * coef,
				burn = SHADOWLING_BRIGHT_BURN_PER_LIMB * coef,
				required_bodytype = BODYTYPE_SHADOW
			)

			if(world.time >= next_burn_sfx_time)
				playsound(T, sfx_burn, 10, TRUE)
				next_burn_sfx_time = world.time + 1 SECONDS

		if(applied_speed)
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
			applied_speed = FALSE

		return

	var/heal_per = (light < SHADOWLING_DIM_THRESHOLD) \
		? SHADOWLING_DARK_HEAL_PER_LIMB_DEEP \
		: SHADOWLING_DARK_HEAL_PER_LIMB_DIM

	var/is_dead = owner.stat == DEAD

	if(is_dead)
		heal_per *= SHADOWLING_DEAD_HEAL_MULTIPLIER

	owner.heal_overall_damage(
		brute = heal_per * coef,
		burn = heal_per * coef,
		required_bodytype = BODYTYPE_SHADOW
	)

	if(is_dead)
		if(owner.get_brute_loss() <= 0 && owner.get_fire_loss() <= 0)
			try_revive()
		return

	var/stam_regen = (light < SHADOWLING_DIM_THRESHOLD) \
		? SHADOWLING_DARK_STAMINA_PER_LIMB_DEEP \
		: SHADOWLING_DARK_STAMINA_PER_LIMB_DIM

	if(stam_regen > 0 && coef > 0)
		owner.adjust_stamina_loss(-(stam_regen * coef))

	if(!owner.has_status_effect(/datum/status_effect/shadow/nightmare))
		owner.apply_status_effect(/datum/status_effect/shadow)

	if(!applied_speed)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
		applied_speed = TRUE

/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling/proc/try_revive()
	if(!owner || owner.stat != DEAD)
		return FALSE
	if(owner.get_brute_loss() > 0 || owner.get_fire_loss() > 0)
		return FALSE
	REMOVE_TRAIT(owner, TRAIT_DEATHCOMA, SHADOWLING_DEATHCOMA_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_STASIS, SHADOWLING_DEATHCOMA_TRAIT)
	owner.revive(HEAL_DAMAGE|HEAL_BODY|HEAL_STATUS|HEAL_CC_STATUS)
	to_chat(owner, span_notice("Тьма полностью восстановила твоё тело. Ты возвращаешься к жизни."))

	return TRUE

/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling/on_remove()
	. = ..()
	if(applied_speed && owner)
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
