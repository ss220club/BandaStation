/mob/living/carbon/human
	var/list/trader_quests = list()
	var/list/completed_trader_quests = list()
	var/next_atm_use = 0
	var/ignore_raid_death = FALSE

/mob/living
	var/mob/living/quest_killer = null
