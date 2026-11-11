/** Повышает отдачу личных исследований без увеличения дохода майнинга. */
/datum/ai_project/research_booster
	name = "Research Acceleration"
	description = "Быстрая RAM вместо медленных SSD и HDD повышает выработку очков исследований примерно на 25%."
	research_cost = 2500
	ram_required = 8
	category = AI_PROJECT_MISC

/datum/ai_project/research_booster/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.research_point_booster += 0.25

/datum/ai_project/research_booster/stop()
	ai.research_point_booster -= 0.25
	return ..()
