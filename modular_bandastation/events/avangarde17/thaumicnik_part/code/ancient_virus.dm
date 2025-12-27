GLOBAL_VAR_INIT(arp_seventeen_max_stage, 2)

/datum/disease/arp_seventeen
	name = "Белок АРП-17"
	max_stages = 5
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS
	spread_text = "Неизвестно"
	cure_text = "Неизвестно"
	cures = list(/datum/reagent/consumable/ethanol/white_russian)	// Placeholder GAGAGA
	agent = "Неизвестно"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	desc = "Неизвестный белок, отсутствующий в базах данных."
	severity = "Неизвестно"
	infectable_biotypes = MOB_ORGANIC

/datum/disease/arp_seventeen/update_stage(new_stage)
	new_stage = min(GLOB.arp_seventeen_max_stage, new_stage)
	stage = new_stage
	if(new_stage == max_stages && !(stage_peaked)) //once a virus has hit its peak, set it to have done so
		stage_peaked = TRUE
	if (stage <= 0)
		cure()
		return FALSE
	return TRUE

/datum/disease/arp_seventeen/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(3.5, seconds_per_tick))
				affected_mob.emote("sneeze")
		if(3)
			if(SPT_PROB(3.5, seconds_per_tick))
				affected_mob.emote("cough")
			if(SPT_PROB(6, seconds_per_tick))
				to_chat(affected_mob, span_danger("Ваше тело болит. Вы чувствуете недомогание"))
		if(4)
			if(SPT_PROB(3.5, seconds_per_tick))
				affected_mob.emote("gasp")
			if(SPT_PROB(6, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вы чувствуете как кровь приливает к вашей голове. Вам это нравится."))
		if(4)
			if(SPT_PROB(6, seconds_per_tick))
				to_chat(affected_mob, span_danger("Вам хорошо. Вы спокойны. Вы здоровы."))
		if(5)
			if(SPT_PROB(30, seconds_per_tick))
				affected_mob.investigate_log("has been gibbed by GBS.", INVESTIGATE_DEATHS)
				affected_mob.gib(DROP_ALL_REMAINS)
				return FALSE

/proc/set_arp_seventeen_max_stage(new_max_stage)
	var/old_max_stage = GLOB.arp_seventeen_max_stage
	GLOB.arp_seventeen_max_stage = new_max_stage
	return "Max stage updated [old_max_stage] -> [new_max_stage]"
