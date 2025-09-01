/datum/action/cooldown/shadowling/shadow_grab
	name = "Теневой захват"
	desc = "Выйти из тени у ближайшей цели (≤2 тайла) и сразу схватить её сильным захватом."
	background_icon_state = "shadow_demon_bg"
	button_icon = 'modular_bandastation/antagonists/icons/shadowlings_actions.dmi'
	button_icon_state = "shadow_grab"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 0

	var/target_grab_level = GRAB_NECK

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/shadow_grab/CanUse(mob/living/carbon/human/H)
	if(!..())
		return FALSE
	if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
		return TRUE
	if(H.has_status_effect(/datum/status_effect/shadow/phase))
		return TRUE
	to_chat(H, span_warning("Вы должны быть в теневой фазе."))
	return FALSE

/datum/action/cooldown/shadowling/shadow_grab/DoEffect(mob/living/carbon/human/H, atom/_)
	var/mob/living/carbon/human/T = find_nearest_target(2)
	if(!T)
		to_chat(H, span_warning("Поблизости нет подходящих целей."))
		return FALSE

	var/obj/effect/dummy/phased_mob/shadowling/P = istype(H.loc, /obj/effect/dummy/phased_mob/shadowling) ? H.loc : null
	if(P)
		var/turf/nearby = pick_adjacent_open_turf(get_turf(T))
		if(nearby)
			P.forceMove(nearby)
		P.eject_jaunter(FALSE)
	else
		H.remove_status_effect(/datum/status_effect/shadow/phase)

	if(get_dist(H, T) > 1)
		step_towards(H, T)

	if(!H.grab(T))
		return FALSE

	while(H.grab_state < target_grab_level)
		if(!H.pulling || H.pulling != T)
			break
		if(!T.grippedby(H, TRUE))
			break

	return (H.pulling == T)

