#define SURGFAIL_LIGHT_AMOUNT_REQUERED 0.6
#define SURGFAIL_LIGHT_AMOUNT_MULTIPLIER 20
#define SURGFAIL_NO_PAINKILLER 80
#define BASIC_SURGERY_SUCCESS_CHANCE 100
#define CRITICAL_SUCCESS_CHANCE 100


/datum/surgery_step/proc/get_failure_probability(mob/living/user, mob/living/target, obj/item/tool, var/modded_time)
	var/success_prob = implement_type ? implements[implement_type] : BASIC_SURGERY_SUCCESS_CHANCE
	var/turf/user_turf = get_turf(user)
	var/light_amount = user_turf.get_lumcount()
	if (light_amount < SURGFAIL_LIGHT_AMOUNT_REQUERED)
		success_prob -= (SURGFAIL_LIGHT_AMOUNT_REQUERED - clamp(light_amount, 0, SURGFAIL_LIGHT_AMOUNT_REQUERED)) * SURGFAIL_LIGHT_AMOUNT_MULTIPLIER
	if ((!(target.stat == UNCONSCIOUS || target.IsSleeping()) && target.stat != DEAD) && !HAS_TRAIT(target, TRAIT_ANALGESIA))
		success_prob -= SURGFAIL_NO_PAINKILLER
	var/fail_prob = CRITICAL_SUCCESS_CHANCE - success_prob
	fail_prob *= modded_time / time

	return fail_prob

#undef SURGFAIL_LIGHT_AMOUNT_REQUERED
#undef SURGFAIL_LIGHT_AMOUNT_MULTIPLIER
#undef SURGFAIL_NO_PAINKILLER
#undef BASIC_SURGERY_SUCCESS_CHANCE
#undef CRITICAL_SUCCESS_CHANCE

/datum/status_effect/grouped/stasis/on_apply()
	. = ..()
	add_traits(list(TRAIT_ANALGESIA), TRAIT_STATUS_EFFECT(id))

/datum/status_effect/grouped/stasis/on_remove()
	. = ..()
	remove_traits(list(TRAIT_ANALGESIA), TRAIT_STATUS_EFFECT(id))
