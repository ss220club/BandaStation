/datum/outfit/job/assistant
	shoes = /obj/item/clothing/shoes/workboots
	id = null
	id_trim = null
	pda_slot = null
	belt = null
	ears = null
	suit = /obj/item/clothing/suit/hooded/wintercoat

/datum/job/assistant
	title = "Гражданский"
	description = "Попробуйте выжить."
	faction = FACTION_STATION
	supervisors = "законами войны"
	total_positions = 3
	spawn_positions = 3
	departments_list = list(
		/datum/job_department/assistant,
	)
	department_for_prefs = /datum/job_department/assistant
	event_description = "Возможно, вам пришлось бежать сюда, возможно вы родились тут. Все это - не важно, ведь перед вами открыт страшный мир Альтамской войны! Будете ли вы пытатся выжить или умрете, зависит только от вас."
