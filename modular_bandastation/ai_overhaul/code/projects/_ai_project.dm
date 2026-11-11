/** Личный проект с зависимостями, стоимостью исследования и необязательной работающей программой. */
/datum/ai_project
	/// Неизменяемый английский ключ проекта для команд и фрагментов перевода.
	var/name = "DEBUG"
	/// Описание эффекта проекта для игрока.
	var/description = "DEBUG"
	/// Вложенные в личное исследование CPU-секунды.
	var/research_progress = 0
	/// Категория каталога проектов из AI_PROJECT_*.
	var/category = AI_PROJECT_MISC
	/// Стоимость исследования в CPU-секундах.
	var/research_cost = 0
	/// Требуемая работающей программе RAM в ТБ.
	var/ram_required = 0
	/// Отмечает применённый эффект работающей программы.
	var/running = FALSE
	/// Приоритет сохранения от 1 до 3 при потере RAM.
	var/memory_priority = 2
	/// Последняя причина автоматической остановки для интерфейса.
	var/stop_reason
	/// Разрешает сохранять запуск проекта в личный профиль.
	var/profile_supported = TRUE
	/// Пути обязательных завершённых проектов.
	var/research_requirements

	/// Отличает запускаемую программу от пассивного исследования.
	var/can_be_run = TRUE
	/// Путь выдаваемой способности; общий для нескольких веток одной способности.
	var/ability_path = FALSE
	/// Работа в CPU-секундах на восстановление одного заряда.
	var/ability_recharge_cost = 0
	/// Накопленная работа текущей перезарядки в CPU-секундах.
	var/ability_recharge_invested = 0

	/// ИИ, которому принадлежит экземпляр проекта.
	var/mob/living/silicon/ai/ai
	/// Личная панель проектов владельца ИИ.
	var/datum/ai_dashboard/dashboard

/** Возвращает русское название проекта, сохраняя name неизменным ключом команд. */
/datum/ai_project/proc/get_display_name()
	return declent_ru_initial(name, override_backup = name)

/datum/ai_project/New(mob/living/silicon/ai/ai, datum/ai_dashboard/dashboard)
	. = ..()
	src.ai = ai
	src.dashboard = dashboard
	if(!ai || !dashboard)
		qdel(src)

/** Проверяет завершение всех обязательных исследований проекта. */
/datum/ai_project/proc/can_research()
	if(!research_requirements)
		return TRUE
	for(var/requirement in research_requirements)
		if(!dashboard.has_completed_project(requirement))
			return FALSE
	return TRUE

/** Запускает проект с проверкой его состояния и требуемых ресурсов. */
/datum/ai_project/proc/run_project(force_run = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!can_be_run)
		return FALSE
	if(!force_run)
		if(!can_run())
			return FALSE
	running = TRUE
	LAZYADD(dashboard.running_projects, src)
	return TRUE

/** Останавливает проект и исключает его из списка работающих программ. */
/datum/ai_project/proc/stop()
	SHOULD_CALL_PARENT(TRUE)
	running = FALSE
	LAZYREMOVE(dashboard.running_projects, src)
	return TRUE

/** Проверяет возможность запуска проекта; переопределения добавляют требования конкретной программы. */
/datum/ai_project/proc/can_run()
	SHOULD_CALL_PARENT(TRUE)
	return !running

/** Применяет результат завершённого исследования; базовый проект не добавляет эффекта. */
/datum/ai_project/proc/finish()
	return

/** Подсказывает, где использовать результат завершённого исследования. */
/datum/ai_project/proc/get_completion_message()
	if(can_be_run)
		return "Программа открыта. Запустите её во вкладке «Программы», выделив необходимую RAM."
	if(ability_path)
		var/datum/action/innate/ai/ability = locate(ability_path) in ai.actions
		return "Доступна способность «[ability.name]». Используйте её кнопку на панели способностей."
	return "Открыты следующие проекты этой ветки. Выберите их во вкладке «Исследования»."

/** Выдаёт способность один раз; возвращает новый action либо FALSE, если способность уже есть. */
/datum/ai_project/proc/add_ability(datum/action/innate/ai/ability)
	var/datum/action/innate/ai/has_ability = locate(ability) in ai.actions
	if(has_ability)
		return FALSE

	var/datum/action/action = new ability()
	action.Grant(ai)
	return action

/** Дополняет штатные способности верхним пределом перезаряжаемых зарядов. */
/datum/action/innate/ai
	/// Верхний предел зарядов способности при перезарядке.
	var/max_uses = 1

/datum/ai_project/Destroy()
	ai = null
	dashboard = null
	return ..()
