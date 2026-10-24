/datum/job/donor/representative_ussp
	important_information = "Вы - представитель КССП, прибывший для отдыха и переговоров. Космический закон действует и на вас."
	title = "Representative USSP"
	description = "Гость для отдыха и переговоров; космический закон действует, иммунитета нет."
	donor_tier = 4
	config_tag = "DONOR_REPRESENTATIVE_USSP"
	total_positions = 1
	spawn_positions = 1
	display_order = 38
	outfit = /datum/outfit/job/donor/representative_ussp
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	job_variant_specs = list(
		"default" = list("Представитель КССП", /datum/outfit/job/donor/representative_ussp),
		"diplomat" = list("Дипломат КССП", /datum/outfit/job/donor/representative_ussp),
		"press_secretary" = list("Пресс-секретарь КССП", /datum/outfit/job/donor/representative_ussp),
	)
