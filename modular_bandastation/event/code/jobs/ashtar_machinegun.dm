/datum/job/vulp_ashtar_kulemet
	title = "Боец Аштара (Пулеметчик)"
	supervisors = "офицером вашего отделения"
	description = "Будьте готовы пойти на штурм со своим верным другом, прикрывайте своих соклановцев подавляющим огнем своей любимой игрушки, а также будьте готовы умереть за свой клан! Вас точно не забудут."
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/vulpa_ashtar/kulumet
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	event_description = "В ваши обязанности входит следование приказам офицера вашего отделения и исполнение долга перед cвоим Кланом. Вам не рекомендуется покидать пределы своей базы без разрешение офицеров в одиночку. Обязательно посетите брифинг в основном здании базы, после - получите свои задачи у офицеров или лично у командира операцией. Помните - это опасное место, поэтому будьте бдительны и верны своим соклановцам!"

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
