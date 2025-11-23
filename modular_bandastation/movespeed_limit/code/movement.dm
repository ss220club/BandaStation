GLOBAL_VAR_INIT(legs_trip_threshold, 0.85)
GLOBAL_VAR_INIT(legs_break_threshold, 0.3)

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return

	if(shoes && body_position == STANDING_UP && has_gravity(loc))
		if((. && !moving_diagonally) || (!. && moving_diagonally == SECOND_DIAG_STEP))
			SEND_SIGNAL(shoes, COMSIG_SHOES_STEP_ACTION)

	check_movespeed()

/mob/living/carbon/human/proc/check_movespeed() // чем ближе коэффицент замедления к legs_break_threshold -> тем выше шанс повредить ноги

	if(cached_multiplicative_slowdown >= GLOB.legs_trip_threshold)
		return

	if(prob(50))
		Knockdown(2 SECONDS, 0, TRUE)
		to_chat(src, span_bolddanger("Вы оступились и упали от слишком быстрого бега!"))

	if(cached_multiplicative_slowdown >= GLOB.legs_break_threshold)
		return

	var/excess = GLOB.legs_break_threshold - cached_multiplicative_slowdown
	var/chance = excess / GLOB.legs_break_threshold

	if(prob(chance * 100))
		apply_damage(40, BRUTE, "l_leg")
		apply_damage(40, BRUTE, "r_leg")
		Knockdown(2 SECONDS, 0, TRUE)
		to_chat(src, span_bolddanger("Вы повредили ноги, споткнувшись от слишком быстрого бега!"))
