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
	var/mob/living/killer = vars["quest_killer"]
	if(killer && ishuman(killer))
		check_trader_kill_quests(quest_killer, src)

	. = ..()
