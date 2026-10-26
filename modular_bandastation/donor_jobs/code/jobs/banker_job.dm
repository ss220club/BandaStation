/datum/job/donor/banker
	important_information = "Начните своё дело со стартовыми 5000 кредитами: откройте банк или мастерскую, договоритесь с сотрудниками и клиентами."
	title = "Banker"
	description = "Богатый предприниматель: банк, мастерская, найм и бизнес."
	donor_tier = 5
	config_tag = "DONOR_BANKER"
	total_positions = 2
	spawn_positions = 2
	display_order = 41
	outfit = /datum/outfit/job/donor/banker
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	job_variant_specs = list(
		"default" = list("Банкир", /datum/outfit/job/donor/banker),
		"independent_banker" = list("Независимый банкир", /datum/outfit/job/donor/banker),
		"corporate" = list("Корпорат", /datum/outfit/job/donor/banker),
		"businessman" = list("Бизнесмен", /datum/outfit/job/donor/banker),
		"nt_banker" = list("Банкир НТ", /datum/outfit/job/donor/banker),
		"nt_corporate" = list("Корпорат НТ", /datum/outfit/job/donor/banker),
		"nt_businessman" = list("Бизнесмен НТ", /datum/outfit/job/donor/banker),
	)
