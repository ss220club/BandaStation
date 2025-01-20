/datum/round_event_control/brand_intelligence
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)
	event_group = /datum/event_group/bsod
	head_required_power = 1

/datum/round_event_control/carp_migration
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL, TAG_ALIEN)
	max_occurrences = 3
	event_group = /datum/event_group/guests

/datum/round_event_control/communications_blackout
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)
	eng_required_power = 1

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
	eng_required_power = 2
	med_required_power = 1

/datum/round_event_control/radiation_storm
	weight = 5
	max_occurrences = 1
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/supermatter_surge
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)
	event_group = /datum/event_group/error
	eng_required_power = 2

/datum/round_event_control/stray_meteor
	tags = list(TAG_DESTRUCTIVE, TAG_SPACE)
	event_group = /datum/event_group/debris
	eng_required_power = 2

/datum/round_event_control/shuttle_catastrophe
	tags = list(TAG_COMMUNAL)
	head_required_power = 1

/datum/round_event_control/shuttle_insurance
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/vent_clog
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/anomaly
	weight = 10 // Lower from original 15 because it KEEPS SPAWNING THEM
	tags = list(TAG_DESTRUCTIVE, TAG_MAGICAL)
	event_group = /datum/event_group/anomalies
	rnd_required_power = 1

/datum/round_event_control/portal_storm_narsie
	tags = list(TAG_COMBAT)

/datum/round_event_control/obsessed
	weight = 0 // use storyteller variants instead

/datum/round_event_control/gravity_generator_blackout
	tags = list(TAG_COMMUNAL, TAG_SPACE)
	event_group = /datum/event_group/bsod
	weight = 8
	max_occurrences = 2
	eng_required_power = 1

/datum/round_event_control/grey_tide
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY)
	event_group = /datum/event_group/meteors

/datum/round_event_control/heart_attack
	tags = list(TAG_TARGETED, TAG_MAGICAL)
	med_required_power = 1

/datum/round_event_control/sandstorm
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL)
	event_group = /datum/event_group/debris

/datum/round_event_control/wormholes
	tags = list(TAG_COMMUNAL, TAG_MAGICAL)
	event_group = /datum/event_group/anomalies

/datum/round_event_control/immovable_rod
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_MAGICAL)
	eng_required_power = 2
