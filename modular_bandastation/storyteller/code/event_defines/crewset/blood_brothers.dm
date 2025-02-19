/datum/round_event_control/antagonist/solo/brother
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	typepath = /datum/round_event/antagonist/solo/brother
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG)
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_BLUESHIELD,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_MAGISTRATE,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_DETECTIVE,
		JOB_WARDEN,
		JOB_SECURITY_OFFICER,
	)
	required_enemies = 1
	weight = 15
	maximum_antags = 2
	maximum_antags_per_round = 2
	denominator = 30
	cost = 0.45 // so it doesn't eat up threat for a relatively low-threat antag

/datum/round_event_control/antagonist/solo/brother/roundstart
	name = "Antag-mix"
	roundstart = TRUE
	earliest_start = 0 SECONDS
	extra_spawned_events = list(
		/datum/round_event_control/antagonist/solo/traitor/adds = 12,
		/datum/round_event_control/antagonist/solo/heretic/adds = 10,
		/datum/round_event_control/antagonist/solo/changeling/adds = 8,
	)
	roundstart_cost = 20

/datum/round_event_control/antagonist/solo/brother/midround
	name = "Blood Brothers (Admin spawn)"
	earliest_start = 0 SECONDS
	extra_spawned_events = list(
		/datum/round_event_control/antagonist/solo/traitor/adds = 12,
		/datum/round_event_control/antagonist/solo/heretic/adds = 10,
		/datum/round_event_control/antagonist/solo/changeling/adds = 8,
	)
	weight = 0

/datum/round_event/antagonist/solo/brother/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/team/brother_team/team = new
	team.add_member(antag_mind)
	team.forge_brother_objectives()
	antag_mind.add_antag_datum(/datum/antagonist/brother, team)
	GLOB.pre_setup_antags -= antag_mind
