/datum/antagonist/clock_cultist/clockmob
	show_in_antagpanel = FALSE
	///Our warp action
	var/datum/action/cooldown/clock_cult/clockmob_warp/warp_action = new
	// multi_area_bound component not in BandaStation base; area confinement skipped

/datum/antagonist/clock_cultist/clockmob/Destroy()
	QDEL_NULL(warp_action)
	return ..()

/datum/antagonist/clock_cultist/clockmob/apply_innate_effects(mob/living/mob_override)
	. = ..()
	warp_action.Grant(owner.current)

/datum/antagonist/clock_cultist/clockmob/remove_innate_effects(mob/living/mob_override)
	. = ..()
	warp_action.Remove(owner.current)
