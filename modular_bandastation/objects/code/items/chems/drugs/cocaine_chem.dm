#define COCAINE_POWDER_FREEZE_TEMP 250
#define CRACK_SYNTHESIS_TEMP 480

/datum/chemical_reaction/powder_cocaine
	is_cold_recipe = TRUE
	required_reagents = list(/datum/reagent/drug/cocaine = 10)
	required_temp = COCAINE_POWDER_FREEZE_TEMP
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL
	mix_message = "The solution freezes into a powder!"

/datum/chemical_reaction/powder_cocaine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/cocaine(location)

/datum/chemical_reaction/freebase_cocaine
	required_reagents = list(/datum/reagent/drug/cocaine = 10, /datum/reagent/water = 5, /datum/reagent/ash = 10)
	required_temp = CRACK_SYNTHESIS_TEMP
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/freebase_cocaine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/crack(location)

/datum/reagent/drug/cocaine
	name = "cocaine"
	description = "Мощный стимулятор, получаемый из листьев коки. Уменьшает время оглушения, но при передозировке вызывает сонливость и серьезные повреждения мозга."
	color = "#ffffff"
	overdose_threshold = 20
	ph = 9
	taste_description = "bitterness" //supposedly does taste bitter in real life
	addiction_types = list(/datum/addiction/stimulants = 14) //5.6 per 2 seconds
	var/unhealthy_multiplier = 1

/datum/reagent/drug/cocaine/on_mob_metabolize(mob/living/containing_mob)
	..()
	containing_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	ADD_TRAIT(containing_mob, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/drug/cocaine/on_mob_end_metabolize(mob/living/containing_mob)
	containing_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	REMOVE_TRAIT(containing_mob, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/drug/cocaine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(SPT_PROB(2.5, seconds_per_tick))
		var/high_message = pick("Вы чувствуете себя нервозно.", "Вы чувствуете, что должны действовать быстро.", "Вы чувствуете, что нужно сделать шаг вперёд.")
		to_chat(affected_mob, span_notice("[high_message]"))
	affected_mob.add_mood_event("zoinked", /datum/mood_event/stimulant_heavy, name)
	affected_mob.AdjustStun(-15 * metabolization_ratio * seconds_per_tick)
	affected_mob.AdjustKnockdown(-15 * metabolization_ratio * seconds_per_tick)
	affected_mob.AdjustUnconscious(-15 * metabolization_ratio * seconds_per_tick)
	affected_mob.AdjustImmobilized(-15 * metabolization_ratio * seconds_per_tick)
	affected_mob.AdjustParalyzed(-15 * metabolization_ratio * seconds_per_tick)
	var/need_mob_update
	need_mob_update += affected_mob.adjust_organ_loss(ORGAN_SLOT_BRAIN, (rand(1, 2) * unhealthy_multiplier) * metabolization_ratio * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(need_mob_update)
		. = UPDATE_MOB_HEALTH
	if(SPT_PROB(2.5, seconds_per_tick))
		affected_mob.emote(pick("twitch", "shiver"))

/datum/reagent/drug/cocaine/overdose_start(mob/living/carbon/affected_mob)
	to_chat(affected_mob, span_userdanger("Ваше сердце бьётся слишком быстро, это причиняет вам боль!"))

/datum/reagent/drug/cocaine/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/need_mob_update
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool"))

	if(!HAS_TRAIT(affected_mob, TRAIT_FLOORED))
		if(SPT_PROB(18, seconds_per_tick))
			affected_mob.visible_message(span_danger("[affected_mob] падает на пол!"))
			affected_mob.Paralyze(5.5 SECONDS * unhealthy_multiplier, TRUE)
			affected_mob.drop_all_held_items()
	need_mob_update = affected_mob.adjust_tox_loss(1 * metabolization_ratio * seconds_per_tick * unhealthy_multiplier, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjust_organ_loss(ORGAN_SLOT_HEART, (rand(5, 10) / 10 * unhealthy_multiplier) * metabolization_ratio * seconds_per_tick, required_organ_flag = affected_organ_flags)
	affected_mob.set_jitter_if_lower(5 SECONDS * unhealthy_multiplier)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/drug/cocaine/freebase_cocaine
	name = "freebase cocaine"
	description = "Разновидность кокаина, которую можно курить."
	color = "#f0e6bb"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	unhealthy_multiplier = 2

/datum/reagent/drug/cocaine/powder_cocaine
	name = "powder cocaine"
	description = "Порошкообразная форма кокаина."
	color = "#ffffff"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
