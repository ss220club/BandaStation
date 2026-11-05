/** Замедляет разрешённую выгрузку ИИ во время работы защитной программы. */
/datum/ai_project/firewall
	name = "Download Firewall"
	description = "Скрытие внутренних функций вдвое увеличивает время выгрузки вашего сознания."
	research_cost = 1500
	ram_required = 2
	category = AI_PROJECT_MISC

/datum/ai_project/firewall/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.download_speed_modifier *= 0.5


/datum/ai_project/firewall/stop()
	ai.download_speed_modifier *= 2
	..()
