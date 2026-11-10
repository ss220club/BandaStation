/datum/component/caltrop/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(HAS_TRAIT(arrived, TRAIT_LOOT_GOBLIN_STEADY_FEET))
		return
	return ..()

/obj/structure/table/glass/check_break(mob/living/M)
	if(HAS_TRAIT(M, TRAIT_LOOT_GOBLIN_STEADY_FEET))
		return FALSE
	return ..()
