/datum/job/donor/unemployed
	important_information = "Вы оставшийся без работы обитатель станции. Найдите занятие и способы выживания; ваша должность не делает вас антагонистом."
	title = "Uncertain"
	description = "Забытый работник и выживание в технических тоннелях. Не автоматический антагонист."
	donor_tier = 3
	config_tag = "DONOR_UNCERTAIN"
	total_positions = -1
	spawn_positions = -1
	display_order = 35
	outfit = /datum/outfit/job/donor/unemployed
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_variant_specs = list(
		"default" = list("Безработный", /datum/outfit/job/donor/unemployed),
		"unemployed_assistant" = list("Безработный Ассистент", /datum/outfit/job/donor/unemployed),
		"free_assistant" = list("Свободный Ассистент", /datum/outfit/job/donor/unemployed),
		"working_off_debt_assistant" = list("Отрабатыващий Ассистент", /datum/outfit/job/donor/unemployed),
		"maintenance_assistant" = list("Ассистент Технических Тоннелей", /datum/outfit/job/donor/unemployed),
	)
