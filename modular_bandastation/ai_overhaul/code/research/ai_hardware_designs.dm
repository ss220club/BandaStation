/** Открывает печать физических планок RAM на штатном протолате. */
/datum/design/ram
	abstract_type = /datum/design/ram
	build_type = PROTOLATHE
	category = list(RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
	construction_time = 2 SECONDS

/** Открывает печать физической планки RAM на 1 ТБ. */
/datum/design/ram/ram1
	name = "Standard Memory"
	desc = "Получена из выведенного из эксплуатации экспериментального оборудования NT-CONLAB."
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ai_ram

/** Открывает печать физической планки RAM на 2 ТБ. */
/datum/design/ram/ram2
	name = "High-capacity Memory"
	desc = "Усовершенствованная технология обеспечивает высокую ёмкость без потери производительности."
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ai_ram/high_capacity

/** Открывает печать физической планки RAM на 3 ТБ. */
/datum/design/ram/ram3
	name = "Hyper-capacity Memory"
	desc = "Манипуляции с материей на почти атомном уровне увеличивают ёмкость без заметного снижения производительности."
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ai_ram/hyper_capacity

/** Открывает печать физической планки RAM на 4 ТБ. */
/datum/design/ram/ram4
	name = "Bluespace Memory"
	desc = "Блюспейс-технологии увеличивают ёмкость RAM без снижения скорости."
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ai_ram/bluespace

/** Открывает печать пустого корпуса серверного модуля для ручной сборки. */
/datum/design/ai_server_module
	name = "Server Rack"
	desc = "Пустой корпус серверного модуля ИИ. Откройте отвёрткой, вставьте CPU и RAM и закройте перед установкой в серверный шкаф."
	build_type = PROTOLATHE
	build_path = /obj/item/server_rack
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	construction_time = 2 SECONDS
	category = list(RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление физического нейропроцессора соответствующего технологического уровня. */
/datum/design/cpu_basic
	name = "Neural Processing Unit"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ai_cpu
	construction_time = 5 SECONDS
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление физического нейропроцессора соответствующего технологического уровня. */
/datum/design/cpu_advanced
	name = "Advanced Neural Processing Unit"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ai_cpu/advanced
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление физического нейропроцессора соответствующего технологического уровня. */
/datum/design/cpu_experimental
	name = "Experimental Neural Processing Unit"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 6,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 6,
	)
	build_path = /obj/item/ai_cpu/experimental
	construction_time = 7.5 SECONDS
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/** Открывает изготовление физического нейропроцессора соответствующего технологического уровня. */
/datum/design/cpu_bluespace
	name = "Bluespace Neural Processing Unit"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ai_cpu/bluespace
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
