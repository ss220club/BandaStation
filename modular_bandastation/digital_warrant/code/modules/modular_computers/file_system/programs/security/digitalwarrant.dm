/datum/computer_file/program/digitalwarrant
	filename = "digitalwarrant"
	filedesc = "Warrant Assistant"
	extended_desc = "Позволяет пользователю создавать, редактировать и просматривать цифровые ордера."
	program_icon = "id-card"
	tgui_id = "NtosDigitalWarrant"
	size = 8
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	download_access = list(ACCESS_SECURITY, ACCESS_FLAG_COMMAND)

	var/datum/digital_warrant/active_warrant
	/// List of accesses that are allowed to authorize warrant access escalation
	var/static/list/warrant_authorizer_access = list(ACCESS_HOS, ACCESS_CAPTAIN, ACCESS_MAGISTRATE)

	var/last_icon_attempt


/datum/computer_file/program/digitalwarrant/proc/format_author(obj/item/card/id/I)
	if(!I)
		return "Unauthorized"
	var/name_part = sanitize(I.registered_name)
	var/assignment_part = I.assignment ? sanitize(I.assignment) : "(Unknown)"
	return "[name_part] - [assignment_part]"

/datum/computer_file/program/digitalwarrant/proc/has_warrant_authorizer_access(obj/item/card/id/I)
	if(!I)
		return FALSE
	for(var/access_flag in warrant_authorizer_access)
		if(access_flag in I.access)
			return TRUE
	return FALSE

/datum/computer_file/program/digitalwarrant/proc/serialize_warrant(datum/digital_warrant/W)
	return list(
		"id" = REF(W),
		"namewarrant" = W.namewarrant,
		"jobwarrant" = W.jobwarrant,
		"charges" = W.charges,
		"auth" = W.auth,
		"idauth" = W.idauth,
		"arrestsearch" = W.arrestsearch,
		"subject_icon" = W.subject_icon_b64,
	)

// Attempts to populate the subject icon cache for the active warrant (lazy generation)
/datum/computer_file/program/digitalwarrant/proc/ensure_subject_icon()
	if(!active_warrant)
		return

	if(active_warrant.subject_icon_b64)
		return // Already cached

	if(!isnull(last_icon_attempt) && world.time < last_icon_attempt + 50)
		return
	last_icon_attempt = world.time

	var/datum/record/crew/matched_record
	for(var/datum/record/crew/CR in GLOB.manifest.general)
		if(CR.name == active_warrant.namewarrant && CR.rank == active_warrant.jobwarrant)
			matched_record = CR
			break
	if(!matched_record)
		return

	var/obj/item/photo/front = matched_record.get_front_photo()
	if(!front || !front.picture?.picture_image)
		return
	var/icon/record_icon = front.picture.picture_image
	if(!record_icon)
		return

	var/icon/processed = process_subject_icon(record_icon)
	if(!processed)
		processed = record_icon
	active_warrant.subject_icon_b64 = icon2base64(processed)


#define DIGITAL_WARRANT_ICON_TARGET_SIZE 96
#define DIGITAL_WARRANT_ICON_HEAD_HEIGHT 16
/datum/computer_file/program/digitalwarrant/proc/process_subject_icon(icon/I)
	if(!I)
		return null
	var/icon/W = new(I)

	var/height = 32
	var/width = 32

	if(DIGITAL_WARRANT_ICON_HEAD_HEIGHT < height)
		var/start_y = max(1, height - DIGITAL_WARRANT_ICON_HEAD_HEIGHT + 1)

		W.Crop(1, start_y, width, height)

	W.Scale(DIGITAL_WARRANT_ICON_TARGET_SIZE, DIGITAL_WARRANT_ICON_TARGET_SIZE)
	return W

/datum/computer_file/program/digitalwarrant/ui_data(mob/user)
	var/list/data = list()
	var/list/crew_manifest = list()
	for(var/datum/record/crew/CR in GLOB.manifest.general)
		crew_manifest += list(list("name" = CR.name, "job" = CR.rank))
	data["crew_manifest"] = crew_manifest
	if(active_warrant)
		// Lazily attempt to (re)generate subject icon if absent
		ensure_subject_icon()
		data["active"] = serialize_warrant(active_warrant)
		data["warrants"] = null
	else
		var/list/listed = list()
		for(var/datum/digital_warrant/W in GLOB.all_warrants)
			listed += list(serialize_warrant(W))
		data["warrants"] = listed
		data["active"] = null
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
			active_warrant.charges = ""
			active_warrant.arrestsearch = "arrest"
			return TRUE
		if("add_search")
			active_warrant = new()
			active_warrant.charges = ""
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
			// Invalidate cached subject icon since subject identity changed
			active_warrant.subject_icon_b64 = null
			return TRUE
		if("edit_charges")
			if(!active_warrant)
				return TRUE
			active_warrant.charges = isnull(params["charges"]) ? active_warrant.charges : sanitize(params["charges"])
			return TRUE
		if("authorize")
			if(!active_warrant || !I)
				return TRUE
			active_warrant.auth = format_author(I)
			return TRUE
		if("authorize_access")
			if(!active_warrant || active_warrant.arrestsearch == "search" || !I)
				return TRUE
			// Allow broader set of high-authority roles instead of only HoS
			if(!has_warrant_authorizer_access(I))
				return TRUE
			// Locate the warrant subject once; from that derive the job datum
			var/datum/record/crew/warrant_subject
			for(var/datum/record/crew/CR in GLOB.manifest.general)
				if(CR.name == active_warrant.namewarrant && CR.rank == active_warrant.jobwarrant)
					warrant_subject = CR
					break
			if(!warrant_subject)
				return TRUE
			var/datum/job/J = SSjob.get_job(warrant_subject.rank)
			if(!J)
				return TRUE
			var/list/warrant_access = get_job_accesses(J)
			active_warrant.idauth = format_author(I)
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
		var/datum/job/trim_job = job_trim.find_job()
		if(trim_job && (trim_job == J || trim_job.type == J.type || trim_job.title == J.title))
			return job_trim.access.Copy()
	return list()
