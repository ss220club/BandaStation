/datum/job/cargo_technician
	important_information = "Доставляйте товары, ресурсы и еду между отделами. Вы сотрудник снабжения и подчиняетесь квартирмейстеру."
	job_variant_specs = list(
		"default" = list(JOB_CARGO_TECHNICIAN_RU, /datum/outfit/job/cargo_tech),
		"deliverer" = list("Доставщик", /datum/outfit/job/cargo_tech/deliverer),
		"porter" = list("Переносчик", /datum/outfit/job/cargo_tech/deliverer),
	)

/// Saved selections of the former Russian duplicate still use the Deliverer outfit.
/datum/job/cargo_technician/resolve_job_variant(variant_id)
	return ..(variant_id == "deliverer_ru" ? "deliverer" : variant_id)
