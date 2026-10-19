GLOBAL_LIST_EMPTY(ai_subnets)

/** Хранит квоты физического кабельного сегмента внутри общей логической сети. */
/datum/ai_subnet
	/// Имя физической подсети для распределения квот.
	var/name
	/// Доля свободного CPU подсети; -1 включает автоматическое распределение.
	var/cpu_quota = -1
	/// Квоты категорий внутри подсети; -1 оставляет автоматическую долю.
	var/list/activity_cpu_quotas = list("recovery" = -1, "research" = -1, "archive" = -1, "science" = -1, "mining" = -1)

/datum/ai_subnet/New()
	var/static/next_id = 0
	name = "Кабельный сегмент [++next_id]"
	GLOB.ai_subnets += src

/datum/ai_subnet/Destroy()
	GLOB.ai_subnets -= src
	return ..()

/obj/machinery/ai
	/// Физическая кабельная подсеть объекта, не объединяемая мостами.
	var/datum/ai_subnet/ai_subnet

/obj/structure/ai_ethernet
	/// Физическая кабельная подсеть объекта, не объединяемая мостами.
	var/datum/ai_subnet/ai_subnet

/** Восстанавливает физические кабельные подсети без объединения их через сетевые мосты. */
/datum/controller/subsystem/ai_networks/proc/rebuild_subnets(list/edges)
	var/list/used = list()
	var/list/old = GLOB.ai_subnets.Copy()
	for(var/list/component as anything in cable_components(edges))
		var/list/component_nodes = component["nodes"]
		var/list/component_cables = component["cables"]
		var/datum/ai_subnet/subnet
		for(var/obj/machinery/ai/node as anything in component_nodes)
			if(node.ai_subnet && !(node.ai_subnet in used))
				subnet = node.ai_subnet
				break
		if(!subnet)
			for(var/obj/structure/ai_ethernet/cable as anything in component_cables)
				if(cable.ai_subnet && !(cable.ai_subnet in used))
					subnet = cable.ai_subnet
					break
		if(!subnet)
			subnet = new
		used += subnet
		for(var/obj/machinery/ai/node as anything in component_nodes)
			node.ai_subnet = subnet
		for(var/obj/structure/ai_ethernet/cable as anything in component_cables)
			cable.ai_subnet = subnet
	for(var/datum/ai_subnet/subnet as anything in old)
		if(!(subnet in used))
			qdel(subnet)

/** Возвращает физические подсети, входящие в эту логическую сеть. */
/datum/ai_network/proc/local_subnets()
	var/list/result = list()
	for(var/obj/machinery/ai/node as anything in nodes)
		if(!QDELETED(node.ai_subnet))
			result |= node.ai_subnet
	return result

/** Задаёт долю фонового CPU подсети; отрицательное значение включает автоматическое распределение. */
/datum/ai_network/proc/set_subnet_quota(datum/ai_subnet/target, amount)
	var/list/subnets = local_subnets()
	if(!(target in subnets) || !isnum(amount) || (amount != -1 && (amount < 0 || amount > 1)))
		return FALSE
	var/assigned = 0
	for(var/datum/ai_subnet/subnet as anything in subnets)
		if(subnet != target)
			assigned += max(0, subnet.cpu_quota)
	if(amount >= 0 && assigned + amount > 1.00001)
		return FALSE
	target.cpu_quota = amount
	return TRUE

/** Меняет квоту категории только в действительной подсети при совпадении ревизии политики. */
/datum/ai_network/proc/activity_allocation_action(action, datum/ai_subnet/target, category, amount, expected_revision)
	if(QDELETED(target) || !(target in local_subnets()) || !(category in target.activity_cpu_quotas) || !isnum(expected_revision) || expected_revision != resource_policy_revision)
		return FALSE
	var/assigned = 0
	for(var/other in target.activity_cpu_quotas)
		if(other != category)
			assigned += max(0, target.activity_cpu_quotas[other])
	if(action == "max_network_cpu")
		amount = max(0, 1 - assigned)
	else if(action == "reset_network_cpu")
		amount = -1
	else if(action != "allocate_network_cpu")
		return FALSE
	if(!isnum(amount) || (amount != -1 && (amount < 0 || amount > 1)) || (amount >= 0 && assigned + amount > 1.00001))
		return FALSE
	target.activity_cpu_quotas[category] = amount < 0 ? -1 : min(amount, max(0, 1 - assigned))
	return TRUE

/** Согласует ручные и автоматические квоты подсетей с общим доступным бюджетом. */
/datum/ai_network/proc/normalize_subnet_quotas()
	var/list/subnets = local_subnets()
	var/assigned = 0
	for(var/datum/ai_subnet/subnet as anything in subnets)
		assigned += max(0, subnet.cpu_quota)
	if(assigned > 1)
		for(var/datum/ai_subnet/subnet as anything in subnets)
			if(subnet.cpu_quota >= 0)
				subnet.cpu_quota /= assigned

/** Строит единый план расходования свободного CPU с учётом квот, весов и готовности задач. */
/datum/ai_network/proc/background_cpu_plan()
	var/list/groups = list("recovery" = recovery_jobs(), "research" = research_jobs(), "archive" = decryption_jobs(), "science" = science_jobs(), "mining" = mining_jobs())
	var/list/weights = list()
	var/list/job_subnets = list()
	var/list/category_counts = list()
	for(var/category in groups)
		var/list/jobs = groups[category]
		for(var/datum/job as anything in jobs)
			var/obj/machinery/ai/host = job
			if(istype(job, /obj/item/ai_neural_backup))
				var/obj/item/ai_neural_backup/backup = job
				host = backup.recovery_host()
			var/datum/ai_subnet/subnet = host?.ai_subnet
			if(QDELETED(subnet))
				continue
			job_subnets[job] = subnet
			if(!category_counts[subnet])
				category_counts[subnet] = list()
			var/list/counts = category_counts[subnet]
			counts[category]++
			if(subnet.activity_cpu_quotas[category] != 0)
				weights[subnet] += job_weights[category]
	var/reserved = 0
	var/automatic_weight = 0
	for(var/datum/ai_subnet/subnet as anything in local_subnets())
		if(subnet.cpu_quota >= 0)
			reserved += subnet.cpu_quota
		else
			automatic_weight += weights[subnet] || 0
	var/list/budgets = list()
	var/spare = spare_cpu()
	for(var/datum/ai_subnet/subnet as anything in weights)
		budgets[subnet] = subnet.cpu_quota >= 0 ? spare * subnet.cpu_quota : (automatic_weight ? spare * max(0, 1 - reserved) * weights[subnet] / automatic_weight : 0)
	var/list/category_budgets = list()
	for(var/datum/ai_subnet/subnet as anything in category_counts)
		var/list/counts = category_counts[subnet]
		var/manual = 0
		var/auto_weight = 0
		for(var/category in subnet.activity_cpu_quotas)
			var/quota = subnet.activity_cpu_quotas[category]
			if(quota >= 0)
				manual += quota
			else
				auto_weight += (counts[category] || 0) * job_weights[category]
		var/list/shares = list()
		for(var/category in subnet.activity_cpu_quotas)
			var/quota = subnet.activity_cpu_quotas[category]
			shares[category] = quota >= 0 ? quota : (auto_weight ? max(0, 1 - manual) * (counts[category] || 0) * job_weights[category] / auto_weight : 0)
		category_budgets[subnet] = shares
	var/list/result = list()
	for(var/category in groups)
		var/list/rates = list()
		var/list/jobs = groups[category]
		for(var/datum/job as anything in jobs)
			var/datum/ai_subnet/subnet = job_subnets[job]
			if(subnet)
				var/list/shares = category_budgets[subnet]
				var/list/counts = category_counts[subnet]
				rates[job] = (budgets[subnet] || 0) * shares[category] / counts[category]
		result[category] = rates
	return result

/** Возвращает подсети, их квоты и фактические назначения из переданного плана задач. */
/datum/ai_network/proc/subnet_ui_data(list/job_plan)
	if(!islist(job_plan))
		job_plan = background_cpu_plan()
	var/list/result = list()
	for(var/datum/ai_subnet/subnet as anything in local_subnets())
		var/allocated = 0
		var/list/activities = list()
		for(var/category in job_plan)
			var/activity_cpu = 0
			var/job_count = 0
			var/list/rates = job_plan[category]
			for(var/datum/job as anything in rates)
				var/obj/machinery/ai/host = job
				if(istype(job, /obj/item/ai_neural_backup))
					var/obj/item/ai_neural_backup/backup = job
					host = backup.recovery_host()
				if(host?.ai_subnet == subnet)
					allocated += rates[job]
					activity_cpu += rates[job]
					job_count++
			activities += list(list("category" = category, "quota" = subnet.activity_cpu_quotas[category], "cpu" = activity_cpu, "jobs" = job_count))
		result += list(list("ref" = REF(subnet), "name" = subnet.name, "quota" = subnet.cpu_quota, "cpu" = allocated, "activities" = activities))
	return result
