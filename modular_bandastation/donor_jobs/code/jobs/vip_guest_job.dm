/datum/job/donor/vip_guest
	important_information = "Вы - особый и богатый гость Нанотрейзен. Ваш статус не отменяет космический закон."
	title = "VIP Corporate Guest"
	description = "Особый гость Нанотрейзен. Статус не отменяет космический закон."
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
		"vip_guest" = list("VIP-гость", /datum/outfit/job/donor/vip_guest),
		"vip_person" = list("VIP-персона", /datum/outfit/job/donor/vip_guest),
		"nt_vip_guest" = list("VIP-гость Нанотрейзен", /datum/outfit/job/donor/vip_guest),
		"nt_vip_person" = list("VIP-персона Нанотрейзен", /datum/outfit/job/donor/vip_guest),
		"nt_corporate_guest" = list("Гость корпорации Нанотрейзен", /datum/outfit/job/donor/vip_guest),
	)
