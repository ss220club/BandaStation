/datum/job/tsf_army_officer
	title = "Армейский офицер ТСФ"
	supervisors = "полковником"
	description = "Командуйте своим отделением резервистов. Приведите ТСФ к победе если начнется битва!"
	departments_list = list(
		/datum/job_department/command,
	)
	outfit = /datum/outfit/tsf/marine/officer/carwo
	faction = FACTION_STATION
	total_positions = 3
	spawn_positions = 3
	event_description = "Вам удалось дослужиться до звания младшего офицера и теперь в вашем распоряжении небольшой отряд или целый взвод, которые будут исполнять ваши приказы! Обязательно посетите брифинг в основном здании посольства и получите задачи у полковника."

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/command
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/outfit/tsf/marine/officer/carwo
	id_trim = /datum/id_trim/job/tsf/marine/officer

/datum/id_trim/job/tsf/marine/officer
	assignment = "TSF - Marine Officer"
	trim_state = "trim_tsf_rank2"
	big_pointer = TRUE
	job = /datum/job/tsf_army_officer
