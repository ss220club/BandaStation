/datum/job/donor/acolyte
	important_information = "Помогайте священнику проводить богослужения. Его религиозные способности и право освящать воду не передаются вам автоматически."
	title = "Acolyte"
	description = "Помощник священника. Не получает его религиозные способности и право освящать воду автоматически."
	donor_tier = 2
	config_tag = "DONOR_ACOLYTE"
	total_positions = 5
	spawn_positions = 5
	display_order = 25
	outfit = /datum/outfit/job/donor/acolyte
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Послушник", /datum/outfit/job/donor/acolyte),
		"monk" = list("Монах", /datum/outfit/job/donor/acolyte),
		"disciple" = list("Приспешник", /datum/outfit/job/donor/acolyte),
		"follower" = list("Последователь", /datum/outfit/job/donor/acolyte),
		"ritualist" = list("Обрядчик", /datum/outfit/job/donor/acolyte),
	)
