/datum/job/donor/vip_guest
	important_information = "Вы особый гость NT со стартовыми 2000 кредитами. Ваш статус не отменяет законы корпорации и правила сервера."
	title = "VIP Corporate Guest"
	description = "Особый гость NT; РП-статус не отменяет законы и правила."
	donor_tier = 5
	config_tag = "DONOR_VIP_GUEST"
	total_positions = -1
	spawn_positions = -1
	display_order = 40
	outfit = /datum/outfit/job/donor/vip_guest
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	job_variant_specs = list(
		"default" = list("VIP-гость корпорации", /datum/outfit/job/donor/vip_guest),
		"vip_guest" = list("VIP Гость", /datum/outfit/job/donor/vip_guest),
		"vip_person" = list("VIP Персона", /datum/outfit/job/donor/vip_guest),
		"nt_vip_guest" = list("VIP Гость NT", /datum/outfit/job/donor/vip_guest),
		"nt_vip_person" = list("VIP Персона NT", /datum/outfit/job/donor/vip_guest),
		"nt_corporate_guest" = list("Гость Корпорации NT", /datum/outfit/job/donor/vip_guest),
	)
