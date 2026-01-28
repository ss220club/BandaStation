#define POLLUTION_AMOUNT_LOW 20
#define POLLUTION_AMOUNT_HIGH 40
#define POLLUTION_OXY_LOSS_MAX 30

/datum/pollutant
	/// Name of the pollutant, if null will be treated as abstract and wont be initialized as singleton
	var/name
	/// Flags of the pollutant, determine whether it has an appearance, smell, touch act, breath act
	var/pollutant_flags = NONE
	/// Below are variables for appearance
	/// What color will the pollutant be, can be left null
	var/color
	/// What is it desired alpha?
	var/alpha = 255
	/// How "thick" is it, the thicker the quicker it gets to desired alpha and is stronger than other pollutants in blending appearance
	var/thickness = 1

///When a pollutant touches an unprotected carbon mob
/datum/pollutant/proc/touch_act(mob/living/carbon/victim, amount)
	return

///When a carbon mob breathes in the pollutant
/datum/pollutant/proc/breathe_act(mob/living/carbon/victim, amount)
	var/obj/item/organ/lungs/L = victim.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!L)
		return FALSE

	if(amount >= POLLUTION_AMOUNT_HIGH)
		victim.emote("cough", forced = TRUE)
		victim.adjust_oxy_loss(min(amount * 0.1, POLLUTION_OXY_LOSS_MAX))
		return TRUE

	if(amount >= POLLUTION_AMOUNT_LOW)
		if(prob(20))
			victim.emote("cough")
		return TRUE

	return FALSE

#undef POLLUTION_AMOUNT_LOW
#undef POLLUTION_AMOUNT_HIGH
#undef POLLUTION_OXY_LOSS_MAX
