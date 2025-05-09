// -- Reagents that modify pain. --
/datum/reagent
	/// Modifier applied by this reagent to the mob's pain.
	/// This is both a multiplicative modifier to their overall recieved pain,
	/// and an additive modifier to their per tick pain decay rate.
	var/pain_modifier = null

/datum/reagent/on_mob_metabolize(mob/living/carbon/user)
	. = ..()
	if(!isnull(pain_modifier))
		user.set_pain_mod("[PAIN_MOD_CHEMS]-[name]", pain_modifier)

/datum/reagent/on_mob_end_metabolize(mob/living/carbon/user)
	. = ..()
	user.unset_pain_mod("[PAIN_MOD_CHEMS]-[name]")

// Morphine buff to actually work as a painkiller
/datum/reagent/medicine/morphine
	addiction_types = list(/datum/addiction/opiods = 30) //5u = 100 progress, 25-30u = addiction
	pain_modifier = 0.4

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustBruteLoss(-0.2 * REM * delta_time, FALSE)
	M.adjustFireLoss(-0.1 * REM * delta_time, FALSE)
	M.cause_pain(BODY_ZONES_ALL, -0.3)

	return TRUE

/datum/reagent/medicine/epinephrine
	pain_modifier = 0.9

/datum/reagent/medicine/atropine
	pain_modifier = 0.8

/datum/reagent/medicine/mine_salve
	pain_modifier = 0.75

// Determined = fight or flight mode = should have less pain
/datum/reagent/determination
	pain_modifier = 0.5

// Drugs reduce pain, alcohol reduces pain based on boozepwr
/datum/reagent/drug/space_drugs
	pain_modifier = 0.8

/datum/reagent/consumable/ethanol/New()
	if(boozepwr)
		var/new_pain_modifier = 12 / (boozepwr * 0.2)
		if(isnull(pain_modifier) && new_pain_modifier < 1)
			pain_modifier = new_pain_modifier
	return ..()

/datum/reagent/consumable/ethanol/painkiller
	pain_modifier = 0.75

// Abductor chem sets pain mod to 0 so abductors can do their surgeries
/datum/reagent/medicine/cordiolis_hepatico
	pain_modifier = 0

// Healium functions as an anesthetic
/datum/reagent/healium
	pain_modifier = 0.75

/datum/reagent/healium/on_mob_metabolize(mob/living/L)
	. = ..()
	if(L.IsSleeping())
		var/obj/item/organ/lungs/our_lungs = L.getorganslot(ORGAN_SLOT_LUNGS)
		our_lungs?.on_anesthetic = TRUE

/datum/reagent/healium/on_mob_end_metabolize(mob/living/L)
	. = ..()
	var/obj/item/organ/lungs/our_lungs = L.getorganslot(ORGAN_SLOT_LUNGS)
	our_lungs?.on_anesthetic = FALSE

// Cryoxadone slowly heals pain, a la wounds
/datum/reagent/medicine/cryoxadone
	pain_modifier = 0.5

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	var/power = -0.00003 * (M.bodytemperature ** 2) + 3
	if(M.bodytemperature < T0C)
		M.cause_pain(BODY_ZONES_ALL, -0.25 * power * REM * delta_time, 0.01)

/datum/reagent/medicine/stimulants
	pain_modifier = 0.5

/datum/reagent/medicine/changelingadrenaline
	pain_modifier = 0.5

/// New reagents

/datum/reagent/medicine/painkiller
	name = "prescription painkiller"

/datum/reagent/medicine/painkiller/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(current_cycle >= 5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "numb", /datum/mood_event/narcotic_medium, name)

	var/highest_boozepwr = 0
	for(var/datum/reagent/consumable/ethanol/alcohol in M.reagents.reagent_list)
		if(alcohol.boozepwr > highest_boozepwr)
			highest_boozepwr = alcohol.boozepwr

	if(highest_boozepwr)
		M.apply_damage(round(highest_boozepwr / 33, 0.5) * REM * delta_time, TOX)
		. = TRUE

// Aspirin. Bad at headaches, good at everything else, okay at fevers.
// Use healing chest and limb pain primarily.
/datum/reagent/medicine/painkiller/aspirin
	name = "Asprin"
	description = "A medication that combats pain and fever. Can cause mild nausea. Overdosing is toxic, and causes high body temperature, sickness, hallucinations, dizziness, and confusion."
	reagent_state = LIQUID
	color = "#9c46ff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 6.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.6

/datum/reagent/medicine/painkiller/aspirin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	// Not good at headaches, but very good at treating everything else.
	M.adjustBruteLoss(-0.1 * REM * delta_time, FALSE)
	M.adjustFireLoss(-0.05 * REM * delta_time, FALSE)
	M.cause_pain(BODY_ZONE_HEAD, -0.02 * REM * delta_time)
	M.cause_pain(BODY_ZONES_LIMBS, -0.04 * REM * delta_time)
	M.cause_pain(BODY_ZONE_CHEST, -0.08 * REM * delta_time)
	// Okay at fevers.
	M.adjust_bodytemperature(-15 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, M.get_body_temp_normal())
	// Causes more disgust than paracetamol.
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && DT_PROB(50 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(3 * REM * delta_time)

	. = ..()
	return TRUE

/datum/reagent/medicine/painkiller/aspirin/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(!istype(M))
		return

	// On overdose, heat up the body...
	M.adjust_bodytemperature(30 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time)
	// Causes sickness...
	M.apply_damage(1 * REM * delta_time, TOX)
	if(M.disgust < 100 && DT_PROB(100 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(6 * REM * delta_time)
	// ...Hallucinations after a while...
	if(current_cycle >= 15 && DT_PROB(75 * max(1 - creation_purity, 0.5), delta_time))
		M.hallucination = clamp(M.hallucination + 3 * REM * delta_time, 0, 20)
	// ...Dizziness after a longer while...
	if(current_cycle >= 20 && DT_PROB(50 * max(1 - creation_purity, 0.5), delta_time))
		M.dizziness = clamp(M.dizziness + (1 * REM * delta_time), 0, 5)
	// ...And finally, confusion
	if(current_cycle >= 25 && DT_PROB(30 * max(1 - creation_purity, 0.5), delta_time))
		M.set_confusion(clamp(M.get_confusion() + 2, 1, 6))

	return TRUE

/datum/chemical_reaction/medicine/aspirin
	results = list(/datum/reagent/medicine/painkiller/aspirin = 3)
	required_reagents = list(/datum/reagent/medicine/sal_acid = 1, /datum/reagent/acetone = 1, /datum/reagent/oxygen = 1)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

// Paracetamol. Okay at headaches, okay at everything else, bad at fevers, less disgust.
// Use for general healing every type of pain.
/datum/reagent/medicine/painkiller/paracetamol
	name = "Paracetamol"
	description = "A painkiller that combats mind to moderate pain, headaches, and low fever. Causes mild nausea. Overdosing causes liver damage, sickness, and can be lethal."
	reagent_state = LIQUID
	color = "#fcaeff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 4.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.6

/datum/reagent/medicine/painkiller/paracetamol/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	// Good general painkiller.
	M.adjustBruteLoss(-0.05 * REM * delta_time, FALSE)
	M.adjustFireLoss(-0.05 * REM * delta_time, FALSE)
	M.adjustToxLoss(-0.05 * REM * delta_time, FALSE)
	M.cause_pain(BODY_ZONES_ALL, -0.05 * REM * delta_time)
	// Not very good at treating fevers.
	M.adjust_bodytemperature(-12 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, M.get_body_temp_normal())
	// Causes liver damage - higher dosages causes more liver damage.
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, volume / 25 * REM * delta_time)
	// Causes a flat amount of disgust - not very much.
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && DT_PROB(66 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(1.5 * REM * delta_time)

	. = ..()
	return TRUE

/datum/reagent/medicine/painkiller/paracetamol/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(!istype(M))
		return

	// On overdose, cause sickness and liver damage.
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2 * REM * delta_time)
	if(M.disgust < 100 && DT_PROB(100 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(5 * REM * delta_time)

	return TRUE

/datum/chemical_reaction/medicine/paracetamol
	results = list(/datum/reagent/medicine/painkiller/paracetamol = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid/nitracid = 1)
	optimal_temp = 480
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

// Ibuprofen. Best at headaches, best at fevers, less good at everything else.
// Use for treating head pain primarily.
/datum/reagent/medicine/painkiller/ibuprofen
	name = "Ibuprofen"
	description = "A medication that combats mild pain, headaches, and fever. Causes mild nausea and dizziness in higher dosages. Overdosing causes sickness, drowsiness, dizziness, and mild pain."
	reagent_state = LIQUID
	color = "#e695ff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 5.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	pain_modifier = 0.6

/datum/reagent/medicine/painkiller/ibuprofen/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	// Really good at treating headaches.
	M.adjustBruteLoss(-0.05 * REM * delta_time, FALSE)
	M.adjustToxLoss(-0.1 * REM * delta_time, FALSE)
	M.cause_pain(BODY_ZONE_HEAD, -0.08 * REM * delta_time)
	M.cause_pain(BODY_ZONE_CHEST, -0.04 * REM * delta_time)
	M.cause_pain(BODY_ZONES_LIMBS, -0.02 * REM * delta_time)
	// Causes flat liver damage.
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5 * REM * delta_time)
	// Really good at treating fevers.
	M.adjust_bodytemperature(-25 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, M.get_body_temp_normal())
	// Causes more disgust the longer it's in someone...
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && DT_PROB(50 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(max(current_cycle * 0.1, 5) * REM * delta_time)
	// ...and dizziness.
	if(current_cycle >= 25 && DT_PROB(30 * max(1 - creation_purity, 0.5), delta_time))
		M.dizziness = clamp(M.dizziness + (1 * REM * delta_time), 0, 5)

	. = ..()
	return TRUE

/datum/reagent/medicine/painkiller/ibuprofen/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(!istype(M))
		return

	// On overdose, causes liver damage and chest pain...
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM * delta_time)
	M.cause_pain(BODY_ZONE_CHEST, 0.24 * REM * delta_time)
	// Sickness...
	if(M.disgust < 100 && DT_PROB(100 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(5 * REM * delta_time)
	// ...Drowsyness...
	if(DT_PROB(75 * max(1 - creation_purity, 0.5), delta_time))
		M.drowsyness += 1 * REM * delta_time
	// ...And dizziness
	if(DT_PROB(85 * max(1 - creation_purity, 0.5), delta_time))
		M.dizziness += 2 * REM * delta_time

	return TRUE

/datum/chemical_reaction/medicine/ibuprofen
	results = list(/datum/reagent/medicine/painkiller/ibuprofen = 5)
	required_reagents = list(/datum/reagent/propionic_acid = 1, /datum/reagent/phenol = 1, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

// Component in ibuprofen.
/datum/reagent/propionic_acid
	name = "Propionic Acid"
	description = "A pungent liquid that's often used in preservatives and synthesizing of other chemicals."
	reagent_state = LIQUID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#c7a9c9"
	ph = 7

/datum/chemical_reaction/propionic_acid
	results = list(/datum/reagent/propionic_acid = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen = 1)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)
	is_cold_recipe = TRUE
	required_temp = 250
	optimal_temp = 200
	overheat_temp = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

// Combination drug of other painkillers. It's a real thing. Less side effects, heals pain generally, mildly toxic in high doses.
// Upgrade to paracetamol and aspirin if you go through the effort to get coffee.
/datum/reagent/medicine/painkiller/aspririn_para_coffee
	name = "aspirin/paracetamol/caffeine"
	description = "A combination drug that effectively treats moderate pain with low side effects when used in low dosage. Toxic in higher dosages."
	reagent_state = LIQUID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#e695ff"
	metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/medicine/painkiller/aspririn_para_coffee/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()

	// Heals all pain a bit if in low dosage. High metabolism, so it must make it count.
	if(volume <= 10)
		M.cause_pain(BODY_ZONES_ALL, -1 * REM * delta_time)
	// Mildly toxic in higher dosages.
	else if(DT_PROB(volume * 3, delta_time))
		M.apply_damage(3 * REM * delta_time, TOX)

/datum/chemical_reaction/medicine/aspririn_para_coffee
	results = list(/datum/reagent/medicine/painkiller/aspririn_para_coffee = 3)
	required_reagents = list(/datum/reagent/medicine/painkiller/aspirin = 1, /datum/reagent/medicine/painkiller/paracetamol = 1, /datum/reagent/consumable/coffee = 1)
	optimal_ph_min = 2
	optimal_ph_max = 12
	reaction_tags = REACTION_TAG_HARD| REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG
	reaction_flags = REACTION_INSTANT

// Oxycodone. Very addictive, heals pain very fast, also a drug.
/datum/reagent/medicine/oxycodone
	name = "Oxycodone"
	description = "A drug that rapidly treats major to extreme pain. Highly addictive. Overdose can cause heart attacks."
	reagent_state = LIQUID
	color = "#ffcb86"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 5.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opiods = 45) //5u = 150 progress, 15-20u = addiction
	pain_modifier = 0.3

/datum/reagent/medicine/oxycodone/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(current_cycle >= 9)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "numb", /datum/mood_event/narcotic_heavy, name)
	M.adjustBruteLoss(-0.3 * REM * delta_time, FALSE)
	M.adjustFireLoss(-0.2 * REM * delta_time, FALSE)
	M.cause_pain(BODY_ZONES_ALL, -0.6 * REM * delta_time)
	M.set_drugginess(10 * REM * delta_time)
	if(M.disgust < DISGUST_LEVEL_VERYGROSS && DT_PROB(50 * max(1 - creation_purity, 0.5), delta_time))
		M.adjust_disgust(3 * REM * delta_time)
	if(DT_PROB(33 * max(1 - creation_purity, 0.5), delta_time))
		M.dizziness = clamp(M.dizziness + (1 * REM * delta_time), 0, 5)
	. = ..()
	return TRUE

/datum/reagent/medicine/oxycodone/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/human_mob = M
	if(DT_PROB(15 - (5 * normalise_creation_purity()), delta_time))
		var/can_heart_fail = (!human_mob.undergoing_cardiac_arrest() && human_mob.can_heartattack())
		var/picked_option = rand(1, (can_heart_fail ? 6 : 3))
		switch(picked_option)
			if(1)
				to_chat(human_mob, span_danger("Your legs don't want to move."))
				human_mob.Paralyze(60 * REM * delta_time)
			if(2)
				to_chat(human_mob, span_danger("Your breathing starts to shallow."))
				human_mob.losebreath = clamp(human_mob.losebreath + 3 * REM * delta_time, 0, 12)
				human_mob.apply_damage((15 / creation_purity), OXY)
			if(3)
				human_mob.drop_all_held_items()
			if(4)
				to_chat(human_mob, span_danger("You feel your heart skip a beat."))
				human_mob.Jitter(3 * REM * delta_time)
			if(5)
				to_chat(human_mob, span_danger("You feel the world spin."))
				human_mob.Dizzy(3 * REM * delta_time)
			if(6)
				to_chat(human_mob, span_userdanger("You feel your heart seize and stop completely!"))
				if(human_mob.stat == CONSCIOUS)
					human_mob.visible_message(span_userdanger("[human_mob] clutches at [human_mob.p_their()] chest as if [human_mob.p_their()] heart stopped!"), ignored_mobs = human_mob)
				human_mob.emote("scream")
				human_mob.set_heartattack(TRUE)
				metabolization_rate *= 4
		return TRUE

/obj/item/food/grown/poppy
	juice_results = list(/datum/reagent/medicine/oxycodone = 0)

/obj/item/food/grown/poppy/geranium
	juice_results = null

/obj/item/food/grown/poppy/lily
	juice_results = null

/obj/item/reagent_containers/pill/asprin
	name = "asprin pill"
	desc = "Used to treat moderate pain and fever. Metabolizes slowly. Best at treating chest pain."
	icon_state = "pill7"
	list_reagents = list(/datum/reagent/medicine/painkiller/aspirin = 10) // Lasts ~4 minutes, heals ~20 pain in chest (lower in other parts)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/ibuprofen
	name = "ibuprofen pill"
	desc = "Used to treat mild pain, headaches, and fever. Metabolizes slowly. Best at treating head pain."
	icon_state = "pill8"
	list_reagents = list(/datum/reagent/medicine/painkiller/ibuprofen = 10) // Lasts ~4 minutes, heals ~20 pain in head (lower in other parts)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/paracetamol
	name = "paracetamol pill"
	desc = "Used to treat moderate pain and headaches. Metabolizes slowly. Good as a general painkiller."
	icon_state = "pill9"
	list_reagents = list(/datum/reagent/medicine/painkiller/paracetamol = 10) // Lasts ~4 minutes, heals ~15 pain per bodypart
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/morphine/diluted
	desc = "Used to treat major to severe pain. Causes moderate drowsyness. Mildly addictive."
	icon_state = "pill11"
	list_reagents = list(/datum/reagent/medicine/morphine = 5) // Lasts ~1 minute, heals ~10 pain per bodypart (~100 pain)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/oxycodone
	name = "oxycodon pill"
	desc = "Used to treat severe to extreme pain. Rapid acting, may cause delirium. Very addictive."
	icon_state = "pill12"
	list_reagents = list(/datum/reagent/medicine/oxycodone = 5) // Lasts ~1 minute, heals ~20 pain per bodypart (~200 pain)
	rename_with_volume = TRUE

/obj/item/storage/pill_bottle/painkillers
	name = "bottle of painkillers"
	desc = "Contains multiple pills used to treat anywhere from mild to extreme pain. CAUTION: Do not take in conjunction with alcohol."
	icon = 'jollystation_modules/icons/obj/chemical.dmi'
	custom_premium_price = PAYCHECK_HARD * 1.5

/obj/item/storage/pill_bottle/painkillers/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 14
	STR.max_combined_w_class = 28

/obj/item/storage/pill_bottle/painkillers/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/asprin(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/ibuprofen(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/paracetamol(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/morphine/diluted(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/pill/oxycodone(src)

/obj/machinery/vending/drugs
	added_premium = list(/obj/item/storage/pill_bottle/painkillers = 2)

/obj/item/reagent_containers/hypospray/medipen/survival/painkiller
	name = "emergency painkiller medipen"
	desc = "A medipen that contains a dosage of heavy duty painkillers. WARNING: Side effects or addiction may occur with rapid consecutive usage. Do not use in combination with alcohol."
	icon = 'jollystation_modules/icons/obj/syringe.dmi'
	icon_state = "painkiller_stimpen"
	base_icon_state = "painkiller_stimpen"
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/oxycodone = 7.5, /datum/reagent/medicine/morphine = 5, /datum/reagent/medicine/modafinil = 2.5)
