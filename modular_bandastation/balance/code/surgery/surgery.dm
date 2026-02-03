#define SURGERY_DIFFICULTY_NONE 0
#define SURGERY_DIFFICULTY_LOW 1
#define SURGERY_DIFFICULTY_MEDIUM 5
#define SURGERY_DIFFICULTY_HIGH 10
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
	// /datum/status_effect/incapacitating/stamcrit,
	/datum/status_effect/tox_vomit,
	/datum/status_effect/woozy,
	/datum/status_effect/seizure,
))

/datum/surgery_operation
	var/difficulty = SURGERY_DIFFICULTY_LOW

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

// Abductor's operations w/o side effects
/datum/surgery_operation/limb/clamp_bleeders/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/close_skin/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/incise_organs/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/incise_skin/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/organ_manipulation/external/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/organ_manipulation/internal/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/retract_skin/abductor
	difficulty = SURGERY_DIFFICULTY_NONE
/datum/surgery_operation/limb/unclamp_bleeders/abductor
	difficulty = SURGERY_DIFFICULTY_NONE

// Stationwide operations
/datum/surgery_operation/limb/bionecrosis
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/limb/bioware
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/limb/amputate
	difficulty = SURGERY_DIFFICULTY_HIGH
/datum/surgery_operation/basic/dissection
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/basic/core_removal
	difficulty = SURGERY_DIFFICULTY_HIGH
/datum/surgery_operation/prosthetic_replacement
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/organ
	difficulty = SURGERY_DIFFICULTY_HIGH
/datum/surgery_operation/organ/fix_wings
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/basic/viral_bonding
	difficulty = SURGERY_DIFFICULTY_HIGH
/datum/surgery_operation/basic/revival
	difficulty = SURGERY_DIFFICULTY_HIGH
/datum/surgery_operation/limb/organ_manipulation
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/organ/repair
	difficulty = SURGERY_DIFFICULTY_LOW
/datum/surgery_operation/organ/stomach_pump
	difficulty = SURGERY_DIFFICULTY_MEDIUM
/datum/surgery_operation/limb/replace_limb
	difficulty = SURGERY_DIFFICULTY_MEDIUM



#undef SURGERY_DIFFICULTY_NONE
#undef SURGERY_DIFFICULTY_LOW
#undef SURGERY_DIFFICULTY_MEDIUM
#undef SURGERY_DIFFICULTY_HIGH
#undef SURGERY_PROB_MODIFIER
#undef LOWER_OFFSET_GAP
#undef UPPER_OFFSET_GAP
#undef EFFECT_DURATION_BASE
