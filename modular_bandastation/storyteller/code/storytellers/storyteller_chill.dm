/datum/storyteller/chill
	name = "The Chill"
	desc = "The Chill will be light on events compared to other storytellers, especially so on ones involving combat, destruction, or chaos. Best for more chill rounds."
	welcome_text = "The day is going slowly."
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 0.7,
		EVENT_TRACK_MAJOR = 0.7,
		EVENT_TRACK_ROLESET = 0.7,
		EVENT_TRACK_OBJECTIVES = 1
		)
	guarantees_roundstart_roleset = FALSE
	tag_multipliers = list(TAG_COMBAT = 0.6, TAG_DESTRUCTIVE = 0.7)
	always_votable = TRUE //good for low pop
	population_max = 45
	weight = 2
