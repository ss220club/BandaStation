/datum/job/curator/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!spawned.mind)
		return
	ADD_TRAIT(spawned.mind, TRAIT_BLOODSUCKER_HUNTER, JOB_TRAIT)

/datum/job/chaplain/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!spawned.mind)
		return
	spawned.mind.teach_crafting_recipe(/datum/crafting_recipe/hardened_stake)
	spawned.mind.teach_crafting_recipe(/datum/crafting_recipe/silver_stake)
	ADD_TRAIT(spawned.mind, TRAIT_BLOODSUCKER_HUNTER, JOB_TRAIT)
