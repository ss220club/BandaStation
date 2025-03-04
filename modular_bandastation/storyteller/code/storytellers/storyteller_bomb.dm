/datum/storyteller/bomb
	name = "The Bomb"
	desc = "The Bomb enjoys a good fight but abhors senseless destruction. Prefers heavy hits on single targets."
	welcome_text = "GLA! GLA! GLA!"
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1.2,
		EVENT_TRACK_MAJOR = 1.15,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	tag_multipliers = list(TAG_COMBAT = 1.4, TAG_DESTRUCTIVE = 2, TAG_TARGETED = 1.2)
	population_min = 25 //combat based so we should have some kind of min pop(even if low)
	weight = 3
