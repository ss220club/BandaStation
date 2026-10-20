/datum/job/cargo_technician
	important_information = "Доставляйте товары, ресурсы и еду между отделами. Вы сотрудник снабжения и подчиняетесь квартирмейстеру."
	job_variant_specs = list(
		"default" = list(JOB_CARGO_TECHNICIAN_RU, /datum/outfit/job/cargo_tech),
		"deliverer" = list("Deliverer", /datum/outfit/job/cargo_tech/deliverer),
		"deliverer_ru" = list("Доставщик", /datum/outfit/job/cargo_tech/deliverer),
		"porter" = list("Переносчик", /datum/outfit/job/cargo_tech/deliverer),
	)
