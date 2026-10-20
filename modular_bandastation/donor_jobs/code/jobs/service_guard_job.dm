/datum/job/donor/service_guard
	important_information = "Поддерживайте порядок в сервисном отделе. Согласовывайте действия с сотрудниками отдела и службой безопасности; должность не даёт полномочий офицера СБ."
	title = "Guard"
	description = "Порядок в баре и на кухне. Не сотрудник СБ и не охотник на антагонистов."
	donor_tier = 3
	config_tag = "DONOR_GUARD"
	total_positions = 1
	spawn_positions = 1
	display_order = 33
	outfit = /datum/outfit/job/donor/service_guard
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Охранник сервиса", /datum/outfit/job/donor/service_guard),
		"bodyguard" = list("Охранник", /datum/outfit/job/donor/service_guard),
		"external_guard" = list("Сторож Сервиса", /datum/outfit/job/donor/service_guard),
		"technical_guard" = list("Охранник Сервиса", /datum/outfit/job/donor/service_guard),
		"personal_guard" = list("Вышибала Сервиса", /datum/outfit/job/donor/service_guard),
	)
