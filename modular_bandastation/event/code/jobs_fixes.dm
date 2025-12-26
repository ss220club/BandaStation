// Some crude fixes to disable runtimes and unnecessary behavior in various cases while using this event module

// We don't have heads in this event, so console is unable to get access from them.
/datum/computer_file/program/department_order/set_linked_department(datum/job_department/department)
	return

// We need 0 vanilla officer, but that proc overrides default var. We disable it.
/datum/controller/subsystem/job/setup_officer_positions()
	var/datum/job/J = SSjob.get_job(JOB_SECURITY_OFFICER)
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")
	J.total_positions = 0
	J.spawn_positions = 0

// We don't need load_jobs_from_config proc call
/datum/controller/subsystem/job/reset_occupations()
	job_debug("RO: Occupations reset.")
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player?.mind)
			continue
		player.mind.set_assigned_role(get_job_type(/datum/job/unassigned))
	setup_occupations()
	unassigned = list()
	//if(CONFIG_GET(flag/load_jobs_from_txt))
		// Any errors with the configs has already been said, we don't need to repeat them here.
		//load_jobs_from_config(silent = TRUE)
	overflow_role = /datum/job/assistant
	set_overflow_role(overflow_role)
	return

// Same thing.
/datum/controller/subsystem/job/Initialize()
	setup_job_lists()
	job_config_datum_singletons = generate_config_singletons() // we set this up here regardless in case someone wants to use the verb to generate the config file.
	if(!length(all_occupations))
		setup_occupations()
	//if(CONFIG_GET(flag/load_jobs_from_txt))
		//load_jobs_from_config()
	overflow_role = /datum/job/assistant
	set_overflow_role(overflow_role)
