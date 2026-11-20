/** Ускоряет перемещение по камерам при работающей программе. */
/datum/ai_project/camera_speed
	name = "Optimised Camera Acceleration"
	description = "Алгоритмы глубокого обучения ускоряют перемещение между камерами."
	research_cost = 250
	ram_required = 1
	category = AI_PROJECT_CAMERAS

/datum/ai_project/camera_speed/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.acceleration = TRUE

/datum/ai_project/camera_speed/stop()
	ai.acceleration = ai.decentralized ? FALSE : initial(ai.acceleration)
	return ..()
