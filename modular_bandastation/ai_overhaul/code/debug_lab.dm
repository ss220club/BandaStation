GLOBAL_DATUM(ai_debug_lab, /datum/ai_debug_lab)

/** Разрешает станционные уровни и административную лабораторию ИИ. */
/proc/ai_supported_location(atom/source)
	var/turf/tile = get_turf(source)
	return tile && (is_station_level(tile.z) || istype(get_area(tile), /area/ai_debug_lab))

/** Проверяет принадлежность одной лаборатории либо общей среде вне лабораторий. */
/proc/ai_same_debug_environment(atom/first, atom/second)
	var/area/first_area = get_area(first)
	var/area/second_area = get_area(second)
	if(istype(first_area, /area/ai_debug_lab) || istype(second_area, /area/ai_debug_lab))
		return first_area == second_area
	return TRUE

/** Изолированная административная область с собственной базой исследований. */
/area/ai_debug_lab
	name = "Лаборатория отладки ИИ"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	ambient_buzz = null
	area_flags = UNIQUE_AREA | NOTELEPORT
	/// Отдельная база исследований административной лаборатории.
	var/datum/techweb/research

/** Создаёт и хранит повторно используемый стенд для ручной проверки механик ИИ. */
/datum/ai_debug_lab
	/// Область, изолирующая тестовые ресурсы от станции.
	var/area/ai_debug_lab/room
	/// Опорная клетка для расстановки стенда и входа администратора.
	var/turf/entrance
	/// Защищает от одновременного повторного создания лаборатории.
	var/creating = FALSE
	/// Объекты, созданные как оборудование этого стенда.
	var/list/equipment = list()
	/// Исходные тела администраторов для возврата из тестовых тел.
	var/list/return_bodies = list()
	/// Исходные места администраторов для выхода со стенда.
	var/list/return_locations = list()
	/// Основное тестовое ядро.
	var/obj/machinery/ai/data_core/primary_core
	/// Резервное тестовое ядро для проверки переноса.
	var/obj/machinery/ai/data_core/backup_core
	/// Тестовый шкаф с вычислительными модулями.
	var/obj/machinery/ai/server_cabinet/server
	/// Штатный протолат с отдельными исследованиями и материалами лаборатории.
	var/obj/machinery/rnd/production/protolathe/ai_debug_lab/protolathe
	/// Консоль отдельной лабораторной базы исследований.
	var/obj/machinery/computer/rdconsole/ai_debug_lab/research_console
	/// Корневая стойка законов тестовой сети.
	var/obj/machinery/ai_law_rack/base/law_rack
	/// Подготовленный ИИ стенда, тело которого может занять администратор.
	var/mob/living/silicon/ai/test_ai
	/// Тестовое тело с доступом к обслуживанию оборудования.
	var/mob/living/carbon/human/engineer
	/// Тестовый связанный киборг.
	var/mob/living/silicon/robot/cyborg

/datum/ai_debug_lab/Destroy()
	if(GLOB.ai_debug_lab == src)
		GLOB.ai_debug_lab = null
	QDEL_NULL(test_ai)
	QDEL_NULL(engineer)
	QDEL_NULL(cyborg)
	for(var/atom/movable/thing as anything in equipment)
		qdel(thing)
	equipment.Cut()
	if(room)
		QDEL_NULL(room.research)
	return ..()

/** Создаёт тестовое помещение и оборудование один раз; возвращает готовность стенда. */
/datum/ai_debug_lab/proc/create()
	if(creating)
		return FALSE
	if(entrance)
		return TRUE
	creating = TRUE
	var/datum/space_level/level = SSmapping.add_new_zlevel("AI Debug Lab", ZTRAITS_AWAY)
	room = new
	room.research = new /datum/techweb
	room.research.id = "AI Debug Lab"
	room.research.organization = "NT / Отладка ИИ"
	room.research.adjust_all_points(100000)
	var/base_x = round(world.maxx / 2) - 10
	var/base_y = round(world.maxy / 2) - 7
	var/datum/gas_mixture/lab_air = SSair.parse_gas_string(OPENTURF_DEFAULT_ATMOS)
	lab_air.temperature = T0C + 5
	for(var/x in 0 to 20)
		for(var/y in 0 to 14)
			var/turf/tile = locate(base_x + x, base_y + y, level.z_value)
			tile.change_area(get_area(tile), room)
			if(x == 0 || x == 20 || y == 0 || y == 14)
				tile.ChangeTurf(/turf/closed/wall)
			else
				var/turf/open/floor/floor_tile = tile.ChangeTurf(/turf/open/floor/iron)
				floor_tile.copy_air(lab_air)
				floor_tile.air_update_turf(FALSE, FALSE)
	entrance = locate(base_x + 10, base_y + 3, level.z_value)
	primary_core = place(/obj/machinery/ai/data_core, -7, 7)
	backup_core = place(/obj/machinery/ai/data_core, -3, 7)
	server = place(/obj/machinery/ai/server_cabinet/prefilled, 1, 7)
	place(/obj/machinery/ai/server_cabinet/prefilled, 5, 7)
	var/obj/machinery/ai/master_subcontroller/coordinator = place(/obj/machinery/ai/master_subcontroller, 8, 7)
	coordinator.enabled_areas |= room
	for(var/delta_x in list(-7, -3, 1, 5, 8))
		var/turf/node = at(delta_x, 7)
		place(/obj/machinery/ai_floor_cooler, delta_x, 7)
		ai_lay_cable_path(node, at(delta_x, 6))
	ai_lay_cable_path(at(-7, 6), at(8, 6))
	for(var/turf/tile as anything in block(at(-7, 6), at(8, 7)))
		for(var/obj/structure/ai_ethernet/cable in tile)
			equipment |= cable
	protolathe = place(/obj/machinery/rnd/production/protolathe/ai_debug_lab, -7, 2)
	place(/obj/machinery/computer/ai_overclocking, -4, 2)
	research_console = place(/obj/machinery/computer/rdconsole/ai_debug_lab, -1, 2)
	place(/obj/machinery/rnd/production/circuit_imprinter/ai_debug_lab, 2, 2)
	place(/obj/machinery/computer/ai_control_console, -7, 4)
	var/obj/machinery/computer/ai_resource_distribution/resources = place(/obj/machinery/computer/ai_resource_distribution, -3, 4)
	place(/obj/machinery/computer/ai_server_console, 1, 4)
	place(/obj/machinery/computer/aifixer, 5, 4)
	place(/obj/machinery/door/airlock, 8, 4)
	place(/obj/machinery/airalarm, 8, 5)
	law_rack = place(/obj/machinery/ai_law_rack/base, 7, 2)
	law_rack.anchored = TRUE
	law_rack.secured = TRUE
	law_rack.add_ai_module(new /obj/item/ai_module/law/core/full/asimov(law_rack), 1)
	place(/obj/item/storage/belt/utility/full, -7, -1)
	place(/obj/item/multitool, -6, -1)
	var/obj/item/stack/ai_ethernet_coil/coil = place(/obj/item/stack/ai_ethernet_coil, -5, -1)
	coil.add(49)
	place(/obj/item/aicard, -3, -1)
	place(/obj/item/mmi/posibrain, -2, -1)
	place(/obj/item/ai_module/law/syndicate, 1, -1)
	place(/obj/item/ai_module/law/core/full/damaged, 2, -1)
	place(/obj/item/disk/ai_research_archive, 4, -1)
	place(/obj/item/disk/ai_research_archive/bitrunning/advanced, 5, -1)
	place(/obj/item/disk/ai_research_archive/bitrunning/high_grade, 6, -1)
	for(var/cpu_type in list(/obj/item/ai_cpu, /obj/item/ai_cpu/advanced, /obj/item/ai_cpu/experimental, /obj/item/ai_cpu/bluespace))
		place(cpu_type, -7, 0)
	place(/obj/item/server_rack, -6, 0)
	for(var/ram_type in list(/obj/item/ai_ram, /obj/item/ai_ram/high_capacity, /obj/item/ai_ram/hyper_capacity, /obj/item/ai_ram/bluespace))
		place(ram_type, -6, 0)
	for(var/material_type in list(/obj/item/stack/sheet/iron, /obj/item/stack/sheet/glass, /obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/bluespace_crystal))
		var/obj/item/stack/sheets = place(material_type, -5, 0)
		sheets.add(49)
	fill_materials()
	place(/obj/machinery/camera/ai_debug_lab, -6, 5)
	place(/obj/machinery/camera/ai_debug_lab, 6, 5)
	SSai_networks.rebuild()
	var/mob/living/brain/brain = new
	test_ai = new(primary_core, brain, /datum/ai_laws/default/asimov)
	qdel(brain)
	equipment += test_ai
	test_ai.fully_replace_character_name(null, "NT / Тестовый ИИ")
	test_ai.network = "ai_debug_lab"
	test_ai.setup_decentralized_ai()
	primary_core.transfer_AI(test_ai)
	law_rack.link_silicon(test_ai, announce = FALSE)
	var/datum/ai_os/pool = test_ai.resource_pool()
	pool.set_cpu(test_ai, 0.5)
	pool.set_ram(test_ai, pool.total_ram)
	resources.selected_network = test_ai.ai_network
	engineer = place(/mob/living/carbon/human, -1, 0)
	engineer.fully_replace_character_name(null, "Инженер лаборатории ИИ")
	engineer.equip_to_slot_or_del(new /obj/item/clothing/under/rank/rnd/roboticist(engineer), ITEM_SLOT_ICLOTHING)
	engineer.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(engineer), ITEM_SLOT_FEET)
	engineer.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(engineer), ITEM_SLOT_BELT)
	var/obj/item/card/id/advanced/card = new(engineer)
	card.access = list(ACCESS_RD, ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_TCOMMS)
	card.registered_name = engineer.real_name
	engineer.equip_to_slot_or_del(card, ITEM_SLOT_ID)
	cyborg = new(at(3, 0), null, test_ai)
	equipment += cyborg
	creating = FALSE
	return TRUE

/** Возвращает клетку стенда по смещению от входа. */
/datum/ai_debug_lab/proc/at(delta_x, delta_y)
	RETURN_TYPE(/turf)
	return locate(entrance.x + delta_x, entrance.y + delta_y, entrance.z)

/** Создаёт объект заданного type на клетке стенда и учитывает его в оборудовании. */
/datum/ai_debug_lab/proc/place(type, delta_x, delta_y)
	var/atom/movable/thing = new type(at(delta_x, delta_y))
	equipment += thing
	return thing

/** Пополняет местные материалы штатных станков лаборатории. */
/datum/ai_debug_lab/proc/fill_materials()
	var/list/material_types = list(/datum/material/iron, /datum/material/glass, /datum/material/silver, /datum/material/gold, /datum/material/bluespace)
	for(var/obj/machinery/rnd/production/production in equipment)
		if(QDELETED(production) || !production.materials?.mat_container)
			continue
		var/datum/material_container/storage = production.materials.mat_container
		var/target_amount = min(50 * SHEET_MATERIAL_AMOUNT, storage.max_amount / length(material_types))
		for(var/material_type in material_types)
			var/datum/material/material = SSmaterials.get_material(material_type)
			storage.insert_amount_mat(target_amount - storage.get_material_amount(material), material)

/** Запоминает исходное тело администратора и место возврата перед занятием тестового тела. */
/datum/ai_debug_lab/proc/remember(client/admin)
	if(admin.mob == test_ai || admin.mob == engineer || admin.mob == cyborg || get_area(admin.mob) == room)
		return
	return_bodies[admin.ckey] = WEAKREF(admin.mob)
	var/turf/tile = get_turf(admin.mob)
	if(tile)
		return_locations[admin.ckey] = WEAKREF(tile)

ADMIN_VERB(ai_debug_lab, R_DEBUG, "AI - Тестовая лаборатория", "Создать тестовый отсек ИИ или открыть его инструменты.", ADMIN_CATEGORY_DEBUG)
	if(!SSticker.HasRoundStarted())
		to_chat(user, span_notice("Дождитесь начала раунда, чтобы собрать лабораторию на готовой карте."), confidential = TRUE)
		return
	if(!GLOB.ai_debug_lab)
		GLOB.ai_debug_lab = new
	var/datum/ai_debug_lab/lab = GLOB.ai_debug_lab
	if(!lab.create())
		to_chat(user, span_notice("Лаборатория ещё строится. Повторите команду через несколько секунд."), confidential = TRUE)
		return
	var/choice = tgui_input_list(user, "Исследования и материалы здесь отдельные. Тестовые тела можно занимать с правом R_ADMIN.", "Лаборатория ИИ", list("Перейти в лабораторию", "Управлять тестовым ИИ", "Управлять инженером", "Вернуться в исходное тело", "Исследовать следующую шину RAM", "Открыть всё оборудование", "Завершить проекты тестового ИИ", "Пополнить материалы", "Переключить питание", "Нормализовать температуру"))
	if(!choice || !check_rights_for(user, R_DEBUG) || !user.mob || QDELETED(lab))
		return
	switch(choice)
		if("Перейти в лабораторию")
			if(isAI(user.mob))
				to_chat(user, span_warning("Сначала выйдите в призрака или переключитесь на инженера: ИИ должен оставаться в физическом ядре."), confidential = TRUE)
				return
			lab.remember(user)
			user.mob.forceMove(lab.entrance)
		if("Управлять тестовым ИИ", "Управлять инженером")
			if(!check_rights_for(user, R_ADMIN))
				return
			var/mob/target = choice == "Управлять тестовым ИИ" ? lab.test_ai : lab.engineer
			if(QDELETED(target) || target.stat == DEAD || (target.client && target.client != user))
				to_chat(user, span_warning("Тестовое тело погибло, удалено или занято другим игроком."), confidential = TRUE)
				return
			lab.remember(user)
			target.PossessByPlayer(user.key)
		if("Вернуться в исходное тело")
			var/datum/weakref/body_ref = lab.return_bodies[user.ckey]
			var/mob/body = body_ref?.resolve()
			if(!body || (body.client && body.client != user))
				to_chat(user, span_warning("Исходное тело недоступно. Используйте штатные команды администратора."), confidential = TRUE)
				return
			if(body != user.mob)
				if(!check_rights_for(user, R_ADMIN))
					return
				body.PossessByPlayer(user.key)
			var/datum/weakref/location_ref = lab.return_locations[user.ckey]
			var/turf/previous_location = location_ref?.resolve()
			if(previous_location && !isAI(body))
				body.forceMove(previous_location)
			lab.return_bodies -= user.ckey
			lab.return_locations -= user.ckey
		if("Исследовать следующую шину RAM")
			for(var/node_path in list(/datum/techweb_node/ai_ram_2, /datum/techweb_node/ai_ram_3, /datum/techweb_node/ai_ram_4))
				if(lab.room.research.researched_nodes[node_path])
					continue
				lab.room.research.research_node(node_path, force = TRUE, auto_adjust_cost = FALSE, get_that_dosh = FALSE)
				var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
				to_chat(user, span_notice("В лаборатории исследовано: [node.display_name]. Проверьте число разъёмов в серверном модуле."), confidential = TRUE)
				break
		if("Открыть всё оборудование")
			for(var/node_path in SSresearch.techweb_nodes)
				if(findtext("[node_path]", "/datum/techweb_node/ai_") != 1)
					continue
				lab.room.research.research_node(node_path, force = TRUE, auto_adjust_cost = FALSE, get_that_dosh = FALSE)
		if("Завершить проекты тестового ИИ")
			for(var/datum/ai_project/project as anything in lab.test_ai?.dashboard?.available_projects.Copy())
				lab.test_ai.dashboard.finish_project(project, FALSE)
		if("Пополнить материалы")
			lab.fill_materials()
		if("Переключить питание")
			lab.room.requires_power = !lab.room.requires_power
			lab.room.power_equip = FALSE
			lab.room.power_light = FALSE
			lab.room.power_environ = FALSE
			lab.room.power_change()
			to_chat(user, span_notice("Питание лаборатории: [lab.room.requires_power ? "отключено" : "включено"]. Батареи ядер работают штатно."), confidential = TRUE)
		if("Нормализовать температуру")
			for(var/turf/open/tile in get_area_turfs(lab.room))
				tile.air.temperature = T0C + 5
				tile.air_update_turf(FALSE, FALSE)
			for(var/obj/machinery/ai/machine in lab.equipment)
				machine.core_temp = T0C - 20
	if(!QDELETED(lab.protolathe))
		SStgui.update_uis(lab.protolathe)
	if(!QDELETED(lab.research_console))
		SStgui.update_uis(lab.research_console)
	log_admin("[key_name(user)] использовал лабораторию ИИ: [choice].")
	message_admins(span_adminnotice("[key_name_admin(user)] использовал лабораторию ИИ: [choice]."))

/obj/machinery/computer/rdconsole/ai_debug_lab/post_machine_initialize()
	stored_research = ai_station_techweb(src)
	return ..()

/obj/machinery/rnd/production/circuit_imprinter/ai_debug_lab/post_machine_initialize()
	stored_research = ai_station_techweb(src)
	return ..()

/** Штатный протолат, подключённый только к лабораторным исследованиям и материалам. */
/obj/machinery/rnd/production/protolathe/ai_debug_lab

/obj/machinery/rnd/production/protolathe/ai_debug_lab/post_machine_initialize()
	stored_research = ai_station_techweb(src)
	return ..()

/** Камера стенда для проверки наблюдения тестового ИИ. */
/obj/machinery/camera/ai_debug_lab
	network = list("ai_debug_lab")
	c_tag = "Лаборатория ИИ"
