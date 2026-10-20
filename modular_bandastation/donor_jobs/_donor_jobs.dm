/datum/modpack/donor_jobs
	name = "Donor jobs"
	desc = "Нативные профессии для подписчиков и варианты штатных профессий."
	author = "PhantornRU"

/datum/modpack/donor_jobs/initialize()
	. = ..()
	initialize_donor_station_traits()
	register_donor_job_titles()
