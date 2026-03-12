/datum/reagent/toxin/khara
	name = "Споры Кхара"
	description = "Микроскопические биоинженерные споры внеземного происхождения. Они агрессивно колонизируют \
					органические ткани, вызывая стремительный рост опухолеподобных образований, которые в итоге рождают новую хищную форму жизни."
	color = COLOR_MAROON
	taste_description = "горькое железо и гниль"
	taste_mult = 1.4
	chemical_flags = REAGENT_IGNORE_STASIS | REAGENT_INVISIBLE
	metabolization_rate = REAGENTS_METABOLISM * 4
	toxpwr = 0
	liver_damage_multiplier = 0
	silent_toxin = TRUE
	penetrates_skin = VAPOR

/datum/reagent/toxin/khara/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if(is_khara_creature(exposed_mob))
		exposed_mob.heal_overall_damage(5, 5, 5)
	else
		exposed_mob.take_overall_damage(2)

/datum/reagent/toxin/khara/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	var/obj/item/organ/lungs/L = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!L || !(L.organ_flags & ORGAN_ORGANIC) || is_khara_creature(affected_mob))
		return

	if(SPT_PROB(20, seconds_per_tick))
		affected_mob.emote("cough")

	var/infect_chance = 7
	if(affected_mob.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
		infect_chance *= 0.5

	if(SPT_PROB(infect_chance, seconds_per_tick))
		affected_mob.ForceContractDisease(new /datum/disease/khara(), del_on_fail = TRUE)
