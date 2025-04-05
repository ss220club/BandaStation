/datum/mood_event/drankblood
	description = span_nicegreen("Я жадно поглощаю то, что питает меня.")
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = span_boldwarning("Я выпил кровь низшего существа. Отвратительно.")
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = span_boldwarning("Я пил кровь мёртвеца. Я должен быть выше этого.")
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = span_boldwarning("Я поглотил всю жизнь другово разумного существа. Я чувствую себя... менее человечным.")
	mood_change = -20
	timeout = 15 MINUTES

/datum/mood_event/madevamp
	description = span_boldwarning("Благодаря мне, смертный достиг апофеоза немёртвости.")
	mood_change = 15
	timeout = 10 MINUTES

/datum/mood_event/coffinsleep
	description = span_nicegreen("Днем я спал в гробу. Я прекрасно выспался.")
	mood_change = 10
	timeout = 5 MINUTES

/datum/mood_event/daylight_1
	description = span_boldwarning("Этот деревянный гроб ужасен! Я так и не смог нормально выспаться.")
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/daylight_2
	description = span_boldwarning("Лучи мерзкого солнца обожгли меня!")
	mood_change = -7
	timeout = 5 MINUTES

///Candelabrum's mood event to non Bloodsucker/Vassals
/datum/mood_event/vampcandle
	description = span_boldwarning("Этот свет разрушает мою связь с реальностью!")
	mood_change = -15
	timeout = 5 MINUTES

//Blood mirror's mood event to non-bloodsuckers/vassals that attempt to use it and get randomly warped.
/datum/mood_event/bloodmirror
	description = span_boldwarning("КРОВАВОЕ ПРОРОЧЕСТВО ЗАХВАТИЛО МОЮ ДУШУ.")
	mood_change = -30
	timeout = 7 MINUTES
