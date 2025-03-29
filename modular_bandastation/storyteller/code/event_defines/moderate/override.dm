/datum/round_event_control/brand_intelligence
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)
	event_group = /datum/event_group/bsod
	req_departments_power = list(STS_HEAD = 70)

/datum/round_event_control/carp_migration
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN)
	max_occurrences = 3
	event_group = /datum/event_group/guests

/datum/round_event_control/communications_blackout
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)
	req_departments_power = list(STS_ENG = 30)

/datum/round_event_control/fugitives
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMBAT)
	checks_antag_cap = TRUE

/datum/round_event_control/pirates
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMBAT, TAG_COMMUNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/ion_storm
	tags = list(TAG_TARGETED, TAG_ALIEN)
	event_group = /datum/event_group/bsod

/datum/round_event_control/processor_overload
	max_occurrences = 2
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/comms

/datum/round_event_control/radiation_leak
	tags = list(TAG_COMMUNAL)
	max_occurrences = 2
	req_departments_power = list(STS_MED = 40)

/datum/round_event_control/radiation_storm
	weight = 5
	max_occurrences = 1
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/supermatter_surge
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)
	event_group = /datum/event_group/error
	req_departments_power = list(STS_ENG = 60)

/datum/round_event_control/stray_meteor
	tags = list(TAG_DESTRUCTIVE, TAG_SPACE)
	event_group = /datum/event_group/debris
	req_departments_power = list(STS_ENG = 60)

/datum/round_event_control/shuttle_catastrophe
	tags = list(TAG_COMMUNAL)
	req_departments_power = list(STS_HEAD = 50)

/datum/round_event_control/shuttle_insurance
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/vent_clog
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/anomaly
	weight = 10 // Lower from original 15 because it KEEPS SPAWNING THEM
	tags = list(TAG_DESTRUCTIVE, TAG_MAGICAL)
	event_group = /datum/event_group/anomalies
	req_departments_power = list(STS_RND = 30)

/datum/round_event_control/portal_storm_narsie
	tags = list(TAG_COMBAT)

/datum/round_event_control/obsessed
	weight = 0 // use storyteller variants instead

/datum/round_event_control/gravity_generator_blackout
	tags = list(TAG_COMMUNAL, TAG_SPACE)
	event_group = /datum/event_group/bsod
	weight = 8
	max_occurrences = 2
	req_departments_power = list(STS_ENG = 30)

/datum/round_event_control/grey_tide
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY)
	event_group = /datum/event_group/meteors

/datum/round_event_control/heart_attack
	tags = list(TAG_TARGETED, TAG_MAGICAL)
	req_departments_power = list(STS_MED = 30)

/datum/round_event_control/sandstorm
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL)
	event_group = /datum/event_group/debris

/datum/round_event_control/wormholes
	weight = 7
	tags = list(TAG_COMMUNAL, TAG_MAGICAL)
	event_group = /datum/event_group/anomalies

/datum/round_event_control/immovable_rod
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_MAGICAL)
	req_departments_power = list(STS_ENG = 50)

/datum/round_event_control/changeling
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN)
	event_group = /datum/event_group/comms
	checks_antag_cap = TRUE

/datum/round_event_control/nightmare
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/revenant
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY, TAG_EXTERNAL, TAG_MAGICAL)
	checks_antag_cap = TRUE

/datum/round_event_control/anomaly/anomaly_vortex
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE)
	req_departments_power = list(STS_RND = 70)
	weight = 5

/datum/round_event_control/anomaly/anomaly_pyro
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE)
	req_departments_power = list(STS_RND = 70, STS_ENG = 40)
	weight = 5

/datum/round_event_control/spacevine
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_ALIEN)
	checks_antag_cap = TRUE
	event_group = /datum/event_group/guests
	req_departments_power = list(STS_MED = 50)
	weight = 5

/datum/round_event_control/abductor
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_TARGETED, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event_control/meteor_wave/dust_storm
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPACE, TAG_DESTRUCTIVE)
	event_group = /datum/event_group/meteors
	req_departments_power = list(STS_ENG = 80)

/datum/round_event_control/bureaucratic_error
	track = EVENT_TRACK_MODERATE // if you've ever dealt with 10 mimes you understand why.
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/error
	weight = 5
	max_occurrences = 1
	req_departments_power = list(STS_HEAD = 80)
