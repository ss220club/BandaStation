/datum/round_event_control/spider_infestation
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_ALIEN)
	weight = 2

/datum/round_event_control/blob
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_EXTERNAL, TAG_ALIEN)
	earliest_start = 60 MINUTES
	checks_antag_cap = TRUE
	event_group = /datum/event_group/blobs
