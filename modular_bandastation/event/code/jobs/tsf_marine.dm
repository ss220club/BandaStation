/datum/job/tsf_marine
	title = "Резервист ТСФ"
	supervisors = "офицером вашего отделения"
	description = "Будьте готовы защищать посольство от нападок противника, а также будьте готовы умереть за Федерацию! Вас точно не забудут."
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/tsf/marine/carwo
	faction = FACTION_STATION
	total_positions = 6
	spawn_positions = 6
	event_description = "В ваши обязанности входит следование приказам офицера вашего отделения и исполнение долга перед Федерацией. Вам не рекомендуется покидать пределы посольства без разрешение офицеров в одиночку. Обязательно посетите брифинг в основном здании посольства, после - получите свои задачи у офицеров или лично у полковника. Помните - Посольство всегда в опасности, поэтому будьте бдительны и верны долгу!"

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/job_department/service
	ui_color = "#6681a5"
