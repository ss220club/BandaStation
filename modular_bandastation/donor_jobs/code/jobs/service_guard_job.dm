/datum/job/donor/service_guard
	important_information = "Поддерживайте порядок в отделе обслуживания. Согласовывайте действия с сотрудниками отдела и службой безопасности: должность не даёт полномочий офицера службы безопасности."
	title = "Guard"
	description = "Порядок в баре и на кухне. Не сотрудник службы безопасности и не охотник на антагонистов."
	donor_tier = 3
	config_tag = "DONOR_GUARD"
	total_positions = 1
	spawn_positions = 1
	display_order = 33
	outfit = /datum/outfit/job/donor/service_guard
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	job_variant_specs = list(
		"default" = list("Охранник", /datum/outfit/job/donor/service_guard),
		"bodyguard" = list("Телохранитель", /datum/outfit/job/donor/service_guard),
		"external_guard" = list("Сторож", /datum/outfit/job/donor/service_guard),
		"technical_guard" = list("Технический охранник", /datum/outfit/job/donor/service_guard),
		"bouncer" = list("Вышибала", /datum/outfit/job/donor/service_guard),
	)

/// Preserve the selected role when reading the former, misleading variant ID.
/datum/job/donor/service_guard/resolve_job_variant(variant_id)
	return ..(variant_id == "personal_guard" ? "bouncer" : variant_id)
