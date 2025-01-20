/datum/round_event_control/bureaucratic_error
	track = EVENT_TRACK_MAJOR // if you've ever dealt with 10 mimes you understand why.
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/error
	weight = 5
	max_occurrences = 1
	head_required_power = 3

/datum/round_event_control/earthquake
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE)
	eng_required_power = 2

/datum/round_event_control/meteor_wave
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMMUNAL, TAG_SPACE, TAG_DESTRUCTIVE)
	event_group = /datum/event_group/meteors
	eng_required_power = 3

/datum/round_event_control/anomaly/anomaly_vortex
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE)
	rnd_required_power = 3

/datum/round_event_control/anomaly/anomaly_pyro
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE)
	rnd_required_power = 3

/datum/round_event_control/revenant
	min_players = 20
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY)

/datum/round_event_control/abductor
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_TARGETED, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/fugitives
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT)
	checks_antag_cap = TRUE

/datum/round_event_control/voidwalker
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_SPACE)

/datum/round_event_control/pirates
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_COMMUNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/operative
	track = EVENT_TRACK_MAJOR //this is a safe guard and does not trigger normally(technically it can but not really) so no tags
	checks_antag_cap = TRUE

/datum/round_event_control/wizard/round_start
	track = EVENT_TRACK_MAJOR
	weight = 5
	tags = list(TAG_COMMUNAL, TAG_DESTRUCTIVE)
	roundstart = TRUE

/datum/round_event_control/changeling
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN)
	event_group = /datum/event_group/comms
	checks_antag_cap = TRUE

/datum/round_event_control/slaughter
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event_control/portal_storm_syndicate
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT)
	event_group = /datum/event_group/guests

/datum/round_event_control/spacevine
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_ALIEN)
	checks_antag_cap = TRUE
	event_group = /datum/event_group/guests
	med_required_power = 2

/datum/round_event_control/morph
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/nightmare
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/revenant
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY, TAG_EXTERNAL, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event_control/portal_storm_monkey
	track = EVENT_TRACK_MAJOR
