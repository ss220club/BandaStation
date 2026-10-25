/datum/modpack/donor_jobs/proc/register_donor_job_titles()
	GLOB.job_titles_ru += list(
		"Barber" = "Парикмахер",
		"Bath" = "Банщик",
		"Casino" = "Крупье",
		"Waiter" = "Официант",
		"Acolyte" = "Послушник",
		"Wrestler" = "Борец",
		"Musician" = "Музыкант",
		"Actor" = "Актёр",
		"Administrator" = "Сервис-администратор",
		"Tourist TSF" = "Турист ТСФ",
		"Tourist USSP" = "Турист КССП",
		"Cleaning Manager" = "Менеджер по клинингу",
		"Guard" = "Охранник сервиса",
		"Migrant" = "Мигрант",
		"Uncertain" = "Безработный",
		"Adjutant" = "Адъютант",
		"Representative TSF" = "Представитель ТСФ",
		"Representative USSP" = "Представитель КССП",
		"Dealer" = "Торговец",
		"VIP Corporate Guest" = "VIP-гость корпорации",
		"Banker" = "Банкир",
		"Security Clown" = "Клоун службы безопасности",
	)
	GLOB.job_titles_ru_to_en.Cut()
	// Build the native cache, then keep the same ambiguous-title priority as TGUI.
	job_title_ru_to_en(JOB_BRIDGE_ASSISTANT_RU)
	GLOB.job_titles_ru_to_en[JOB_BRIDGE_ASSISTANT_RU] = JOB_BRIDGE_ASSISTANT
