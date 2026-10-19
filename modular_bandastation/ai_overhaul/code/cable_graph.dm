/** Возвращает оптоволоконные кабели на клетке, не объединяя независимые пересечения. */
/proc/ai_cables_on_tile(turf/tile)
	var/list/result = list()
	if(!tile)
		return result
	for(var/obj/structure/ai_ethernet/cable in tile)
		if(!QDELETED(cable))
			result += cable
	return result

/** Проверяет маску разъёмов и конфликты кабелей на клетке; ignore исключает заменяемый сегмент. */
/proc/ai_can_place_cable(turf/tile, ports, obj/structure/ai_ethernet/ignore)
	if(!tile || !isnum(ports) || ports != round(ports) || ports < 1 || ports > AI_CABLE_ALL_PORTS)
		return FALSE
	for(var/obj/structure/ai_ethernet/cable as anything in ai_cables_on_tile(tile))
		if(cable != ignore && (cable.ports & ports))
			return FALSE
	return TRUE

/** Обновляет кабели клетки и соседей после изменения соединений. */
/proc/ai_refresh_cable_tile(turf/tile)
	if(!tile)
		return
	var/list/tiles = list(tile)
	for(var/direction in GLOB.ai_cable_directions)
		var/turf/neighbor = get_step(tile, direction)
		if(neighbor)
			tiles += neighbor
	for(var/turf/current as anything in tiles)
		for(var/obj/structure/ai_ethernet/cable as anything in ai_cables_on_tile(current))
			cable.update_appearance(UPDATE_ICON)

/obj/machinery/ai
	/// Слабая ссылка на явно выбранный сегмент под оборудованием.
	var/datum/weakref/wired_cable_ref

/** Возвращает выбранный местный кабель либо единственный подходящий сегмент. */
/obj/machinery/ai/proc/network_cable()
	RETURN_TYPE(/obj/structure/ai_ethernet)
	if(!isturf(loc))
		return null
	if(wired_cable_ref)
		var/obj/structure/ai_ethernet/selected = wired_cable_ref.resolve()
		return !QDELETED(selected) && selected.loc == loc ? selected : null
	var/list/cables = ai_cables_on_tile(loc)
	return length(cables) == 1 ? cables[1] : null

/** Привязывает оборудование к местному сегменту; null возвращает автоматический выбор. */
/obj/machinery/ai/proc/select_network_cable(obj/structure/ai_ethernet/cable)
	if(cable && (QDELETED(cable) || !isturf(loc) || cable.loc != loc))
		return FALSE
	wired_cable_ref = cable ? WEAKREF(cable) : null
	SSai_networks.dirty = TRUE
	return TRUE

/** Проверяет физический доступ пользователя с мультитулом к выбору разъёма. */
/obj/machinery/ai/proc/can_select_network_cable(mob/living/user, obj/item/tool)
	return !QDELETED(user) && !QDELETED(tool) && !user.incapacitated && user.Adjacent(src) && tool.tool_behaviour == TOOL_MULTITOOL && user.is_holding(tool)

/obj/machinery/ai/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(!can_select_network_cable(user, tool))
		return ITEM_INTERACT_BLOCKING
	var/list/choices = list("Автоматически (только один кабель)" = null)
	for(var/obj/structure/ai_ethernet/cable as anything in ai_cables_on_tile(get_turf(src)))
		choices["[ai_cable_port_names(cable.ports)] / [cable.ai_network?.name || "изолирован"]"] = cable
	var/selection = tgui_input_list(user, "Выберите местный разъём оборудования. Пересекающиеся кабели не объединяются в одно соединение.", "Оптоволоконная проводка", choices)
	if(QDELETED(src) || !selection || !can_select_network_cable(user, tool) || !(selection in choices))
		return ITEM_INTERACT_BLOCKING
	var/obj/structure/ai_ethernet/cable = choices[selection]
	if(!select_network_cable(cable))
		return ITEM_INTERACT_BLOCKING
	SSai_networks.rebuild()
	balloon_alert(user, network_cable() ? "кабель выбран" : "автоматическое подключение")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/examine(mob/user)
	. = ..()
	var/obj/structure/ai_ethernet/cable = network_cable()
	if(cable)
		. += span_notice("Местный оптоволоконный кабель: [ai_cable_port_names(cable.ports)].")
	else if(wired_cable_ref || length(ai_cables_on_tile(get_turf(src))) > 1)
		. += span_notice("Подходящий оптоволоконный кабель не выбран. Нажмите ПКМ мультитулом, чтобы выбрать местный разъём.")

/** Строит граф совпадающих концов кабелей и подключённого оборудования по индексам клеток. */
/datum/controller/subsystem/ai_networks/proc/cable_graph(list/tile_cables, list/tile_nodes)
	var/list/edges = list()
	for(var/turf/tile as anything in tile_cables)
		for(var/obj/structure/ai_ethernet/cable as anything in tile_cables[tile])
			edges[cable] = list()
	for(var/turf/tile as anything in tile_nodes)
		for(var/obj/machinery/ai/node as anything in tile_nodes[tile])
			edges[node] = list()
	for(var/turf/tile as anything in tile_cables)
		for(var/obj/structure/ai_ethernet/cable as anything in tile_cables[tile])
			var/list/adjacent = edges[cable]
			for(var/direction in GLOB.ai_cable_directions)
				var/list/neighbors = tile_cables[get_step(tile, direction)]
				for(var/obj/structure/ai_ethernet/neighbor as anything in neighbors)
					if(cable.connects_to(neighbor, direction))
						adjacent |= neighbor
	for(var/turf/tile as anything in tile_nodes)
		var/list/local_nodes = tile_nodes[tile]
		for(var/obj/machinery/ai/node as anything in local_nodes)
			var/list/adjacent = edges[node]
			var/obj/structure/ai_ethernet/cable = node.network_cable()
			if(cable && edges[cable])
				adjacent |= cable
				var/list/cable_neighbors = edges[cable]
				cable_neighbors |= node
			else if(!length(tile_cables[tile]) && !node.wired_cable_ref)
				for(var/obj/machinery/ai/peer as anything in local_nodes)
					if(peer != node && !peer.wired_cable_ref && !peer.network_cable())
						adjacent |= peer
	return edges

/** Разбивает граф на связные части; with_bridges учитывает работающие парные мосты. */
/datum/controller/subsystem/ai_networks/proc/cable_components(list/edges, with_bridges = FALSE)
	var/list/unvisited = list()
	for(var/atom/vertex as anything in edges)
		unvisited[vertex] = TRUE
	var/list/result = list()
	while(length(unvisited))
		var/atom/start = unvisited[1]
		var/list/queue = list(start)
		var/list/nodes = list()
		var/list/cables = list()
		unvisited -= start
		for(var/index = 1; index <= length(queue); index++)
			var/atom/vertex = queue[index]
			if(istype(vertex, /obj/structure/ai_ethernet))
				cables += vertex
			else
				nodes += vertex
			var/list/neighbors = edges[vertex]
			for(var/atom/neighbor as anything in neighbors)
				if(unvisited[neighbor])
					unvisited -= neighbor
					queue += neighbor
			if(with_bridges && istype(vertex, /obj/machinery/ai/network_bridge))
				var/obj/machinery/ai/network_bridge/bridge = vertex
				if(bridge.cached_link && unvisited[bridge.partner])
					unvisited -= bridge.partner
					queue += bridge.partner
		result += list(list("nodes" = nodes, "cables" = cables))
	return result
