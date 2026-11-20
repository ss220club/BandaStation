/** Плата для сборки переноса ИИ штатными инструментами. */
/obj/item/circuitboard/computer/ai_upload_download
	name = "AI Control Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/ai_control_console

/** Плата для сборки обзора нейросети штатными инструментами. */
/obj/item/circuitboard/computer/ai_server_overview
	name = "AI Server Overview Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/ai_server_console

/** Плата для сборки распределения ресурсов ИИ штатными инструментами. */
/obj/item/circuitboard/computer/ai_resource_distribution
	name = "AI Resource Distribution Console"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/ai_resource_distribution

/** Плата для сборки серверного шкафа штатными инструментами. */
/obj/item/circuitboard/machine/server_cabinet
	name = "Server Cabinet"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/ai/server_cabinet
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/capacitor = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 1,
	)

/** Плата для сборки физического ядра ИИ штатными инструментами. */
/obj/item/circuitboard/machine/ai_data_core
	name = "AI Data Core"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/ai/data_core
	req_components = list(
		/obj/item/stock_parts/power_store/cell/high = 1,
		/datum/stock_part/capacitor = 4,
		/datum/stock_part/matter_bin = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 2,
	)

/** Плата основного ядра для стартового размещения ИИ. */
/obj/item/circuitboard/machine/ai_data_core/primary
	name = "Primary AI Data Core"
	build_path = /obj/machinery/ai/data_core/primary

/** Плата для сборки дисплея ядра ИИ штатными инструментами. */
/obj/item/circuitboard/machine/ai_core_display
	name = "AI Core Display"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/status_display/ai_core

/** Открывает изготовление платы обзора нейросети. */
/datum/design/board/ai_server_overview
	name = "AI Server Overview Console Board"
	desc = "Позволяет изготовить плату консоли наблюдения за серверами ИИ."
	build_path = /obj/item/circuitboard/computer/ai_server_overview
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление платы распределения ресурсов ИИ. */
/datum/design/board/ai_resource_distribution
	name = "AI Resource Distribution Console Board"
	desc = "Позволяет изготовить плату консоли распределения ресурсов ИИ."
	build_path = /obj/item/circuitboard/computer/ai_resource_distribution
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление платы серверного шкафа. */
/datum/design/board/server_cabinet
	name = "Server Cabinet Board"
	desc = "Плата серверного шкафа."
	build_path = /obj/item/circuitboard/machine/server_cabinet
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление платы физического ядра ИИ. */
/datum/design/board/ai_data_core
	name = "AI Data Core Board"
	desc = "Плата ядра ИИ."
	build_path = /obj/item/circuitboard/machine/ai_data_core
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление платы дисплея ядра ИИ. */
/datum/design/board/ai_core_display
	name = "AI Core Display Board"
	desc = "Плата дисплея ядра ИИ."
	build_path = /obj/item/circuitboard/machine/ai_core_display
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Плата для сборки станции разгона штатными инструментами. */
/obj/item/circuitboard/computer/ai_overclocking
	name = "AI Overclocking Workstation"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/ai_overclocking

/** Открывает изготовление платы управления ИИ. */
/datum/design/board/ai_control
	name = "AI Control Console Board"
	build_path = /obj/item/circuitboard/computer/ai_upload_download
	category = list(RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH)

/** Открывает изготовление платы станции разгона. */
/datum/design/board/ai_overclocking
	name = "AI Overclocking Workstation Board"
	build_path = /obj/item/circuitboard/computer/ai_overclocking
	category = list(RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH)

/** Плата для сборки сетевого моста штатными инструментами. */
/obj/item/circuitboard/machine/ai_network_bridge
	name = "Neural Network Bridge"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/ai/network_bridge
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5,
	)

/** Открывает изготовление платы сетевого моста. */
/datum/design/board/ai_network_bridge
	name = "Neural Network Bridge"
	desc = "Парный ретранслятор для связи с удалённым оборудованием ИИ."
	build_path = /obj/item/circuitboard/machine/ai_network_bridge
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
