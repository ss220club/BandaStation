/proc/check_trader_kill_quests(
	mob/living/carbon/human/killer,
	mob/living/victim
)
	if(!killer)
		return
	if(!killer.trader_quests)
		return
	for(var/trader_id in killer.trader_quests)
		var/datum/trader_quest/Q = killer.trader_quests[trader_id]
		if(Q.on_target_killed(killer, victim))
			Q.complete(killer, trader_id, null)

/mob/living/carbon/human/species/monkey/punpun/death(gibbed)

	world.log << "PUNPUN DIED"

	if(quest_killer)
		world.log << "QUEST KILLER = [quest_killer]"
	else
		world.log << "QUEST KILLER IS NULL"

	if(quest_killer && ishuman(quest_killer))
		check_trader_kill_quests(quest_killer, src)

	. = ..()
