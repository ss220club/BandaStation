// ============================================
// ДИЗАЙНЫ ДЛЯ ФАБРИКАТОРОВ — ДЕТАЛИ КПБ (IPC)
// ===========================================

// ============================================================
// TECHWEB НОДА — даёт доступ ко всем IPC-дизайнам в R&D
// ============================================================

/datum/techweb_node/ipc_parts
	id = "ipc_parts"
	starting_node = TRUE
	display_name = "Детали КПБ"
	description = "Компоненты для создания и ремонта синтетических организмов IPC: части тела, органы, базовые импланты и оборудование."
	design_ids = list(
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
	)
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
