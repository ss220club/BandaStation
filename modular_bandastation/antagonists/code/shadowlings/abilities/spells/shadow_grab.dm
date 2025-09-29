// MARK: Ability
/datum/action/cooldown/shadowling/shadow_grab
	name = "Теневой захват"
	desc = "Выйти из тени у ближайшей цели (≤2 тайла) и сразу схватить её сильным захватом."
	button_icon_state = "shadow_grab"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 0
	// Shadowling related
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0
	var/target_grab_level = GRAB_NECK

/datum/action/cooldown/shadowling/shadow_grab/can_use(mob/living/carbon/human/H)
	if(!..())
		return FALSE
	if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
		return TRUE
	if(H.has_status_effect(/datum/status_effect/shadow/phase))
		return TRUE
	owner.balloon_alert(owner, "вы должны быть нематериальны")
	return FALSE

/datum/action/cooldown/shadowling/shadow_grab/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	var/mob/living/carbon/human/T = find_nearest_target(2)
	if(!T)
		owner.balloon_alert(owner, "нет доступных целей")
		return FALSE

	var/turf/nearby = pick_adjacent_open_turf(get_turf(T))
	var/datum/action/cooldown/shadowling/shadow_phase/SP
	for(var/datum/action/cooldown/shadowling/shadow_phase/X in H.actions)
		SP = X; break
	if(SP)
		SP.materialize_near(H, nearby, FALSE)
	else
		if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
			var/obj/effect/dummy/phased_mob/shadowling/P = H.loc
			if(istype(nearby)) P.forceMove(nearby)
			P.eject_jaunter(FALSE)
		else
			H.remove_status_effect(/datum/status_effect/shadow/phase)

	if(get_dist(H, T) > 1)
		step_towards(H, T)

	if(QDELETED(H) || QDELETED(T) || get_dist(H, T) > 1)
		owner.balloon_alert(owner, "слишком далеко для захвата")
		return FALSE

	if(!H.grab(T))
		return FALSE

	while(H.grab_state < target_grab_level)
		if(!H.pulling || H.pulling != T)
			break
		if(!T.grippedby(H, TRUE))
			break

	return (H.pulling == T)

/datum/action/cooldown/shadowling/shadow_grab/StartCooldown(time_override)
	..(time_override)
	enable()
