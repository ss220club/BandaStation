/datum/job/donor/adjutant
	important_information = "Помогайте главам советами, документами и бытовыми делами. Подчиняйтесь главе персонала и капитану."
	variant_information = list(
		/datum/outfit/job/donor/adjutant/butler = "Дворецкий: помогайте главам в бытовых делах и поддерживайте порядок на мостике. Подчинение и полномочия остаются адъютантскими.",
		/datum/outfit/job/donor/adjutant/maid = "Горничная: помогайте главам в бытовых делах и поддерживайте порядок на мостике. Подчинение и полномочия остаются адъютантскими.",
	)
	title = "Adjutant"
	description = "Помощник глав по документам, советам и бытовым вопросам. Подчинён главе персонала и капитану."
	donor_tier = 4
	config_tag = "DONOR_ADJUTANT"
	total_positions = 3
	spawn_positions = 3
	display_order = 36
	outfit = /datum/outfit/job/donor/adjutant
	supervisors = "главой персонала и капитаном"
	departments_list = list(/datum/job_department/service)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Адъютант", /datum/outfit/job/donor/adjutant),
		"butler" = list("Дворецкий", /datum/outfit/job/donor/adjutant/butler),
		"maid" = list("Горничная", /datum/outfit/job/donor/adjutant/maid),
	)
