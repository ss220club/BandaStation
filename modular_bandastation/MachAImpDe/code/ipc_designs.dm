// ============================================
// ДИЗАЙНЫ ДЛЯ ФАБРИКАТОРОВ — ДЕТАЛИ КПБ (IPC)
// ============================================
//
// Категории:
//   КПБ/Части тела   — bodyparts (механфаб)
//   КПБ/Органы       — внутренние органы (механфаб)
//   КПБ/Импланты     — имплантаты (механфаб)
//   КПБ/Оборудование — стол и прочее оборудование (механфаб)
//
//   Платы компьютеров/Медицинские консоли — плата терминала (прототокарный)
//   Оборудование/Медицинское оборудование  — синтетический стол (прототокарный)
// ============================================

// ============================================================
// TECHWEB НОДА — даёт доступ ко всем IPC-дизайнам в R&D
// ============================================================

/datum/techweb_node/ipc_parts
	id = "ipc_parts"
	starting_node = TRUE
	display_name = "Детали КПБ"
	description = "Компоненты для создания и ремонта синтетических организмов IPC: части тела, органы, базовые импланты и оборудование."
	design_ids = list(
		// Плата терминала
		"synthetic_diagnostic_terminal_board",
		// Диагностический стол
		"synthetic_diagnostic_table",
		// Части тела
		"ipc_bodypart_head",
		"ipc_bodypart_chest",
		"ipc_bodypart_arm_left",
		"ipc_bodypart_arm_right",
		"ipc_bodypart_leg_left",
		"ipc_bodypart_leg_right",
		// Органы
		"ipc_organ_positronic",
		"ipc_organ_battery",
		"ipc_organ_eyes",
		"ipc_organ_ears",
		"ipc_organ_tongue",
		// Импланты (базовые)
		"ipc_implant_magnetic_joints",
		"ipc_implant_sealed_joints",
		"ipc_implant_reactive_repair",
		"ipc_implant_magnetic_leg",
	)

// ============================================================
// TECHWEB НОДА — боевые импланты КПБ (требует исследования)
// ============================================================

/datum/techweb_node/ipc_combat_implants
	id = "ipc_combat_implants"
	display_name = "Боевые импланты КПБ"
	description = "Наступательные модули для синтетических организмов IPC: встроенное оружие, ускорители реакции."
	prereq_ids = list(TECHWEB_NODE_COMBAT_IMPLANTS)
	design_ids = list(
		"ipc_implant_arm_razor",
		"ipc_implant_mantis_right",
		"ipc_implant_mantis_left",
		"ipc_implant_arm_cannon",
		"ipc_implant_sandevistan",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

// ============================================================
// ПЛАТА СИНТЕТИЧЕСКОГО ДИАГНОСТИЧЕСКОГО ТЕРМИНАЛА
// ============================================================

/datum/design/board/synthetic_diagnostic_terminal_board
	name = "Плата синтетического диагностического терминала"
	desc = "Позволяет напечатать плату для синтетического диагностического терминала."
	id = "synthetic_diagnostic_terminal_board"
	build_path = /obj/item/circuitboard/computer/operating/synthetic
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

// ============================================================
// СИНТЕТИЧЕСКИЙ ДИАГНОСТИЧЕСКИЙ СТОЛ
// ============================================================

/datum/design/synthetic_diagnostic_table
	name = "Набор синтетического диагностического стола"
	desc = "Компоненты для сборки синтетического диагностического стола. Примените к раме стола для окончательной сборки."
	id = "synthetic_diagnostic_table"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/stack/synthetic_table_kit
	materials = list(
		/datum/material/silver  = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron    = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass   = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

// ============================================================
// ЧАСТИ ТЕЛА КПБ — КПБ/Части тела
// ============================================================

/datum/design/ipc_bodypart_head
	name = "Голова КПБ (монитор)"
	desc = "Голова-монитор для синтетического организма IPC с встроенным дисплеем."
	id = "ipc_bodypart_head"
	build_path = /obj/item/bodypart/head/ipc/monitor
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_BODYPARTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_bodypart_chest
	name = "Корпус КПБ"
	desc = "Торсовая часть шасси для синтетического организма IPC."
	id = "ipc_bodypart_chest"
	build_path = /obj/item/bodypart/chest/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_BODYPARTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_bodypart_arm_left
	name = "Левая рука КПБ"
	desc = "Левая рука для синтетического организма IPC."
	id = "ipc_bodypart_arm_left"
	build_path = /obj/item/bodypart/arm/left/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_BODYPARTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_bodypart_arm_right
	name = "Правая рука КПБ"
	desc = "Правая рука для синтетического организма IPC."
	id = "ipc_bodypart_arm_right"
	build_path = /obj/item/bodypart/arm/right/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_BODYPARTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_bodypart_leg_left
	name = "Левая нога КПБ"
	desc = "Левая нога для синтетического организма IPC."
	id = "ipc_bodypart_leg_left"
	build_path = /obj/item/bodypart/leg/left/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_BODYPARTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_bodypart_leg_right
	name = "Правая нога КПБ"
	desc = "Правая нога для синтетического организма IPC."
	id = "ipc_bodypart_leg_right"
	build_path = /obj/item/bodypart/leg/right/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_BODYPARTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

// ============================================================
// ОРГАНЫ КПБ — КПБ/Органы
// ============================================================

/datum/design/ipc_organ_positronic
	name = "Позитронное ядро"
	desc = "Вычислительное ядро IPC — аналог мозга. Требует осторожного обращения."
	id = "ipc_organ_positronic"
	build_path = /obj/item/organ/brain/positronic
	materials = list(
		/datum/material/iron    = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass   = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold    = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_ORGANS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_organ_battery
	name = "Источник питания КПБ"
	desc = "Перезаряжаемый источник питания для IPC. Аналог сердца."
	id = "ipc_organ_battery"
	build_path = /obj/item/organ/heart/ipc_battery
	materials = list(
		/datum/material/iron   = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_ORGANS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_organ_eyes
	name = "Оптические сенсоры КПБ"
	desc = "Визуальные сенсоры для IPC."
	id = "ipc_organ_eyes"
	build_path = /obj/item/organ/eyes/robotic/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_ORGANS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_organ_ears
	name = "Аудио сенсоры КПБ"
	desc = "Аудиальные сенсоры для IPC."
	id = "ipc_organ_ears"
	build_path = /obj/item/organ/ears/robot/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_ORGANS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_organ_tongue
	name = "Голосовой синтезатор КПБ"
	desc = "Речевой синтезатор для IPC."
	id = "ipc_organ_tongue"
	build_path = /obj/item/organ/tongue/robot/ipc
	materials = list(
		/datum/material/iron  = SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_ORGANS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

// ============================================================
// ИМПЛАНТЫ КПБ — КПБ/Импланты
// ============================================================

/datum/design/ipc_implant_magnetic_joints
	name = "Магнитные суставы КПБ"
	desc = "Имплант: магнитные суставы, препятствующие отрыву конечностей."
	id = "ipc_implant_magnetic_joints"
	build_path = /obj/item/implant/ipc/magnetic_joints
	materials = list(
		/datum/material/iron   = SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_sealed_joints
	name = "Запечатанные суставы КПБ"
	desc = "Имплант: запечатанные суставы повышенной прочности."
	id = "ipc_implant_sealed_joints"
	build_path = /obj/item/implant/ipc/sealed_joints
	materials = list(
		/datum/material/iron   = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_reactive_repair
	name = "Реактивный ремонт КПБ"
	desc = "Имплант: система автоматического восстановления повреждений."
	id = "ipc_implant_reactive_repair"
	build_path = /obj/item/implant/ipc/reactive_repair
	materials = list(
		/datum/material/iron    = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver  = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold    = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_magnetic_leg
	name = "Магнитная нога КПБ"
	desc = "Имплант: магнитные ботинки для фиксации на металлических поверхностях."
	id = "ipc_implant_magnetic_leg"
	build_path = /obj/item/implant/ipc/magnetic_leg
	materials = list(
		/datum/material/iron   = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_arm_razor
	name = "Моновайер"
	desc = "Имплант: монофиламентная режущая струна в предплечье."
	id = "ipc_implant_arm_razor"
	build_path = /obj/item/implant/ipc/arm_razor
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_mantis_right
	name = "Лезвие богомола (правое)"
	desc = "Имплант: выдвижное лезвие богомола в правое предплечье."
	id = "ipc_implant_mantis_right"
	build_path = /obj/item/implant/ipc/mantis
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_mantis_left
	name = "Лезвие богомола (левое)"
	desc = "Имплант: выдвижное лезвие богомола в левое предплечье."
	id = "ipc_implant_mantis_left"
	build_path = /obj/item/implant/ipc/mantis/left
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_arm_cannon
	name = "Дробовик в руке"
	desc = "Имплант: встроенный дробовик в предплечье."
	id = "ipc_implant_arm_cannon"
	build_path = /obj/item/implant/ipc/arm_cannon
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/ipc_implant_sandevistan
	name = "Сандевистан"
	desc = "Имплант: ускоритель реакции — кратковременное ускорение всех систем."
	id = "ipc_implant_sandevistan"
	build_path = /obj/item/implant/ipc/sandevistan
	materials = list(
		/datum/material/iron    = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold    = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver  = SHEET_MATERIAL_AMOUNT * 0.5,
	)
	category = list(RND_CATEGORY_IPC + RND_SUBCATEGORY_IPC_IMPLANTS)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
