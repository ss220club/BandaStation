/datum/movespeed_modifier/shadowling/phase
	multiplicative_slowdown = -2
	priority = 30
	movetypes = GROUND

/datum/status_effect/shadow/phase
	id = "shadow_phase"
	tick_interval = 0.3 SECONDS
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT

	var/light_immunity = FALSE

/datum/status_effect/shadow/phase/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_UNDENSE, src)

	owner.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/phase)

	return TRUE

/datum/status_effect/shadow/phase/on_remove()
	. = ..()
	if(!istype(owner))
		return

	owner.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/phase)
	REMOVE_TRAIT(owner, TRAIT_UNDENSE, src)

	var/is_inside = FALSE
	if(istype(owner.loc, /obj/effect/dummy/phased_mob/shadowling))
		is_inside = TRUE

	if(is_inside)
		var/obj/effect/dummy/phased_mob/shadowling/P = owner.loc
		P.eject_jaunter(FALSE)

	animate(owner, alpha = 255, time = 0.3 SECONDS)

	if(!is_inside)
		shadow_phase_start_entry_cooldown(owner)


/datum/status_effect/shadow/phase/tick(seconds_between_ticks)
	if(!istype(owner))
		return

	if(light_immunity)
		return

	var/turf/T = get_turf(owner)
	if(!T)
		return

	var/brightness = T.get_lumcount()
	if(brightness >= SHADOWLING_LIGHT_THRESHOLD)
		owner.Knockdown(1 SECONDS)
		owner.Paralyze(1 SECONDS)
		owner.remove_status_effect(type)

/obj/effect/dummy/phased_mob/shadowling
	parent_type = /obj/effect/dummy/phased_mob/shadow
	name = "shadows"
	phased_mob_icon_state = "purple_laser"

	var/light_immunity = FALSE
	light_max = SHADOWLING_LIGHT_THRESHOLD
	movespeed = 1.5

/obj/effect/dummy/phased_mob/shadowling/check_light_level(atom/location_to_check)
	if(light_immunity)
		return FALSE

	var/atom/place = location_to_check || src
	var/turf/T = get_turf(place)
	if(!istype(T))
		return FALSE

	var/brightness = T.get_lumcount()
	if(isnull(brightness))
		return FALSE

	return brightness > light_max

/obj/effect/dummy/phased_mob/shadowling/eject_jaunter(forced_out = FALSE)
	var/mob/living/L = jaunter
	. = ..()

	if(istype(L))
		animate(L, alpha = 255, time = 0.3 SECONDS)

		if(forced_out && !light_immunity)
			L.Knockdown(1 SECONDS)
			L.Paralyze(1 SECONDS)

		shadow_phase_start_entry_cooldown(L)
