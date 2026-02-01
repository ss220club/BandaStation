/datum/job/tsf_medic
	title = "Полевой медик ТСФ"
	supervisors = "офицером вашего отделения"
	description = "Спасайте своих ребят на поле боя доставая пули из задницы. Главное не умрите первым!"
	departments_list = list(
		/datum/job_department/service,
	)
	outfit = /datum/outfit/tsf/marine/medic
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	event_description = "Вы поступили на службу для оказания помощи солдатам и офицерам! В вашем распоряжении небольшой полевой госпиталь посольства. Обязательно посетите брифинг в основном здании посольства и получите задачи у полковника."

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/service
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

