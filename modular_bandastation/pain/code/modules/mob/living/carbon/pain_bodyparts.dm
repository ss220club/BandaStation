// -- Bodypart and Organ pain definitions. --

/obj/item/organ/lungs
	/// Whether we are currently breathing enough N2O to be considered asleep.
	var/on_anesthetic = FALSE

/*
 * Returns TRUE if we are breathing enough [partial_pressure] of N2O to be asleep.
 */
/obj/item/organ/lungs/proc/check_anesthetic(partial_pressure, min_sleep)
	return partial_pressure > min_sleep

/obj/item/bodypart
	/// The amount of pain this limb is experiencing (A bit for default)
	var/pain = 15
	/// The min amount of pain this limb can experience
	var/min_pain = 0
	/// The max amount of pain this limb can experience
	var/max_pain = PAIN_LIMB_MAX
	/// Modifier applied to pain that this part recieves
	var/bodypart_pain_modifier = 1
	/// The last type of pain we recieved.
	var/last_recieved_pain_type = BRUTE

/obj/item/bodypart/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE)
	. = ..()
	if(!.)
		return

	var/dominant_type = (brute > burn ? BRUTE : BURN)
	var/can_inflict = max_damage - get_damage()
	var/total_damage = brute + burn
	if(total_damage > can_inflict && total_damage > 0)
		brute = round(brute * (can_inflict / total_damage), DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage), DAMAGE_PRECISION)

	if(can_inflict > 0)
		owner?.cause_pain(body_zone, body_damage_coeff * (brute + burn), dominant_type)

/*
 * Gets our bodypart's effective pain (pain * pain modifiers).
 *
 * Returns our effective pain.
 */
/obj/item/bodypart/proc/get_modified_pain()
	if(owner?.pain_controller)
		return pain * bodypart_pain_modifier * owner.pain_controller.pain_modifier
	else
		return pain * bodypart_pain_modifier

/*
 * Effects on this bodypart has when pain is gained.
 *
 * amount - amount of pain gained
 */
/obj/item/bodypart/proc/on_gain_pain_effects(amount)
	if(!owner)
		return FALSE

	var/base_max_stamina_damage = initial(max_stamina_damage)

	switch(pain)
		if(10 to 25)
			max_stamina_damage = base_max_stamina_damage / 1.2
		if(25 to 50)
			max_stamina_damage = base_max_stamina_damage / 1.5
		if(50 to 65)
			max_stamina_damage = base_max_stamina_damage / 2
		if(65 to INFINITY)
			if(can_be_disabled && !HAS_TRAIT_FROM(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS))
				to_chat(owner, span_userdanger("Your [name] goes numb from the pain!"))
				ADD_TRAIT(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)
				update_disabled()

	return TRUE

/*
 * Effects on this bodypart has when pain is lost and some time passes without any pain gain.
 *
 * amount - amount of pain lost
 */
/obj/item/bodypart/proc/on_lose_pain_effects(amount)
	if(!owner)
		return FALSE

	var/base_max_stamina_damage = initial(max_stamina_damage)
	switch(pain)
		if(0 to 10)
			max_stamina_damage = base_max_stamina_damage
		if(10 to 25)
			max_stamina_damage = base_max_stamina_damage / 1.2
		if(25 to 50)
			max_stamina_damage = base_max_stamina_damage / 1.5
	if(pain < 65 && HAS_TRAIT_FROM(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS))
		to_chat(owner, span_green("You can feel your [name] again!"))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, PAIN_LIMB_PARALYSIS)
		update_disabled()

	return TRUE

/*
 * Effects on this bodypart when pain is processed (every 2 seconds)
 */
/obj/item/bodypart/proc/processed_pain_effects(delta_time)
	if(!owner || !pain)
		return FALSE

	return TRUE

/*
 * Feedback messages from this limb when it is sustaining pain.
 *
 * healing_pain - if TRUE, the bodypart has gone some time without recieving pain, and is healing.
 */
/obj/item/bodypart/proc/pain_feedback(delta_time, healing_pain)
	if(!owner || !pain)
		return FALSE

	if(owner.has_status_effect(STATUS_EFFECT_DETERMINED))
		return FALSE

	var/list/feedback_phrases = list()
	var/static/list/healing_phrases = list("but is improving", "but is starting to dull", "but the stinging is stopping", "but feels faint")

	var/picked_emote = pick(PAIN_EMOTES)
	switch(pain)
		if(10 to 25)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("aches", "feels sore", "stings slightly", "tingles", "twinges")
		if(25 to 50)
			owner.pain_emote(picked_emote)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("hurts", "feels sore", "stings", "throbs", "pangs", "cramps", "feels wrong", "feels loose")
			if(last_recieved_pain_type == BURN)
				feedback_phrases += list("stings to the touch", "burns")
		if(50 to 65)
			owner.pain_emote(picked_emote)
			owner.flash_pain_overlay(2)
			feedback_phrases += list("really hurts", "is losing feeling", "throbs painfully", "is in agony", "anguishes", "feels broken", "feels terrible")
			if(last_recieved_pain_type == BURN)
				feedback_phrases += list("burns to the touch", "burns", "singes")
		if(65 to INFINITY)
			if(DT_PROB(12, delta_time))
				owner.pain_emote("scream")
			owner.flash_pain_overlay(2, 2 SECONDS)
			feedback_phrases += list("is numb from the pain")

	if(feedback_phrases.len)
		to_chat(owner, span_danger("Your [name] [pick(feedback_phrases)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))
	return TRUE

// --- Chest ---
/obj/item/bodypart/chest
	max_pain = PAIN_CHEST_MAX

/obj/item/bodypart/chest/robot
	pain = PAIN_CHEST_MAX
	bodypart_pain_modifier = 0.5

/obj/item/bodypart/chest/pain_feedback(delta_time, healing_pain)
	if(!owner || !pain)
		return FALSE

	if(owner.has_status_effect(STATUS_EFFECT_DETERMINED))
		return FALSE

	var/list/feedback_phrases = list()
	var/list/side_feedback = list()
	var/static/list/healing_phrases = list("but is improving", "but is starting to dull", "but the stinging is stopping", "but feels faint", "but is settling", "but it subsides")

	var/picked_emote = pick(PAIN_EMOTES)
	switch(pain)
		if(10 to 40)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("aches", "feels sore", "stings slightly", "tingles", "twinges")
		if(40 to 75)
			owner.pain_emote(picked_emote)
			owner.flash_pain_overlay(1, 2 SECONDS)
			feedback_phrases += list("hurts", "feels sore", "stings", "throbs", "pangs", "cramps", "feels tight")
			side_feedback += list("Your side hurts", "Your side pangs", "Your ribs hurt", "Your ribs pang", "Your neck stiffs")
		if(75 to 110)
			owner.pain_emote(picked_emote)
			owner.flash_pain_overlay(2, 2 SECONDS)
			feedback_phrases += list("really hurts", "is losing feeling", "throbs painfully", "stings to the touch", "is in agony", "anguishes", "feels broken", "feels tight")
			side_feedback += list("You feel a sharp pain in your side", "Your ribs feel broken")
		if(110 to INFINITY)
			owner.pain_emote(pick("groan", "scream", picked_emote))
			owner.flash_pain_overlay(2, 3 SECONDS)
			feedback_phrases += list("hurts madly", "is in agony", "is anguishing", "burns to the touch", "feels terrible", "feels constricted")
			side_feedback += list("You feel your ribs jostle in your [name]")

	if(side_feedback.len && last_recieved_pain_type == BRUTE && DT_PROB(50, delta_time))
		to_chat(owner, span_danger("[pick(side_feedback)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))
	else if(feedback_phrases.len)
		to_chat(owner, span_danger("Your [name] [pick(feedback_phrases)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))

	return TRUE

// --- Head ---
/obj/item/bodypart/head
	max_pain = PAIN_HEAD_MAX

/obj/item/bodypart/head/robot
	pain = PAIN_HEAD_MAX
	bodypart_pain_modifier = 0.5

/obj/item/bodypart/head/on_gain_pain_effects(amount)
	. = ..()
	if(!.)
		return FALSE

	if(amount > 10)
		owner.apply_damage(pain / 3, BRAIN)

	return TRUE

/obj/item/bodypart/head/pain_feedback(delta_time, healing_pain)
	if(!owner || !pain)
		return FALSE

	var/list/feedback_phrases = list()
	var/list/side_feedback = list()
	var/static/list/healing_phrases = list("but is improving", "but is starting to dull", "but the stinging is stopping", "but the tension is stopping", "but is settling", "but it subsides", "but the pressure fades")

	switch(pain)
		if(10 to 30)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("aches", "feels sore", "stings slightly", "tingles", "twinges")
			side_feedback += list("Your neck feels sore", "Your eyes feel tired")
		if(30 to 60)
			owner.flash_pain_overlay(1)
			feedback_phrases += list("hurts", "feels sore", "stings", "throbs", "pangs")
			side_feedback += list("Your neck aches badly", "Your eyes hurt", "You feel a migrane coming on", "You feel a splitting headache")
		if(60 to 90)
			owner.flash_pain_overlay(2)
			feedback_phrases += list("really hurts", "is losing feeling", "throbs painfully", "is in agony", "anguishes", "feels broken", "feels terrible")
			side_feedback += list("Your neck stiffs", "You feel pressure in your [name]", "The back of your eyes begin hurt", "You feel a terrible migrane")
		if(90 to INFINITY)
			owner.pain_emote(pick("groan", pick(PAIN_EMOTES)))
			owner.flash_pain_overlay(2, 2 SECONDS)
			feedback_phrases += list("hurts madly", "is in agony", "is anguishing", "feels terrible", "is in agony", "feels tense")
			side_feedback += list("You feel a splitting migrane", "Pressure floods your [name]", "Your head feels as if it's being squeezed", "Your eyes hurt to keep open")

	if(side_feedback.len && last_recieved_pain_type == BRUTE && DT_PROB(50, delta_time))
		to_chat(owner, span_danger("[pick(side_feedback)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))
	else if(feedback_phrases.len)
		to_chat(owner, span_danger("Your [name] [pick(feedback_phrases)][healing_pain ? ", [pick(healing_phrases)]." : "!"]"))

	return TRUE

// --- Right Leg ---
/obj/item/bodypart/r_leg/robot
	pain = PAIN_LIMB_MAX
	bodypart_pain_modifier = 0.5

/obj/item/bodypart/r_leg/robot/surplus
	pain = 40
	bodypart_pain_modifier = 0.8

/obj/item/bodypart/r_leg/processed_pain_effects(delta_time)
	. = ..()
	if(!.)
		return FALSE

	if(get_modified_pain() > 30 && DT_PROB(10, delta_time))
		if(owner.apply_status_effect(STATUS_EFFECT_LIMP_PAIN))
			to_chat(owner, span_danger("Your [name] hurts to walk on!"))

	return TRUE

// --- Left Leg ---
/obj/item/bodypart/l_leg/robot
	pain = PAIN_LIMB_MAX
	bodypart_pain_modifier = 0.5

/obj/item/bodypart/l_leg/robot/surplus
	pain = 40
	bodypart_pain_modifier = 0.8

/obj/item/bodypart/l_leg/processed_pain_effects(delta_time)
	. = ..()
	if(!.)
		return FALSE

	if(get_modified_pain() > 30 && DT_PROB(10, delta_time))
		if(owner.apply_status_effect(STATUS_EFFECT_LIMP_PAIN))
			to_chat(owner, span_danger("Your [name] hurts to walk on!"))

	return TRUE

// --- Right Arm ---
/obj/item/bodypart/r_arm/robot
	pain = PAIN_LIMB_MAX
	bodypart_pain_modifier = 0.5

/obj/item/bodypart/r_arm/robot/surplus
	pain = 40
	bodypart_pain_modifier = 0.8

// --- Left Arm ---
/obj/item/bodypart/l_arm/robot
	pain = PAIN_LIMB_MAX
	bodypart_pain_modifier = 0.5

/obj/item/bodypart/l_arm/robot/surplus
	pain = 40
	bodypart_pain_modifier = 0.8
