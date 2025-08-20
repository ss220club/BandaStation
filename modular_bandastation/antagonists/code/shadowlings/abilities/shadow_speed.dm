/datum/movespeed_modifier/shadowling/dark
	multiplicative_slowdown = 0.8 // ~+20% скорости (меньше — быстрее)
	priority = 10 // чтобы перебить мелкие эффекты
	movetypes = GROUND // подставь ваш набор, если нужен

/proc/shadowling_apply_dark_speed(mob/living/L)
	// если у вас есть макросы — используйте их (ADD_MOVESPEED_MODIFIER).
	if(ismob(L))
		L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)

/proc/shadowling_remove_dark_speed(mob/living/L)
	if(ismob(L))
		L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/dark)
