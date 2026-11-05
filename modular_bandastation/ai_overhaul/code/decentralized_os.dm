GLOBAL_DATUM_INIT(ai_os, /datum/ai_os, new)

/** Учитывает CPU, RAM, назначения и охлаждение одной логической нейросети. */
/datum/ai_os
	/// Читаемое имя сети или пула для интерфейсов.
	var/name = "Распределённая система управления ресурсами"
	/// Доступная вычислительная мощность в ТГц.
	var/total_cpu = 0
	/// Мощность до теплового ограничения в ТГц.
	var/nominal_cpu = 0
	/// Доступная оперативная память в ТБ.
	var/total_ram = 0
	/// Назначенные ИИ доли общего CPU; 1 означает весь пул.
	var/list/cpu_assigned = list()
	/// Назначенные ИИ целые объёмы RAM в ТБ.
	var/list/ram_assigned = list()
	/// Текущий предел температуры оборудования в K, пересчитываемый по активному охлаждению.
	var/temp_limit = AI_TEMP_LIMIT
	/// Разрешает управление ресурсами только людям с соответствующим доступом.
	var/human_lock = FALSE
	/// Логическая нейросеть, которой принадлежит пул.
	var/datum/ai_network/network

/datum/ai_os/Destroy()
	network = null
	cpu_assigned.Cut()
	ram_assigned.Cut()
	return ..()

/** Снимает с ИИ назначения CPU и RAM этого пула. */
/datum/ai_os/proc/remove_ai(mob/living/silicon/ai/ai)
	cpu_assigned -= ai
	ram_assigned -= ai

/** Возвращает сумму назначенных долей CPU, где 1 означает весь пул. */
/datum/ai_os/proc/total_cpu_assigned()
	var/total = 0
	for(var/mob/living/silicon/ai/ai as anything in cpu_assigned)
		total += cpu_assigned[ai]
	return total

/** Возвращает общий назначенный объём RAM в ТБ. */
/datum/ai_os/proc/total_ram_assigned()
	var/total = 0
	for(var/mob/living/silicon/ai/ai as anything in ram_assigned)
		total += ram_assigned[ai]
	return total

/** Пересчитывает доступные CPU и RAM, затем отзывает назначения потерянной памяти. */
/datum/ai_os/proc/update_hardware()
	if(src == GLOB.ai_os)
		SSai_networks.rebuild()
		for(var/datum/ai_network/current as anything in GLOB.ai_networks)
			current.resources.update_hardware()
		return
	total_ram = 0
	total_cpu = 0
	nominal_cpu = 0
	refresh_cooling()
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in GLOB.server_cabinets)
		if(network && !(cabinet in network.nodes))
			continue
		if(QDELETED(cabinet) || cabinet.valid_ticks <= 0)
			continue
		total_ram += cabinet.total_ram
		nominal_cpu += cabinet.total_cpu
		total_cpu += cabinet.effective_cpu()
	update_allocations()

/** Сокращает назначения RAM до доступного объёма после изменения оборудования. */
/datum/ai_os/proc/update_allocations()
	var/excess = max(0, total_ram_assigned() - total_ram)
	for(var/mob/living/silicon/ai/ai as anything in ram_assigned.Copy())
		if(QDELETED(ai))
			remove_ai(ai)
			continue
		if(excess <= 0)
			continue
		var/reduction = min(ram_assigned[ai], excess)
		ram_assigned[ai] -= reduction
		excess -= reduction
		if(reduction)
			to_chat(ai, span_warning("Серверные ресурсы потеряны: отозвано [reduction] ТБ RAM. Программы могут остановиться."))

/** Назначает ИИ долю CPU от 0 до 1, проверяя принадлежность сети и свободный бюджет. */
/datum/ai_os/proc/set_cpu(mob/living/silicon/ai/ai, amount, update = TRUE)
	if(QDELETED(ai) || !istype(ai) || !isnum(amount) || amount < 0 || amount > 1)
		return FALSE
	if(network && ai.ai_network != network)
		return FALSE
	if(total_cpu_assigned() - cpu_assigned[ai] + amount > 1.00001)
		return FALSE
	cpu_assigned[ai] = amount
	return TRUE

/** Назначает ИИ целое число ТБ RAM в пределах доступного бюджета его сети. */
/datum/ai_os/proc/set_ram(mob/living/silicon/ai/ai, amount, update = TRUE)
	if(QDELETED(ai) || !istype(ai) || !isnum(amount) || amount < 0 || amount != round(amount))
		return FALSE
	if(network && ai.ai_network != network)
		return FALSE
	if(total_ram_assigned() - ram_assigned[ai] + amount > total_ram)
		return FALSE
	ram_assigned[ai] = amount
	return TRUE

/** Обнуляет назначения CPU и RAM ИИ через проверки пула. */
/datum/ai_os/proc/clear_ai_resources(mob/living/silicon/ai/ai)
	return set_cpu(ai, 0) && set_ram(ai, 0)

/** Пересчитывает действующее охлаждение и возвращает температурный предел в K. */
/datum/ai_os/proc/get_temp_limit()
	refresh_cooling()
	return temp_limit

/** Применяет к текущей сети один бонус охлаждения от живого ИИ с завершённым проектом. */
/datum/ai_os/proc/refresh_cooling()
	temp_limit = AI_TEMP_LIMIT
	if(!network)
		return
	for(var/obj/machinery/ai/data_core/core in network.nodes)
		if(QDELETED(core) || core.valid_ticks <= 0 || !core.has_power() || (core.machine_stat & (BROKEN | EMPED)))
			continue
		for(var/mob/living/silicon/ai/ai in core)
			if(!QDELETED(ai) && ai.stat != DEAD && !ai.control_disabled && ai.dashboard?.has_completed_project(/datum/ai_project/coolant_manager))
				temp_limit += 10
				return
