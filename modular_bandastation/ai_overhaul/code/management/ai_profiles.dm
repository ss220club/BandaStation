/datum/ai_dashboard
	/// Три личных профиля программ, приоритетов и CPU с ключами номеров слотов.
	var/list/work_profiles = list()
	/// Результаты последнего применения профиля, включая пропущенные действия.
	var/list/profile_report = list()

/** Проверяет целочисленный номер одного из трёх личных профилей. */
/datum/ai_dashboard/proc/valid_profile_slot(slot)
	return isnum(slot) && slot == round(slot) && slot >= 1 && slot <= 3

/** Возвращает сохранённые профили и доступность их действий для интерфейса. */
/datum/ai_dashboard/proc/profile_ui_data()
	var/list/result = list()
	for(var/slot in 1 to 3)
		var/list/profile = work_profiles["[slot]"]
		var/list/programs = profile?["programs"]
		var/list/allocations = profile?["cpu"]
		var/cpu = 0
		for(var/key in allocations)
			cpu += allocations[key]
		result += list(list("slot" = slot, "saved" = !!profile, "name" = profile?["name"] || "Профиль [slot]", "program_count" = length(programs), "cpu_share" = cpu))
	return result

/** Сохраняет программы, их приоритеты и доли CPU в выбранный личный слот. */
/datum/ai_dashboard/proc/save_work_profile(slot, profile_name)
	if(!valid_profile_slot(slot) || !istext(profile_name))
		return FALSE
	profile_name = trim(strip_html(profile_name, 32))
	if(!length(profile_name))
		return FALSE
	var/list/programs = list()
	var/list/priorities = list()
	for(var/datum/ai_project/project as anything in completed_projects)
		if(!project.can_be_run || !project.profile_supported)
			continue
		priorities[project.name] = project.memory_priority
		if(project.running)
			programs[project.name] = project.memory_priority
	var/list/allocations = list()
	for(var/key in cpu_usage)
		var/datum/ai_project/project = get_project_by_name(key)
		if(project && !project.running && cpu_usage[key] > 0)
			allocations[key] = cpu_usage[key]
	work_profiles["[slot]"] = list("name" = profile_name, "programs" = programs, "priorities" = priorities, "cpu" = allocations, "spare_research" = contribute_spare_cpu)
	profile_report = list("Профиль «[profile_name]» сохранён.")
	return TRUE

/** Удаляет профиль из допустимого личного слота. */
/datum/ai_dashboard/proc/delete_work_profile(slot)
	if(!valid_profile_slot(slot) || !work_profiles["[slot]"])
		return FALSE
	work_profiles -= "[slot]"
	profile_report = list("Профиль удалён. Текущие программы и назначения не изменены.")
	return TRUE

/** Проверяет возможность назначения CPU проекту при применении профиля. */
/datum/ai_dashboard/proc/profile_cpu_available(datum/ai_project/project)
	if(!project || !project.can_research())
		return FALSE
	if(project in available_projects)
		return TRUE
	if(!project.ability_path || project.ability_recharge_cost <= 0)
		return FALSE
	if(project != recharge_project(project.ability_path))
		return FALSE
	var/datum/action/innate/ai/ability = locate(project.ability_path) in owner.actions
	return ability && ability.uses < ability.max_uses

/** Применяет доступную часть профиля в текущем бюджете и записывает причины пропусков. */
/datum/ai_dashboard/proc/apply_work_profile(slot)
	if(!valid_profile_slot(slot))
		return FALSE
	var/list/profile = work_profiles["[slot]"]
	if(!profile)
		return FALSE
	profile_report = list()
	for(var/datum/ai_project/project as anything in LAZYCOPY(running_projects))
		if(project.profile_supported)
			stop_project(project)
	for(var/key in cpu_usage)
		if(!get_project_by_name(key)?.running)
			cpu_usage[key] = 0
	var/list/priorities = profile["priorities"]
	for(var/key in priorities)
		set_memory_priority(get_project_by_name(key), priorities[key])
	var/list/programs = profile["programs"]
	var/list/pending = list()
	for(var/key in programs)
		var/datum/ai_project/project = get_project_by_name(key)
		if(!project || !(project in completed_projects) || !project.can_be_run || !project.profile_supported)
			profile_report += "Программа «[key]» больше недоступна."
			continue
		pending += project
	var/datum/ai_project/memory_compressor/compressor = locate() in pending
	if(compressor)
		pending -= compressor
		if(!run_project(compressor))
			profile_report += "Не запущена программа «[compressor.get_display_name()]»: условия запуска не выполнены."
	var/started = compressor?.running ? 1 : 0
	while(length(pending))
		var/datum/ai_project/next
		for(var/datum/ai_project/project as anything in pending)
			if(!next || project.memory_priority > next.memory_priority)
				next = project
		pending -= next
		if(run_project(next))
			started++
		else
			next.stop_reason = "Профиль: недостаточно ресурсов или не выполнены условия запуска"
			profile_report += "Не запущена программа «[next.get_display_name()]»: недостаточно ресурсов или не выполнены условия запуска."
	var/list/allocations = profile["cpu"]
	var/list/eligible = list()
	var/requested_cpu = 0
	for(var/key in allocations)
		var/datum/ai_project/project = get_project_by_name(key)
		if(!profile_cpu_available(project))
			profile_report += "Назначение CPU для «[project?.get_display_name() || key]» пропущено: исследование или перезарядка сейчас недоступны."
			continue
		eligible += project
		requested_cpu += allocations[key]
	var/free_cpu = 1
	for(var/key in cpu_usage)
		free_cpu -= cpu_usage[key]
	var/scale = requested_cpu > 0 ? min(1, max(0, free_cpu) / requested_cpu) : 1
	for(var/datum/ai_project/project as anything in eligible)
		set_project_cpu(project, allocations[project.name] * scale)
	if(scale < 1)
		profile_report += "Назначения CPU уменьшены пропорционально: часть CPU нужна работающим программам."
	contribute_spare_cpu = profile["spare_research"]
	enforce_program_memory()
	profile_report.Insert(1, "Профиль «[profile["name"]]» применён. Запущено программ: [started] из [length(programs)].")
	telemetry_log.record(profile_report[1], length(profile_report) > 1 ? "warning" : "info")
	return TRUE
