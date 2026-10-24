/datum/job/donor/bath_attendant
	important_information = "Организуйте баню, отдых и встречи экипажа; следите за чистотой и удобством посетителей."
	title = "Bath"
	description = "Баня, отдых и встречи экипажа."
	donor_tier = 2
	config_tag = "DONOR_BATH"
	total_positions = 1
	spawn_positions = 1
	display_order = 22
	outfit = /datum/outfit/job/donor/bath_attendant
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Банщик", /datum/outfit/job/donor/bath_attendant),
		"bath_owner" = list("Хозяин бани", /datum/outfit/job/donor/bath_attendant),
		"bath_steamer" = list("Парильщик", /datum/outfit/job/donor/bath_attendant),
		"bath_master" = list("Пармейстер", /datum/outfit/job/donor/bath_attendant),
	)
