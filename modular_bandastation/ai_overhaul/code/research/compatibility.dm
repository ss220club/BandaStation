/** Возвращает отдельную базу лаборатории либо штатную научную базу станции. */
/proc/ai_station_techweb(atom/source)
	RETURN_TYPE(/datum/techweb)
	var/area/ai_debug_lab/lab_area = get_area(source)
	if(istype(lab_area))
		return lab_area.research
	return locate(/datum/techweb/science) in SSresearch.techwebs

/datum/controller/subsystem/research/New()
	. = ..()
	point_types[TECHWEB_POINT_TYPE_AI] = "Иссл. ИИ"

/** Обеспечивает совместимость стартовых исследований оборудования ИИ со штатной базой. */
/datum/techweb_node/ai_hardware
	display_name = "Инфраструктура ИИ"
	description = "Распределённые ядра и базовое нейронное вычислительное оборудование."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/ai_ethernet_coil,
		/datum/design/board/ai_network_bridge,
		/datum/design/board/ai_master_subcontroller,
		/datum/design/ram/ram1,
		/datum/design/cpu_basic,
		/datum/design/board/ai_server_overview,
		/datum/design/board/ai_resource_distribution,
		/datum/design/board/server_cabinet,
		/datum/design/board/ai_data_core,
		/datum/design/board/ai_core_display,
		/datum/design/ai_server_module,
		/datum/design/board/ai_control,
		/datum/design/board/ai_overclocking,
		/datum/design/board/ai_floor_cooler,
	)
