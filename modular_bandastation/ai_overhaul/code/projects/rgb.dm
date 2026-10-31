/** Управляет косметическим освещением доступных ядер с восстановлением прежнего света. */
/datum/ai_project/rgb
	name = "RGB Lighting"
	description = "Декоративная цветная подсветка доступных ядер вашей сети. Отключённые от сети ядра возвращаются к обычному освещению."
	research_cost = 500
	ram_required = 0
	category = AI_PROJECT_MISC
	/// Ядра, на которых этот проект установил RGB-освещение.
	var/list/lit_cores = list()

/datum/ai_project/rgb/can_run()
	return ..() && length(ai.controllable_data_cores())

/datum/ai_project/rgb/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return
	process()
	START_PROCESSING(SSprocessing, src)

/datum/ai_project/rgb/stop()
	STOP_PROCESSING(SSprocessing, src)
	clear_lighting()
	return ..()

/datum/ai_project/rgb/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	clear_lighting()
	return ..()

/datum/ai_project/rgb/process(seconds_per_tick)
	var/list/reachable = list()
	if(running && !QDELETED(ai))
		reachable = ai.controllable_data_cores()
	for(var/obj/machinery/ai/data_core/core as anything in lit_cores - reachable)
		if(!QDELETED(core))
			core.release_rgb(src)
	for(var/obj/machinery/ai/data_core/core as anything in reachable - lit_cores)
		core.claim_rgb(src)
	lit_cores = reachable

/** Снимает только освещение, установленное этим RGB-проектом. */
/datum/ai_project/rgb/proc/clear_lighting()
	for(var/obj/machinery/ai/data_core/core as anything in lit_cores)
		if(!QDELETED(core))
			core.release_rgb(src)
	lit_cores.Cut()

/obj/machinery/ai/data_core
	/// Активные источники RGB-освещения этого ядра.
	var/list/rgb_projects = list()
	/// Параметры света до первого RGB-проекта для последующего восстановления.
	var/list/pre_rgb_light

/** Регистрирует источник RGB-освещения и запоминает свет ядра перед первым проектом. */
/obj/machinery/ai/data_core/proc/claim_rgb(datum/ai_project/rgb/project)
	if(project in rgb_projects)
		return
	if(!length(rgb_projects))
		pre_rgb_light = list(light_range, light_power, light_color)
		set_light(2, 1, pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PURPLE))
	rgb_projects += project

/** Снимает источник RGB и восстанавливает прежний свет после последнего проекта. */
/obj/machinery/ai/data_core/proc/release_rgb(datum/ai_project/rgb/project)
	if(!(project in rgb_projects))
		return
	rgb_projects -= project
	if(!length(rgb_projects))
		set_light(pre_rgb_light[1], pre_rgb_light[2], pre_rgb_light[3])
		pre_rgb_light = null
