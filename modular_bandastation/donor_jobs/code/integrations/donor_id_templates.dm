/// Extend the initialized native template lists without changing CentCom authentication.
/datum/controller/subsystem/id_access/setup_tgui_lists()
	. = ..()
	for(var/trim_path in subtypesof(/datum/id_trim/job))
		var/datum/id_trim/job/trim = trim_singletons_by_path[trim_path]
		if(trim.centcom_template && trim.job)
			centcom_job_templates[trim_path] = trim.assignment
