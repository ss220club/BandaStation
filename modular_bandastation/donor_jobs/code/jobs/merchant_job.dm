/datum/job/donor/merchant
	important_information = "Обустройте торговую точку и продавайте гражданские товары экипажу. Стартовый ассортимент находится в рюкзаке; дальнейшие сделки заключайте с другими жителями станции."
	title = "Dealer"
	description = "Гражданская торговля: небольшой стартовый ассортимент и сделки с экипажем."
	donor_tier = 4
	config_tag = "DONOR_DEALER"
	total_positions = 2
	spawn_positions = 2
	display_order = 39
	outfit = /datum/outfit/job/donor/merchant
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Торговец", /datum/outfit/job/donor/merchant),
		"security_seller" = list("Независимый торговец", /datum/outfit/job/donor/merchant),
		"merchant" = list("Купец", /datum/outfit/job/donor/merchant),
		"philanthropist" = list("Меценат", /datum/outfit/job/donor/merchant),
		"trader" = list("Коммерсант", /datum/outfit/job/donor/merchant),
		"junk_dealer" = list("Барахольщик", /datum/outfit/job/donor/merchant),
	)
