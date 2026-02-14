/datum/techweb_node/xenobio_protocols
	id = "xenobio_protocols"
	display_name = "Протоколы ксенобио"
	description = "Стандартизированные процедуры анализа инопланетной биологии. Ускоряют накопление очков исследования ксенобио."
	prereq_ids = list(TECHWEB_NODE_XENOBIOLOGY)
	design_ids = list()
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/xenobio_advanced
	id = "xenobio_advanced"
	display_name = "Продвинутая ксенобиология"
	description = "Углублённые методы реконструкции рецептов слаймов. Дополнительно ускоряют накопление очков ксенобио."
	prereq_ids = list("xenobio_protocols")
	design_ids = list()
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
