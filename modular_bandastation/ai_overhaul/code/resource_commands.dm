/** Проверяет сеть и бюджет назначений; относительные команды также проверяют ревизию. */
/datum/ai_os/proc/allocation_action(action, mob/living/silicon/ai/ai, amount, expected_revision, expected_cpu, expected_ram)
	if(QDELETED(ai) || !istype(ai) || (network && ai.ai_network != network))
		return FALSE
	var/current_cpu = cpu_assigned[ai] || 0
	var/current_ram = ram_assigned[ai] || 0
	if(action != "set_cpu" && action != "set_ram")
		if(QDELETED(network) || !isnum(expected_revision) || expected_revision != network.resource_policy_revision)
			return FALSE
	switch(action)
		if("set_cpu")
			return set_cpu(ai, amount)
		if("set_ram")
			return set_ram(ai, amount)
		if("max_cpu")
			if(total_cpu <= 0)
				return FALSE
			return set_cpu(ai, clamp(1 - total_cpu_assigned() + current_cpu, 0, 1))
		if("max_ram")
			return set_ram(ai, max(0, total_ram - total_ram_assigned() + current_ram))
		if("add_ram")
			return set_ram(ai, current_ram + 1)
		if("remove_ram")
			return current_ram > 0 && set_ram(ai, current_ram - 1)
		if("clear_ai_resources")
			if(!isnum(expected_cpu) || !isnum(expected_ram))
				return FALSE
			if(json_encode(list(expected_cpu, expected_ram)) != json_encode(list(current_cpu, current_ram)))
				return FALSE
			return clear_ai_resources(ai)
	return FALSE
