/datum/job/donor/tourist_tsf
	important_information = "Вы турист ТСФ: отдыхайте, общайтесь и находите подработку. Законы NT действуют и на вас; межгосударственные разногласия не разрешают нарушать правила."
	title = "Tourist TSF"
	description = "Отдых и подработки иностранного посетителя; законы NT действуют. Вражда государств не разрешает нарушать правила."
	donor_tier = 3
	config_tag = "DONOR_TOURIST_TSF"
	total_positions = -1
	spawn_positions = -1
	display_order = 30
	outfit = /datum/outfit/job/donor/tourist_tsf
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_variant_specs = list(
		"default" = list("Турист ТСФ", /datum/outfit/job/donor/tourist_tsf),
		"visitor" = list("Посетитель ТСФ", /datum/outfit/job/donor/tourist_tsf),
	)
