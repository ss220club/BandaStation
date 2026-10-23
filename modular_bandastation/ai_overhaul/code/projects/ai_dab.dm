/** Возвращает доступные рабочие ядра своей сети для дистанционных эффектов проектов. */
/mob/living/silicon/ai/proc/controllable_data_cores()
	var/list/cores = list()
	SSai_networks.rebuild()
	if(control_disabled || stat == DEAD || !istype(loc, /obj/machinery/ai/data_core))
		return cores
	var/obj/machinery/ai/data_core/host = loc
	if(!host.ai_network || (host.valid_ticks <= 0 || !host.valid_holder()) || (host.machine_stat & (BROKEN | EMPED)))
		return cores
	for(var/obj/machinery/ai/data_core/core in host.ai_network.nodes)
		if(core.valid_ticks > 0 && core.valid_holder())
			cores += core
	return cores

/** Открывает косметическую анимацию доступных ядер своей сети. */
/datum/ai_project/dab
	name = "D.A.B"
	description = "Заставляет подключённые ядра ИИ изображать человеческий жест «дэб». Только внешний эффект."
	research_cost = 750
	ram_required = 0
	profile_supported = FALSE
	category = AI_PROJECT_MISC

/datum/ai_project/dab/can_run()
	return ..() && length(ai.controllable_data_cores())

/datum/ai_project/dab/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/ai/data_core/core as anything in ai.controllable_data_cores())
		core.neural_dab()
	stop()

/obj/machinery/ai/data_core
	/// Срок окончания косметической анимации в отсчётах world.time.
	var/neural_dab_until = 0

/** Запускает короткую косметическую анимацию физического ядра. */
/obj/machinery/ai/data_core/proc/neural_dab()
	if(world.time < neural_dab_until)
		return
	var/duration = rand(3, 7)
	neural_dab_until = world.time + 2 * duration + 1
	var/matrix/original = matrix(transform)
	var/matrix/tilted = matrix(original)
	tilted.Turn(rand(35, 55))
	animate(src, transform = tilted, time = duration)
	animate(transform = original, time = duration)
