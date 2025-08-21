/datum/status_effect/shadow/phase
	id = "shadow_phase"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	duration = -1
	tick_interval = 5 // каждые 0.5с, если у вас seconds_between_ticks = deciseconds; иначе подгоните

/datum/status_effect/shadow/phase/on_apply()
	. = ..()
	var/mob/living/L = owner
	if(!L) return
	// визуал/коллизия
	L.alpha = 120
	L.density = FALSE
	// проходимость + ускорение в тени
	ADD_TRAIT(L, TRAIT_PASSTABLE, "shadow_phase")
	L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)

/datum/status_effect/shadow/phase/on_remove()
	. = ..()
	var/mob/living/L = owner
	if(!L) return
	L.alpha = initial(L.alpha)
	L.density = TRUE
	REMOVE_TRAIT(L, TRAIT_PASSTABLE, "shadow_phase")
	L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)

/datum/status_effect/shadow/phase/tick(seconds_between_ticks)
	var/mob/living/L = owner
	if(!L) return
	if(get_local_brightness(L) >= L_BRIGHT)
		// яркий свет насильно «выталкивает» из тени и чуть станит
		L.remove_status_effect(type)
		L.Stun(1 SECONDS)
