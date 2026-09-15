/// Applies vampire-specific holy water effects without changing the shared reagent.
/datum/component/vampire_holywater
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/vampire_holywater/Initialize(...)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/vampire_holywater/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_REAGENT_TICK, PROC_REF(on_reagent_tick))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_reagent_exposed))

/datum/component/vampire_holywater/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOB_REAGENT_TICK, COMSIG_ATOM_EXPOSE_REAGENT))

/datum/component/vampire_holywater/proc/on_reagent_tick(mob/living/carbon/human/affected_mob, datum/reagent/chem, seconds_per_tick, metabolization_ratio)
	SIGNAL_HANDLER
	if(!istype(chem, /datum/reagent/water/holywater))
		return

	var/datum/antagonist/vampire_thrall/thrall = affected_mob.mind?.has_antag_datum(/datum/antagonist/vampire_thrall)
	if(thrall)
		// Reagent ticks occur before on_mob_life(), where holy water reaches this threshold and purges itself.
		var/metabolized = chem.data?["deciseconds_metabolized"] || 0
		if(metabolized + seconds_per_tick * 1 SECONDS * metabolization_ratio >= 1 MINUTES)
			affected_mob.mind.remove_antag_datum(/datum/antagonist/vampire_thrall)
			chem.holder?.remove_reagent(chem.type, chem.volume)
			affected_mob.visible_message(span_userdanger("[affected_mob] отшатывается; краски возвращаются на [affected_mob.p_their()] кожу, а вместе с ними — контроль над собой!"))
			return COMSIG_MOB_STOP_REAGENT_TICK

	var/datum/antagonist/vampire/vampire = affected_mob.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || vampire.get_ability(/datum/vampire_passive/full) || !prob(80) || !vampire.bloodtotal)
		return

	if(vampire.bloodusable)
		affected_mob.adjust_stutter_up_to(2 SECONDS, 20 SECONDS)
		affected_mob.adjust_jitter_up_to(60 SECONDS, 60 SECONDS)
		affected_mob.adjust_stamina_loss(5)
		if(prob(20))
			INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), "scream")
		vampire.adjust_nullification(20, 4)
		vampire.subtract_usable_blood(3)
		if(!vampire.bloodusable)
			chem.holder?.remove_reagent(chem.type, chem.volume)
			affected_mob.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 0, distance = 0)
			return COMSIG_MOB_STOP_REAGENT_TICK

		affected_mob.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 0)
		affected_mob.adjust_brute_loss(3)
		return

	switch(chem.current_cycle)
		if(1 to 4)
			to_chat(affected_mob, span_warning("Что-то шипит в ваших венах!"))
			vampire.adjust_nullification(20, 4)
		if(5 to 12)
			to_chat(affected_mob, span_danger("Вы чувствуете сильное жжение внутри!"))
			affected_mob.adjust_fire_loss(1)
			affected_mob.adjust_stutter_up_to(2 SECONDS, 20 SECONDS)
			affected_mob.adjust_jitter_up_to(40 SECONDS, 40 SECONDS)
			if(prob(20))
				INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), "scream")
			vampire.adjust_nullification(20, 4)
		if(13 to INFINITY)
			affected_mob.visible_message(
				span_danger("[affected_mob] внезапно вспыхивает!"),
				span_userdanger("Вас внезапно охватывает священное пламя!"),
				span_danger("Вы слышите, как что-то внезапно вспыхивает!"),
			)
			affected_mob.set_fire_stacks(min(affected_mob.fire_stacks + 3, 5))
			affected_mob.ignite_mob()
			affected_mob.adjust_fire_loss(3)
			affected_mob.adjust_stutter_up_to(2 SECONDS, 20 SECONDS)
			affected_mob.adjust_jitter_up_to(60 SECONDS, 60 SECONDS)
			if(prob(40))
				INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), "scream")
			vampire.adjust_nullification(20, 4)

/datum/component/vampire_holywater/proc/on_reagent_exposed(mob/living/carbon/human/affected_mob, datum/reagent/chem, _reac_volume, methods)
	SIGNAL_HANDLER
	if(!istype(chem, /datum/reagent/water/holywater) || !(methods & TOUCH))
		return
	var/datum/antagonist/vampire/vampire = affected_mob.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || vampire.get_ability(/datum/vampire_passive/full))
		return
	if(affected_mob.wear_mask)
		to_chat(affected_mob, span_warning("Ваша маска защищает вас от святой воды!"))
		return
	if(affected_mob.head)
		to_chat(affected_mob, span_warning("Ваш шлем защищает вас от святой воды!"))
		return
	to_chat(affected_mob, span_warning("Что-то святое мешает вашим силам!"))
	vampire.adjust_nullification(5, 2)
