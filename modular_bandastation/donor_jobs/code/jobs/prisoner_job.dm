/datum/job/prisoner
	important_information = "Вы ЗАКЛЮЧЕННЫЙ. Вы не являетесь антагонистом на сервере и данная роль не позволяет вам нарушать правила сервера. \
		Вы находитесь на временном содержании в бриге станции принадлежащей Нанотрейзен за преступление против \
		корпорации и теперь отбываете свой срок.  Вы заинтересованы в том чтобы попасть на волю за хорошее поведение, но \
		если выдастся случай для побега - вам никто не запретит этим воспользоваться, верно?  Избегайте любых действий \
		которые могут привести к вашей гибели. Вы не служите Синдикату и не заинтересованы помогать им, если не \
		являетесь антагонистом, но если они помогут вам - то почему бы и да."
	job_variant_specs = list(
		"default" = list("Заключённый", /datum/outfit/job/prisoner),
		"prisoner" = list("Заключенный", /datum/outfit/job/prisoner),
		"felon" = list("Уголовник", /datum/outfit/job/prisoner),
		"lawbreaker" = list("Законопреступник", /datum/outfit/job/prisoner),
		"permanent_prisoner" = list("Пермазаключенный", /datum/outfit/job/prisoner),
		"illegal_migrant" = list("Нелегальный Мигрант", /datum/outfit/job/prisoner),
		"illegal_worker" = list("Нелегальный Работник", /datum/outfit/job/prisoner),
		"lifer" = list("Пожизненно-Заключенный", /datum/outfit/job/prisoner),
		"political_prisoner" = list("Политический Заключенный", /datum/outfit/job/prisoner),
		"criminal" = list("Заключенный Преступник", /datum/outfit/job/prisoner),
		"bandit" = list("Заключенный Бандит", /datum/outfit/job/prisoner),
		"conman" = list("Заключенный Мошенник", /datum/outfit/job/prisoner),
		"thief" = list("Заключенный Вор", /datum/outfit/job/prisoner),
		"murderer" = list("Заключенный Убийца", /datum/outfit/job/prisoner),
		"drug_dealer" = list("Заключенный Наркоторговец", /datum/outfit/job/prisoner),
		"recidivist" = list("Заключенный Рецидивист", /datum/outfit/job/prisoner),
		"saboteur" = list("Заключенный Саботер", /datum/outfit/job/prisoner),
		"torturer" = list("Заключенный Мучитель", /datum/outfit/job/prisoner),
		"swindler" = list("Заключенный Жулик", /datum/outfit/job/prisoner),
		"scoundrel" = list("Заключенный Негодяй", /datum/outfit/job/prisoner),
		"hooligan" = list("Заключенный Хулиган", /datum/outfit/job/prisoner),
		"nt_enemy" = list("Заключенный Враг-NT", /datum/outfit/job/prisoner),
		"mafioso" = list("Заключенный Мафиози", /datum/outfit/job/prisoner),
		"corrupt_official" = list("Заключенный Коррупционер", /datum/outfit/job/prisoner),
		"psychopath" = list("Заключенный Психопат", /datum/outfit/job/prisoner),
		"counterfeiter" = list("Заключенный Фальшивокредитчик", /datum/outfit/job/prisoner),
		"slaver" = list("Заключенный Работорговец", /datum/outfit/job/prisoner),
	)

/datum/job/prisoner/config_check()
	if(CONFIG_GET(flag/donor_prisoner_gate))
		allow_bureaucratic_error = FALSE
		if(isnull(CHECK_MAP_JOB_CHANGE(title, "total_positions")))
			total_positions = 5
		if(isnull(CHECK_MAP_JOB_CHANGE(title, "spawn_positions")))
			spawn_positions = 3
		random_spawns_possible = FALSE
	return ..()

/datum/job/prisoner/get_job_variants()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return list()
	return ..()

/datum/job/prisoner/requires_explicit_preference()
	return CONFIG_GET(flag/donor_prisoner_gate)
