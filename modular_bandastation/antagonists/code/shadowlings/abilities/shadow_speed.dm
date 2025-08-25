/datum/movespeed_modifier/shadowling/dark
	multiplicative_slowdown = 0.2
	priority = 10
	movetypes = GROUND

/proc/shadowling_apply_dark_speed(mob/living/L)
	if(ismob(L))
		L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)

/proc/shadowling_remove_dark_speed(mob/living/L)
	if(ismob(L))
		L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
