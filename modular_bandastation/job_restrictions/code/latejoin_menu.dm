/datum/latejoin_menu/proc/is_job_allowed_for_species(
	datum/job/job_datum,
	mob/dead/new_player/owner
)
	var/species = owner.client?.prefs?.read_preference(/datum/preference/choiced/species)
	if(!species)
		return TRUE

	if(species == /datum/species/human)
		return TRUE

	var/list/job_restrictions = CONFIG_GET(str_list/job_restrictions)
	return !(job_datum.title in job_restrictions)

/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/owner = user
	var/list/departments = list()
	var/list/data = list(
		"disable_jobs_for_non_observers" = SSlag_switch.measures[DISABLE_NON_OBSJOBS],
		"round_duration" = DisplayTimeText(world.time - SSticker.round_start_time, round_seconds_to = 1),
		"departments" = departments,
	)

	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				data["shuttle_status"] = "The station has been evacuated."
			if(SHUTTLE_CALL, SHUTTLE_DOCKED, SHUTTLE_IGNITING, SHUTTLE_ESCAPE)
				if(!SSshuttle.canRecall())
					data["shuttle_status"] = "The station is currently undergoing evacuation procedures."

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"open_slots" = 0,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			if(LAZYLEN(job_datum.departments_list) > 1 \
				&& job_datum.departments_list[1] != department.type \
				&& !(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue

			if(!is_job_allowed_for_species(job_datum, owner))
				continue

			var/job_availability = owner.IsJobUnavailable(job_datum.title, latejoin = TRUE)

			var/list/job_data = list(
				"prioritized" = (job_datum in SSjob.prioritized_jobs),
				"used_slots" = job_datum.current_positions,
				"open_slots" = job_datum.total_positions < 0 ? "∞" : job_datum.total_positions,
			)

			if(job_availability != JOB_AVAILABLE)
				if(job_datum.job_flags & JOB_HIDE_WHEN_EMPTY)
					continue
				job_data["unavailable_reason"] = get_job_unavailable_error_message(job_availability, job_datum.title)

			if(job_datum.total_positions < 0)
				department_data["open_slots"] = "∞"

			if(department_data["open_slots"] != "∞")
				if(job_datum.total_positions - job_datum.current_positions > 0)
					department_data["open_slots"] += job_datum.total_positions - job_datum.current_positions

			department_jobs[job_datum.title] = job_data

	return data

/datum/latejoin_menu/ui_static_data(mob/user)
	var/list/departments = list()
	var/mob/dead/new_player/owner = user

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"color" = department.ui_color,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			if(LAZYLEN(job_datum.departments_list) > 1 \
				&& job_datum.departments_list[1] != department.type \
				&& !(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue

			if((job_datum.job_flags & JOB_HIDE_WHEN_EMPTY) \
				&& owner.IsJobUnavailable(job_datum.title, latejoin = TRUE) != JOB_AVAILABLE)
				continue

			// not really static anymore, but who cares
			if(!is_job_allowed_for_species(job_datum, owner))
				continue

			var/list/job_data = list(
				"command" = !!(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
				"description" = job_datum.description,
			)

			department_jobs[job_datum.title] = job_data

	return list("departments_static" = departments)
