///amount of reagent to inject per time
#define REAGENT_AMOUNT "reagent_amount"
///amount of reagent to inject before the implant stops injecting
#define REAGENT_THRESHOLD "reagent_threshold"

/obj/item/organ/cyberimp/chest/pump
	name = "pump"
	desc = "Маленькая помпа, используемая для инъекции реагентов в кровоток."
	icon_state = "nutriment_implant"
	aug_overlay = "nutripump"
	slot = ORGAN_SLOT_STOMACH_AID
	var/is_reagent_threshhold = TRUE
	/**
	 * list of reagents with their injection and threshold amounts
	 * * REAGENT_AMOUNT - amount of reagent to inject per time
	 * * REAGENT_THRESHOLD - amount of reagent to inject before the implant stops injecting
	 */
	var/list/reagent_data = list()
	/// time between injections
	var/cooldown_time = 5 SECONDS

/obj/item/organ/cyberimp/chest/pump/on_life(seconds_per_tick, times_fired)
	if(!TIMER_COOLDOWN_FINISHED(src, COOLDOWN_PUMP))
		return
	for(var/reagent_type in reagent_data)
		var/list/data = reagent_data[reagent_type]
		if(is_reagent_threshhold && !owner.reagents.has_reagent(target_reagent = reagent_type, amount = data[REAGENT_THRESHOLD]))
			owner.reagents.add_reagent(reagent_type, data[REAGENT_AMOUNT])
	if(custom_check(seconds_per_tick, times_fired))
		custom_effect(seconds_per_tick, times_fired)
	TIMER_COOLDOWN_START(src, COOLDOWN_PUMP, cooldown_time)

/**
 * This is a stub, it should be overridden by the implant
 * to check if the implant can be used or not for the specific actions.
*/
/obj/item/organ/cyberimp/chest/pump/proc/custom_check(seconds_per_tick, times_fired)
	return FALSE

/**
 * This is a stub, it should be overridden by the implant
 * to apply the specific effect of the implant.
*/
/obj/item/organ/cyberimp/chest/pump/proc/custom_effect(seconds_per_tick, times_fired)
	return

/obj/item/organ/cyberimp/chest/pump/centcom
    name = "combat medicine pump"
	desc = "Маленькая помпа, используемая для инъекции крайне эффективных препаратов в кровоток."
    reagent_data = list(
        /datum/reagent/medicine/syndicate_nanites = list(
            REAGENT_AMOUNT = 5,
            REAGENT_THRESHOLD = 20
        ),
		/datum/reagent/medicine/leporazine = list(
			REAGENT_AMOUNT = 2,
			REAGENT_THRESHOLD = 8
		),
        /datum/reagent/medicine/synaptizine = list(
            REAGENT_AMOUNT = 2,
            REAGENT_THRESHOLD = 4
        ),
		/datum/reagent/medicine/coagulant = list(
			REAGENT_AMOUNT = 4,
			REAGENT_THRESHOLD = 16
		),
			/datum/reagent/medicine/salglu_solution = list(
			REAGENT_AMOUNT = 10,
			REAGENT_THRESHOLD = 50
		)
    )

/obj/item/organ/cyberimp/chest/pump/centcom/custom_check(seconds_per_tick, times_fired)
	return owner.nutrition <= NUTRITION_LEVEL_HUNGRY

/obj/item/organ/cyberimp/chest/pump/centcom/custom_effect(seconds_per_tick, times_fired)
	. = ..()
	to_chat(owner, span_notice("You feel less hungry..."))
	owner.adjust_nutrition(25 * seconds_per_tick)

/obj/item/organ/cyberimp/chest/pump/sansufentanyl
	name = "sansufentanyl pump"
	desc = "Помпа, используемая для инъекции синтетического опиоида в фент-реактор. Жизненно важный механизм для функционирования фент-дроидов"
	reagent_data = list(
		/datum/reagent/medicine/sansufentanyl = list(
			REAGENT_AMOUNT = 1,
			REAGENT_THRESHOLD = 4
		)
	)

#undef REAGENT_AMOUNT
#undef REAGENT_THRESHOLD
