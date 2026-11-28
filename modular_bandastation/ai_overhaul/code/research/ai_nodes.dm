/** Открывает изготовление улучшенных нейропроцессоров. */
/datum/techweb_node/ai_cpu_advanced
	display_name = "Продвинутые нейропроцессоры"
	description = "Высокоэффективное производство значительно ускоряет нейропроцессоры ценой повышенного энергопотребления."
	unlocked_designs = list(/datum/design/cpu_advanced)
	prerequisite_nodes = list(/datum/techweb_node/parts_upg, /datum/techweb_node/ai_hardware)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает изготовление экспериментальных нейропроцессоров. */
/datum/techweb_node/ai_cpu_experimental
	display_name = "Экспериментальные нейропроцессоры"
	description = "Небольшие изменения позволяют использовать ранее отбракованные нейропроцессоры. Они потребляют больше энергии, но лучше поддаются разгону."
	unlocked_designs = list(/datum/design/cpu_experimental)
	prerequisite_nodes = list(/datum/techweb_node/ai_cpu_advanced)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает изготовление блюспейс-нейропроцессоров. */
/datum/techweb_node/ai_cpu_bluespace
	display_name = "Блюспейс-нейропроцессоры"
	description = "Блюспейс-технологии позволяют производить сверхбыстрые нейропроцессоры с очень высоким энергопотреблением."
	unlocked_designs = list(/datum/design/cpu_bluespace)
	prerequisite_nodes = list(/datum/techweb_node/ai_cpu_advanced, /datum/techweb_node/applied_bluespace)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает изготовление RAM на 2 ТБ. */
/datum/techweb_node/ai_ram_high_cap
	display_name = "Модули памяти высокой ёмкости"
	description = "Улучшения производства памяти повышают плотность хранения данных."
	unlocked_designs = list(/datum/design/ram/ram2)
	prerequisite_nodes = list(/datum/techweb_node/parts_upg, /datum/techweb_node/ai_hardware)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает изготовление RAM на 3 ТБ. */
/datum/techweb_node/ai_ram_hyper
	display_name = "Модули памяти сверхвысокой ёмкости"
	description = "Развитие технологии памяти обеспечивает ранее недостижимую плотность данных."
	unlocked_designs = list(/datum/design/ram/ram3)
	prerequisite_nodes = list(/datum/techweb_node/ai_ram_high_cap)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает изготовление RAM на 4 ТБ. */
/datum/techweb_node/ai_ram_bluespace
	display_name = "Блюспейс-модули памяти"
	description = "Микросхемы хранят данные в специальных блюспейс-карманах. Плотность данных значительно выше, но изготовление дороже."
	unlocked_designs = list(/datum/design/ram/ram4)
	prerequisite_nodes = list(/datum/techweb_node/ai_ram_hyper, /datum/techweb_node/applied_bluespace)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает 2-й разъём CPU при изготовлении серверного модуля. */
/datum/techweb_node/ai_cpu_2
	display_name = "Дополнительные разъёмы CPU"
	description = "Развитие теории данных позволяет установить дополнительный CPU в каждый серверный модуль ИИ."
	unlocked_designs = list(/datum/design/ai_cpu_2)
	prerequisite_nodes = list(/datum/techweb_node/ai_hardware)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает 3-й разъём CPU при изготовлении серверного модуля. */
/datum/techweb_node/ai_cpu_3
	display_name = "Продвинутые разъёмы CPU"
	description = "256-битные вычисления позволяют добавить ещё один CPU."
	unlocked_designs = list(/datum/design/ai_cpu_3)
	prerequisite_nodes = list(/datum/techweb_node/ai_architecture_256, /datum/techweb_node/ai_cpu_2)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает 4-й разъём CPU при изготовлении серверного модуля. */
/datum/techweb_node/ai_cpu_4
	display_name = "Блюспейс-разъёмы CPU"
	description = "Мгновенная передача данных между кэшами позволяет установить четвёртый CPU."
	unlocked_designs = list(/datum/design/ai_cpu_4)
	prerequisite_nodes = list(/datum/techweb_node/ai_architecture_bluespace, /datum/techweb_node/ai_cpu_3)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает 2-й разъём RAM при изготовлении серверного модуля. */
/datum/techweb_node/ai_ram_2
	display_name = "Улучшенная шина памяти"
	description = "Открывает второй разъём RAM при ручной сборке серверного модуля. Шина не печатается отдельно: откройте корпус отвёрткой и вставьте дополнительную планку памяти."
	unlocked_designs = list(/datum/design/ai_ram_2)
	prerequisite_nodes = list(/datum/techweb_node/ai_hardware)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает 3-й разъём RAM при изготовлении серверного модуля. */
/datum/techweb_node/ai_ram_3
	display_name = "Продвинутая шина памяти"
	description = "Открывает третий разъём RAM при ручной сборке серверного модуля. Шина не печатается отдельно; ёмкость планок памяти исследуется отдельно."
	unlocked_designs = list(/datum/design/ai_ram_3)
	prerequisite_nodes = list(/datum/techweb_node/ai_architecture_256, /datum/techweb_node/ai_ram_2)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает 4-й разъём RAM при изготовлении серверного модуля. */
/datum/techweb_node/ai_ram_4
	display_name = "Блюспейс-шина памяти"
	description = "Открывает четвёртый разъём RAM при ручной сборке серверного модуля. Шина применяется автоматически и не печатается отдельно."
	unlocked_designs = list(/datum/design/ai_ram_4)
	prerequisite_nodes = list(/datum/techweb_node/ai_ram_3, /datum/techweb_node/ai_architecture_bluespace)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Продвигает архитектуру оборудования ИИ к следующему уровню исследований. */
/datum/techweb_node/ai_architecture_256
	display_name = "256-битные вычисления"
	description = "Опыт изготовления оборудования показывает необходимость дополнительных CPU и модулей памяти. Открывает доступ к этим технологиям."
	prerequisite_nodes = list(/datum/techweb_node/ai_ram_2, /datum/techweb_node/ai_cpu_2)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/** Открывает верхний уровень архитектуры оборудования ИИ. */
/datum/techweb_node/ai_architecture_bluespace
	display_name = "Блюспейс-вычисления"
	description = "Мгновенная блюспейс-передача данных внутри серверного модуля открывает последний уровень вычислительных технологий."
	prerequisite_nodes = list(/datum/techweb_node/ai_architecture_256, /datum/techweb_node/applied_bluespace)
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
