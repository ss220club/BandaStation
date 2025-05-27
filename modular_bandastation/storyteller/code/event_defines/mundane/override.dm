/datum/round_event_control/space_dust
	track = EVENT_TRACK_MUNDANE
	weight = 10
	max_occurrences = 10
	tags = list(TAG_DESTRUCTIVE, TAG_SPACE)

/datum/round_event_control/camera_failure
	track = EVENT_TRACK_MUNDANE
	weight = 10
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)
	req_departments_power = list(STS_ENG = 30)

/datum/round_event_control/aurora_caelus
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_POSITIVE, TAG_SPACE)

/datum/round_event_control/brain_trauma
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_TARGETED, TAG_MAGICAL) //im putting magical on this because I think this can give the magic brain traumas
	req_departments_power = list(STS_MED = 30)

/datum/round_event_control/grid_check
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)

/datum/round_event_control/disease_outbreak
	max_occurrences = 2
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_TARGETED, TAG_COMMUNAL, TAG_EXTERNAL, TAG_ALIEN, TAG_MAGICAL)
	req_departments_power = list(STS_MED = 60)

/datum/round_event_control/electrical_storm
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_SPOOKY)
	event_group = /datum/event_group/error
	req_departments_power = list(STS_ENG = 50)

/datum/round_event_control/fake_virus
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_TARGETED)
	weight = 0

/datum/round_event_control/falsealarm
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/error

/datum/round_event_control/market_crash
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/mice_migration
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_DESTRUCTIVE, TAG_ALIEN) //not really alien but rat lords kind of are
	event_group = /datum/event_group/guests

/datum/round_event_control/wisdomcow
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_POSITIVE, TAG_MAGICAL)
	event_group = /datum/event_group/guests
	weight =  0

/datum/round_event_control/shuttle_loan
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/stray_cargo
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)
	req_departments_power = list(STS_ENG = 40)

/datum/round_event_control/tram_malfunction
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/error
	req_departments_power = list(STS_ENG = 60)

/datum/round_event_control/bitrunning_glitch
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_TARGETED)

/datum/round_event_control/easter
	track = EVENT_TRACK_MUNDANE
	roundstart = TRUE
	weight = 0
	max_occurrences = 0
	tags = list(TAG_COMMUNAL, TAG_POSITIVE)

/datum/round_event_control/rabbitrelease
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_POSITIVE)

/datum/round_event_control/valentines
	track = EVENT_TRACK_MUNDANE
	roundstart = TRUE
	weight = 0
	max_occurrences = 0
	tags = list(TAG_COMMUNAL, TAG_POSITIVE)

/datum/round_event_control/santa
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_POSITIVE)

/datum/round_event_control/spooky
	track = EVENT_TRACK_MUNDANE
	roundstart = TRUE
	weight = 0
	max_occurrences = 0
	tags = list(TAG_COMMUNAL, TAG_POSITIVE, TAG_SPOOKY)

/datum/round_event_control/mass_hallucination
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_MAGICAL)

/datum/round_event_control/sentience
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_SPOOKY, TAG_MAGICAL)

//SCRUBBER OVERRIDES
/datum/round_event_control/scrubber_overflow
	tags = list(TAG_COMMUNAL)
	event_group = /datum/event_group/scrubber_overflow

/datum/round_event_control/scrubber_overflow/threatening
	weight = 0
	req_departments_power = list(STS_ENG = 30)

/datum/round_event_control/scrubber_overflow/catastrophic
	weight = 0
	req_departments_power = list(STS_ENG = 50, STS_MED = 50)

/datum/round_event_control/scrubber_overflow/every_vent
	weight = 0
	req_departments_power = list(STS_ENG = 50, STS_MED = 50, STS_HEAD = 50)
