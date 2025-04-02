/datum/job/curator/New()
	mind_traits += list(TRAIT_BLOODSUCKER_HUNTER)
	return ..()

/datum/job/curator/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!spawned.mind)
		return
	spawned.mind.teach_crafting_recipe(/datum/crafting_recipe/hardened_stake)
	spawned.mind.teach_crafting_recipe(/datum/crafting_recipe/silver_stake)
