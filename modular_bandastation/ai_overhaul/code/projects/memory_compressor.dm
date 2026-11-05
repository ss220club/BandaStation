/** Даёт дополнительную RAM, постоянно занимая 15% личного CPU. */
/datum/ai_project/memory_compressor
	name = "Memory Compressor"
	description = "Продвинутый алгоритм сжимает память системного ядра и освобождает 3 ТБ RAM. Требует 15% свободного CPU."
	category = AI_PROJECT_EFFICIENCY
	research_cost = 2250

/datum/ai_project/memory_compressor/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	dashboard.free_ram += 3
	dashboard.cpu_usage[name] = 0.15

/datum/ai_project/memory_compressor/stop()
	dashboard.free_ram -= 3
	dashboard.cpu_usage[name] = 0
	..()

/datum/ai_project/memory_compressor/can_run()
	. = ..()
	if(!.)
		return
	var/total_cpu_used = 0
	for(var/project_name in dashboard.cpu_usage)
		total_cpu_used += dashboard.cpu_usage[project_name]
	if(total_cpu_used + 0.15 <= 1 + 0.00001)
		return TRUE
	to_chat(ai, span_warning("Программа не может быть запущена: требуется 15% свободного CPU!"))
	return FALSE
