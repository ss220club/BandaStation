/** Открывает подробный осмотр людей во время работы программы. */
/datum/ai_project/examine_humans
	name = "Examination Upgrade"
	description = "Экспериментальные алгоритмы обработки изображения позволяют подробно осматривать людей."
	research_cost = 4000
	ram_required = 4
	research_requirements = list(/datum/ai_project/diag_med_hud)
	category = AI_PROJECT_SURVEILLANCE

/datum/ai_project/examine_humans/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.can_examine_humans = TRUE

/datum/ai_project/examine_humans/stop()
	ai.can_examine_humans = FALSE
	..()
