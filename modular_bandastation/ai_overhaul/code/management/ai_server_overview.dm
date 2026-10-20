/** Показывает доступные узлы и ограниченную диагностику нейросети. */
/obj/machinery/computer/ai_server_console
	name = "\improper AI server overview console"
	desc = "Консоль наблюдения за серверами нейронной сети ИИ."
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	circuit = /obj/item/circuitboard/computer/ai_server_overview

/obj/machinery/computer/ai_server_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiServerConsole", name)
		ui.open()

/obj/machinery/computer/ai_server_console/ui_data(mob/user)
	SSai_networks.rebuild()
	var/list/servers = list()
	for(var/obj/machinery/ai/server_cabinet/cabinet as anything in GLOB.server_cabinets)
		if(!ai_same_debug_environment(src, cabinet))
			continue
		var/temperature_limit = cabinet.resource_pool().get_temp_limit()
		servers += list(list(
			"ref" = REF(cabinet),
			"network" = cabinet.ai_network?.name || "Отключено",
			"temperature_limit" = temperature_limit,
			"throttle_temperature" = temperature_limit - AI_CPU_THROTTLE_MARGIN,
			"recovery_temperature" = temperature_limit - AI_CPU_THROTTLE_MARGIN - AI_CPU_RECOVERY_MARGIN,
			"area" = "[ai_localized_area(cabinet)]",
			"status" = cabinet.get_holder_status() || "В сети",
			"working" = cabinet.valid_holder(),
			"total_cpu" = cabinet.total_cpu,
			"effective_cpu" = cabinet.effective_cpu(),
			"thermal_status" = cabinet.thermal_status(),
			"module_power" = cabinet.current_module_power(),
			"ram" = cabinet.total_ram,
			"card_capacity" = "[length(cabinet.installed_racks)]/[cabinet.max_racks]",
			"temp" = cabinet.core_temp,
		))
	var/list/cores = list()
	for(var/obj/machinery/ai/data_core/core as anything in GLOB.data_cores)
		if(!ai_same_debug_environment(src, core))
			continue
		cores += list(list(
			"ref" = REF(core),
			"network" = core.ai_network?.name || "Отключено",
			"temperature_limit" = core.resource_pool().get_temp_limit(),
			"area" = "[ai_localized_area(core)]",
			"status" = core.get_holder_status() || "В сети",
			"working" = core.can_transfer_ai(),
			"temp" = core.core_temp,
			"primary" = core == GLOB.primary_data_core,
		))
	var/list/bridges = list()
	var/area/local_area = get_area(src)
	var/list/local_cables = ai_cables_on_tile(get_turf(src))
	var/obj/structure/ai_ethernet/local_cable = length(local_cables) == 1 ? local_cables[1] : null
	var/datum/ai_subnet/local_subnet = local_cable?.ai_subnet
	for(var/obj/machinery/ai/network_bridge/bridge as anything in GLOB.ai_network_bridges)
		if(!ai_same_debug_environment(src, bridge))
			continue
		var/responding = !bridge.endpoint_status()
		var/local = bridge.Adjacent(src) || (!QDELETED(local_subnet) && bridge.ai_subnet == local_subnet)
		if(local_area && !istype(local_area, /area/space) && bridge.z == z && get_area(bridge) == local_area)
			local = TRUE
		bridges += list(list(
			"ref" = REF(bridge),
			"area" = responding || local ? "[ai_localized_area(bridge)]" : "Местоположение неизвестно: нет ответа",
			"network" = bridge.ai_network?.name || "Отключено",
			"status" = responding || local ? (bridge.link_status() || "Связь установлена") : "Нет ответа; причина неизвестна",
			"working" = bridge.link_available(),
			"remote_area" = responding ? bridge.remote_area() : "Нет ответа",
		))
	return list("servers" = servers, "cores" = cores, "bridges" = bridges, "temperature_limit" = GLOB.ai_os.get_temp_limit())
