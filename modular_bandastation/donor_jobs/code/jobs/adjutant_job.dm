/datum/job/donor/adjutant
	important_information = "Помогайте главам советами, документами и бытовыми делами. Подчиняйтесь главе персонала и капитану; вы не заменяете АВД или представителя NT."
	variant_information = list(
		/datum/outfit/job/donor/adjutant/butler = "Дворецкий: помогайте главам в бытовых делах и поддерживайте порядок на мостике. Подчинение и полномочия остаются адъютантскими.",
		/datum/outfit/job/donor/adjutant/maid = "Горничная: помогайте главам в бытовых делах и поддерживайте порядок на мостике. Подчинение и полномочия остаются адъютантскими.",
	)
	title = "Adjutant"
	description = "Помощник глав по документам, советам и бытовым вопросам. Подчинён HoP и капитану. Не АВД и не представитель NT."
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
		"default" = list("Помощник глав", /datum/outfit/job/donor/adjutant),
		"butler" = list("Butler", /datum/outfit/job/donor/adjutant/butler),
		"butler_ru" = list("Дворецкий", /datum/outfit/job/donor/adjutant/butler),
		"maid" = list("Maid", /datum/outfit/job/donor/adjutant/maid),
		"maid_ru" = list("Горничная", /datum/outfit/job/donor/adjutant/maid),
	)
