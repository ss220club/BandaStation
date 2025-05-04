#define REAGENT_AMOUNT "reagent_amount"
#define REAGENT_THRESHOLD "reagent_threshold"

/obj/item/organ/cyberimp/chest/pump
	name = "pump"
	desc = "A small pump, used to inject reagints into the bloodstream."
	icon_state = "nutriment_implant"
	aug_overlay = "nutripump"
	slot = ORGAN_SLOT_STOMACH_AID
	var/is_reagent_threshhold = TRUE
	var/list/reagent_data = list() // list of reagents with their injection and threshold amounts
	var/synthesizing = FALSE // is implant on synthesizing cooldown
	var/cooldown_time = 5 SECONDS // time between injections
	var/injecting_notification = "You feel a rush of energy in your bloodstream."

/obj/item/organ/cyberimp/chest/pump/on_life(seconds_per_tick, times_fired)
    if(synthesizing)
        return
    for(var/reagent_type in reagent_data)
        var/list/data = reagent_data[reagent_type]
        if(is_reagent_threshhold && !owner.reagents.has_reagent(target_reagent = reagent_type, amount = data[REAGENT_THRESHOLD]))
            owner.reagents.add_reagent(reagent_type, data[REAGENT_AMOUNT])
            synthesizing = TRUE
    if(custom_check())
        custom_effect()
    if(synthesizing)
        to_chat(owner, span_notice(injecting_notification))
        addtimer(CALLBACK(src, PROC_REF(cooldown)), cooldown_time)


/obj/item/organ/cyberimp/chest/pump/proc/cooldown()
	synthesizing = FALSE

/obj/item/organ/cyberimp/chest/pump/proc/custom_check()
	// This is a stub, it should be overridden by the implant
	// to check if the implant can be used or not.
	return FALSE

/obj/item/organ/cyberimp/chest/pump/proc/custom_effect()
	// This is a stub, it should be overridden by the implant
	// to apply the effect of the implant.
	synthesizing = TRUE
	return

/obj/item/organ/cyberimp/chest/pump/centcom
    name = "combat medicine pump"
    desc = "A small pump, used to inject extremely effective drugs into the bloodstream."
    reagent_data = list(
        /datum/reagent/medicine/adminordrazine = list(
            REAGENT_AMOUNT = 4,
            REAGENT_THRESHOLD = 16
        ),
        /datum/reagent/medicine/synaptizine = list(
            REAGENT_AMOUNT = 1,
            REAGENT_THRESHOLD = 4
        )
    )

/obj/item/organ/cyberimp/chest/pump/sansufentanyl
	name = "сансуфентаниловая помпа"
	desc = "Помпа, используемая для инъекции синтетического опиоида в фент-реактор. Жизненно важный механизм для функционирования фент-дроидов"
	reagent_data = list(
		/datum/reagent/medicine/sansufentanyl = list(
			REAGENT_AMOUNT = 1,
			REAGENT_THRESHOLD = 4
		)
	)
