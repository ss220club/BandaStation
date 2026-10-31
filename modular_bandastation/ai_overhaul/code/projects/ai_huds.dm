/** Даёт расширенный охранный HUD при работающей программе. */
/datum/ai_project/security_hud
	name = "Advanced Security HUD"
	description = "Анализ записей службы безопасности и имплантов слежения."
	research_cost = 1250
	ram_required = 2
	category = AI_PROJECT_HUDS

/datum/ai_project/security_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(.)
		ai.set_project_sensor(TRAIT_SECURITY_HUD_ID_ONLY, TRAIT_SECURITY_HUD)

/datum/ai_project/security_hud/stop()
	ai.set_project_sensor(TRAIT_SECURITY_HUD, TRAIT_SECURITY_HUD_ID_ONLY)
	return ..()

/** Даёт медицинский и диагностический HUD при работающей программе. */
/datum/ai_project/diag_med_hud
	name = "Advanced Medical & Diagnostic HUD"
	description = "Анализ медицинских записей и диагностических данных."
	research_cost = 1000
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/diag_med_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(.)
		ai.set_project_sensor(TRAIT_MEDICAL_HUD_SENSOR_ONLY, TRAIT_MEDICAL_HUD)

/datum/ai_project/diag_med_hud/stop()
	ai.set_project_sensor(TRAIT_MEDICAL_HUD, TRAIT_MEDICAL_HUD_SENSOR_ONLY)
	return ..()

/** Заменяет сенсорный HUD проекта, не затрагивая остальные источники сенсорных признаков. */
/mob/living/silicon/ai/proc/set_project_sensor(old_trait, new_trait)
	remove_sensors()
	silicon_huds -= old_trait
	silicon_huds |= new_trait
	if(sensors_on)
		add_sensors()
