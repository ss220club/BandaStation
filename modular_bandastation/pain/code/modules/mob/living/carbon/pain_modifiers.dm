// -- Pain modifiers. --
// Eternal youth gives a small bonus pain mod.
/datum/symptom/youth/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	switch(A.stage)
		if(5)
			A.affected_mob.set_pain_mod(PAIN_MOD_YOUTH, 0.9)

/datum/symptom/youth/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	A.affected_mob.unset_pain_mod(PAIN_MOD_YOUTH)

// Some Traumas
/datum/brain_trauma/mild/concussion/on_life(delta_time, times_fired)
	. = ..()
	if(DT_PROB(1, delta_time))
		owner.cause_pain(BODY_ZONE_HEAD, 10)

/datum/brain_trauma/special/tenacity/on_gain()
	. = ..()
	owner.set_pain_mod(PAIN_MOD_TENACITY, 0)

/datum/brain_trauma/special/tenacity/on_lose()
	owner.unset_pain_mod(PAIN_MOD_TENACITY)
	. = ..()

// Near death experience
/mob/living/carbon/human/set_health(new_value)
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_SIXTHSENSE, "near-death"))
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "near-death", /datum/mood_event/deaths_door)
		set_pain_mod(PAIN_MOD_NEAR_DEATH, 0.1)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "near-death")
		unset_pain_mod(PAIN_MOD_NEAR_DEATH)

// Stasis - This is a bit of a cop-out.
/obj/machinery/stasis/chill_out(mob/living/carbon/target)
	. = ..()
	if(!istype(target) || target != occupant)
		return

	target.set_pain_mod(PAIN_MOD_STASIS, 0)

/obj/machinery/stasis/thaw_them(mob/living/carbon/target)
	. = ..()
	if(!istype(target))
		return

	target.unset_pain_mod(PAIN_MOD_STASIS)
