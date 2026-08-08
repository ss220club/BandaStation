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
		Q.on_any_human_killed(killer, victim)
		if(Q.on_target_killed(killer, victim))
			Q.add_progress(killer, trader_id)

/proc/check_trader_reputation_events(mob/living/carbon/human/player, mob/living/victim)
	if(!player)
		return
	if(istype(victim, /mob/living/basic/killer))
		player.add_trader_rep(TRADER_KAMILLA, -1)
		to_chat(player, span_warning("Ваша репутация с торговцем Камилла понизилась на -1."))
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/card/id/I = H.wear_id
		if(I)
			to_chat(player, span_notice("Найдена ID-карта: [I.type]"))
			if(istype(I, /obj/item/card/id/advanced/blessed))
				player.add_trader_rep(TRADER_TERESA, -50)
				to_chat(player, span_warning("Вы убили сотрудника Милосердия! Репутация с Терезой понизилась на -50."))

/proc/check_trader_bunker_events(mob/living/carbon/human/player)
	if(!player)
		return
	if(!player.trader_quests)
		return
	for(var/trader_id in player.trader_quests)
		var/datum/trader_quest/Q = player.trader_quests[trader_id]
		Q.on_forest_bunker_open(player)
