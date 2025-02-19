/datum/round_event_control/antagonist/solo/traitor
	antag_flag = ROLE_SYNDICATE_INFILTRATOR
	tags = list(TAG_COMBAT)
	antag_datum = /datum/antagonist/traitor
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

/datum/round_event_control/antagonist/solo/traitor/adds
	name = "Traitors"
	weight = 0
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	earliest_start = 0 SECONDS
	roundstart_cost = 15

/datum/round_event_control/antagonist/solo/traitor/solomode
	name = "Traitors"
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	roundstart = TRUE
	earliest_start = 0 SECONDS
	base_antags = 1
	maximum_antags = 1
	roundstart_cost = 15
	exclusive_roundstart_event = TRUE
	price_to_buy_adds = 20

/datum/round_event_control/antagonist/solo/traitor/midround
	name = "Sleeper Agents (Traitors)"
	antag_flag = ROLE_SLEEPER_AGENT
	antag_datum = /datum/antagonist/traitor
	prompted_picking = FALSE
	can_change_count = TRUE
