/datum/job/donor/migrant
	important_information = "Обустройтесь на станции, знакомьтесь с экипажем и ищите работу. Соблюдайте космический закон."
	title = "Migrant"
	description = "Новый житель/посетитель станции, поиск работы и места в корпорации."
	donor_tier = 3
	config_tag = "DONOR_MIGRANT"
	total_positions = -1
	spawn_positions = -1
	display_order = 34
	outfit = /datum/outfit/job/donor/migrant
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_variant_specs = list(
		"default" = list("Мигрант", /datum/outfit/job/donor/migrant),
	)
