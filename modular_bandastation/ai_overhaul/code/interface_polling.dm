/obj/machinery/power/apc/attack_ai(mob/user)
	if(isAI(user))
		var/mob/living/silicon/ai/ai = user
		if(ai.decentralized && istype(ai.loc, /obj/machinery/ai/data_core) && !ai.poll_neural_interface(src))
			return FALSE
	return ..()

/obj/machinery/airalarm/attack_ai(mob/user)
	if(isAI(user))
		var/mob/living/silicon/ai/ai = user
		if(ai.decentralized && istype(ai.loc, /obj/machinery/ai/data_core) && !ai.poll_neural_interface(src))
			return FALSE
	return ..()

/** Проверяет доступ к target через рабочее ядро и координатор нужной зоны. */
/mob/living/silicon/ai/proc/can_poll_neural_interface(obj/machinery/target)
	if(QDELETED(src) || QDELETED(target) || control_disabled || incapacitated || stat == DEAD)
		return FALSE
	if(!istype(loc, /obj/machinery/ai/data_core))
		return FALSE
	var/obj/machinery/ai/data_core/host = loc
	if(!host.has_power() || (host.machine_stat & (BROKEN | EMPED)))
		return FALSE
	if(!can_see(target) || !target.can_interact(src) || (target.machine_stat & EMPED))
		return FALSE
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = target
		return apc.can_use(src)
	if(istype(target, /obj/machinery/airalarm))
		var/obj/machinery/airalarm/alarm = target
		return !alarm.aidisabled && !alarm.shorted && alarm.buildstage == AIR_ALARM_BUILD_COMPLETE
	return FALSE

/** Выполняет ускоренный опрос устройства, повторно проверяя условия после ожидания. */
/mob/living/silicon/ai/proc/poll_neural_interface(obj/machinery/target)
	if(!can_poll_neural_interface(target))
		return FALSE
	if(find_subcontroller(get_area(target)))
		return TRUE
	if(LAZYACCESS(do_afters, "neural_interface_poll"))
		return FALSE
	to_chat(src, span_notice("Нет связи с разрешённым координатором ИИ. Подключение к [target.declent_ru(DATIVE)] (1 секунда)..."))
	var/completed = do_after(src, 1 SECONDS, target,
		timed_action_flags = IGNORE_HELD_ITEM | IGNORE_SLOWDOWNS,
		extra_checks = CALLBACK(src, PROC_REF(can_poll_neural_interface), target),
		interaction_key = "neural_interface_poll", cog_icon = null)
	return completed && can_poll_neural_interface(target)
