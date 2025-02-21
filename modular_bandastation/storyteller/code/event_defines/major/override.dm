/datum/round_event_control/earthquake
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE)
	req_departments_power = list(STS_ENG = 70)

/datum/round_event_control/meteor_wave
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMMUNAL, TAG_SPACE, TAG_DESTRUCTIVE)
	event_group = /datum/event_group/meteors
	req_departments_power = list(STS_ENG = 90)

/datum/round_event_control/revenant
	min_players = 20
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY)

/datum/round_event_control/operative
	track = EVENT_TRACK_MAJOR //this is a safe guard and does not trigger normally(technically it can but not really) so no tags
	checks_antag_cap = TRUE

/datum/round_event_control/wizard/round_start
	track = EVENT_TRACK_MAJOR
	weight = 5
	tags = list(TAG_COMMUNAL, TAG_DESTRUCTIVE)
	roundstart = TRUE

/datum/round_event_control/slaughter
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event_control/portal_storm_syndicate
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT)
	event_group = /datum/event_group/guests

/datum/round_event_control/morph
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/portal_storm_monkey
	track = EVENT_TRACK_MAJOR
