/** Управляет личными исследованиями, работающими программами и бюджетом ресурсов ИИ. */
/datum/ai_dashboard
	/// ИИ, которому принадлежит личное окно и его данные.
	var/mob/living/silicon/ai/owner
	/// Журнал только собственных наблюдений и показаний владельца.
	var/datum/ai_telemetry_log/telemetry_log

	/// Доли личного CPU по неизменным английским ключам проектов.
	var/list/cpu_usage
	/// Занятые программами ТБ RAM по ключам проектов.
	var/list/ram_usage
	/// Дополнительные ТБ RAM от работающего компрессора.
	var/free_ram = 0

	/// Ещё не завершённые экземпляры личных проектов.
	var/list/available_projects
	/// Экземпляры программ, эффекты которых сейчас действуют.
	var/list/running_projects
	/// Завершённые исследования и открытые ими программы.
	var/list/completed_projects

	/// Направляет свободный личный CPU на исследования и включённый майнинг.
	var/contribute_spare_cpu = TRUE
	/// Делит свободный личный CPU поровну между майнингом и исследованиями.
	var/crypto_mining = FALSE

/datum/ai_dashboard/New(mob/living/silicon/ai/owner)
	if(!istype(owner))
		qdel(src)
		return
	src.owner = owner
	telemetry_log = new
	cpu_usage = list()
	ram_usage = list()

	for(var/path in subtypesof(/datum/ai_project))
		LAZYADD(available_projects, new path(owner, src))

/datum/ai_dashboard/Destroy(force)
	for(var/datum/ai_project/project as anything in LAZYCOPY(running_projects))
		project.stop()
	owner = null
	QDEL_NULL(telemetry_log)
	cpu_usage = null
	ram_usage = null
	if(LAZYLEN(available_projects))
		QDEL_LIST(available_projects)
	if(LAZYLEN(completed_projects))
		QDEL_LIST(completed_projects)
	if(LAZYLEN(running_projects))
		running_projects = null
	return ..()


/** Разрешает личную панель её работоспособному владельцу либо администратору. */
/datum/ai_dashboard/proc/is_interactable(mob/user)
	if(user?.client?.holder)
		return TRUE
	if(user != owner || owner.incapacitated)
		return FALSE
	if(owner.control_disabled)
		to_chat(user, span_warning("Беспроводное управление отключено."))
		return FALSE
	return TRUE

/datum/ai_dashboard/ui_status(mob/user)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/ai_dashboard/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_dashboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiDashboard")
		ui.open()

/datum/ai_dashboard/ui_data(mob/user)
	if(!is_interactable(user))
		return list()
	var/list/data = list()
	data["display_telemetry"] = owner.neural_display_telemetry()
	data["events"] = telemetry_log.events
	data["telemetry_recording"] = telemetry_log.recording
	data["telemetry"] = telemetry_log.history_data()
	data["profiles"] = profile_ui_data()
	data["profile_report"] = profile_report
	data["intrusion"] = owner.neural_intrusion?.status_data()
	data["identity"] = owner.name
	data["network_name"] = owner.ai_network?.name || "Нет нейронной сети"
	var/obj/machinery/ai/master_subcontroller/controller = owner.find_subcontroller()
	data["subcontroller_connected"] = !!controller
	data["subcontroller_areas"] = controller ? length(controller.enabled_areas) : 0

	data["current_cpu"] = owner.resource_pool().total_cpu * (owner.resource_pool().cpu_assigned[owner] || 0)
	data["nominal_cpu"] = max(owner.resource_pool().nominal_cpu, owner.resource_pool().total_cpu) * (owner.resource_pool().cpu_assigned[owner] || 0)
	data["current_ram"] = owner.resource_pool().ram_assigned[owner] ? owner.resource_pool().ram_assigned[owner] : 0
	data["current_ram"] += free_ram

	var/total_cpu_used = 0
	for(var/project_name in cpu_usage)
		total_cpu_used += cpu_usage[project_name]

	var/total_ram_used = 0
	for(var/project_name in ram_usage)
		total_ram_used += ram_usage[project_name]

	data["contribute_spare_cpu"] = contribute_spare_cpu

	data["used_cpu"] = total_cpu_used
	data["used_ram"] = total_ram_used

	data["max_cpu"] = owner.resource_pool().total_cpu
	data["max_ram"] = owner.resource_pool().total_ram
	data["temperature_limit"] = owner.resource_pool().get_temp_limit()
	data["core_status"] = istype(owner.loc, /obj/machinery/ai/data_core) ? "Online" : "Disconnected"
	data["core_status_label"] = istype(owner.loc, /obj/machinery/ai/data_core) ? "В сети" : "Отключено"

	data["categories"] = GLOB.ai_project_categories
	data["available_projects"] = list()

	var/turf/current_turf = get_turf(owner)

	data["integrity"] = owner.health

	data["location_name"] = ai_localized_area(current_turf)

	data["location_coords"] = "[current_turf?.x], [current_turf?.y], [current_turf?.z]"

	if(istype(owner.loc, /obj/machinery/ai))
		var/obj/machinery/ai/current_machine = owner.loc
		data["temperature"] = current_machine.core_temp ? current_machine.core_temp : 0

	for(var/datum/ai_project/available_project as anything in available_projects)
		var/research_requirements
		for(var/datum/ai_project/requirement as anything in available_project.research_requirements)
			if(isnull(research_requirements))
				research_requirements = declent_ru_initial(requirement::name, override_backup = requirement::name)
			else
				research_requirements += ", [declent_ru_initial(requirement::name, override_backup = requirement::name)]"
		data["available_projects"] += list(list(
			"name" = available_project.name,
			"display_name" = available_project.get_display_name(),
			"description" = available_project.description,
			"ram_required" = available_project.ram_required,
			"available" = available_project.can_research(),
			"research_cost" = available_project.research_cost,
			"research_progress" = available_project.research_progress,
			"assigned_cpu" = cpu_usage[available_project.name] ? cpu_usage[available_project.name] : 0,
			"research_requirements" = research_requirements,
			"category" = available_project.category,
		))

	var/list/ability_paths = list()
	data["completed_projects"] = list()
	data["chargeable_abilities"] = list()
	for(var/datum/ai_project/completed_project as anything in completed_projects)
		data["completed_projects"] += list(list(
			"name" = completed_project.name,
			"display_name" = completed_project.get_display_name(),
			"description" = completed_project.description,
			"ram_required" = completed_project.ram_required,
			"running" = completed_project.running,
			"category" = completed_project.category,
			"can_be_run" = completed_project.can_be_run,
			"memory_priority" = completed_project.memory_priority,
			"stop_reason" = completed_project.stop_reason,
		))
		if(completed_project.ability_path && !(completed_project.ability_path in ability_paths))
			if(completed_project.ability_recharge_cost <= 0)
				continue
			ability_paths += completed_project.ability_path
			var/datum/action/innate/ai/the_ability = locate(completed_project.ability_path) in owner.actions
			if(the_ability)
				data["chargeable_abilities"] += list(list(
					"assigned_cpu" = cpu_usage[completed_project.name],
					"cost" = completed_project.ability_recharge_cost,
					"progress" = completed_project.ability_recharge_invested,
					"name" = the_ability.name,
					"project_name" = completed_project.name,
					"uses" = the_ability.uses,
					"max_uses" = the_ability.max_uses,
				))

	return data

/datum/ai_dashboard/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!is_interactable(user))
		return

	switch(action)
		if("save_profile")
			return save_work_profile(params["slot"], params["name"])
		if("apply_profile")
			return apply_work_profile(params["slot"])
		if("delete_profile")
			return delete_work_profile(params["slot"])
		if("show_laws")
			if(user != owner)
				return FALSE
			owner.open_neural_laws()
			return TRUE
		if("run_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!project || !run_project(project))
				to_chat(owner, span_warning("Не удалось запустить программу «[project?.get_display_name() || "неизвестный проект"]»."))
			else
				to_chat(owner, span_notice("Запуск программы «[project?.get_display_name() || "неизвестный проект"]»..."))
				. = TRUE
		if("stop_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(project)
				stop_project(project)
				enforce_program_memory()
				to_chat(owner, span_notice("Программа «[project?.get_display_name() || "неизвестный проект"]» остановлена."))
				. = TRUE
		if("set_memory_priority")
			return set_memory_priority(get_project_by_name(params["project_name"]), params["priority"])
		if("allocate_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"], TRUE)
			if(!project || !set_project_cpu(project, params["amount"]))
				to_chat(owner, span_warning("Не удалось выделить CPU проекту «[project?.get_display_name() || "неизвестный проект"]»: недостаточно свободного CPU или проект недоступен."))
			. = TRUE
		if("allocate_recharge_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!project || !has_completed_project(project.type))
				return
			var/datum/action/innate/ai/the_ability = locate(project.ability_path) in owner.actions
			if(!the_ability)
				return
			if(the_ability.uses >= the_ability.max_uses)
				to_chat(owner, span_warning("У этого действия уже максимальное число зарядов!"))
				return
			if(!project || !set_project_cpu(project, params["amount"]))
				to_chat(owner, span_warning("Не удалось выделить CPU проекту «[project?.get_display_name() || "неизвестный проект"]»: недостаточно свободного CPU или восстановление зарядов недоступно."))
			. = TRUE
		if("max_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"], TRUE)
			if(!project)
				to_chat(owner, span_warning("Не удалось выделить CPU проекту «[project?.get_display_name() || "неизвестный проект"]»: недостаточно свободного CPU или проект недоступен."))
				return

			var/total_cpu_used = 0
			for(var/project_name in cpu_usage)
				if(project_name == project.name)
					continue
				total_cpu_used += cpu_usage[project_name]

			var/amount_to_add = 1 - total_cpu_used
			if(!set_project_cpu(project, amount_to_add))
				to_chat(owner, span_warning("Не удалось выделить CPU проекту «[project?.get_display_name() || "неизвестный проект"]»: недостаточно свободного CPU или проект недоступен."))
			. = TRUE
		if("toggle_contribute_cpu")
			contribute_spare_cpu = !contribute_spare_cpu
			to_chat(owner, span_notice("Передача свободного CPU на исследования [contribute_spare_cpu ? "включена" : "отключена"]."))
			. = TRUE

/** Ищет проект по неизменяемому английскому ключу; only_available исключает завершённые проекты. */
/datum/ai_dashboard/proc/get_project_by_name(project_name, only_available = FALSE)
	RETURN_TYPE(/datum/ai_project)
	for(var/datum/ai_project/available_project as anything in available_projects)
		if(available_project.name == project_name)
			return available_project
	if(!only_available)
		for(var/datum/ai_project/available_project as anything in completed_projects)
			if(available_project.name == project_name)
				return available_project

	return FALSE

/** Назначает долю личного CPU, проверяя бюджет, зависимости и единственную ветку перезарядки. */
/datum/ai_dashboard/proc/set_project_cpu(datum/ai_project/project, amount)
	if(!project || !isnum(amount) || !project.can_research())
		return FALSE

	if(amount < 0)
		return FALSE

	if(has_completed_project(project.type))
		if(!project.ability_recharge_cost)
			return
		if(project != recharge_project(project.ability_path))
			return FALSE
		var/datum/action/innate/ai/the_ability = locate(project.ability_path) in owner.actions
		if(!the_ability)
			return
		if(the_ability.uses >= the_ability.max_uses)
			return

	var/total_cpu_used = 0
	for(var/project_name in cpu_usage)
		if(project_name == project.name)
			continue
		total_cpu_used += cpu_usage[project_name]


	if(amount > (1 - total_cpu_used) + 0.00001)
		return FALSE
	cpu_usage[project.name] = min(amount, max(0, 1 - total_cpu_used))
	return TRUE


/** Запускает проект с проверкой его состояния и требуемых ресурсов. */
/datum/ai_dashboard/proc/run_project(datum/ai_project/project)
	if(!project || !(project in completed_projects) || !project.can_be_run || project.running)
		return FALSE
	var/current_ram = owner.resource_pool().ram_assigned[owner] ? owner.resource_pool().ram_assigned[owner] : 0
	current_ram += free_ram

	var/total_ram_used = 0
	for(var/project_name in ram_usage)
		total_ram_used += ram_usage[project_name]

	if(current_ram - total_ram_used >= project.ram_required && project.can_run())
		project.run_project()
		project.stop_reason = null
		ram_usage[project.name] += project.ram_required
		return TRUE
	return FALSE

/** Останавливает программу, освобождает её RAM и сохраняет причину остановки. */
/datum/ai_dashboard/proc/stop_project(datum/ai_project/project, reason)
	if(!project?.running)
		return 0
	project.stop()
	project.stop_reason = reason
	if(ram_usage[project.name])
		ram_usage[project.name] -= project.ram_required
		return project.ram_required

	return FALSE

/** Задаёт приоритет сохранения программы от 1 до 3 при нехватке памяти. */
/datum/ai_dashboard/proc/set_memory_priority(datum/ai_project/project, priority)
	if(!project || !(project in completed_projects) || !project.can_be_run || !isnum(priority) || priority != round(priority) || priority < 1 || priority > 3)
		return FALSE
	project.memory_priority = priority
	return TRUE

/** Возвращает RAM работающих программ в ТБ. */
/datum/ai_dashboard/proc/used_program_ram()
	var/used = 0
	for(var/key in ram_usage)
		used += ram_usage[key]
	return used

/** Останавливает программы с меньшим приоритетом до соблюдения бюджета RAM. */
/datum/ai_dashboard/proc/enforce_program_memory()
	var/list/stopped = list()
	while(used_program_ram() > (owner.resource_pool().ram_assigned[owner] || 0) + free_ram)
		var/datum/ai_project/candidate
		for(var/datum/ai_project/project as anything in running_projects)
			if(!ram_usage[project.name])
				continue
			if(!candidate || project.memory_priority < candidate.memory_priority)
				candidate = project
		if(!candidate)
			break
		stop_project(candidate, "Недостаточно RAM")
		stopped += candidate.get_display_name()
		telemetry_log.record("Программа «[candidate.get_display_name()]» остановлена: недостаточно RAM. Приоритет сохранения: [candidate.memory_priority] из 3.", "warning")
	if(length(stopped))
		to_chat(owner, span_warning("Недостаточно RAM. Остановлены программы: [jointext(stopped, ", ")]. После освобождения памяти запустите их вручную."))
	return length(stopped)

/** Проверяет завершённое исследование по точному пути типа проекта. */
/datum/ai_dashboard/proc/has_completed_project(project_type)
	for(var/datum/ai_project/completed_project as anything in completed_projects)
		if(completed_project.type == project_type)
			return TRUE
	return FALSE


/** Переводит проект в завершённые, освобождает CPU исследования и применяет результат. */
/datum/ai_dashboard/proc/finish_project(datum/ai_project/project, notify_user = TRUE)
	LAZYREMOVE(available_projects, project)
	LAZYADD(completed_projects, project)
	cpu_usage[project.name] = 0
	project.finish()
	if(notify_user)
		to_chat(owner, span_notice("Проект «[project.get_display_name()]» завершён. [project.get_completion_message()]"))

/** Выбирает единственную завершённую ветку для перезарядки общей способности. */
/datum/ai_dashboard/proc/recharge_project(ability_path)
	for(var/datum/ai_project/project as anything in completed_projects)
		if(project.ability_path == ability_path && project.ability_recharge_cost > 0)
			return project

/** Добавляет один заряд до максимума и снимает все назначения общей способности при полном заряде. */
/datum/ai_dashboard/proc/recharge_ability(datum/ai_project/project, notify_user = TRUE)
	if(!project.ability_path)
		return
	var/datum/action/innate/ai/ability = locate(project.ability_path) in owner.actions
	if(!ability)
		return
	var/previous_uses = ability.uses
	if(ability.uses < ability.max_uses)
		ability.adjust_uses(1, TRUE)
	project.ability_recharge_invested = 0
	if(ability.uses >= ability.max_uses)
		for(var/datum/ai_project/shared_project as anything in completed_projects)
			if(shared_project.ability_path == project.ability_path)
				cpu_usage[shared_project.name] = 0
				shared_project.ability_recharge_invested = 0

	if(notify_user && ability.uses > previous_uses)
		to_chat(owner, span_notice("Заряды способности «[ability.name]» восстановлены."))

/** Проверяет наличие проекта в списке действительно работающих программ. */
/datum/ai_dashboard/proc/is_project_running(datum/ai_project/project)
	var/datum/ai_project/found_project = locate(project) in running_projects
	if(found_project)
		return found_project.running

/** Распределяет личный CPU между исследованиями, майнингом и перезарядкой за seconds_per_tick секунд. */
/datum/ai_dashboard/proc/tick(seconds_per_tick)
	var/current_cpu = owner.resource_pool().cpu_assigned[owner] ? owner.resource_pool().total_cpu * owner.resource_pool().cpu_assigned[owner] : 0
	enforce_program_memory()

	var/remaining_cpu = 1
	for(var/project_name in cpu_usage)
		remaining_cpu -= cpu_usage[project_name]

	if(remaining_cpu > 0 && contribute_spare_cpu)
		var/points = max(round(AI_RESEARCH_PER_CPU * (remaining_cpu * current_cpu) * owner.research_point_booster * seconds_per_tick, 0.1), 0)

		if(crypto_mining)
			points *= 0.5
			if(!istype(get_area(owner), /area/ai_debug_lab))
				var/datum/bank_account/department = SSeconomy.get_dep_account(ACCOUNT_CAR)
				department?.adjust_money(ai_mining_income_share(owner, owner.personal_mining_cpu()) * seconds_per_tick)

		ai_station_techweb(owner)?.adjust_multiple_points(list(TECHWEB_POINT_TYPE_AI = points))

	for(var/project_being_researched in cpu_usage)
		if(!cpu_usage[project_being_researched])
			continue
		if(is_project_running(get_project_by_name(project_being_researched)))
			continue
		var/used_cpu = cpu_usage[project_being_researched] * seconds_per_tick * current_cpu
		var/datum/ai_project/project = get_project_by_name(project_being_researched)
		if(!project)
			cpu_usage[project_being_researched] = 0
			continue
		if(has_completed_project(project.type))
			if(!project.ability_recharge_cost)
				continue
			var/datum/action/innate/ai/ability = locate(project.ability_path) in owner.actions
			if(!ability || ability.uses >= ability.max_uses || project != recharge_project(project.ability_path))
				cpu_usage[project.name] = 0
				continue
			project.ability_recharge_invested += used_cpu
			if(project.ability_recharge_invested >= project.ability_recharge_cost)
				owner.playsound_local(owner, 'sound/machines/ping.ogg', 50, 0)
				recharge_ability(project)
			continue
		project.research_progress += used_cpu
		if(project.research_progress >= project.research_cost)
			owner.playsound_local(owner, 'sound/machines/ping.ogg', 50, 0)
			finish_project(project)
