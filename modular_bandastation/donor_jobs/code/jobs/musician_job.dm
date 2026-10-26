/datum/job/donor/musician
	important_information = "Играйте музыку, устраивайте концерты и выступайте вместе с другими артистами."
	title = "Musician"
	description = "Музыкальная атмосфера."
	donor_tier = 2
	config_tag = "DONOR_MUSICAN"
	total_positions = 1
	spawn_positions = 1
	display_order = 27
	outfit = /datum/outfit/job/donor/musician
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Музыкант", /datum/outfit/job/donor/musician),
		"maestro" = list("Маэстро", /datum/outfit/job/donor/musician/keyboard),
		"guitarist" = list("Гитарист", /datum/outfit/job/donor/musician),
		"drummer" = list("Барабанщик", /datum/outfit/job/donor/musician/drummer),
		"pianist" = list("Пианист", /datum/outfit/job/donor/musician/keyboard),
		"piper" = list("Волынщик", /datum/outfit/job/donor/musician/keyboard),
		"violinist" = list("Скрипач", /datum/outfit/job/donor/musician/violinist),
		"jester" = list("Скоморох", /datum/outfit/job/donor/musician/jester),
		"saxophonist" = list("Саксофонист", /datum/outfit/job/donor/musician/saxophonist),
		"soloist" = list("Солист", /datum/outfit/job/donor/musician/vocalist),
		"singer" = list("Певец", /datum/outfit/job/donor/musician/vocalist),
		"touring_musician" = list("Гастролёр", /datum/outfit/job/donor/musician/touring_musician),
	)
