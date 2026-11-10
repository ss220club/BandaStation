/obj/item/organ/brain/primate/on_mob_bump(mob/source, mob/living/crossing_mob)
	if(HAS_TRAIT(owner, TRAIT_LOOT_GOBLIN))
		return
	return ..()

/datum/action/item_action/organ_action/toggle_trip/Grant(mob/grant_to)
	if(HAS_TRAIT(grant_to, TRAIT_LOOT_GOBLIN))
		return
	return ..()
