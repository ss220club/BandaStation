/datum/mood_event/favorite_food
	description = "Мне очень понравилась эта еда."
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/gross_food
	description = "Мне очень не понравилась эта еда."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/disgusting_food
	description = "Эта еда была отвратительна!"
	mood_change = -6
	timeout = 4 MINUTES

/datum/mood_event/allergic_food
	description = "Моё горло зудит."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/breakfast
	description = "Нет ничего лучше сытного завтрака, чтобы начать смену."
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/food
	timeout = 5 MINUTES
	var/quality = FOOD_QUALITY_NORMAL

/datum/mood_event/food/New(mob/M, ...)
	. = ..()
	mood_change = 2 + 2 * quality
	description = "Эта была [GLOB.food_quality_description[quality]] пища."

/datum/mood_event/food/nice
	quality = FOOD_QUALITY_NICE

/datum/mood_event/food/good
	quality = FOOD_QUALITY_GOOD

/datum/mood_event/food/verygood
	quality = FOOD_QUALITY_VERYGOOD

/datum/mood_event/food/fantastic
	quality = FOOD_QUALITY_FANTASTIC

/datum/mood_event/food/amazing
	quality = FOOD_QUALITY_AMAZING

/datum/mood_event/food/top
	quality = FOOD_QUALITY_TOP

/datum/mood_event/pacifist_eating_fish_item
	description = "I shouldn't be eating living creatures..."
	mood_change = -1 //The disgusting food moodlet already has a pretty big negative value, this is just for context.
	timeout = 4 MINUTES
