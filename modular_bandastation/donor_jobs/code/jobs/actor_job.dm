/datum/job/donor/actor
	important_information = "Устраивайте сценические представления, приглашайте гостей и выступайте вместе с другими артистами."
	variant_information = list(
		/datum/outfit/job/donor/actor/painter = "Создавайте картины, рисунки и инсталляции штатными художественными инструментами. Согласовывайте размещение работ с владельцами помещений.",
	)
	title = "Actor"
	description = "Шоу, сцена и совместные представления с другими артистами."
	donor_tier = 2
	config_tag = "DONOR_ACTOR"
	total_positions = 5
	spawn_positions = 5
	display_order = 28
	outfit = /datum/outfit/job/donor/actor
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Актёр", /datum/outfit/job/donor/actor),
		"artist" = list("Артист", /datum/outfit/job/donor/actor),
		"standup_comedian" = list("Стендапер", /datum/outfit/job/donor/actor),
		"comedian" = list("Комедиант", /datum/outfit/job/donor/actor/comedian),
		"variety_artist" = list("Эстрадный артист", /datum/outfit/job/donor/actor),
		"painter" = list("Художник", /datum/outfit/job/donor/actor/painter),
		"creator" = list("Творец", /datum/outfit/job/donor/actor/painter),
		"art_critic" = list("Искусствовед", /datum/outfit/job/donor/actor/painter),
		"landscape_painter" = list("Пейзажист", /datum/outfit/job/donor/actor/painter),
		"photorealist" = list("Фотореалист", /datum/outfit/job/donor/actor/painter),
		"performance_artist" = list("Перформанс-артист", /datum/outfit/job/donor/actor/painter),
	)
