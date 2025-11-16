/datum/surgery/advanced/viral_bonding
	name = "Вирусная связь"
	desc = "Хирургическая процедура, которая вызывает симбиотические отношения между вирусом и его хозяином. Пациенту необходимо ввести дозу спейсацилина, питательную среду и формальдегид."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/viral_bond,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/viral_bonding/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(!LAZYLEN(target.diseases))
		return FALSE
	return TRUE

/datum/surgery_step/viral_bond
	name = "вирусная связь (прижигатель)"
	implements = list(
		TOOL_CAUTERY = 100,
		TOOL_WELDER = 50,
		/obj/item = 30) // 30% success with any hot item.
	time = 10 SECONDS
	chems_needed = list(/datum/reagent/medicine/spaceacillin,/datum/reagent/consumable/virus_food,/datum/reagent/toxin/formaldehyde)

/datum/surgery_step/viral_bond/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()

	return TRUE

/datum/surgery_step/viral_bond/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("Вы начинаете нагревать костный мозг у [target.declent_ru(GENITIVE)] с помощью [tool.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает нагревать костный мозг у [target.declent_ru(GENITIVE)] с помощью [tool.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] начинает нагревать что-то в груди у [target.declent_ru(GENITIVE)] с помощью [tool.declent_ru(GENITIVE)]..."),
	)
	display_pain(target, "Вы чувствуете, как жгучий жар распространяется по вашей груди!")

/datum/surgery_step/viral_bond/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	display_results(
		user,
		target,
		span_notice("Костный мозг у [target.declent_ru(GENITIVE)] начинает медленно пульсировать. Вирусная связь завершена."),
		span_notice("Костный мозг у [target.declent_ru(GENITIVE)] начинает медленно пульсировать."),
		span_notice("[capitalize(user.declent_ru(NOMINATIVE))] завершает операцию."),
	)
	display_pain(target, "Вы чувствуете легкую пульсацию в груди.")
	for(var/datum/disease/infected_disease as anything in target.diseases)
		if(infected_disease.severity != DISEASE_SEVERITY_UNCURABLE) //no curing quirks, sweaty
			infected_disease.carrier = TRUE
	return TRUE
