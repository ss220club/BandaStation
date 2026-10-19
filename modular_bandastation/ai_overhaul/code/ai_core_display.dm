GLOBAL_LIST_EMPTY(ai_core_displays)

/** Физический дисплей состояния установленного ИИ. */
/obj/machinery/status_display/ai_core
	name = "\improper AI core display"
	desc = "Большой экран, на котором ИИ может показывать выбранное изображение. Предназначен только для отображения: разместить ИИ внутри него нельзя."
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-empty"
	circuit = /obj/item/circuitboard/machine/ai_core_display
	density = TRUE

	/// Режим физического дисплея из штатных SD_*.
	var/mode = SD_BLANK
	/// Выбранное изображение эмоции ИИ.
	var/emotion = "Neutral"
	/// Слабая ссылка на ИИ, чьё состояние показано на дисплее.
	var/datum/weakref/displayed_ai_ref

/obj/machinery/status_display/ai_core/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.ai_core_displays.Add(src)
	set_ai(resolve_ai_icon_sync(emotion))

/obj/machinery/status_display/ai_core/Destroy()
	GLOB.ai_core_displays.Remove(src)
	return ..()

/obj/machinery/status_display/ai_core/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return
	. += "<b>Законы подключённых ИИ:</b>"
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		var/active_status = "(Ядро: [FOLLOW_LINK(user, AI.loc)], глаз: [FOLLOW_LINK(user, AI.eyeobj)])"
		if(!AI.mind && AI.deployed_shell)
			active_status = "(Управляет [FOLLOW_LINK(user, AI.deployed_shell)][AI.deployed_shell.declent_ru(ACCUSATIVE)])"
		else if(!AI.mind)
			active_status = "([span_warning("НЕАКТИВЕН")])"

		. += "<b>[AI] [active_status] подчиняется следующим законам: </b>"
		for(var/law in AI.laws.get_law_list(include_zeroth = TRUE))
			. += law

/obj/machinery/status_display/ai_core/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!default_unfasten_wrench(user, tool, 4 SECONDS))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/machinery/status_display/ai_core/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		displayed_ai_ref = WEAKREF(user)
		user.pick_icon()
		update()

/** Задаёт изображение на физическом дисплее ядра. */
/obj/machinery/status_display/ai_core/proc/set_ai(new_icon_state, new_icon)
	icon = initial(icon)
	if(new_icon)
		icon = new_icon
	if(new_icon_state)
		icon_state = new_icon_state

/obj/machinery/status_display/ai_core/process()
	if(machine_stat & (NOPOWER|BROKEN))
		cut_overlays()
		icon = initial(icon)
		icon_state = initial(icon_state)
		return PROCESS_KILL
	var/mob/living/silicon/ai/displayed_ai = displayed_ai_ref?.resolve()
	if(!displayed_ai)
		for(var/mob/living/silicon/ai/candidate as anything in GLOB.ai_list)
			if(candidate.decentralized)
				displayed_ai = candidate
				displayed_ai_ref = WEAKREF(candidate)
				break
	if(!displayed_ai)
		cut_overlays()
		icon_state = initial(icon_state)
		return
	icon = displayed_ai.icon
	icon_state = displayed_ai.icon_state
	copy_overlays(displayed_ai)
