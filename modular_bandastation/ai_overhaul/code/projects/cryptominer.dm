/** Делит свободный личный CPU между исследованиями и общим майнингом своей среды. */
/datum/ai_project/crypto_miner
	name = "Crypto Miner"
	description = "Половина свободного CPU идёт на майнинг в бюджет станции, другая — на исследования. Доход делит общую убывающую отдачу с серверным майнингом; ускорение исследований не повышает выплаты."
	category = AI_PROJECT_MISC
	research_cost = 2000

/datum/ai_project/crypto_miner/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	dashboard.crypto_mining = TRUE

/datum/ai_project/crypto_miner/stop()
	dashboard.crypto_mining = FALSE
	return ..()
