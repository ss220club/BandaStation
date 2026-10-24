/datum/job/donor/representative_tsf
	important_information = "Вы - представитель ТСФ, прибывший для отдыха и переговоров. Космический закон действует и на вас."
	title = "Representative TSF"
	description = "Гость для отдыха и переговоров; космический закон действует, иммунитета нет."
	donor_tier = 4
	config_tag = "DONOR_REPRESENTATIVE_TSF"
	total_positions = 1
	spawn_positions = 1
	display_order = 37
	outfit = /datum/outfit/job/donor/representative_tsf
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	job_variant_specs = list(
		"default" = list("Представитель ТСФ", /datum/outfit/job/donor/representative_tsf),
		"diplomat" = list("Дипломат ТСФ", /datum/outfit/job/donor/representative_tsf),
		"publicist" = list("Публицист ТСФ", /datum/outfit/job/donor/representative_tsf),
	)
