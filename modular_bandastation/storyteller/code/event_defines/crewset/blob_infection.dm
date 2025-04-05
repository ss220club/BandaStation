/datum/round_event_control/antagonist/solo/blob
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_EXTERNAL, TAG_ALIEN)
	earliest_start = 60 MINUTES
	checks_antag_cap = TRUE
	antag_flag = ROLE_BLOB_INFECTION
	min_players = 20
	antag_datum = /datum/antagonist/blob/infection
	maximum_antags = 1
	event_group = /datum/event_group/blobs

/datum/round_event_control/antagonist/solo/blob/midround
	name = "Blob infection (Blob)"
	prompted_picking = FALSE
