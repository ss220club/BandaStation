GLOBAL_LIST_EMPTY(server_cabinets)

/obj/machinery/ai/server_cabinet
	name = "Server Cabinet"
	desc = "Серверный шкаф с разъёмами bPCIe для установки серверных модулей."
	icon = 'modular_bandastation/ai_overhaul/icons/telecomms.dmi'
	icon_state = "expansion_bus"
	base_icon_state = "expansion_bus"

	circuit = /obj/item/circuitboard/machine/server_cabinet

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	active_power_usage = 0

	/// Физические серверные модули, установленные в шкаф.
	var/list/installed_racks

	/// Доступная вычислительная мощность в ТГц.
	var/total_cpu = 0
	/// Доля доступной номинальной мощности после теплового ограничения CPU.
	var/thermal_factor = 1
	/// Доступная оперативная память в ТБ.
	var/total_ram = 0

	/// Последнее рассчитанное потребление модулей в ваттах.
	var/cached_power_usage = 0

	/// Количество физических слотов серверных модулей.
	var/max_racks = 2

	/// Отмечает наличие ресурсов шкафа в пуле сети.
	var/hardware_synced = FALSE

	/// Прошлая готовность шкафа для обнаружения отказа и восстановления.
	var/was_valid_holder = FALSE
	/// Создаёт стартовый модуль при инициализации подготовленного шкафа.
	var/roundstart = FALSE
	/// Оставшийся запас шагов обработки до отказа после потери рабочих условий.
	var/valid_ticks = MAX_AI_EXPANSION_TICKS
	/// Множитель тепловыделения после установки деталей.
	var/heat_modifier = 1
	/// Множитель потребления после установки деталей.
	var/power_modifier = 1

/obj/machinery/ai/server_cabinet/Initialize(mapload)
	. = ..()
	roundstart = mapload
	installed_racks = list()
	GLOB.server_cabinets += src
	RefreshParts()
	update_appearance()
	register_context()

/obj/machinery/ai/server_cabinet/Destroy(force)
	eject_decryption_disk()
	installed_racks = list()
	GLOB.server_cabinets -= src
	GLOB.ai_os.update_hardware()
	return ..()

/obj/machinery/ai/server_cabinet/RefreshParts()
	. = ..()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		new_power_mod -= (capacitor.tier - 1) / 40

	for(var/datum/stock_part/matter_bin/bin in component_parts)
		new_heat_mod -= (bin.tier - 1) / 30

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod

	idle_power_usage = initial(idle_power_usage) * power_modifier

/obj/machinery/ai/server_cabinet/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Оборудование не работает. Причина: [holder_status]")
	if(!valid_ticks)
		. += span_notice("На небольшом экране написано: «ОТКЛЮЧЕНО».")
	. += span_notice("Установлено серверных модулей: [length(installed_racks)] из [max_racks].")
	. += span_notice("Множитель потребления мощности: [span_bold("[power_modifier * 100]%")]")
	. += span_notice("Множитель тепловыделения: [span_bold("[heat_modifier * 100]%")]")
	. += span_notice("CPU доступно: [round(effective_cpu(), 0.01)] из [total_cpu] ТГц. [thermal_status()]")

	for(var/obj/item/server_rack/rack as anything in installed_racks)
		. += span_notice("Установлен серверный модуль с производительностью [rack.get_cpu()] ТГц и памятью [rack.contained_ram] ТБ. Потребляет [rack.get_power_usage()] Вт.")
	. += span_notice("Используйте лом, чтобы извлечь все установленные серверные модули.")

/obj/machinery/ai/server_cabinet/process(seconds_per_tick)
	var/was_online = valid_ticks > 0
	var/working = valid_holder()
	valid_ticks = clamp(valid_ticks + (working ? 1 : -1) * seconds_per_tick / 2, 0, MAX_AI_EXPANSION_TICKS)
	var/frequency_changed = update_thermal_state(seconds_per_tick)
	if(was_online != (valid_ticks > 0) || !hardware_synced || frequency_changed)
		GLOB.ai_os.update_hardware()
		hardware_synced = TRUE
	if(was_valid_holder != working || was_online != (valid_ticks > 0))
		update_appearance()
	was_valid_holder = working

/** Плавно меняет множитель CPU по температуре и seconds_per_tick, разделяя пороги перегрева и восстановления. */
/obj/machinery/ai/server_cabinet/proc/update_thermal_state(seconds_per_tick)
	if(!isnum(seconds_per_tick) || seconds_per_tick <= 0 || !valid_holder(ignore_temperature = TRUE))
		return FALSE
	var/previous = thermal_factor
	var/start = resource_pool().get_temp_limit() - AI_CPU_THROTTLE_MARGIN
	var/target = clamp(1 - (core_temp - start) / AI_CPU_THROTTLE_MARGIN * (1 - AI_CPU_MIN_THERMAL_FACTOR), AI_CPU_MIN_THERMAL_FACTOR, 1)
	if(target < thermal_factor)
		thermal_factor = max(target, thermal_factor - AI_CPU_THROTTLE_RATE * seconds_per_tick)
	else if(core_temp <= start - AI_CPU_RECOVERY_MARGIN)
		thermal_factor = min(1, thermal_factor + AI_CPU_RECOVERY_RATE * seconds_per_tick)
	return previous != thermal_factor

/** Возвращает фактическую мощность шкафа в ТГц с учётом теплового ограничения. */
/obj/machinery/ai/server_cabinet/proc/effective_cpu()
	return valid_ticks > 0 ? total_cpu * thermal_factor : 0

/** Возвращает текущее состояние теплового ограничения сервера для диагностики. */
/obj/machinery/ai/server_cabinet/proc/thermal_status()
	if(valid_ticks <= 0)
		return "Шкаф отключён"
	if(thermal_factor >= 1)
		return "Штатная частота"
	if(core_temp <= resource_pool().get_temp_limit() - AI_CPU_THROTTLE_MARGIN - AI_CPU_RECOVERY_MARGIN)
		return "Восстановление частоты после охлаждения"
	return "Тепловое ограничение частоты; требуется охлаждение"

/** Суммирует текущее потребление установленных модулей в ваттах. */
/obj/machinery/ai/server_cabinet/proc/current_module_power()
	var/ram_power = total_ram * AI_POWER_PER_CARD
	var/cpu_power = max(0, cached_power_usage - ram_power)
	return (ram_power + cpu_power * (0.2 + 0.8 * thermal_factor)) * power_modifier

/obj/machinery/ai/server_cabinet/process_atmos()
	. = ..()
	if(!.)
		return FALSE
	if(valid_ticks <= 0 || !valid_holder(ignore_temperature = TRUE))
		return FALSE
	var/total_usage = current_module_power()
	use_energy(total_usage)
	var/temperature_increase = (total_usage / AI_HEATSINK_CAPACITY)* heat_modifier
	core_temp += temperature_increase * AI_TEMPERATURE_MULTIPLIER
	return TRUE

/obj/machinery/ai/server_cabinet/update_overlays()
	. = ..()
	if(length(installed_racks) > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top")
	if(length(installed_racks) > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom")

	if(machine_stat & (BROKEN|NOPOWER|EMPED))
		return .

	. += mutable_appearance(icon, "[base_icon_state]_on")
	if(!valid_ticks)
		return
	if(length(installed_racks) > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top_on")
	if(length(installed_racks) > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom_on")

/obj/machinery/ai/server_cabinet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/disk/ai_research_archive))
		return insert_encrypted_disk(user, tool)
	if(istype(tool, /obj/item/server_rack))
		return install_rack(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/machinery/ai/server_cabinet/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(length(installed_racks))
		balloon_alert(user, "извлеките модули!")
		return .
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/server_cabinet/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(remove_racks(user))
		tool.play_tool_sound(src, 50)
		return ITEM_INTERACT_SUCCESS
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/server_cabinet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Закрыть" : "Открыть"] панель"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/server_rack))
		context[SCREENTIP_CONTEXT_LMB] = "Вставить серверный модуль"
		return CONTEXTUAL_SCREENTIP_SET
	if(panel_open && (held_item.tool_behaviour == TOOL_CROWBAR))
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET

/** Устанавливает физический модуль в свободный слот и обновляет ресурсы шкафа. */
/obj/machinery/ai/server_cabinet/proc/install_rack(mob/living/user, obj/item/server_rack/new_rack)
	if(QDELETED(new_rack) || new_rack.panel_open || (!length(new_rack.contained_cpus) && !new_rack.contained_ram))
		if(user)
			balloon_alert(user, "нужен закрытый модуль с деталями!")
		return FALSE
	if(length(installed_racks) >= max_racks)
		if(user)
			balloon_alert(user, "не помещается!")
		return FALSE
	if(user)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		balloon_alert(user, "модуль установлен")
	if(user && !user.transferItemToLoc(new_rack, src))
		return FALSE
	if(!user)
		new_rack.forceMove(src)
	LAZYADD(installed_racks, new_rack)
	recalculate_racks()
	return TRUE

/** Пересчитывает ресурсы по фактическому содержимому всех установленных модулей. */
/obj/machinery/ai/server_cabinet/proc/recalculate_racks()
	total_cpu = 0
	total_ram = 0
	cached_power_usage = 0
	for(var/obj/item/server_rack/rack as anything in installed_racks)
		total_cpu += rack.get_cpu()
		total_ram += rack.contained_ram
		cached_power_usage += rack.get_power_usage()
	GLOB.ai_os.update_hardware()
	use_power = length(installed_racks) ? ACTIVE_POWER_USE : IDLE_POWER_USE
	update_appearance()

/** Извлекает установленные модули с пересчётом CPU, RAM и потребления. */
/obj/machinery/ai/server_cabinet/proc/remove_racks(mob/living/user)
	if(!length(installed_racks))
		return FALSE
	var/turf/turf_dropped = drop_location()
	for(var/obj/item/server_rack/rack as anything in installed_racks.Copy())
		rack.forceMove(turf_dropped)
		LAZYREMOVE(installed_racks, rack)
	recalculate_racks()
	if(user)
		balloon_alert(user, "модули извлечены")
	return TRUE

/obj/machinery/ai/server_cabinet/prefilled/Initialize(mapload)
	. = ..()
	install_rack(new_rack = new /obj/item/server_rack/roundstart(src))

/obj/machinery/ai/server_cabinet/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == decryption_disk)
		decryption_disk = null
		decryption_enabled = FALSE
	if(!(gone in installed_racks))
		return
	var/obj/item/server_rack/rack = gone
	installed_racks -= rack
	recalculate_racks()
