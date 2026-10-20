/datum/job/donor/security_clown
	important_information = "Поддерживайте мораль сотрудников службы безопасности и подчиняйтесь начальнику отдела. Вы остаётесь клоуном с обязанностями перед NT; не охотьтесь за антагонистами, пока есть действующие офицеры."
	title = "Security Clown"
	description = "Поддерживайте мораль сотрудников СБ и подчиняйтесь начальнику отдела. Вы остаётесь клоуном: не охотьтесь за антагонистами, пока есть действующие офицеры."
	donor_tier = 5
	config_tag = "DONOR_SECLOWN"
	total_positions = 1
	spawn_positions = 1
	display_order = 42
	outfit = /datum/outfit/job/clown/security
	supervisors = JOB_HEAD_OF_SECURITY_RU
	departments_list = list(/datum/job_department/security)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	plasmaman_outfit = /datum/outfit/plasmaman/clown
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_NAIVE)
	liver_traits = list(TRAIT_COMEDY_METABOLISM)
	job_variant_specs = list(
		"default" = list("Клоун СБ", /datum/outfit/job/clown/security),
		"security_clown" = list("Клоун Службы Безопасности", /datum/outfit/job/clown/security),
		"detective" = list("Клоун-Детектив", /datum/outfit/job/clown/security/detective),
		"warden" = list("Клоун-Смотритель", /datum/outfit/job/clown/security/warden),
		"honkective" = list("Хонкектив", /datum/outfit/job/clown/security/detective),
		"cadet" = list("Клоун Кадет", /datum/outfit/job/clown/security/cadet),
	)

/datum/job/donor/security_clown/after_spawn(mob/living/spawned, client/player_client)
	if(ishuman(spawned))
		var/mob/living/carbon/human/human = spawned
		if(!human.job_variant_context?.identity_applied)
			human.apply_pref_name(/datum/preference/name/clown, player_client)
	return ..()
