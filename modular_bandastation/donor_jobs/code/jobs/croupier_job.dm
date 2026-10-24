/datum/job/donor/croupier
	important_information = "Организуйте казино: раздавайте карты, проводите игры и соблюдайте договорённости с посетителями."
	title = "Casino"
	description = "Организация казино и азартных развлечений."
	donor_tier = 2
	config_tag = "DONOR_CASINO"
	total_positions = 3
	spawn_positions = 3
	display_order = 23
	outfit = /datum/outfit/job/donor/croupier
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Крупье", /datum/outfit/job/donor/croupier),
		"dealer" = list("Дилер", /datum/outfit/job/donor/croupier),
		"slot_assistant" = list("Слот-ассистент", /datum/outfit/job/donor/croupier),
		"pit_boss" = list("Пит-босс", /datum/outfit/job/donor/croupier),
	)
