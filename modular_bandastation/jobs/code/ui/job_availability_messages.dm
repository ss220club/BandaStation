/// Additional admission codes; the native formatter owns its generic fallback.
/proc/get_additional_job_unavailable_message(availability)
	switch(availability)
		if(JOB_UNAVAILABLE_JOB_LOCK)
			return "Профессия недоступна по дополнительным условиям входа."
		if(JOB_UNAVAILABLE_CHARACTER_PROFILE)
			return "Назначенный персонаж не проходит условия профессии. Проверьте слот, возраст, вид и повторный вход."
	return null
