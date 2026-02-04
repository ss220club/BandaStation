#define SURGERY_TOOL_MOD_GHETTO 10
#define SURGERY_TOOL_MOD_ADVANCED 0
#define SURGERY_TOOL_MOD_ALIEN 1
#define SURGERY_TOOL_MOD_AUGMENT 0
#define SURGERY_TOOL_MOD_BASIC 5

/datum/surgery_operation/proc/get_modified_failure_chance(operation_time, mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/fail_chance = clamp(GET_FAILURE_CHANCE(operation_time, operation_args[OPERATION_SPEED]), 0, 99)

	// Боль
	if(!(HAS_TRAIT(patient, TRAIT_ANALGESIA) || patient.stat >= 2))
		fail_chance += 40

	// Свет или абдуктор
	if(!(surgeon.has_nightvision() || isabductor(surgeon)))
		var/turf/patient_turf = get_turf(patient)
		var/light_amount = patient_turf.get_lumcount() // минимальное кол-во света для успеха - 0.6
		if(light_amount < 0.6)
			fail_chance += (1.0 - (light_amount / 0.6))**1.5 * 60.0

	// Инструменты
	var/tool_mod = 0
	if(isitem(tool) || tool_check(tool))
		var/obj/item/realtool = tool
		var/tool_type = realtool.type
		if(implements[tool] > 1.15) // чек на гетто инструмент
			tool_mod = SURGERY_TOOL_MOD_GHETTO
		else
			if(findtext("[tool_type]", "/advanced"))
				tool_mod = SURGERY_TOOL_MOD_ADVANCED
			else if(findtext("[tool_type]", "/alien"))
				tool_mod = SURGERY_TOOL_MOD_ALIEN
			else if(findtext("[tool_type]", "/augment"))
				tool_mod = SURGERY_TOOL_MOD_AUGMENT
			else
				tool_mod = SURGERY_TOOL_MOD_BASIC

	fail_chance += tool_mod

	return fail_chance
	
#undef SURGERY_TOOL_MOD_GHETTO
#undef SURGERY_TOOL_MOD_ADVANCED
#undef SURGERY_TOOL_MOD_ALIEN
#undef SURGERY_TOOL_MOD_AUGMENT
#undef SURGERY_TOOL_MOD_BASIC
