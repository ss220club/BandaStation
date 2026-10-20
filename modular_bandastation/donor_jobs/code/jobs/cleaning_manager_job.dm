/datum/job/donor/cleaning_manager
	important_information = "Поддерживайте чистоту станции. Для ключа уборщика требуется штатная временная авторизация через устройство аутентификации глав."
	variant_information = list(
		/datum/outfit/job/donor/cleaning_manager/apprentice = "Работайте с инструментами, обустройте мастерскую и помогайте станции. Для работ в отделах согласуйте доступ и задачи с их сотрудниками.",
	)
	title = "Cleaning Manager"
	description = "Уборка станции, обслуживание освещения и организация чистоты."
	donor_tier = 3
	config_tag = "DONOR_CLEANING_MANAGER"
	total_positions = 2
	spawn_positions = 2
	display_order = 32
	outfit = /datum/outfit/job/donor/cleaning_manager
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Менеджер по клинингу", /datum/outfit/job/donor/cleaning_manager),
		"cleaning_manager" = list("Менеджер по Клинингу", /datum/outfit/job/donor/cleaning_manager),
		"rat_catcher" = list("Ловец Крыс", /datum/outfit/job/donor/cleaning_manager),
		"cleaner_1" = list("Уборщик I-разряда", /datum/outfit/job/donor/cleaning_manager),
		"cleaner_2" = list("Уборщик II-разряда", /datum/outfit/job/donor/cleaning_manager),
		"cleaner_3" = list("Уборщик III-разряда", /datum/outfit/job/donor/cleaning_manager),
		"cleaner_4" = list("Уборщик IV-разряда", /datum/outfit/job/donor/cleaning_manager),
		"cleaner_5" = list("Уборщик V-разряда", /datum/outfit/job/donor/cleaning_manager),
		"apprentice" = list("Подмастерье", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"maintenance_assistant" = list("Ассистент-Механик", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"assistant_1" = list("Ассистент I-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"assistant_2" = list("Ассистент II-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"assistant_3" = list("Ассистент III-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"assistant_4" = list("Ассистент IV-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"assistant_5" = list("Ассистент V-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
	)
