/datum/storyteller/pups
	name = "Poops x10"
	desc = "It's super friendly storyteller, to make your game more fun."
	welcome_text = "Friendship is a magic!"

	event_repetition_multiplier = 0.1

	starting_point_multipliers = list(
		EVENT_TRACK_MUNDANE = 10,
		EVENT_TRACK_MODERATE = 10,
		EVENT_TRACK_MAJOR = 10,
		EVENT_TRACK_ROLESET = 10,
		EVENT_TRACK_OBJECTIVES = 10
		)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 10,
		EVENT_TRACK_MODERATE = 10,
		EVENT_TRACK_MAJOR = 10,
		EVENT_TRACK_ROLESET = 10,
		EVENT_TRACK_OBJECTIVES = 10
		)
	tag_multipliers = list(TAG_DESTRUCTIVE = 2, TAG_COMMUNAL = 2, TAG_POSITIVE = 2, TAG_MAGICAL = 2)
	population_min = 15
	ignores_roundstart = TRUE
	weight = 1
	restricted = TRUE
	guarantees_roundstart_roleset = TRUE
