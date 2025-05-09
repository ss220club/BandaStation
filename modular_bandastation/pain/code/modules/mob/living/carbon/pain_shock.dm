// -- Shock from too much pain. --
/datum/disease/shock
	form = "Condition"
	name = "Shock"
	spread_text = "Neurogenic" // Only model pain shock
	max_stages = 3
	stage_prob = 1
	cure_text = "Maintain a high body temperature, stop blood loss, and provide pain relievers while monitoring closely."
	agent = "Pain"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "Occurs when a subject enters a state of shock due to high pain, blood loss, heart difficulties, and other injuries. \
		If left untreated the subject may experience cardiac arrest."
	severity = DISEASE_SEVERITY_DANGEROUS
	disease_flags = CAN_CARRY
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE

/*
 * Checks which cure conditions we fulfill.
 *
 * returns the total number of conditions we fulfill.
 */
/datum/disease/shock/proc/check_cure_conditions()
	. = 0
	. += affected_mob.bodytemperature > affected_mob.get_body_temp_cold_damage_limit()
	. += !affected_mob.is_bleeding()
	. += affected_mob.body_position == LYING_DOWN
	. += 2 * (affected_mob.pain_controller.get_average_pain() < 40)

/datum/disease/shock/has_cure()
	return check_cure_conditions() >= 3 && !affected_mob.undergoing_cardiac_arrest()

/datum/disease/shock/cure()
	affected_mob = null
	return ..()

/datum/disease/shock/after_add()
	affected_mob.apply_status_effect(STATUS_EFFECT_LOWBLOODPRESSURE)

/datum/disease/shock/remove_disease()
	affected_mob.remove_status_effect(STATUS_EFFECT_LOWBLOODPRESSURE)

/datum/disease/shock/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	if(!affected_mob.pain_controller)
		cure()
		return FALSE

	if(affected_mob.stat == DEAD)
		cure()
		return FALSE

	// Having any 2 cure conditions present will keep us below stage 3
	if(check_cure_conditions() >= 2 && stage > 2)
		update_stage(2)

	// If we have enough conditions present to cure us, roll for a cure
	if(has_cure() && DT_PROB(check_cure_conditions(), delta_time) && stage <= 2)
		to_chat(affected_mob, span_bold(span_green("Your body feels awake and active again!")))
		cure()
		return FALSE

	switch(stage)
		// compensated (or nonprogressive) - still able to sustain themselves
		// - agitation, anxiety
		// - nausea or vomiting
		// - chills
		if(1)
			cure_text = "Subject is in stage one of shock. Provide immediate pain relief and stop blood loss to prevent worsening condition."
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Your chest feels uncomfortable."))
				affected_mob.pain_emote(pick("mumble", "grumble"))
				affected_mob.flash_pain_overlay(1)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("You feel nauseous."))
				if(prob(50))
					affected_mob.vomit(35, stun = FALSE)
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("You feel anxious."))
				affected_mob.jitteriness += rand(6,8)
			if(DT_PROB(6, delta_time))
				to_chat(affected_mob, span_danger("You feel cold."))
				affected_mob.pain_emote("shiver")
			affected_mob.adjust_bodytemperature(-5 * delta_time, affected_mob.get_body_temp_cold_damage_limit() + 5) // Not lethal

		// decompensated (or progressive) - unable to maintain themselves
		// - mental issues
		// - difficulty breathing / high heart rate
		// - decrease in body temperature
		if(2)
			cure_text = "Subject is in stage two of shock. Provide additional pain relief, assist in maintaining a high body temperature and stop further blood loss to prevent cardiac arrest."
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, span_danger("Your chest feels wrong!"))
				affected_mob.pain_emote(pick("mumble", "grumble"))
				affected_mob.flash_pain_overlay(2)
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("You can't focus on anything!"))
				affected_mob.add_confusion(rand(4,8))
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("You're having difficulties breathing!"))
				affected_mob.losebreath = clamp(affected_mob.losebreath + 4, 0, 12)
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("You skip a breath!"))
				affected_mob.pain_emote("gasp")
				affected_mob.apply_damage(rand(5, 15), OXY)
			if(DT_PROB(8, delta_time))
				to_chat(affected_mob, span_danger("You feel freezing!"))
				affected_mob.pain_emote("shiver")
			affected_mob.adjust_bodytemperature(-10 * delta_time, affected_mob.get_body_temp_cold_damage_limit() - 5) // uh oh

		// irreversible - point of no return, system failure
		// cardiac arrest
		if(3)
			cure_text = "Subject is in stage three of shock. Cardiac arrest is imminent - urgent action is needed."
			if(DT_PROB(33, delta_time))
				if(affected_mob.can_heartattack())
					to_chat(affected_mob, span_userdanger("Your heart stops!"))
					affected_mob.visible_message(span_danger("[affected_mob] grabs at their chest and collapses!"), ignored_mobs = affected_mob)
					affected_mob.set_heartattack(TRUE)
					cure()
					return FALSE
				else
					affected_mob.losebreath += 10
			else if(DT_PROB(10, delta_time))
				to_chat(affected_mob, span_userdanger(pick("You feel your heart skip a beat...", "You feel your body shutting down...", "You feel your heart beat irregularly...")))
			affected_mob.adjust_bodytemperature(-10 * delta_time, affected_mob.get_body_temp_cold_damage_limit() - 20) // welp
