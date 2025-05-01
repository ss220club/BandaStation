/datum/storyteller/angryverse
	name = "Angryverse"
	desc = "Angryverse is more combat-oriented storyteller to make shifts more agressive"
	always_votable = TRUE
	welcome_text = "Let's have some fun, kids!"
	weight = 6
	exclude_events = list(
		/datum/round_event_control/stray_meteor,
		/datum/round_event_control/meteor_wave,
		/datum/round_event_control/earthquake,
		/datum/round_event_control/stray_cargo,
		/datum/round_event_control/meteor_wave/threatening,
		/datum/round_event_control/meteor_wave/catastrophic,
		/datum/round_event_control/meteor_wave/meaty,
		/datum/round_event_control/stray_cargo/syndicate,
	)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.2,
		EVENT_TRACK_MODERATE = 1.5,
		EVENT_TRACK_MAJOR = 1.3,
		EVENT_TRACK_ROLESET = 1.5,
		EVENT_TRACK_OBJECTIVES = 1
		)
	tag_multipliers = list(TAG_CREW_ANTAG = 1.5)
	antag_denominator = 10
	roundstart_cap_multiplier = 0.6
	sec_antag_modifier = 1.5
