#define CHANGELING_PHEROMONE_MIN_DISTANCE 10 //More generous than the agent pinpointer because you don't know who you're looking for.
#define CHANGELING_PHEROMONE_MAX_DISTANCE 25 //They can smell your fear a mile away.  Well, 50 meters.
#define CHANGELING_PHEROMONE_PING_TIME 20 //2s update time.


/datum/action/changeling/pheromone_receptors
	name = "Pheromone Receptors"
	desc = "Мы настраиваем свои органы чувств, чтобы отслеживать других генокрадов по запаху. Чем ближе они, тем легче их найти."
	helptext = "Мы будем знать общее направление движения близлежащих генокрадов, причем более близкие запахи будут сильнее. Во время действия этой функции наша химическая выработка замедлена."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"
	chemical_cost = 0 //Reduces regain rate while active.
	dna_cost = 2
	var/receptors_active = FALSE

/datum/action/changeling/pheromone_receptors/Remove(mob/living/carbon/user)
	if(receptors_active)
		var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
		changeling.chem_recharge_slowdown -= 0.25
		user.remove_status_effect(/datum/status_effect/agent_pinpointer/changeling)
	..()

/datum/action/changeling/pheromone_receptors/sting_action(mob/living/carbon/user)
	..()
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(HAS_TRAIT(user, TRAIT_ANOSMIA)) //Anosmia quirk holders can't smell anything
		to_chat(user, span_warning("Мы не чувствуем запаха!"))
		return
	if(!receptors_active)
		to_chat(user, span_warning("Мы ищем по запаху ближайших генокрадов."))
		changeling.chem_recharge_slowdown += 0.25
		user.apply_status_effect(/datum/status_effect/agent_pinpointer/changeling)
	else
		to_chat(user, span_notice("Мы прекращаем поиски."))
		changeling.chem_recharge_slowdown -= 0.25
		user.remove_status_effect(/datum/status_effect/agent_pinpointer/changeling)

	receptors_active = !receptors_active

//Modified IA pinpointer - Points to the NEAREST changeling, but will only get you within a few tiles of the target.
//You'll still have to rely on intuition and observation to make the identification.  Lings can 'hide' in public places.
/datum/status_effect/agent_pinpointer/changeling
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/changeling
	minimum_range = CHANGELING_PHEROMONE_MIN_DISTANCE
	tick_interval = CHANGELING_PHEROMONE_PING_TIME
	range_fuzz_factor = 0

/datum/status_effect/agent_pinpointer/changeling/scan_for_target()
	var/turf/my_loc = get_turf(owner)

	var/list/mob/living/carbon/changelings = list()

	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C != owner && C.mind)
			var/datum/antagonist/changeling/antag_datum = IS_CHANGELING(C)
			if(istype(antag_datum))
				var/their_loc = get_turf(C)
				var/distance = get_dist_euclidean(my_loc, their_loc)
				if (distance < CHANGELING_PHEROMONE_MAX_DISTANCE)
					changelings[C] = (CHANGELING_PHEROMONE_MAX_DISTANCE ** 2) - (distance ** 2)

	if(changelings.len)
		scan_target = pick_weight(changelings) //Point at a 'random' changeling, biasing heavily towards closer ones.
	else
		scan_target = null


/atom/movable/screen/alert/status_effect/agent_pinpointer/changeling
	name = "Аромат феромона"
	desc = "Нос всегда знает."

#undef CHANGELING_PHEROMONE_MIN_DISTANCE
#undef CHANGELING_PHEROMONE_MAX_DISTANCE
#undef CHANGELING_PHEROMONE_PING_TIME
