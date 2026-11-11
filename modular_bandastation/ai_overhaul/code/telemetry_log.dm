#define AI_TELEMETRY_HISTORY_LIMIT 64
#define AI_TELEMETRY_SAMPLE_INTERVAL (2 SECONDS)
#define AI_TELEMETRY_SAMPLE_WINDOW (2 MINUTES)

/** Даёт личным окнам ИИ одинаковые показания для экранных помех. */
/mob/living/silicon/ai/proc/neural_display_telemetry()
	var/list/data = list("integrityPercent" = (health + 100) / 2)
	if(!dashboard)
		return data
	var/datum/ai_os/pool = resource_pool()
	var/reserved_cpu = 0
	for(var/project_name in dashboard.cpu_usage)
		reserved_cpu += dashboard.cpu_usage[project_name]
	var/used_ram = 0
	for(var/project_name in dashboard.ram_usage)
		used_ram += dashboard.ram_usage[project_name]
	if(pool.total_cpu * (pool.cpu_assigned[src] || 0) > 0)
		data["cpuReserved"] = reserved_cpu
	data["cpuScope"] = "projects"
	data["memoryUsed"] = used_ram
	data["memoryCapacity"] = (pool.ram_assigned[src] || 0) + dashboard.free_ram
	if(istype(loc, /obj/machinery/ai))
		var/obj/machinery/ai/host = loc
		data["temperatures"] = list(list("value" = host.core_temp, "limit" = pool.get_temp_limit()))
	return data

/** Хранит ограниченную историю доступных владельцу показаний с явными пробелами наблюдений. */
/datum/ai_telemetry_log
	/// Ограниченная последовательность собственных наблюдённых событий ИИ.
	var/list/events = list()
	/// Последние подтверждённые состояния доступных узлов.
	var/list/last_endpoints = list()
	/// Последнее наблюдавшееся физическое ядро владельца.
	var/last_host
	/// Предыдущая подтверждённая мощность сети в ТГц.
	var/last_cpu
	/// Предыдущий подтверждённый объём RAM сети в ТБ.
	var/last_ram
	/// Предыдущая подтверждённая личная доля CPU.
	var/last_assigned_cpu
	/// Предыдущий подтверждённый личный объём RAM в ТБ.
	var/last_assigned_ram
	/// Время предыдущего наблюдения в отсчётах world.time.
	var/last_sample_time
	/// Отличает первый снимок от изменения ранее наблюдавшегося состояния.
	var/has_observed = FALSE
	/// Разрешает сохранять новые наблюдения и показания.
	var/recording = FALSE
	/// Последовательный идентификатор следующей местной записи журнала.
	var/next_id = 0
	/// Ограниченная история показаний для графиков личной панели.
	var/list/samples = list()
	/// Номер непрерывного участка истории; меняется после пробела наблюдений.
	var/sample_segment = 0
	/// Время последнего образца графика в отсчётах world.time.
	var/last_reading_time
	/// Последняя наблюдавшаяся сеть для отделения независимых участков истории.
	var/last_network

/datum/ai_telemetry_log/Destroy()
	events.Cut()
	last_endpoints.Cut()
	samples.Cut()
	return ..()

/** Добавляет наблюдённое событие с местным временем и важностью в ограниченный журнал. */
/datum/ai_telemetry_log/proc/record(message, severity = "info")
	events.Insert(1, list(list(
		"id" = ++next_id,
		"time" = round_timestamp(),
		"message" = message,
		"severity" = severity,
	)))
	if(length(events) > AI_TELEMETRY_HISTORY_LIMIT)
		events.Cut(AI_TELEMETRY_HISTORY_LIMIT + 1)

/** Снимает доступные ИИ показания; отсутствие ответа отмечается без предположений о причине. */
/datum/ai_telemetry_log/proc/observe(mob/living/silicon/ai/observer)
	var/obj/machinery/ai/data_core/host = observer.loc
	var/online = istype(host) && !QDELETED(host) && host.has_power() && !(host.machine_stat & (BROKEN | EMPED)) && host.valid_ticks > 0 && observer.stat == STABLE && !observer.control_disabled
	if(!online)
		recording = FALSE
		return
	var/datum/ai_os/pool = observer.resource_pool()
	if(!observer.ai_network)
		recording = FALSE
		return
	var/list/endpoints = list()
	for(var/obj/machinery/ai/node as anything in observer.ai_network.nodes)
		if(QDELETED(node) || !node.has_power() || (node.machine_stat & (BROKEN | EMPED)))
			continue
		endpoints += REF(node)
	var/current_cpu = round(pool.total_cpu, 0.01)
	var/current_ram = pool.total_ram
	var/assigned_cpu = round(pool.total_cpu * pool.cpu_assigned[observer], 0.01)
	var/assigned_ram = pool.ram_assigned[observer] || 0
	var/new_segment = !recording || last_host != REF(host) || last_network != REF(observer.ai_network) || (!isnull(last_sample_time) && world.time - last_sample_time > 10 SECONDS)
	if(new_segment)
		sample_segment++
	if(new_segment || isnull(last_reading_time) || world.time - last_reading_time >= AI_TELEMETRY_SAMPLE_INTERVAL)
		var/reserved_cpu = 0
		for(var/key in observer.dashboard.cpu_usage)
			reserved_cpu += observer.dashboard.cpu_usage[key]
		samples += list(list(
			"time" = world.time / (1 SECONDS),
			"segment" = sample_segment,
			"source" = ai_localized_area(host),
			"cpu" = assigned_cpu,
			"cpu_nominal" = round(max(pool.total_cpu, pool.nominal_cpu) * pool.cpu_assigned[observer], 0.01),
			"cpu_reserved" = round(assigned_cpu * reserved_cpu, 0.01),
			"ram" = assigned_ram + observer.dashboard.free_ram,
			"ram_used" = observer.dashboard.used_program_ram(),
			"temperature" = host.core_temp,
			"temperature_limit" = pool.get_temp_limit(),
		))
		last_reading_time = world.time
		trim_samples()
	if(!recording || (!isnull(last_sample_time) && world.time - last_sample_time > 10 SECONDS))
		record(has_observed ? "Наблюдение возобновлено. События во время перерыва неизвестны." : "Начата запись местной телеметрии. Предыдущие события неизвестны.")
		record("Сейчас отвечают узлы: [length(endpoints)]. Заявленные ресурсы: [current_cpu] ТГц / [current_ram] ТБ.")
	else
		var/lost = length(last_endpoints - endpoints)
		var/found = length(endpoints - last_endpoints)
		if(lost)
			record("Нет ответа от [lost] ранее доступных узлов. Причина неизвестна.", "warning")
		if(found)
			record("Получен ответ от [found] дополнительных узлов.")
		if(last_host != REF(host))
			record("Ядро выполнения сменилось. Местная телеметрия подключена к текущему ядру.")
		if(last_cpu != current_cpu || last_ram != current_ram)
			record("Заявленные ресурсы изменились: [last_cpu] ТГц / [last_ram] ТБ → [current_cpu] ТГц / [current_ram] ТБ.", current_cpu < last_cpu || current_ram < last_ram ? "warning" : "info")
		if(last_assigned_cpu != assigned_cpu || last_assigned_ram != assigned_ram)
			record("Местное выделение изменилось: [assigned_cpu] ТГц / [assigned_ram] ТБ. Кто изменил выделение — неизвестно.")
	last_endpoints = endpoints
	last_host = REF(host)
	last_network = REF(observer.ai_network)
	last_cpu = current_cpu
	last_ram = current_ram
	last_assigned_cpu = assigned_cpu
	last_assigned_ram = assigned_ram
	last_sample_time = world.time
	has_observed = TRUE
	recording = TRUE

/** Ограничивает историю показаний по времени и числу образцов. */
/datum/ai_telemetry_log/proc/trim_samples()
	while(length(samples))
		var/list/oldest = samples[1]
		if(length(samples) <= AI_TELEMETRY_HISTORY_LIMIT && oldest["time"] >= (world.time - AI_TELEMETRY_SAMPLE_WINDOW) / (1 SECONDS))
			break
		samples.Cut(1, 2)

/** Возвращает историю телеметрии с разрывами между независимыми периодами наблюдения. */
/datum/ai_telemetry_log/proc/history_data()
	trim_samples()
	return list(
		"samples" = samples,
		"now" = world.time / (1 SECONDS),
		"age" = isnull(last_reading_time) ? null : max(0, (world.time - last_reading_time) / (1 SECONDS)),
		"recording" = recording,
	)

#undef AI_TELEMETRY_HISTORY_LIMIT
#undef AI_TELEMETRY_SAMPLE_INTERVAL
#undef AI_TELEMETRY_SAMPLE_WINDOW
