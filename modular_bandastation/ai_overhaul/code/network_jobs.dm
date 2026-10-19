/datum/ai_network
	/// Относительные веса категорий готовых фоновых задач.
	var/list/job_weights = list("recovery" = 1, "research" = 1, "archive" = 1, "science" = 1, "mining" = 1)

/** Задаёт целый относительный вес категории фоновых задач от 1 до 10. */
/datum/ai_network/proc/set_job_weight(category, amount)
	if(!(category in job_weights) || !isnum(amount) || amount < 1 || amount > 10 || amount != round(amount))
		return FALSE
	job_weights[category] = amount
	return TRUE

/** Возвращает суммарный вес готовых фоновых задач сети. */
/datum/ai_network/proc/background_job_weight()
	return length(recovery_jobs()) * job_weights["recovery"] + length(research_jobs()) * job_weights["research"] + length(decryption_jobs()) * job_weights["archive"] + length(science_jobs()) * job_weights["science"] + length(mining_jobs()) * job_weights["mining"]

/obj/machinery/ai/server_cabinet
	/// Разрешает серверу фоновый майнинг за свободный CPU.
	var/background_mining = FALSE
	/// Кредиты, накопленные на физическом сервере и доступные для снятия.
	var/mining_balance = 0
	/// Разрешает серверу помогать обычным исследованиям станции.
	var/background_science = FALSE
	/// Уже перечисленные сервером обычные научные очки.
	var/background_science_points = 0
	/// Дробный остаток обычных научных очков до перечисления целой части.
	var/background_science_pending = 0
	/// Разрешает серверу исследовать инфраструктуру ИИ.
	var/background_research = FALSE
	/// Уже перечисленные очки исследований инфраструктуры ИИ.
	var/background_research_points = 0
	/// Дробный остаток очков ИИ до перечисления целой части.
	var/background_research_pending = 0

/** Проверяет пригодность закрытого серверного шкафа к фоновой работе. */
/obj/machinery/ai/server_cabinet/proc/can_run_background_research()
	return !QDELETED(src) && !panel_open && valid_ticks > 0 && total_cpu > 0 && valid_holder()

/** Накапливает дробные очки ИИ и перечисляет целую часть в местную базу исследований. */
/obj/machinery/ai/server_cabinet/proc/contribute_background_research(points)
	var/datum/techweb/science = ai_station_techweb(src)
	if(!science || !isnum(points) || points <= 0)
		return
	background_research_pending += points
	var/deposit = FLOOR(background_research_pending, 1)
	if(deposit <= 0)
		return
	background_research_pending -= deposit
	background_research_points += deposit
	science.adjust_multiple_points(list(TECHWEB_POINT_TYPE_AI = deposit))

/** Накапливает обычные научные очки и перечисляет целую часть в местную базу исследований. */
/obj/machinery/ai/server_cabinet/proc/contribute_station_research(points)
	var/datum/techweb/science = ai_station_techweb(src)
	if(!science || !isnum(points) || points <= 0)
		return
	background_science_pending += points
	var/deposit = FLOOR(background_science_pending, 1)
	if(deposit <= 0)
		return
	background_science_pending -= deposit
	background_science_points += deposit
	science.adjust_multiple_points(list(TECHWEB_POINT_TYPE_GENERIC = deposit))

/** Возвращает готовые серверы с включённой помощью обычным исследованиям. */
/datum/ai_network/proc/science_jobs()
	var/list/jobs = list()
	for(var/obj/machinery/ai/server_cabinet/cabinet in nodes)
		if(ai_station_techweb(cabinet) && cabinet.background_science && cabinet.can_run_background_research())
			jobs += cabinet
	return jobs

/** Возвращает готовые серверы с включённым майнингом. */
/datum/ai_network/proc/mining_jobs()
	var/list/jobs = list()
	for(var/obj/machinery/ai/server_cabinet/cabinet in nodes)
		if(cabinet.background_mining && cabinet.can_run_background_research())
			jobs += cabinet
	return jobs

/** Возвращает число готовых фоновых задач всех категорий. */
/datum/ai_network/proc/background_job_count()
	return length(recovery_jobs()) + length(research_jobs()) + length(decryption_jobs()) + length(science_jobs()) + length(mining_jobs())

/** Возвращает аварийные носители, готовые к восстановлению в ядрах этой сети. */
/datum/ai_network/proc/recovery_jobs()
	var/list/jobs = list()
	for(var/obj/machinery/ai/data_core/core in nodes)
		var/obj/item/ai_neural_backup/backup = core.neural_backup
		if(backup?.recovery_enabled && backup.valid_payload() && backup.recovery_host() == core)
			jobs += backup
	return jobs

/** Возвращает готовые серверы с включёнными исследованиями инфраструктуры ИИ. */
/datum/ai_network/proc/research_jobs()
	var/list/jobs = list()
	for(var/obj/machinery/ai/server_cabinet/cabinet in nodes)
		if(ai_station_techweb(cabinet) && cabinet.background_research && cabinet.can_run_background_research())
			jobs += cabinet
	return jobs

/** Возвращает свободную для фоновых задач мощность сети в ТГц. */
/datum/ai_network/proc/spare_cpu()
	return max(0, resources.total_cpu) * clamp(1 - resources.total_cpu_assigned(), 0, 1)

/** Возвращает общий доход в кредитах за секунду по майнинговым ТГц с убывающей отдачей. */
/proc/ai_mining_income(cpu)
	if(!isnum(cpu) || cpu <= 0)
		return 0
	if(cpu <= AI_NETWORK_MINING_KNEE)
		return cpu * AI_NETWORK_MINING_PRICE
	return AI_NETWORK_MINING_KNEE * AI_NETWORK_MINING_PRICE + log(2, cpu / AI_NETWORK_MINING_KNEE)

/** Возвращает выделенные серверному майнингу ТГц с учётом общего плана фоновых задач. */
/datum/ai_network/proc/mining_cpu()
	var/list/plan = background_cpu_plan()
	var/list/mining = plan["mining"]
	var/total = 0
	for(var/datum/job as anything in mining)
		total += mining[job]
	return total

/** Возвращает половину свободных личных ТГц работающего криптомайнера либо 0. */
/mob/living/silicon/ai/proc/personal_mining_cpu()
	var/obj/machinery/ai/data_core/core = loc
	if(QDELETED(src) || stat != STABLE || control_disabled || !istype(core) || !core.has_power() || (core.machine_stat & (BROKEN | EMPED)) || core.valid_ticks <= 0)
		return 0
	if(!dashboard?.crypto_mining || !dashboard.contribute_spare_cpu || !ai_network || core.ai_network != ai_network || !ai_network.accessible_from(src))
		return 0
	var/remaining = 1
	for(var/project_name in dashboard.cpu_usage)
		remaining -= dashboard.cpu_usage[project_name]
	return ai_network.resources.total_cpu * (ai_network.resources.cpu_assigned[src] || 0) * clamp(remaining, 0, 1) * 0.5

/** Возвращает физический узел для определения общей среды майнинга этой сети. */
/datum/ai_network/proc/mining_source()
	return length(nodes) ? nodes[1] : null

/** Суммирует серверные и личные майнинговые ТГц одной среды, изолируя лаборатории. */
/proc/ai_total_mining_cpu(atom/source)
	var/total = 0
	for(var/datum/ai_network/network as anything in GLOB.ai_networks)
		if(network.accessible_from(source))
			total += network.mining_cpu()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai_same_debug_environment(source, ai))
			total += ai.personal_mining_cpu()
	return total

/** Возвращает доход в кредитах за секунду для cpu ТГц как долю общей кривой своей среды. */
/proc/ai_mining_income_share(atom/source, cpu)
	var/total = ai_total_mining_cpu(source)
	return total > 0 ? ai_mining_income(total) * max(0, cpu) / total : 0

/** Возвращает серверный доход сети в кредитах за секунду с учётом остальных майнеров среды. */
/datum/ai_network/proc/mining_income_per_second()
	return ai_mining_income_share(mining_source(), mining_cpu())

/** Выполняет согласованный план фоновых задач за seconds_per_tick секунд без повторного расходования CPU. */
/datum/ai_network/proc/process_background_jobs(seconds_per_tick)
	if(!isnum(seconds_per_tick) || seconds_per_tick <= 0)
		return
	var/list/plan = background_cpu_plan()
	var/list/recoveries = plan["recovery"]
	var/list/research = plan["research"]
	var/list/decryptions = plan["archive"]
	var/list/science = plan["science"]
	var/list/mining = plan["mining"]
	var/total_mining_cpu = ai_total_mining_cpu(mining_source())
	var/mining_rate = total_mining_cpu > 0 ? ai_mining_income(total_mining_cpu) / total_mining_cpu : 0
	var/total_science = 0
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in science)
		total_science += science[cabinet] * AI_RESEARCH_PER_CPU * AI_STATION_RESEARCH_MULTIPLIER
	var/science_scale = total_science > AI_STATION_RESEARCH_MAX_PER_SECOND ? AI_STATION_RESEARCH_MAX_PER_SECOND / total_science : 1
	for(var/obj/item/ai_neural_backup/backup as anything in recoveries)
		if(recoveries[backup] <= 0)
			continue
		backup.processing_progress = min(AI_BACKUP_CPU_COST, backup.processing_progress + recoveries[backup] * seconds_per_tick)
		if(backup.processing_progress >= AI_BACKUP_CPU_COST)
			backup.finish_recovery()
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in research)
		cabinet.contribute_background_research(research[cabinet] * seconds_per_tick * AI_RESEARCH_PER_CPU)
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in decryptions)
		if(decryptions[cabinet] > 0)
			cabinet.process_decryption(decryptions[cabinet] * seconds_per_tick)
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in science)
		cabinet.contribute_station_research(science[cabinet] * seconds_per_tick * AI_RESEARCH_PER_CPU * AI_STATION_RESEARCH_MULTIPLIER * science_scale)
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in mining)
		cabinet.mining_balance += mining[cabinet] * seconds_per_tick * mining_rate
