/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling
	id = "nyxosynthesis_shadowling"
	tick_interval = 1 SECONDS
	var/applied_speed = FALSE

/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling/tick(seconds_between_ticks)
	var/turf/T = owner?.loc
	if(!isturf(T))
		return

	var/light = T.get_lumcount()
	var/coef = GET_BODYPART_COEFFICIENT(bodyparts)

	if(light >= SHADOWLING_LIGHT_THRESHOLD)
		owner.take_overall_damage(
			brute = SHADOWLING_BRIGHT_BRUTE_PER_LIMB * coef,
			burn  = SHADOWLING_BRIGHT_BURN_PER_LIMB  * coef,
			required_bodytype = BODYTYPE_SHADOW
		)
		if(applied_speed)
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
			applied_speed = FALSE
		return

	var/heal_per = (light < SHADOWLING_DIM_THRESHOLD) ? SHADOWLING_DARK_HEAL_PER_LIMB_DEEP : SHADOWLING_DARK_HEAL_PER_LIMB_DIM

	owner.heal_overall_damage(
		brute = heal_per * coef,
		burn  = heal_per * coef,
		required_bodytype = BODYTYPE_SHADOW
	)

	if(!owner.has_status_effect(/datum/status_effect/shadow/nightmare))
		owner.apply_status_effect(/datum/status_effect/shadow)

	if(!applied_speed)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
		applied_speed = TRUE

/datum/status_effect/grouped/bodypart_effect/nyxosynthesis/shadowling/on_remove()
	. = ..()
	if(applied_speed && owner)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
