#define OVERCLOCKING_DURATION (5 SECONDS)

/** Проверяет разгон одного физического процессора и возвращает результат без потери истории. */
/obj/machinery/computer/ai_overclocking
	name = "overclocking workstation"
	desc = "Станция разгона нейропроцессоров (Overclocking Workstation)."

	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK
	circuit = /obj/item/circuitboard/computer/ai_overclocking

	/// Физический процессор, установленный на станции разгона.
	var/obj/item/ai_cpu/inserted_cpu = null
	/// Отмечает выполняемую проверку устойчивости с действующим таймером.
	var/overclocking = FALSE

	/// Срок окончания текущей проверки устойчивости разгона.
	COOLDOWN_DECLARE(overclocking_timer)

/obj/machinery/computer/ai_overclocking/process()
	if(machine_stat & (BROKEN|NOPOWER|EMPED))
		if(inserted_cpu)
			if(overclocking)
				inserted_cpu.record_overclock_result(FALSE)
			overclocking = FALSE
			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
			inserted_cpu.forceMove(drop_location())
			inserted_cpu = null
		return

	if(overclocking && COOLDOWN_FINISHED(src, overclocking_timer))
		overclocking = FALSE
		if(!inserted_cpu)
			return
		var/overclock_result = inserted_cpu.valid_overclock()
		if(overclock_result == SUCCESSFUL_OVERCLOCK)
			say("Разгон стабилен.")
			inserted_cpu.record_overclock_result(TRUE)
			var/obj/item/ai_cpu/validated_cpu = inserted_cpu
			inserted_cpu = null
			validated_cpu.forceMove(drop_location())
		else
			say("Разгон нестабилен.")
			say("Возможная причина: [overclock_result]")
			inserted_cpu.record_overclock_result(FALSE)
			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)

/obj/machinery/computer/ai_overclocking/Destroy()
	if(inserted_cpu)
		inserted_cpu.speed = initial(inserted_cpu.speed)
		inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
	return ..()

/obj/machinery/computer/ai_overclocking/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/ai_cpu))
		return
	if(inserted_cpu)
		balloon_alert(user, "процессор уже установлен!")
		return ITEM_INTERACT_BLOCKING
	var/obj/item/ai_cpu/cpu = tool
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 50, FALSE)
	if(!user.transferItemToLoc(cpu, src))
		return ITEM_INTERACT_BLOCKING
	inserted_cpu = cpu
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/ai_overclocking/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiOverclocking", name)
		ui.open()

/obj/machinery/computer/ai_overclocking/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["has_cpu"] = !!inserted_cpu
	data["overclocking"] = overclocking

	if(inserted_cpu)
		data["speed"] = inserted_cpu.speed
		data["max_speed"] = inserted_cpu.max_speed
		data["power_multiplier"] = inserted_cpu.power_multiplier
		data["max_power_multiplier"] = inserted_cpu.max_power_multiplier
		data["power_usage"] = inserted_cpu.get_power_usage()
		var/time_left_percent = COOLDOWN_TIMELEFT(src, overclocking_timer)/OVERCLOCKING_DURATION
		data["overclock_progress"] = overclocking ? time_left_percent : FALSE
		data["last_values"] = inserted_cpu.last_overclocking_values


	return data


/obj/machinery/computer/ai_overclocking/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(overclocking && action != "stop_overclock")
		return FALSE
	switch(action)
		if("eject_cpu")
			if(!inserted_cpu)
				return
			playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 50, FALSE)
			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
			inserted_cpu.forceMove(drop_location())
			inserted_cpu = null
			. = TRUE
		if("set_speed")
			if(!inserted_cpu)
				return
			var/new_speed = params["new_speed"]
			if(!isnum(new_speed))
				return
			if(new_speed > inserted_cpu.max_speed)
				inserted_cpu.speed = inserted_cpu.max_speed
				return
			inserted_cpu.speed = clamp(new_speed, 0.1, inserted_cpu.max_speed)
			. = TRUE
		if("set_power")
			if(!inserted_cpu)
				return
			var/new_power = params["new_power"]
			if(!isnum(new_power))
				return
			if(new_power > inserted_cpu.max_power_multiplier)
				inserted_cpu.power_multiplier = inserted_cpu.max_power_multiplier
				return
			inserted_cpu.power_multiplier = clamp(new_power, 0.5, inserted_cpu.max_power_multiplier)
			. = TRUE

		if("test_overclock")
			if(!inserted_cpu)
				return
			overclocking = TRUE
			COOLDOWN_START(src, overclocking_timer, OVERCLOCKING_DURATION)
			. = TRUE

		if("stop_overclock")
			if(!inserted_cpu || !overclocking)
				return
			overclocking = FALSE

			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
			. = TRUE

/obj/machinery/computer/ai_overclocking/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != inserted_cpu)
		return
	inserted_cpu.speed = initial(inserted_cpu.speed)
	inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
	inserted_cpu = null
	overclocking = FALSE

#undef OVERCLOCKING_DURATION
