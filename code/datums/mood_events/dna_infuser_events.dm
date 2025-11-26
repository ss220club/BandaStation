/datum/mood_event/it_was_on_the_mouse
	description = "Хе-хе. \"Всё самое чумовое\". Вот эта игра слов."
	mood_change = 1
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_WHIMSY

/datum/mood_event/gondola_serenity
	description = "Многое могло бы сейчас волновать вас. Но это чувство удовлетворенности, вселенский зов к тому, чтобы просто сидеть и наблюдать, овладевает над всем остальным..."
	mood_change = 10
	special_screen_obj = "mood_gondola"

/datum/mood_event/fish_waterless
	mood_change = -3
	description = "It sucks to be dry. I feel like a fish out of water."

/datum/mood_event/fish_water
	mood_change = 1
	description = "Glug glug!"
