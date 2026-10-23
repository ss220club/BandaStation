/datum/preference_middleware/roundstart_roster

/datum/preference_middleware/roundstart_roster/get_ui_data(mob/user)
	return list("roundstart_roster_restrictions" = GLOB.roundstart_roster?.get_job_restrictions(user.ckey) || list())
