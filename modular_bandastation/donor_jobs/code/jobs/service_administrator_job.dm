/datum/job/donor/service_administrator
	important_information = "Помогайте главе персонала координировать сервис и организуйте мероприятия. Вы помощник и консультант, а не глава отдела обслуживания или замена главы персонала."
	title = "Administrator"
	description = "Координация отдела обслуживания, помощь главе персонала и организация мероприятий. Не глава отдела, не замена главы персонала."
	donor_tier = 3
	config_tag = "DONOR_ADMINISTRATOR"
	total_positions = 1
	spawn_positions = 1
	display_order = 29
	outfit = /datum/outfit/job/donor/service_administrator
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Сервис-администратор", /datum/outfit/job/donor/service_administrator),
		"service_administrator" = list("Сервис-администратор", /datum/outfit/job/donor/service_administrator),
		"steward" = list("Сервис-управитель", /datum/outfit/job/donor/service_administrator),
		"pompadour" = list("Помпадур", /datum/outfit/job/donor/service_administrator),
		"service_manager" = list("Сервис-менеджер", /datum/outfit/job/donor/service_administrator),
	)
