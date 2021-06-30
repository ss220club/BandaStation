// -- Causes of pain, from non-modular actions --
// Surgeries
/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	. = ..()
	if(target.stat == CONSCIOUS)
		var/obj/item/organ/lungs/our_lungs = target.getorganslot(ORGAN_SLOT_LUNGS)
		if(target.IsSleeping() && our_lungs?.on_anesthetic)
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "surgery", /datum/mood_event/anesthetic)
		else
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "surgery", /datum/mood_event/surgery)
			target.flash_pain_overlay(2)

/datum/surgery_step/incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	target.cause_pain(target_zone, 12) // incise doesn't actually deal any direct dmg, unlike saw
	if(target.stat == CONSCIOUS)
		var/obj/item/organ/lungs/our_lungs = target.getorganslot(ORGAN_SLOT_LUNGS)
		if(target.IsSleeping() && our_lungs?.on_anesthetic)
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "surgery", /datum/mood_event/anesthetic)
		else
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "surgery", /datum/mood_event/surgery/major)
			target.flash_pain_overlay(1)

/datum/surgery_step/replace_limb/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/bodypart/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(target.pain_controller && (tool in target.bodyparts))
		// We have to snowflake this because replace_limb uses SPECIAL = TRUE when replacing limbs (which doesn't cause pain because I hate limb code)
		target.cause_pain(target_zone, initial(tool.pain))
		target.cause_pain(BODY_ZONE_CHEST, PAIN_LIMB_REMOVED)
		//TODO: make this a status effect instead (post augment fatigue?)
		target.apply_min_pain(target_zone, 15, 2 MINUTES)

// Disease symptoms
/datum/symptom/headache/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	switch(A.stage)
		if(4)
			A.affected_mob.cause_pain(BODY_ZONE_HEAD, 3 * power)
			A.affected_mob.flash_pain_overlay(1)
		if(5)
			A.affected_mob.cause_pain(BODY_ZONE_HEAD, 5 * power)
			A.affected_mob.flash_pain_overlay(2)

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	switch(A.stage)
		if(2, 3)
			A.affected_mob.cause_pain(BODY_ZONES_ALL, 3 * (pain ? 2 : 1))
			A.affected_mob.flash_pain_overlay(1, 2 SECONDS)
		if(4, 5)
			A.affected_mob.cause_pain(BODY_ZONES_ALL, 12 * (pain ? 2 : 1))
			A.affected_mob.flash_pain_overlay(2, 2 SECONDS)

/datum/symptom/fire/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	switch(A.stage)
		if(4)
			A.affected_mob.cause_pain(BODY_ZONES_ALL, 5, BURN)
			A.affected_mob.flash_pain_overlay(1)
		if(5)
			A.affected_mob.cause_pain(BODY_ZONES_ALL, 10, BURN)
			A.affected_mob.flash_pain_overlay(2)

// Shocks
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	. = ..()
	if(!.)
		return

	var/pain = . / max(bodyparts.len, 2)
	cause_pain(BODY_ZONES_ALL, pain, BURN)
	set_pain_mod(PAIN_MOD_RECENT_SHOCK, 0.5, 30 SECONDS)

// Fleshmend of course heals pain.
/datum/status_effect/fleshmend/tick()
	. = ..()
	if(iscarbon(owner) && !owner.on_fire)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.cause_pain(BODY_ZONES_ALL, -1.5)

// Painkiller withdraw = pain
/datum/addiction/opiods/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(!affected_carbon.pain_controller)
		return
	if(affected_carbon.pain_controller.get_average_pain() <= 20 && DT_PROB(8, delta_time))
		affected_carbon.cause_pain(BODY_ZONES_ALL, 0.5 * delta_time)

/datum/addiction/opiods/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(!affected_carbon.pain_controller)
		return
	if(affected_carbon.pain_controller.get_average_pain() <= 35 && DT_PROB(8, delta_time))
		affected_carbon.cause_pain(BODY_ZONES_ALL, 1 * delta_time)

/datum/addiction/opiods/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(!affected_carbon.pain_controller)
		return
	if(affected_carbon.pain_controller.get_average_pain() <= 50 && DT_PROB(8, delta_time))
		affected_carbon.cause_pain(BODY_ZONES_ALL, 1.5 * delta_time)

// Regen cores.
/datum/status_effect/regenerative_core/on_apply()
	. = ..()
	var/mob/living/carbon/human/human_owner = owner
	if(istype(human_owner) && human_owner.pain_controller)
		human_owner.cause_pain(BODY_ZONES_LIMBS, -15)
		human_owner.cause_pain(BODY_ZONE_CHEST, -20)
		human_owner.cause_pain(BODY_ZONE_HEAD, -10) // heals 90 pain total
