GLOBAL_LIST_EMPTY(ai_networks)
GLOBAL_LIST_EMPTY(ai_network_nodes)
GLOBAL_LIST_EMPTY(ai_ethernet_cables)

/** Объединяет связанные физические узлы в общий пул ресурсов и политики доступа. */
/datum/ai_network
	/// Читаемое имя сети или пула для интерфейсов.
	var/name
	/// Версия политики и назначений для отказа устаревшим командам интерфейса.
	var/resource_policy_revision = 0
	/// Физические устройства одной логической нейросети.
	var/list/nodes = list()
	/// Оптоволоконные кабели, входящие в эту логическую сеть.
	var/list/cables = list()
	/// Общий пул CPU и RAM логической сети.
	var/datum/ai_os/resources

/datum/ai_network/New()
	var/static/next_id = 0
	next_id++
	name = "Нейронная сеть [next_id]"
	resources = new
	resources.network = src
	GLOB.ai_networks += src

/datum/ai_network/Destroy()
	GLOB.ai_networks -= src
	nodes.Cut()
	cables.Cut()
	QDEL_NULL(resources)
	return ..()

/** Запрещает доступ к сети, если её узлы или кабели относятся к другой лабораторной среде. */
/datum/ai_network/proc/accessible_from(atom/source)
	if(!length(nodes))
		return FALSE
	for(var/atom/member as anything in (nodes + cables))
		if(!ai_same_debug_environment(source, member))
			return FALSE
	return TRUE

SUBSYSTEM_DEF(ai_networks)
	name = "AI Networks"
	wait = 2 SECONDS
	dependencies = list(/datum/controller/subsystem/area_spawn)
	/// Требует перестроить топологию после изменения кабелей или оборудования.
	var/dirty = TRUE
	/// Предотвращает повторный вход в пересчёт сети.
	var/rebuilding = FALSE

/datum/controller/subsystem/ai_networks/Initialize()
	load_benchmark_history()
	rebuild()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_networks/fire(resumed)
	rebuild()
	sample_benchmark_history()
	var/list/plans = list()
	for(var/datum/ai_network/network as anything in GLOB.ai_networks)
		plans[network] = network.background_cpu_plan()
	var/list/science_totals = ai_science_cpu_totals(plans)
	for(var/datum/ai_network/network as anything in GLOB.ai_networks)
		network.process_background_jobs(wait / (1 SECONDS), plans[network], science_totals)

/** Перестраивает изменившуюся топологию с переносом назначений, политики доступа и физических подсетей. */
/datum/controller/subsystem/ai_networks/proc/rebuild()
	for(var/obj/machinery/ai/network_bridge/bridge as anything in GLOB.ai_network_bridges)
		var/linked = bridge.link_available()
		if(linked != bridge.cached_link)
			bridge.cached_link = linked
			dirty = TRUE
	if(rebuilding || !dirty)
		return
	rebuilding = TRUE
	dirty = FALSE
	var/list/old_networks = GLOB.ai_networks.Copy()
	var/list/locked_members = list()
	for(var/datum/ai_network/old as anything in old_networks)
		if(!old.resources.human_lock)
			continue
		for(var/atom/member as anything in (old.nodes + old.cables))
			locked_members[member] = TRUE
	var/list/old_cpu = list()
	var/list/old_ram = list()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		var/datum/ai_os/pool = ai.ai_network?.resources
		if(pool)
			old_cpu[ai] = pool.total_cpu * pool.cpu_assigned[ai]
			old_ram[ai] = pool.ram_assigned[ai]
	var/list/tile_cables = list()
	var/list/tile_nodes = list()
	for(var/obj/structure/ai_ethernet/cable as anything in GLOB.ai_ethernet_cables)
		if(QDELETED(cable))
			continue
		if(!isturf(cable.loc))
			cable.ai_network = null
			cable.ai_subnet = null
			continue
		var/turf/home = cable.loc
		if(!tile_cables[home])
			tile_cables[home] = list()
		tile_cables[home] += cable
	for(var/obj/machinery/ai/node as anything in GLOB.ai_network_nodes)
		var/turf/home = get_turf(node)
		if(QDELETED(node) || !home)
			continue
		if(!tile_nodes[home])
			tile_nodes[home] = list()
		tile_nodes[home] += node
	var/list/edges = cable_graph(tile_cables, tile_nodes)
	var/list/previous_subnets = list()
	for(var/atom/member as anything in GLOB.ai_network_nodes + GLOB.ai_ethernet_cables)
		if(istype(member, /obj/machinery/ai))
			var/obj/machinery/ai/node = member
			previous_subnets[member] = node.ai_subnet
		else
			var/obj/structure/ai_ethernet/cable = member
			previous_subnets[member] = cable.ai_subnet
	rebuild_subnets(edges)
	var/list/used_networks = list()
	for(var/list/component as anything in cable_components(edges, TRUE))
		var/list/component_nodes = component["nodes"]
		var/list/component_cables = component["cables"]
		var/datum/ai_network/network
		for(var/obj/machinery/ai/node as anything in component_nodes)
			if(node.ai_network && !(node.ai_network in used_networks))
				network = node.ai_network
				break
		if(!network)
			for(var/obj/structure/ai_ethernet/cable as anything in component_cables)
				if(cable.ai_network && !(cable.ai_network in used_networks))
					network = cable.ai_network
					break
		if(!network)
			network = new
		used_networks += network
		var/list/old_members = network.nodes + network.cables
		var/list/new_members = component_nodes + component_cables
		var/subnets_changed = FALSE
		for(var/obj/machinery/ai/node as anything in component_nodes)
			if(previous_subnets[node] != node.ai_subnet)
				subnets_changed = TRUE
				break
		if(!subnets_changed)
			for(var/obj/structure/ai_ethernet/cable as anything in component_cables)
				if(previous_subnets[cable] != cable.ai_subnet)
					subnets_changed = TRUE
					break
		if(subnets_changed || length(old_members) != length(new_members) || length(new_members - old_members))
			network.resource_policy_revision++
		network.resources.human_lock = FALSE
		for(var/atom/member as anything in (component_nodes + component_cables))
			if(locked_members[member])
				network.resources.human_lock = TRUE
				break
		network.nodes = component_nodes
		network.cables = component_cables
		network.resources.cpu_assigned.Cut()
		network.resources.ram_assigned.Cut()
		for(var/obj/machinery/ai/node as anything in component_nodes)
			node.ai_network = network
		for(var/obj/structure/ai_ethernet/cable as anything in component_cables)
			cable.ai_network = network
		network.resources.update_hardware()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(istype(ai.loc, /obj/machinery/ai/data_core))
			var/obj/machinery/ai/data_core/core = ai.loc
			ai.ai_network = core.ai_network
		else if(!(ai.ai_network in used_networks))
			ai.ai_network = null
		var/datum/ai_os/pool = ai.ai_network?.resources
		if(!pool)
			continue
		pool.cpu_assigned[ai] = pool.total_cpu > 0 ? min(1, (old_cpu[ai] || 0) / pool.total_cpu) : 0
		pool.ram_assigned[ai] = old_ram[ai] || 0
	for(var/datum/ai_network/network as anything in used_networks)
		var/assigned = network.resources.total_cpu_assigned()
		if(assigned > 1)
			for(var/mob/living/silicon/ai/ai as anything in network.resources.cpu_assigned)
				network.resources.cpu_assigned[ai] /= assigned
		network.resources.update_allocations()
		network.normalize_subnet_quotas()
	for(var/datum/ai_network/network as anything in old_networks)
		if(!(network in used_networks))
			qdel(network)
	rebuilding = FALSE

/mob/living/silicon/ai
	/// Текущая логическая сеть объекта, обновляемая при перестроении топологии.
	var/datum/ai_network/ai_network

/** Возвращает актуальный пул своей нейросети либо совместимый общий пул при отсутствии сети. */
/mob/living/silicon/ai/proc/resource_pool()
	RETURN_TYPE(/datum/ai_os)
	SSai_networks.rebuild()
	return ai_network?.resources || GLOB.ai_os

/obj/machinery/ai
	/// Текущая логическая сеть объекта, обновляемая при перестроении топологии.
	var/datum/ai_network/ai_network

/** Возвращает актуальный пул своей нейросети либо совместимый общий пул при отсутствии сети. */
/obj/machinery/ai/proc/resource_pool()
	RETURN_TYPE(/datum/ai_os)
	SSai_networks.rebuild()
	return ai_network?.resources || GLOB.ai_os

/** Направленный оптоволоконный кабель с независимыми разъёмами и явной принадлежностью к сети. */
/obj/structure/ai_ethernet
	name = "neural network cable"
	desc = "Оптоволоконный кабель для передачи данных ИИ с местным разъёмом оборудования. Соединяются только совпадающие окончания у сторон и углов клетки. Независимые линии могут пересекаться на одной клетке. Ключ поворачивает ручной сегмент, кусачки снимают его."
	icon = 'icons/obj/pipes_n_cables/layer_cable.dmi'
	icon_state = "l2-1-2-4-8-node"
	plane = FLOOR_PLANE
	color = "#59d5d8"
	anchored = TRUE
	density = FALSE
	layer = WIRE_LAYER
	/// Текущая логическая сеть объекта, обновляемая при перестроении топологии.
	var/datum/ai_network/ai_network
	/// Битовая маска кардинальных и диагональных концов оптоволоконного кабеля.
	var/ports = NORTH | SOUTH | EAST | WEST
	/// Автоматически соединяется с соседями по сторонам клетки, как силовой кабель.
	var/auto_connect = FALSE

/obj/structure/ai_ethernet/Initialize(mapload, new_ports, automatic = FALSE)
	. = ..()
	auto_connect = automatic
	if(!set_ports(isnull(new_ports) ? ports : new_ports))
		return INITIALIZE_HINT_QDEL
	ai_refresh_cable_tile(get_turf(src))
	GLOB.ai_ethernet_cables += src
	SSai_networks.dirty = TRUE

/** Проверяет совпадающие концы двух соседних сегментов в указанном направлении. */
/obj/structure/ai_ethernet/proc/connects_to(obj/structure/ai_ethernet/other, direction)
	if(QDELETED(other) || !isturf(loc) || !isturf(other.loc) || !(direction in GLOB.ai_cable_directions) || get_step(src, direction) != other.loc)
		return FALSE
	if((direction in GLOB.cardinals) && (ports & direction) && (other.ports & turn(direction, 180)))
		return TRUE
	if(!(ports & (AI_CABLE_ALL_PORTS ^ (NORTH | SOUTH | EAST | WEST))) || !(other.ports & (AI_CABLE_ALL_PORTS ^ (NORTH | SOUTH | EAST | WEST))))
		return FALSE
	for(var/end in GLOB.ai_cable_directions)
		if(!(ports & ai_cable_port(end)))
			continue
		var/end_x = 2 * x + ((end & EAST) ? 1 : ((end & WEST) ? -1 : 0))
		var/end_y = 2 * y + ((end & NORTH) ? 1 : ((end & SOUTH) ? -1 : 0))
		for(var/other_end in GLOB.ai_cable_directions)
			if(!(other.ports & ai_cable_port(other_end)))
				continue
			var/other_x = 2 * other.x + ((other_end & EAST) ? 1 : ((other_end & WEST) ? -1 : 0))
			var/other_y = 2 * other.y + ((other_end & NORTH) ? 1 : ((other_end & SOUTH) ? -1 : 0))
			if(end_x == other_x && end_y == other_y)
				return TRUE
	return FALSE

/** Проверяет и задаёт маску разъёмов, не соединяя независимые пересечения на клетке. */
/obj/structure/ai_ethernet/proc/set_ports(amount)
	if(!isnum(amount) || amount != round(amount) || amount < 1 || amount > AI_CABLE_ALL_PORTS)
		return FALSE
	if(isturf(loc) && !ai_can_place_cable(loc, amount, src))
		return FALSE
	ports = amount
	ai_refresh_cable_tile(get_turf(src))
	SSai_networks.dirty = TRUE
	return TRUE

/** Поворачивает разъёмы сегмента на четверть оборота с обновлением топологии. */
/obj/structure/ai_ethernet/proc/rotate_ports()
	return set_ports(ai_rotate_cable_ports(ports))

/** У автоматического кабеля показывает только соединённые стороны. */
/obj/structure/ai_ethernet/proc/visible_ports()
	if(!auto_connect)
		return ports
	var/result = NONE
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/ai_ethernet/neighbor as anything in ai_cables_on_tile(get_step(src, direction)))
			if(connects_to(neighbor, direction))
				result |= direction
	return result

/obj/structure/ai_ethernet/update_icon_state()
	. = ..()
	icon_state = "l2"
	var/port_count = 0
	var/visible = visible_ports()
	for(var/direction in list(NORTH, SOUTH, EAST, WEST))
		if(visible & direction)
			icon_state += "-[direction]"
			port_count++
	var/list/local_cables = ai_cables_on_tile(get_turf(src))
	if(!port_count)
		icon_state = auto_connect ? "l2-noconnection" : ""
	var/has_node = FALSE
	for(var/obj/machinery/ai/node in loc)
		if(!QDELETED(node) && node.network_cable() == src)
			has_node = TRUE
			break
	if(port_count > 1 && length(local_cables) <= 1 && has_node)
		icon_state += "-node"
	color = local_cables.Find(src) <= 1 ? "#59d5d8" : "#c6a2ff"
	name = "neural network cable ([ai_cable_port_names(ports)])"
	ru_names_rename(ru_names_toml(initial(name), suffix = " ([ai_cable_port_names(ports)])", override_base = initial(name)))

/obj/structure/ai_ethernet/update_overlays()
	. = ..()
	for(var/direction in GLOB.diagonals)
		if(!(ports & ai_cable_port(direction)))
			continue
		var/mutable_appearance/arm = mutable_appearance(icon, "l2-1")
		var/matrix/arm_transform = matrix()
		arm_transform.Scale(1, sqrt(2))
		arm_transform.Turn(dir2angle(direction))
		arm.transform = arm_transform
		. += arm
		var/mutable_appearance/blocker = emissive_blocker(icon, "l2-1", src)
		blocker.transform = arm.transform
		. += blocker

/obj/structure/ai_ethernet/wrench_act(mob/living/user, obj/item/tool)
	if(auto_connect)
		balloon_alert(user, "форма выбирается автоматически")
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 1 SECONDS))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || !user.Adjacent(src))
		return ITEM_INTERACT_BLOCKING
	if(!rotate_ports())
		balloon_alert(user, "окончания кабеля заняты!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "кабель повёрнут")
	return ITEM_INTERACT_SUCCESS

/** Односторонний сегмент для подключения конечного узла. */
/obj/structure/ai_ethernet/endpoint
	ports = NORTH

/** Прямой сегмент оптоволоконного кабеля. */
/obj/structure/ai_ethernet/straight
	ports = NORTH | SOUTH

/** Поворот оптоволоконного кабеля между соседними направлениями. */
/obj/structure/ai_ethernet/corner
	ports = NORTH | EAST

/** Ответвление оптоволоконного кабеля с тремя концами. */
/obj/structure/ai_ethernet/tee
	ports = NORTH | EAST | WEST

/** Диагональный сегмент с отдельными битами направлений. */
/obj/structure/ai_ethernet/diagonal
	ports = AI_CABLE_NORTHEAST | AI_CABLE_SOUTHWEST

/** Преобразует направление BYOND в один бит маски оптоволоконного кабеля. */
/proc/ai_cable_port(direction)
	switch(direction)
		if(NORTHEAST)
			return AI_CABLE_NORTHEAST
		if(SOUTHEAST)
			return AI_CABLE_SOUTHEAST
		if(NORTHWEST)
			return AI_CABLE_NORTHWEST
		if(SOUTHWEST)
			return AI_CABLE_SOUTHWEST
		if(NORTH, SOUTH, EAST, WEST)
			return direction
	return NONE

/** Поворачивает маску нейроразъёмов на четверть оборота по часовой стрелке. */
/proc/ai_rotate_cable_ports(ports)
	var/rotated = NONE
	for(var/direction in GLOB.ai_cable_directions)
		if(ports & ai_cable_port(direction))
			rotated |= ai_cable_port(turn(direction, -90))
	return rotated

/** Возвращает читаемый перечень направлений из маски разъёмов. */
/proc/ai_cable_port_names(ports)
	var/list/names = list()
	var/static/list/direction_names = list("north" = "север", "south" = "юг", "east" = "восток", "west" = "запад", "northeast" = "северо-восток", "southeast" = "юго-восток", "northwest" = "северо-запад", "southwest" = "юго-запад", "up" = "вверх", "down" = "вниз")
	for(var/direction in GLOB.ai_cable_directions)
		if(ports & ai_cable_port(direction))
			names += direction_names[dir2text(direction)] || dir2text(direction)
	return jointext(names, ", ")

/obj/structure/ai_ethernet/Destroy()
	GLOB.ai_ethernet_cables -= src
	ai_network = null
	ai_subnet = null
	SSai_networks.dirty = TRUE
	ai_refresh_cable_tile(get_turf(src))
	return ..()

/obj/structure/ai_ethernet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	ai_refresh_cable_tile(get_turf(old_loc))
	ai_refresh_cable_tile(get_turf(src))
	SSai_networks.dirty = TRUE

/obj/structure/ai_ethernet/wirecutter_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 1 SECONDS))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/ai_ethernet_coil/salvage = new(drop_location(), 1)
	salvage.cable_ports = auto_connect ? NONE : ports
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/ai_ethernet/examine(mob/user)
	. = ..()
	SSai_networks.rebuild()
	. += span_notice("Выводы: [ai_cable_port_names(ports)]. Подключён к [ai_network?.name || "изолированному узлу"].")

/** Моток для ручной прокладки и выбора формы оптоволоконного кабеля. */
/obj/item/stack/ai_ethernet_coil
	name = "neural network cable coil"
	desc = "Моток оптоволокна для передачи данных между устройствами ИИ. По умолчанию кабель сам соединяется с соседними оптоволоконными кабелями по сторонам клетки, как обычная проводка. ЛКМ по мотку в активной руке — выбор ручной формы для независимых пересечений, ПКМ или Alt-клик — поворот и фиксация направления. Каждый сегмент имеет местный разъём оборудования."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "coil"
	color = "#59d5d8"
	singular_name = "сегмент кабеля"
	max_amount = 50
	merge_type = /obj/item/stack/ai_ethernet_coil
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)

	/// Фиксированная маска следующего сегмента; NONE включает самосоединение по сторонам клетки.
	var/cable_ports = NONE

/** Возвращает доступные формы следующего сегмента мотка. */
/proc/ai_cable_shapes()
	var/static/list/shapes = list(
		"Автоматически (как обычная проводка)" = NONE,
		"Окончание (север)" = NORTH,
		"Прямой (север/юг)" = NORTH | SOUTH,
		"Прямой (восток/запад)" = EAST | WEST,
		"Угол (север/восток)" = NORTH | EAST,
		"Т-образный (север/восток/запад)" = NORTH | EAST | WEST,
		"Четырёхсторонний узел" = NORTH | SOUTH | EAST | WEST,
		"Диагональное окончание (северо-восток)" = AI_CABLE_NORTHEAST,
		"Прямая диагональ (северо-восток/юго-запад)" = AI_CABLE_NORTHEAST | AI_CABLE_SOUTHWEST,
		"Диагональный угол (северо-восток/юго-восток)" = AI_CABLE_NORTHEAST | AI_CABLE_SOUTHEAST,
		"Диагональный изгиб (север/северо-восток)" = NORTH | AI_CABLE_NORTHEAST,
		"Диагональный изгиб (север/северо-запад)" = NORTH | AI_CABLE_NORTHWEST,
		"Широкий диагональный изгиб (север/юго-восток)" = NORTH | AI_CABLE_SOUTHEAST,
		"Широкий диагональный изгиб (север/юго-запад)" = NORTH | AI_CABLE_SOUTHWEST,
		"Восьмисторонний узел" = AI_CABLE_ALL_PORTS,
	)
	return shapes.Copy()

/obj/item/stack/ai_ethernet_coil/attack_self(mob/user)
	if(user.incapacitated || !user.is_holding(src))
		return
	var/list/shapes = ai_cable_shapes()
	var/shape = tgui_input_list(user, "Автоматический кабель сам образует линии, углы и ответвления к соседям, как обычная проводка. Для независимого пересечения выберите ручные формы. ПКМ или Alt-клик поворачивает и фиксирует ручной сегмент.", "Оптоволоконный кабель", shapes)
	select_cable_shape(user, shape)

/** Применяет только допустимую форму, повторно проверяя удержание мотка после диалога. */
/obj/item/stack/ai_ethernet_coil/proc/select_cable_shape(mob/user, shape)
	if(QDELETED(src) || QDELETED(user) || user.incapacitated || !user.is_holding(src))
		return FALSE
	var/list/shapes = ai_cable_shapes()
	if(!(shape in shapes))
		return FALSE
	cable_ports = shapes[shape]
	balloon_alert(user, cable_ports ? "форма выбрана" : "автоматическое соединение")
	return TRUE

/** Возвращает ручную форму для поворота; в автоматическом режиме берёт направление взгляда или клика. */
/obj/item/stack/ai_ethernet_coil/proc/placement_ports(turf/tile, mob/user)
	if(cable_ports)
		return cable_ports
	var/direction = get_dir(user, tile)
	if(!direction)
		direction = user.dir
	return ai_cable_port(direction) | ai_cable_port(turn(direction, 180))

/** Поворачивает выбранный сегмент и переводит автоматическое направление в фиксированное. */
/obj/item/stack/ai_ethernet_coil/proc/rotate_next_segment(mob/user)
	if(QDELETED(src) || QDELETED(user) || user.incapacitated || !user.is_holding(src))
		return FALSE
	cable_ports = ai_rotate_cable_ports(placement_ports(get_turf(user), user))
	balloon_alert(user, "направление повёрнуто и закреплено")
	return TRUE

/obj/item/stack/ai_ethernet_coil/attack_self_secondary(mob/user, modifiers)
	return rotate_next_segment(user)

/obj/item/stack/ai_ethernet_coil/click_alt(mob/living/user)
	return rotate_next_segment(user) ? CLICK_ACTION_SUCCESS : CLICK_ACTION_BLOCKING

/obj/item/stack/ai_ethernet_coil/split_stack(amount)
	var/selected_ports = cable_ports
	var/obj/item/stack/ai_ethernet_coil/part = ..()
	if(part)
		part.cable_ports = selected_ports
	return part

/obj/item/stack/ai_ethernet_coil/examine(mob/user)
	. = ..()
	. += span_notice("Следующий сегмент: [cable_ports ? ai_cable_port_names(cable_ports) : "автоматическое соединение с соседями, как у обычной проводки"]. ЛКМ по мотку в активной руке — форма; ПКМ или Alt-клик — поворот и фиксация направления. Автоматический режим можно вернуть через выбор формы.")

/obj/item/stack/ai_ethernet_coil/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /turf/open/floor) || user.incapacitated || !user.is_holding(src) || !user.Adjacent(interacting_with))
		return NONE
	var/automatic = !cable_ports
	var/selected_ports = automatic ? (NORTH | SOUTH | EAST | WEST) : cable_ports
	if(!ai_can_place_cable(interacting_with, selected_ports))
		balloon_alert(user, "окончания кабеля заняты!")
		return ITEM_INTERACT_BLOCKING
	if(!use(1))
		return ITEM_INTERACT_BLOCKING
	new /obj/structure/ai_ethernet(interacting_with, selected_ports, automatic)
	return ITEM_INTERACT_SUCCESS

/** Открывает изготовление мотка оптоволоконного кабеля. */
/datum/design/ai_ethernet_coil
	name = "Neural Network Cable"
	desc = "Оптоволоконный кабель для подключения оборудования ИИ."
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/ai_ethernet_coil
	category = list(RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_ENGINEERING)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
