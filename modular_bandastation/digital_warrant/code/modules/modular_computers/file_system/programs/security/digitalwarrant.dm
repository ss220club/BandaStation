/datum/computer_file/program/digitalwarrant
	filename = "digitalwarrant"
	filedesc = "Warrant Assistant"
	extended_desc = "Позволяет пользователю создавать, редактировать и просматривать цифровые ордера."
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_icon = "warrant"
	tgui_id = "NtosDigitalWarrant"
	size = 8
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	download_access = list(ACCESS_SECURITY, ACCESS_FLAG_COMMAND)

	var/datum/digital_warrant/active_warrant

/datum/computer_file/program/digitalwarrant/proc/serialize_warrant(datum/digital_warrant/W)
	return list(
		"id" = REF(W),
		"namewarrant" = W.namewarrant,
		"jobwarrant" = W.jobwarrant,
		"charges" = W.charges,
		"auth" = W.auth,
		"idauth" = W.idauth,
		"arrestsearch" = W.arrestsearch,
	)

/datum/computer_file/program/digitalwarrant/ui_data(mob/user)
	var/list/data = list()
	if(active_warrant)
		data["active"] = serialize_warrant(active_warrant)
	else
		var/list/listed = list()
		for(var/datum/digital_warrant/W in GLOB.all_warrants)
			listed += list(serialize_warrant(W))
		data["warrants"] = listed
	return data

/datum/computer_file/program/digitalwarrant/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user_living = ui.user
	var/obj/item/card/id/I = user_living?.get_idcard(TRUE)
	switch(action)
		if("open")
			var/datum/digital_warrant/W = locate(params["id"]) in GLOB.all_warrants
			if(W)
				active_warrant = W
			return TRUE
		if("add_arrest")
			active_warrant = new()
			active_warrant.charges = "No charges present"
			active_warrant.arrestsearch = "arrest"
			return TRUE
		if("add_search")
			active_warrant = new()
			active_warrant.charges = "No reason given"
			active_warrant.arrestsearch = "search"
			return TRUE
		if("edit_name")
			if(!active_warrant)
				return TRUE
			active_warrant.namewarrant = isnull(params["name"]) ? active_warrant.namewarrant : sanitize(params["name"])
			active_warrant.jobwarrant = isnull(params["job"]) ? active_warrant.jobwarrant : sanitize(params["job"])
			active_warrant.auth = "Unauthorized"
			active_warrant.idauth = "Unauthorized"
			active_warrant.access = list()
			return TRUE
		if("edit_charges")
			if(!active_warrant)
				return TRUE
			active_warrant.charges = isnull(params["charges"]) ? active_warrant.charges : sanitize(params["charges"])
			return TRUE
		if("authorize")
			if(!active_warrant || !I)
				return TRUE
			active_warrant.auth = "[I.registered_name] - [I.assignment ? I.assignment : "(Unknown)"]"
			return TRUE
		if("authorize_access")
			if(!active_warrant || active_warrant.arrestsearch == "search" || !I)
				return TRUE
			if(!(ACCESS_CHANGE_IDS in I.access))
				return TRUE
			var/datum/record/crew/warrant_subject
			var/datum/job/J = SSjob.get_job(active_warrant.jobwarrant)
			if(!J)
				return TRUE
			for(var/datum/record/crew/CR in GLOB.manifest.general)
				if(CR.name == active_warrant.namewarrant && CR.rank == active_warrant.jobwarrant)
					warrant_subject = CR
					break
			if(!warrant_subject)
				return TRUE
			var/list/warrant_access = get_job_accesses(J)
			if(islist(warrant_access))
				warrant_access.Remove(SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND))
			active_warrant.idauth = "[I.registered_name] - [I.assignment ? I.assignment : "(Unknown)"]"
			active_warrant.access = warrant_access
			return TRUE
		if("save")
			if(!active_warrant)
				return TRUE
			GLOB.all_warrants |= active_warrant
			active_warrant = null
			return TRUE
		if("delete")
			var/datum/digital_warrant/W = locate(params["id"]) in GLOB.all_warrants
			if(W)
				GLOB.all_warrants -= W
			if(active_warrant == W)
				active_warrant = null
			return TRUE
		if("back")
			active_warrant = null
			return TRUE
	return FALSE

/**
 * Returns the configured access list for a given job, based on the job's ID trim singleton.
 */
/datum/computer_file/program/digitalwarrant/proc/get_job_accesses(datum/job/J)
	if(!istype(J))
		return list()
	// Search existing trim singletons for the one tied to this job and copy its access list
	for(var/trim_path in SSid_access.trim_singletons_by_path)
		var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]
		if(!istype(trim, /datum/id_trim/job))
			continue
		var/datum/id_trim/job/job_trim = trim
		if(job_trim.find_job() == J)
			return job_trim.access.Copy()
	return list()
