#define SURGERY_PROB_MODIFIER 5
#define LOWER_OFFSET_GAP 0 MINUTES
#define UPPER_OFFSET_GAP 3 MINUTES
#define EFFECT_DURATION_BASE 2 MINUTES

GLOBAL_LIST_INIT(surgery_effects, list(
	/datum/status_effect/speech/stutter,
	/datum/status_effect/speech/stutter/anxiety,
	/datum/status_effect/speech/stutter/derpspeech,
	/datum/status_effect/speech/slurring/generic,
	/datum/status_effect/speech/slurring/drunk,
	/datum/status_effect/temporary_blindness,
	/datum/status_effect/confusion,
	/datum/status_effect/dizziness,
	/datum/status_effect/drowsiness,
	/datum/status_effect/hallucination,
	/datum/status_effect/pacify,
	/datum/status_effect/eye_blur,
	/datum/status_effect/dazed,
	/datum/status_effect/tox_vomit,
	/datum/status_effect/seizure,
))

/datum/surgery_operation/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	if(!..())
		return FALSE
	var/mob/living/patient = get_patient(operating_on)
	if(patient && prob(difficulty * SURGERY_PROB_MODIFIER))
		var/offset = rand(LOWER_OFFSET_GAP, UPPER_OFFSET_GAP)
		var/duration = EFFECT_DURATION_BASE + offset
		var/picked_effect = pick(GLOB.surgery_effects)
		patient.apply_status_effect(picked_effect, duration, STATUS_EFFECT_REFRESH)
	return TRUE

#undef SURGERY_PROB_MODIFIER
#undef LOWER_OFFSET_GAP
#undef UPPER_OFFSET_GAP
#undef EFFECT_DURATION_BASE
