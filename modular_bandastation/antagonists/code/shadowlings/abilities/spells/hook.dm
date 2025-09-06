/datum/action/cooldown/shadowling/hook
	name = "Теневой крюк"
	desc = "Бросает тень-гарпун и тянет цель к себе. Не сбивает фазу."
	button_icon_state = "shadow_hook"
	cooldown_time = 10 SECONDS
	max_range = 6
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	channel_time = 0

/datum/action/cooldown/shadowling/hook/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	var/mob/living/target = find_nearest_target(max_range)
	if(!istype(target))
		H.balloon_alert(H, "нет цели")
		return FALSE
	if(target.buckled || target.anchored)
		H.balloon_alert(H, "цель закреплена")
		return FALSE

	var/turf/land
	var/obj/effect/dummy/phased_mob/shadowling/P
	if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
		P = H.loc
		land = pick_adjacent_open_turf(get_turf(P))
	else
		land = pick_adjacent_open_turf(get_turf(H))

	if(!land)
		H.balloon_alert(H, "нет места рядом")
		return FALSE

	if(get_dist(target, land) <= 0)
		return TRUE

	target.throw_at(land, max(get_dist(target, land), 1), 2)
	target.adjust_dizzy(2)
	target.adjust_confusion_up_to(2 SECONDS, 2 SECONDS)

	StartCooldown()
	return TRUE
