#define SURGERY_LIGHT_AMOUNT_REQUIRED 0.6
#define MIN_LIGHT_SURGFAIL_PROBABILITY_INCREASE 0
#define MAX_LIGHT_SURGFAIL_PROBABILITY_INCREASE 12
#define NO_PAINKILLER_SURGFAIL_PROBABILITY_INCREASE 70
#define BASIC_SURGERY_SUCCESS_CHANCE 100

/datum/surgery_step/proc/get_failure_probability(mob/living/user, mob/living/target, target_zone, obj/item/tool, var/modded_time)
	var/success_prob = implement_type ? implements[implement_type] : BASIC_SURGERY_SUCCESS_CHANCE
	if(!user.has_nightvision())
		var/turf/target_turf = get_turf(target)
		var/light_amount = target_turf.get_lumcount()
		if (light_amount < SURGERY_LIGHT_AMOUNT_REQUIRED)
			var/actual_to_required_light_ratio = clamp(light_amount, 0, SURGERY_LIGHT_AMOUNT_REQUIRED) / SURGERY_LIGHT_AMOUNT_REQUIRED
			success_prob -= LERP(MAX_LIGHT_SURGFAIL_PROBABILITY_INCREASE, MIN_LIGHT_SURGFAIL_PROBABILITY_INCREASE, actual_to_required_light_ratio)

	var/obj/item/bodypart/target_part = target.get_bodypart(target_zone)
	if(
		!(target_part.bodytype & BODYTYPE_ROBOTIC) &&\
		!(\
			target.stat == UNCONSCIOUS ||\
			target.IsSleeping() ||\
			target.stat == DEAD ||\
			HAS_TRAIT(target, TRAIT_ANALGESIA)\
		)\
	)
		success_prob -= NO_PAINKILLER_SURGFAIL_PROBABILITY_INCREASE

	var/fail_prob = clamp(BASIC_SURGERY_SUCCESS_CHANCE - success_prob, 0, 100)

	return fail_prob

#undef SURGERY_LIGHT_AMOUNT_REQUIRED
#undef MIN_LIGHT_SURGFAIL_PROBABILITY_INCREASE
#undef MAX_LIGHT_SURGFAIL_PROBABILITY_INCREASE
#undef NO_PAINKILLER_SURGFAIL_PROBABILITY_INCREASE
#undef BASIC_SURGERY_SUCCESS_CHANCE
