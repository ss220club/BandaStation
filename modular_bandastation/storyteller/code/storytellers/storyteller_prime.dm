/datum/storyteller/prime
	name = "Andy Prime"
	desc = "Andy Prime is the default Storyteller, and the comparison point for every other Storyteller. Best for an average, varied experience."
	always_votable = TRUE
	welcome_text = "I am not your Andy!"
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
	antag_denominator = 15
	roundstart_cap_multiplier = 0.7
