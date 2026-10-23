/** Пассивно повышает температурный предел текущей рабочей сети владельца на 10 K без суммирования. */
/datum/ai_project/coolant_manager
	name = "Enhanced Coolant Management"
	description = "ИИ оптимизирует охлаждение своей текущей сети и повышает предел температуры оборудования на 10 °C. Бонус нескольких ИИ не складывается."
	category = AI_PROJECT_EFFICIENCY

	research_cost = 2250
	can_be_run = FALSE

/datum/ai_project/coolant_manager/finish()
	ai.resource_pool().refresh_cooling()

/datum/ai_project/coolant_manager/get_completion_message()
	return "Улучшение охлаждения применяется автоматически в вашей текущей рабочей сети. Запускать программу не требуется."
