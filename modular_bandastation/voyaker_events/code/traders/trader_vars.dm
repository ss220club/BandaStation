/mob/living/carbon/human
	var/list/trader_quests = list()
	var/list/completed_trader_quests = list()
	var/next_atm_use = 0
	var/ignore_raid_death = FALSE
	var/list/trader_action_cooldowns = list()

/mob/living/carbon/human/Move(NewLoc, Dir)
	var/previous_area = get_area(src)
	. = ..()
	if(.)
		var/current_area = get_area(src)
		if(previous_area != current_area)
			check_trader_area(current_area)

/mob/living/carbon/human/proc/check_trader_cooldown(id)
	return world.time >= (trader_action_cooldowns[id] || 0)

/mob/living/carbon/human/proc/set_trader_cooldown(id, delay)
	trader_action_cooldowns[id] = world.time + delay

/mob/living/carbon/human/proc/check_trader_area(area/A)
	if(!trader_quests)
		return
	for(var/trader_id in trader_quests)
		var/datum/trader_quest/Q = trader_quests[trader_id]
		Q.on_enter_area(src, A)


/mob/living
	var/mob/living/quest_killer = null
	var/quest_kill_distance = 0
	var/quest_max_kill_distance = 0
