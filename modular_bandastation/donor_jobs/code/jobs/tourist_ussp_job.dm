/datum/job/donor/tourist_ussp
	important_information = "Вы турист КССП: отдыхайте, общайтесь и находите подработку. Законы NT действуют и на вас; межгосударственные разногласия не разрешают нарушать правила."
	title = "Tourist USSP"
	description = "Отдых и подработки иностранного посетителя; законы NT действуют, дипломатического иммунитета нет."
	donor_tier = 3
	config_tag = "DONOR_TOURIST_USSP"
	total_positions = -1
	spawn_positions = -1
	display_order = 31
	outfit = /datum/outfit/job/donor/tourist_ussp
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_variant_specs = list(
		"default" = list("Турист КССП", /datum/outfit/job/donor/tourist_ussp),
		"visitor" = list("Посетитель КССП", /datum/outfit/job/donor/tourist_ussp),
	)
