/** Пересчитывает нейротопологию, фоновые задачи и рекорды оборудования. */
/datum/controller/subsystem/ai_networks
	/// Сохранённые рекорды CPU в ТГц и RAM в ТБ с датами.
	var/list/benchmark_history = list("cpu" = list(), "ram" = list())
	/// Наибольшая доступная мощность раунда в ТГц.
	var/benchmark_peak_cpu = 0
	/// Наибольшая доступная память раунда в ТБ.
	var/benchmark_peak_ram = 0
	/// Предотвращает повторное сохранение рекордов текущего раунда.
	var/benchmark_saved = FALSE

/** Сохраняет ограниченный список рекордов с датами, проверяя загруженные значения. */
/proc/ai_benchmark_records(list/records, value = 0, recorded_date = null)
	var/list/candidates = list()
	if(islist(records))
		for(var/list/entry as anything in records)
			if(!islist(entry) || !isnum(entry["value"]) || entry["value"] <= 0 || !istext(entry["date"]) || length(entry["date"]) > 32)
				continue
			candidates += list(list("value" = entry["value"], "date" = entry["date"]))
	if(isnum(value) && value > 0 && istext(recorded_date))
		candidates += list(list("value" = value, "date" = recorded_date))
	var/list/result = list()
	while(length(candidates) && length(result) < 10)
		var/best = 1
		for(var/index = 2; index <= length(candidates); index++)
			if(candidates[index]["value"] > candidates[best]["value"])
				best = index
		result += list(candidates[best])
		candidates.Cut(best, best + 1)
	return result

/** Загружает локальные рекорды CPU и RAM из JSON с проверкой структуры. */
/datum/controller/subsystem/ai_networks/proc/load_benchmark_history()
#ifndef UNIT_TESTS
	var/path = "data/ai_network_benchmarks.json"
	if(!fexists(path))
		return
	try
		var/list/saved = json_decode(file2text(path))
		if(islist(saved))
			benchmark_history = list("cpu" = ai_benchmark_records(saved["cpu"]), "ram" = ai_benchmark_records(saved["ram"]))
	catch(var/exception/error)
		log_game("AI benchmark history could not be read: [error]")
#endif

/** Обновляет максимумы доступного оборудования за текущий раунд. */
/datum/controller/subsystem/ai_networks/proc/sample_benchmark_history()
	for(var/datum/ai_network/network as anything in GLOB.ai_networks)
		var/station_network = FALSE
		for(var/obj/machinery/ai/data_core/core in network.nodes)
			if(is_station_level(core.z))
				station_network = TRUE
				break
		if(!station_network)
			continue
		benchmark_peak_cpu = max(benchmark_peak_cpu, network.resources.total_cpu)
		benchmark_peak_ram = max(benchmark_peak_ram, network.resources.total_ram)

/** Записывает рекорды раунда один раз при сохранении состояния сервера. */
/datum/controller/subsystem/ai_networks/proc/save_benchmark_history()
#ifndef UNIT_TESTS
	if(benchmark_saved)
		return
	benchmark_saved = TRUE
	var/date = time2text(world.realtime, "YYYY-MM-DD")
	benchmark_history = list("cpu" = ai_benchmark_records(benchmark_history["cpu"], benchmark_peak_cpu, date), "ram" = ai_benchmark_records(benchmark_history["ram"], benchmark_peak_ram, date))
	rustg_file_write(json_encode(benchmark_history), "data/ai_network_benchmarks.json")
#endif
