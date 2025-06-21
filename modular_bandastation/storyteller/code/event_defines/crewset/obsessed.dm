/datum/round_event_control/antagonist/solo/obsessed
	antag_flag = ROLE_OBSESSED
	tags = list(TAG_COMBAT)
	antag_datum // потому-что антаг выдается через событие
	typepath = /datum/round_event/obsessed
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
		ROLE_POSITRONIC_BRAIN,
	)
	weight = 4
	max_occurrences = 3

/datum/round_event_control/antagonist/solo/obsessed/midround
	name = "Compulsive Obsession"
	prompted_picking = FALSE
	maximum_antags = 4
	can_change_count = TRUE

/datum/round_event/obsessed
	var/protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BLUESHIELD,
		JOB_MAGISTRATE,
		JOB_NANOTRASEN_REPRESENTATIVE,
	)
