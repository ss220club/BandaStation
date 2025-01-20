/datum/round_event_control/antagonist/solo/heretic
	antag_flag = ROLE_HERETIC
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_MAGICAL)
	antag_datum = /datum/antagonist/heretic
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_BLUESHIELD,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_MAGISTRATE,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_DETECTIVE,
		JOB_WARDEN,
		JOB_SECURITY_OFFICER,
	)
	weight = 4
	min_players = 20

/datum/round_event_control/antagonist/solo/heretic/roundstart
	name = "Heretics"
	roundstart = TRUE
	earliest_start = 0

/datum/round_event_control/antagonist/solo/heretic/midround
	name = "Midround Heretics"
	prompted_picking = FALSE
	required_enemies = 3
