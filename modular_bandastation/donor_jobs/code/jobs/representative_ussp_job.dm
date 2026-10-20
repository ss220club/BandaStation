/datum/job/donor/representative_ussp
	important_information = "Вы представитель СССП, прибывший для отдыха и переговоров. Законы NT действуют и на вас; межгосударственные разногласия не разрешают нарушать правила."
	title = "Representative USSP"
	description = "Гость для отдыха и переговоров; законы NT действуют, иммунитета нет."
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
		"default" = list("Представитель СССП", /datum/outfit/job/donor/representative_ussp),
		"diplomat" = list("Дипломат СССП", /datum/outfit/job/donor/representative_ussp),
		"press_secretary" = list("Пресс-Секретарь СССП", /datum/outfit/job/donor/representative_ussp),
	)
