/datum/gas/nucleium //NSV13
	id = GAS_NUCLEIUM
	specific_heat = 450 //jesus god why
	name = "Nucleium"
	desc = "Побочный продукт переработки отходов плазмы, образуется в реакторе Stormdrive."
	gas_overlay = "nucleium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 300
	base_value = 5
	primary_color = "#ffc0cb"

/datum/gas/constricted_plasma //NSV13 - words C++ monstermos expects 14 gas types to exist, we only had 13
	id = GAS_CONSTRICTED_PLASMA
	specific_heat = 250
	name = "Constricted plasma"
	desc = "Высоколетучая плазма, которая была магнитно сжата. Топливо для реактора Stormdrive."
	gas_overlay = "constricted_plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 500
	base_value = 3
	primary_color = "#ffc0cb"
