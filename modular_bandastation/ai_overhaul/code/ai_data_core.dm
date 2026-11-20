GLOBAL_LIST_EMPTY(data_cores)
GLOBAL_VAR_INIT(primary_data_core, null)

#define CELL_POWERUSE_MULTIPLIER 0.025

/** Размещает исходного ИИ, обеспечивает питание и участвует в аварийном переносе. */
/obj/machinery/ai/data_core
	name = "AI data core"
	desc = "Сложная компьютерная система, способная почти мгновенно воспроизводить нейронные функции органического существа."
	icon = 'modular_bandastation/ai_overhaul/icons/ai_core.dmi'
	icon_state = "core-offline"
	base_icon_state = "core"

	circuit = /obj/item/circuitboard/machine/ai_data_core
	active_power_usage = AI_DATA_CORE_POWER_USAGE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 10
	use_power = IDLE_POWER_USE
	critical_machine = TRUE

	/// Отключает выделение тепла ядром для специальных вариантов и тестов.
	var/disableheat = FALSE
	/// Отмечает основное стартовое ядро для предпочтительного размещения.
	var/primary = FALSE
	/// Оставшийся запас шагов обработки до отказа после потери рабочих условий.
	var/valid_ticks = MAX_AI_DATA_CORE_TICKS
	COOLDOWN_DECLARE(warning_cooldown)

	/// Множитель тепловыделения после установки деталей.
	var/heat_modifier = 1
	/// Множитель потребления после установки деталей.
	var/power_modifier = 1
	/// Физическая резервная батарея ядра.
	var/obj/item/stock_parts/power_store/cell/integrated_battery

/obj/machinery/ai/data_core/Initialize(mapload)
	. = ..()
	GLOB.data_cores += src
	if(primary && !GLOB.primary_data_core)
		GLOB.primary_data_core = src
	if(!integrated_battery)
		integrated_battery = locate(/obj/item/stock_parts/power_store/cell) in component_parts
		if(integrated_battery)
			component_parts -= integrated_battery
			integrated_battery.forceMove(src)
	RefreshParts()
	update_appearance()
	register_context()

/obj/machinery/ai/data_core/Destroy(force)
	if(neural_backup)
		neural_backup.forceMove(drop_location())
	GLOB.data_cores -= src
	if(GLOB.primary_data_core == src)
		GLOB.primary_data_core = null

	for(var/mob/living/silicon/ai/AI in contents)
		if(!AI.relocate())
			AI.forceMove(get_turf(src))

	QDEL_NULL(integrated_battery)

	return ..()

/obj/machinery/ai/data_core/on_deconstruction()
	. = ..()
	integrated_battery?.forceMove(drop_location())

/obj/machinery/ai/data_core/JoinPlayerHere(mob/matter_bin, buckle)
	return

/obj/machinery/ai/data_core/get_cell()
	return integrated_battery

/obj/machinery/ai/data_core/RefreshParts()
	. = ..()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		new_power_mod -= (capacitor.tier - 1) / 50

	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		new_heat_mod -= (matter_bin.tier - 1) / 15

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod
	active_power_usage = (AI_DATA_CORE_POWER_USAGE * power_modifier)

/obj/machinery/ai/data_core/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/stock_parts/power_store/cell))
		integrated_battery = arrived

/obj/machinery/ai/data_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == neural_backup)
		neural_backup.recovery_enabled = FALSE
		neural_backup = null
	if(gone == integrated_battery)
		integrated_battery = null

/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Оборудование не работает. Причина: [holder_status]")
	. += span_notice("Крепёжные <b>болты</b> [anchored ? "затянуты" : "ослаблены"].")

	if(isobserver(user))
		. += "Температура ядра: <b>[core_temp] К</b>"

	. += "<b>На мониторе перечислены следующие ИИ:</b>"
	for(var/mob/living/silicon/ai/AI in contents)
		if(!isobserver(user))
			. += "<b>[AI.name]</b>"
		else
			. += "<b>[AI] (ядро: [FOLLOW_LINK(user, AI.loc)], глаз: [FOLLOW_LINK(user, AI.eyeobj)])</b>"
		. += AI.examine(user)

/obj/machinery/ai/data_core/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Закрыть" : "Открыть"] панель"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stock_parts/power_store/cell))
		context[SCREENTIP_CONTEXT_LMB] = (integrated_battery) ? "Заменить батареи" : "Добавить батареи"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = (anchored ? "Открепить" : "Закрепить на полу")
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/ai/data_core/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/ai_neural_backup))
		return insert_neural_backup(user, tool)
	if(!istype(tool, /obj/item/stock_parts/power_store/cell))
		return NONE
	if(!panel_open)
		balloon_alert(user, "панель закрыта!")
		return ITEM_INTERACT_BLOCKING
	if(integrated_battery)
		user.put_in_hands(integrated_battery)
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "батареи заменены")
	RefreshParts()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	tool.play_tool_sound(src, 50)
	balloon_alert_to_viewers("работа с винтами...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return .
	if(default_deconstruction_screwdriver(user, "[base_icon_state]-open", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!panel_open)
		balloon_alert(user, "панель закрыта!")
		return .
	balloon_alert_to_viewers("разборка...")
	if(!tool.use_tool(src, user, 4 SECONDS))
		return .
	default_deconstruction_crowbar(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	balloon_alert_to_viewers("[!anchored ? "затягивание" : "ослабление"] болтов...")
	if(!default_unfasten_wrench(user, tool, 4 SECONDS))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/attack_ai(mob/living/silicon/ai/user)
	SSai_networks.rebuild()
	if(user.ai_network != ai_network)
		balloon_alert(user, "другая нейронная сеть!")
		return
	if(user.control_disabled || !user.in_network_core())
		return
	if((user in src))
		return ..()
	if(!can_accept_shunt(user))
		balloon_alert(user, "ядро недоступно!")
		return ..()
	if(user.nuking)
		var/confirmation_alert = tgui_alert(user, "Переход в другое ядро отключит устройство судного дня. Продолжить?", "Перейти в другое ядро?", list("Перейти", "Отмена"))
		if(confirmation_alert != "Перейти")
			return
	if(!can_accept_shunt(user))
		return
	if(do_after(user, 4 SECONDS, src, interaction_key = DOAFTER_SOURCE_AI_SHUNTING) && can_accept_shunt(user) && transfer_AI(user))
		playsound(src, 'sound/machines/ping.ogg', 25, FALSE, 2)
		balloon_alert(user, "переход выполнен")

/** Проверяет готовность ядра и общую сеть живого ИИ перед переходом и после ожидания. */
/obj/machinery/ai/data_core/proc/can_accept_shunt(mob/living/silicon/ai/ai)
	SSai_networks.rebuild()
	return !QDELETED(src) && !QDELETED(ai) && !ai.incapacitated && !ai.control_disabled && ai.in_network_core() && ai.loc != src && ai.ai_network && ai.ai_network == ai_network && can_transfer_ai()

/obj/machinery/ai/data_core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	for(var/mob/living/silicon/ai/AI in contents)
		AI.disconnect_shell()

/** Проверяет жизнеспособность ядра с учётом его резервной батареи. */
/obj/machinery/ai/data_core/proc/valid_data_core(mob/living/silicon/ai/user)
	if(!ai_supported_location(src))
		return FALSE
	if(valid_ticks > 0)
		return TRUE
	return FALSE

/obj/machinery/ai/data_core/process(seconds_per_tick)
	var/was_online = valid_ticks > 0 && has_power()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_DATA_CORE_TICKS)
	var/working = valid_holder()
	if(working)
		valid_ticks = min(MAX_AI_DATA_CORE_TICKS, valid_ticks + seconds_per_tick / 2)
		update_use_power(ACTIVE_POWER_USE)
		if(machine_stat & NOPOWER)
			integrated_battery.use(active_power_usage * CELL_POWERUSE_MULTIPLIER * seconds_per_tick, force = TRUE)
	else
		valid_ticks = max(0, valid_ticks - seconds_per_tick / 2)
		if(valid_ticks <= 0)
			update_use_power(IDLE_POWER_USE)
	if(was_online != (valid_ticks > 0 && has_power()))
		update_appearance()
	if(working)
		return

	if(valid_ticks > MAX_AI_DATA_CORE_TICKS - 3 || !COOLDOWN_FINISHED(src, warning_cooldown))
		return
	COOLDOWN_START(src, warning_cooldown, AI_DATA_CORE_WARNING_COOLDOWN)
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(!can_report_to(AI))
			continue
		if(!AI.mind && AI.deployed_shell?.mind)
			to_chat(AI.deployed_shell, span_userdanger("Ядро ИИ в [ai_localized_area(src, PREPOSITIONAL)] на грани отказа! Для предотвращения отключения требуется немедленное вмешательство."))
		else
			to_chat(AI, span_userdanger("Ядро ИИ в [ai_localized_area(src, PREPOSITIONAL)] на грани отказа! Для предотвращения отключения требуется немедленное вмешательство."))
		AI.playsound_local(AI, 'sound/machines/engine_alert/engine_alert2.ogg', 30)

/** Проверяет, может ли receiver получить показания этого ядра по своей рабочей сети. */
/obj/machinery/ai/data_core/proc/can_report_to(mob/living/silicon/ai/receiver)
	if(!ai_network || receiver.ai_network != ai_network || receiver.control_disabled || receiver.stat != STABLE)
		return FALSE
	if(!istype(receiver.loc, /obj/machinery/ai/data_core))
		return FALSE
	var/obj/machinery/ai/data_core/receiver_host = receiver.loc
	if(!receiver_host.has_power() || (receiver_host.machine_stat & (BROKEN | EMPED)))
		return FALSE
	return has_power() && !(machine_stat & (BROKEN | EMPED))

/obj/machinery/ai/data_core/process_atmos(seconds_per_tick)
	. = ..()
	if(!.)
		return FALSE

	var/ai_creating_heat
	for(var/mob/living/silicon/ai/ai_contents in contents)
		ai_creating_heat = !ai_contents.technically_unpowered
		break

	if((machine_stat & (BROKEN|EMPED)) || !has_power() || disableheat || !ai_creating_heat)
		return FALSE

	var/temp_active_usage = (machine_stat & NOPOWER) ? idle_power_usage * CELL_POWERUSE_MULTIPLIER : active_power_usage * CELL_POWERUSE_MULTIPLIER
	var/temperature_increase = (temp_active_usage / AI_HEATSINK_CAPACITY) * heat_modifier * seconds_per_tick
	core_temp += temperature_increase * AI_TEMPERATURE_MULTIPLIER
	return TRUE

/obj/machinery/ai/data_core/has_power()
	if(!(machine_stat & NOPOWER))
		return TRUE
	return integrated_battery?.charge >= active_power_usage * CELL_POWERUSE_MULTIPLIER

/** Проверяет готовность ядра принять ИИ; не выполняет сам перенос. */
/obj/machinery/ai/data_core/proc/can_transfer_ai()
	if(machine_stat & (BROKEN|EMPED) || !has_power())
		return FALSE
	if(!valid_data_core() || !valid_holder())
		return FALSE
	return TRUE

/** Перемещает исходного ИИ в готовое ядро и обновляет сеть; from_recovery разрешает восстановление с аварийного носителя. */
/obj/machinery/ai/data_core/proc/transfer_AI(mob/living/silicon/ai/AI, from_recovery = FALSE)
	SSai_networks.rebuild()
	if(istype(AI?.loc, /obj/item/ai_neural_backup) && !from_recovery)
		return FALSE
	if(QDELETED(AI) || !can_transfer_ai())
		return FALSE
	if(AI.nuking)
		AI.ShutOffDoomsdayDevice()
	AI.forceMove(src)
	if(AI.ai_network != ai_network)
		AI.release_neural_resources()
		AI.ai_network = ai_network
	AI.setup_decentralized_ai()
	AI.last_used_data_core = src
	AI.is_dying = FALSE
	AI.ai_restore_power()
	AI.set_control_disabled(FALSE)
	AI.radio_enabled = TRUE
	resource_pool().refresh_cooling()
	if(AI.eyeobj)
		AI.eyeobj.setLoc(get_turf(src))
	return TRUE

/obj/machinery/ai/data_core/update_icon_state()
	. = ..()
	if((machine_stat & (BROKEN|EMPED)) || !has_power() || valid_ticks <= 0)
		icon_state = "[base_icon_state]-offline"
	else
		icon_state = base_icon_state


/** Предпочтительное стартовое ядро для размещения ИИ. */
/obj/machinery/ai/data_core/primary
	name = "primary AI data core"
	desc = "Сложная компьютерная система, способная почти мгновенно воспроизводить нейронные функции человека. На выцветшей записке написано: «Основное ядро ИИ»."
	primary = TRUE
	circuit = /obj/item/circuitboard/machine/ai_data_core/primary

#undef CELL_POWERUSE_MULTIPLIER
