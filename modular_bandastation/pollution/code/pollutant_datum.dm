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
	return
