/datum/latejoin_menu/proc/is_latejoin_selection_current(mob/dead/new_player/owner, list/params, datum/latejoin_profile_snapshot/context)
	return owner?.is_latejoin_request_current(context) && params["edit_slot"] == context.editing_slot

/datum/latejoin_menu/proc/is_latejoin_random_job_allowed(mob/dead/new_player/owner, datum/job/job)
	var/client/requester = owner?.client
	return job && requester && !requester.interviewee && (!job.requires_explicit_preference() || requester.prefs.job_preferences[job.title])


/// Adapt the original species helper's input; its config and station-trait checks still run.
/datum/latejoin_menu/proc/get_job_character_species(job_title, mob/dead/new_player/owner)
	var/datum/job/job = SSjob.get_job(job_title)
	if(!job || !owner.client)
		return null
	var/datum/job_character_selection/selection = owner.client.prefs.select_job_character(job, TRUE)
	var/species = selection.species
	qdel(selection)
	return species

/// Display the same selected profile and variant that admission will use.
/datum/latejoin_menu/proc/get_job_character_data(datum/job/job, mob/dead/new_player/user)
	if(!user.client)
		return list("public_title" = job_title_ru(job.title), "command" = !!(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND), "description" = job.description)
	var/datum/preferences/preferences = user.client.prefs
	var/datum/job_character_selection/character = preferences.select_job_character(job, TRUE)
	var/public_title = job.get_character_job_title(character)
	var/profile_name = character.read_preference(/datum/preference/name/real_name)
	var/profile_description = character.error ? "Недоступный профиль" : "Профиль [character.slot]: [profile_name]"
	if(character.randomized)
		profile_description += ", случайные имя и внешность"
	var/list/data = list(
		"command" = !!(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
		"description" = job.description,
		"public_title" = public_title,
		"character_profile" = profile_description,
		"job_icon" = icon2base64(job.get_character_job_icon(character)),
	)
	qdel(character)
	return data

/// Enrich only native dynamic rows: hidden jobs stay hidden and eligibility is not repeated.
/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/owner = user
	var/datum/latejoin_profile_snapshot/profile_context = owner.capture_latejoin_request()
	if(!profile_context)
		return list()
	. = ..()
	if(!owner?.is_latejoin_request_current(profile_context))
		return list()
	var/list/data = .
	data["edit_slot"] = profile_context.editing_slot
	var/list/departments = data["departments"]
	for(var/department_name in departments)
		var/list/department_data = departments[department_name]
		department_data["open_slots"] = 0
		var/list/department_jobs = department_data["jobs"]
		for(var/job_title in department_jobs)
			extend_job_character_data(SSjob.get_job(job_title), user, department_jobs[job_title], department_data)

/// Extend one completed row and count only vacancies available to this player.
/datum/latejoin_menu/proc/extend_job_character_data(datum/job/job, mob/dead/new_player/user, list/job_data, list/department_data)
	job_data += get_job_character_data(job, user)
	var/availability = job_data["availability"]
	if(availability != JOB_AVAILABLE)
		if(availability == JOB_UNAVAILABLE_JOB_LOCK)
			job_data["unavailable_reason"] = job.get_join_lock_reason(user.client) || job_data["unavailable_reason"]
		return
	if(job.total_positions < 0)
		department_data["open_slots"] = "∞"
	if(department_data["open_slots"] != "∞")
		if(job.total_positions - job.current_positions > 0)
			department_data["open_slots"] += job.total_positions - job.current_positions
