/datum/outfit/job/assistant
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	shoes = /obj/item/clothing/shoes/laceup
	id_trim = /datum/id_trim/job/ussp_assistant
	pda_slot = null

/datum/job/assistant
	title = "Безработный"
	departments_list = list(
		/datum/job_department/assistant,
	)
	department_for_prefs = /datum/job_department/assistant

/datum/id_trim/job/ussp_assistant
	assignment = "Безработный"
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/assistant
