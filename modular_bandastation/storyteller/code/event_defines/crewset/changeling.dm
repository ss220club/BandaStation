/datum/round_event_control/antagonist/solo/changeling
	antag_flag = ROLE_CHANGELING
	tags = list(TAG_COMBAT, TAG_ALIEN)
	antag_datum = /datum/antagonist/changeling
	protected_roles = list(
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
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	min_players = 20
	maximum_antags_per_round = 3

/datum/round_event_control/antagonist/solo/changeling/adds
	name = "Changelings"
	roundstart = TRUE
	earliest_start = 0
	roundstart_cost = 20

/datum/round_event_control/antagonist/solo/changeling/solomode
	name = "Changelings"
	roundstart = TRUE
	earliest_start = 0
	base_antags = 1
	maximum_antags = 1
	roundstart_cost = 24
	exclusive_roundstart_event = TRUE
	price_to_buy_adds = 30

/datum/round_event_control/antagonist/solo/changeling/midround
	name = "Genome Awakening (Changelings)"
	prompted_picking = FALSE
	can_change_count = TRUE
