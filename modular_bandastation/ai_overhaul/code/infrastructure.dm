/datum/area_spawn/ai_infrastructure/try_spawn()
	if(SSmapping.current_map.map_name in blacklisted_stations)
		return
	var/list/equipped_starts = list()
	for(var/obj/effect/landmark/start/ai/start in GLOB.start_landmarks_list)
		var/turf/home = get_turf(start)
		if(!home || !is_station_level(home.z))
			continue
		ai_prepare_core_walkway(home)
		if(!(locate(/obj/machinery/ai_floor_cooler) in home))
			new /obj/machinery/ai_floor_cooler(home)
		if(!start.primary_ai && !(locate(/obj/machinery/ai/data_core) in home))
			new /obj/machinery/ai/data_core(home)
		var/area/home_area = get_area(home)
		if(home in equipped_starts)
			continue
		var/list/homes = list(home)
		for(var/obj/effect/landmark/start/ai/other in GLOB.start_landmarks_list)
			var/turf/other_home = get_turf(other)
			if(other_home != home && length(ai_find_cable_path(home, other_home)))
				homes |= other_home
		var/turf/server_turf
		for(var/obj/machinery/ai/server_cabinet/existing as anything in GLOB.server_cabinets)
			if(length(ai_find_cable_path(home, get_turf(existing))))
				server_turf = get_turf(existing)
				break
		SSarea_spawn.clear_cache()
		var/list/candidates
		for(var/placement_mode in list(AREA_SPAWN_MODE_HUG_WALL, AREA_SPAWN_MODE_OPEN))
			candidates = SSarea_spawn.get_turf_candidates(home_area, placement_mode)
			for(var/priority in candidates.Copy())
				var/list/priority_turfs = candidates[priority]
				for(var/turf/candidate as anything in priority_turfs.Copy())
					if((locate(/obj/effect/landmark/start/ai) in candidate) || !length(ai_find_cable_path(home, candidate)))
						priority_turfs -= candidate
				if(!length(priority_turfs))
					candidates -= priority
			if(length(candidates))
				break
		if(!server_turf && !length(candidates) && start.primary_ai)
			var/turf/fixed_home = ai_wired_primary_floor(home_area)
			if(fixed_home)
				var/obj/machinery/ai_floor_cooler/cooler = locate() in home
				cooler?.forceMove(fixed_home)
				start.forceMove(fixed_home)
				home = fixed_home
				homes = list(home)
				for(var/obj/machinery/ai/server_cabinet/existing as anything in GLOB.server_cabinets)
					if(length(ai_find_cable_path(home, get_turf(existing))))
						server_turf = get_turf(existing)
						break
				log_world("Основное место входа ИИ размещено на неподвижном полу ([home.x], [home.y], [home.z]).")
		if(!server_turf && !length(candidates))
			log_mapping("AI infrastructure could not place a server cabinet in [home_area].")
			SSarea_spawn.failed_area_spawns += type
			continue
		if(!server_turf)
			server_turf = SSarea_spawn.pick_turf_candidate(candidates)
			new /obj/machinery/ai/server_cabinet/prefilled(server_turf)
		if(!(locate(/obj/machinery/ai_floor_cooler) in server_turf))
			new /obj/machinery/ai_floor_cooler(server_turf)
		for(var/turf/core_home as anything in homes)
			equipped_starts[core_home] = server_turf
			if(!ai_lay_cable_path(core_home, server_turf))
				log_mapping("AI infrastructure could not cable [home_area] ([core_home.x], [core_home.y], [core_home.z]).")
				SSarea_spawn.failed_area_spawns |= type
	SSarea_spawn.clear_cache()
	GLOB.ai_os.update_hardware()

/** Ищет подходящий пол того же отсека с маршрутом к стартовому серверу. */
/proc/ai_wired_primary_floor(area/room)
	SSarea_spawn.clear_cache()
	for(var/placement_mode in list(AREA_SPAWN_MODE_HUG_WALL, AREA_SPAWN_MODE_OPEN))
		var/list/candidates = SSarea_spawn.get_turf_candidates(room, placement_mode)
		for(var/priority in candidates.Copy())
			var/list/priority_turfs = candidates[priority]
			for(var/turf/candidate as anything in priority_turfs.Copy())
				var/connected = FALSE
				if(is_station_level(candidate.z) && !(locate(/obj/effect/landmark/start/ai) in candidate))
					for(var/obj/machinery/ai/server_cabinet/server as anything in GLOB.server_cabinets)
						if(length(ai_find_cable_path(candidate, get_turf(server))))
							connected = TRUE
							break
				if(!connected)
					priority_turfs -= candidate
			if(!length(priority_turfs))
				candidates -= priority
		if(length(candidates))
			return SSarea_spawn.pick_turf_candidate(candidates)
	return null

/** Проверяет, поддерживает ли клетка оптоволоконный кабель, включая мостки над открытым пространством. */
/proc/ai_cable_supported_turf(turf/tile)
	return isfloorturf(tile) || (istype(tile, /turf/open/openspace) && ((locate(/obj/structure/lattice/catwalk) in tile) || (locate(/obj/structure/transport/linear) in tile)))

/** Готовит короткий проход от площадки ядра, сохраняя открытое пространство под мостками. */
/proc/ai_prepare_core_walkway(turf/home)
	if(!ai_cable_supported_turf(home))
		return FALSE
	var/list/queue = list(home)
	var/list/distance = list()
	distance[home] = 0
	var/list/previous = list()
	for(var/index = 1; index <= length(queue); index++)
		var/turf/current = queue[index]
		for(var/direction in GLOB.cardinals)
			var/turf/tile = get_step(current, direction)
			if(!tile || get_area(tile) != get_area(home) || !isnull(distance[tile]))
				continue
			if(ai_cable_supported_turf(tile))
				while(current != home)
					var/obj/structure/lattice/support = locate() in current
					if(support)
						support.replace_with_catwalk()
					else
						new /obj/structure/lattice/catwalk(current)
					current = previous[current]
				return TRUE
			if(!istype(tile, /turf/open/openspace) || distance[current] >= 2)
				continue
			var/blocked = FALSE
			for(var/atom/movable/obstacle in tile)
				if(obstacle.density)
					blocked = TRUE
					break
			if(blocked)
				continue
			distance[tile] = distance[current] + 1
			previous[tile] = current
			queue += tile
	return FALSE

/obj/structure/lattice/catwalk/Destroy(force)
	var/turf/tile = get_turf(src)
	if(istype(tile, /turf/open/openspace))
		for(var/obj/structure/ai_ethernet/cable in tile)
			qdel(cable)
	return ..()

/** Ищет проходимый маршрут между start и destination для стартовой нейропроводки. */
/proc/ai_find_cable_path(turf/start, turf/destination)
	if(!ai_cable_supported_turf(start) || !ai_cable_supported_turf(destination) || start.z != destination.z || get_area(start) != get_area(destination) || length(ai_cables_on_tile(start)) > 1)
		return list()
	var/list/queue = list(start)
	var/list/visited = list()
	visited[start] = TRUE
	var/list/previous = list()
	for(var/index = 1; index <= length(queue); index++)
		var/turf/current = queue[index]
		if(current == destination)
			var/list/path = list()
			while(current)
				path.Insert(1, current)
				current = previous[current]
			return path
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(current, direction)
			if(!ai_cable_supported_turf(neighbor) || get_area(neighbor) != get_area(start) || visited[neighbor] || length(ai_cables_on_tile(neighbor)) > 1)
				continue
			visited[neighbor] = TRUE
			previous[neighbor] = current
			queue += neighbor
	return list()

/** Прокладывает кабель по найденному маршруту, создавая только необходимые концы и развилки. */
/proc/ai_lay_cable_path(turf/start, turf/destination)
	var/list/path = ai_find_cable_path(start, destination)
	if(length(path) < 2 || length(ai_cables_on_tile(start)) > 1)
		return FALSE
	for(var/index in 1 to length(path))
		var/turf/tile = path[index]
		var/ports = NONE
		if(index > 1)
			ports |= get_dir(tile, path[index - 1])
		if(index < length(path))
			ports |= get_dir(tile, path[index + 1])
		var/obj/structure/ai_ethernet/cable = locate() in tile
		if(cable)
			cable.set_ports(cable.ports | ports)
		else
			new /obj/structure/ai_ethernet(tile, ports)
	return TRUE

/** Размещает консоль переноса ИИ автомаппером без изменения исходных карт. */
/datum/area_spawn/ai_control
	target_areas = list(/area/station/ai/upload/chamber, /area/station/science/robotics, /area/station/science/research)
	desired_atom = /obj/machinery/computer/ai_control_console
	mode = AREA_SPAWN_MODE_HUG_WALL

/datum/area_spawn/ai_control/try_spawn()
	ai_spawn_station_equipment(src)

/** Размещает консоль ресурсов ИИ автомаппером без изменения исходных карт. */
/datum/area_spawn/ai_resources
	target_areas = list(/area/station/ai/upload/chamber, /area/station/science/robotics, /area/station/science/research)
	desired_atom = /obj/machinery/computer/ai_resource_distribution
	mode = AREA_SPAWN_MODE_HUG_WALL

/datum/area_spawn/ai_resources/try_spawn()
	ai_spawn_station_equipment(src)

/** Размещает консоль обзора нейросети автомаппером без изменения исходных карт. */
/datum/area_spawn/ai_overview
	target_areas = list(/area/station/science/robotics, /area/station/ai/upload/chamber, /area/station/science/research)
	desired_atom = /obj/machinery/computer/ai_server_console
	mode = AREA_SPAWN_MODE_HUG_WALL

/datum/area_spawn/ai_overview/try_spawn()
	ai_spawn_station_equipment(src)

/** Размещает станцию разгона автомаппером без изменения исходных карт. */
/datum/area_spawn/ai_overclocking
	target_areas = list(/area/station/science/robotics, /area/station/science/research)
	desired_atom = /obj/machinery/computer/ai_overclocking
	mode = AREA_SPAWN_MODE_HUG_WALL

/datum/area_spawn/ai_overclocking/try_spawn()
	ai_spawn_station_equipment(src)

/** Размещает служебное устройство автомаппером в подходящем станционном отсеке. */
/proc/ai_spawn_station_equipment(datum/area_spawn/placement)
	if(SSmapping.current_map.map_name in placement.blacklisted_stations)
		return
	for(var/obj/machinery/existing as anything in SSmachines.get_machines_by_type_and_subtypes(placement.desired_atom))
		if(is_station_level(existing.z))
			return
	SSarea_spawn.clear_cache()
	for(var/placement_mode in list(AREA_SPAWN_MODE_HUG_WALL, AREA_SPAWN_MODE_OPEN))
		for(var/area_type in placement.target_areas)
			var/area/room = GLOB.areas_by_type[area_type]
			if(!room)
				continue
			var/list/candidates = SSarea_spawn.get_turf_candidates(room, placement_mode)
			if(!length(candidates))
				continue
			placement.spawn_desired_atom(candidates)
			SSarea_spawn.clear_cache()
			return
	log_mapping("[placement.type] could not find any suitable turfs on map [SSmapping.current_map.map_name]!")
	SSarea_spawn.failed_area_spawns |= placement.type

/** Отводит тепло из атмосферы стартового отсека оборудования ИИ. */
/obj/machinery/ai_floor_cooler
	name = "AI floor cooling unit"
	desc = "Электрическая охлаждающая решётка для оборудования ИИ. Целевая температура воздуха — 0 °C. Требует атмосферы и питания от ЛКП. Сервисная панель открывается отвёрткой."
	icon = 'icons/obj/pipes_n_cables/atmos.dmi'
	icon_state = "vent0"
	density = FALSE
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	use_power = ACTIVE_POWER_USE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/ai_floor_cooler

/obj/machinery/ai_floor_cooler/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)

/obj/machinery/ai_floor_cooler/Destroy()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/ai_floor_cooler/process_atmos()
	if(!is_operational || !anchored || panel_open)
		return
	var/turf/open/home = get_turf(src)
	if(!istype(home))
		return
	var/datum/gas_mixture/air = home.return_air()
	if(!air || air.total_moles() < 10 || air.temperature <= AI_FLOOR_COOLER_TARGET)
		return
	var/heat_capacity = air.heat_capacity()
	if(heat_capacity <= 0)
		return
	air.temperature = max(AI_FLOOR_COOLER_TARGET, air.temperature - (40 KILO JOULES) / heat_capacity)
	home.air_update_turf(FALSE, FALSE)

/obj/machinery/ai_floor_cooler/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, icon_state, icon_state, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/machinery/ai_floor_cooler/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/** Плата для сборки охладителя отсека ИИ штатными инструментами. */
/obj/item/circuitboard/machine/ai_floor_cooler
	name = "AI Floor Cooling Unit"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/ai_floor_cooler
	req_components = list(/datum/stock_part/capacitor = 2, /datum/stock_part/micro_laser = 1, /obj/item/stack/cable_coil = 2)

/** Открывает изготовление платы охладителя отсека ИИ. */
/datum/design/board/ai_floor_cooler
	name = "AI Floor Cooling Unit"
	build_path = /obj/item/circuitboard/machine/ai_floor_cooler
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
