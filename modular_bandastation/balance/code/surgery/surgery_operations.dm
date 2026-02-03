#define SURGERY_DIFFICULTY_NONE 0
#define SURGERY_DIFFICULTY_LOW 1
#define SURGERY_DIFFICULTY_MEDIUM 5
#define SURGERY_DIFFICULTY_HIGH 10

/datum/surgery_operation
	var/difficulty = SURGERY_DIFFICULTY_LOW

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
