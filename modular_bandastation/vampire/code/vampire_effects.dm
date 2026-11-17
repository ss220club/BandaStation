/obj/effect/immortality_talisman/proc/shadow_to_animation(turf/end_turf, mob/user)
	var/turf/start_turf = get_turf(src)
	dir = user.dir
	var/x_difference = end_turf.x - start_turf.x
	var/y_difference = end_turf.y - start_turf.y
	var/distance = sqrt(x_difference ** 2 + y_difference ** 2)
	animate(src, time = distance, alpha = 0, pixel_x = x_difference * 32, pixel_y = y_difference * 32)
	QDEL_IN(src, distance)

/// A localized delusion used by Mass Hysteria. Each victim sees only the humans around them.
/datum/hallucination/delusion/preset/vampire_hysteria
	random_hallucination_weight = 0
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/vampire_hysteria/get_delusion_targets()
	. = list()
	for(var/mob/living/carbon/human/nearby_human in view(world.view, hallucinator))
		. += nearby_human

/datum/hallucination/delusion/preset/vampire_hysteria/monkey
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/vampire_hysteria/corgi
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/preset/vampire_hysteria/carp
	delusion_icon_file = 'icons/mob/simple/carp.dmi'
	delusion_icon_state = "carp"
	delusion_name = "carp"

/datum/hallucination/delusion/preset/vampire_hysteria/skeleton
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/preset/vampire_hysteria/zombie
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "zombie"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/vampire_hysteria/demon
	delusion_icon_file = 'icons/mob/simple/demon.dmi'
	delusion_icon_state = "slaughter_demon"
	delusion_name = "demon"
