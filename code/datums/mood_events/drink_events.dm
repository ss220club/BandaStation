/datum/mood_event/drunk
	mood_change = 3
	description = "После напитка-другого всё становится лучше."
	/// The blush overlay to display when the owner is drunk
	var/datum/bodypart_overlay/simple/emote/blush_overlay

/datum/mood_event/drunk/add_effects(drunkness)
	update_change(drunkness)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	blush_overlay = human_owner.give_emote_overlay(/datum/bodypart_overlay/simple/emote/blush)

/// Updates the description and value of the moodlet according to the passed drunkness value
/// (Does not add to or remove from the current level - it will sets it directly to the new value)
/datum/mood_event/drunk/proc/update_change(drunkness = 0)
	var/old_mood = mood_change
	switch(drunkness)
		if(0 to 30)
			mood_change = 3
			description = "После пары напитков всё становится лучше."
		if(30 to 45)
			mood_change = 4
			description = "Становится жарче или это только мне? Нужен ещё один напиток, чтобы остыть."
		if(45 to 60)
			mood_change = 5
			description = "Кто постоянно двигает пол? Я поговорю с ними... после этого напитка."
		if(60 to 90)
			mood_change = 6
			description = "Я не пьян, это ты пьян! Вообще-то... мне нужен ещё один напиток!"
		if(90 to INFINITY)
			mood_change = 3 // crash out
			description = "Ты мой ЛУЧШИЙ друган... Мы с тобой против всего мира, приятель. Давай ещё по одной."
	if(HAS_PERSONALITY(owner, /datum/personality/teetotal))
		mood_change *= -1.5
		description = "Я не люблю выпивать... Мне от этого плохо."
	if(HAS_PERSONALITY(owner, /datum/personality/bibulous))
		mood_change *= 1.5
	if(old_mood != mood_change)
		owner.mob_mood.update_mood()

/datum/mood_event/drunk/remove_effects()
	QDEL_NULL(blush_overlay)

/datum/mood_event/drunk_after
	mood_change = 2
	description = "Опьянение прошло, но я всё ещё чувствую себя хорошо."
	timeout = 5 MINUTES

/datum/mood_event/wrong_brandy
	description = "Я ненавижу такие напитки."
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/quality_revolting
	description = "Это был самый отвратительный напиток за всю историю напитков."
	mood_change = -8
	timeout = 7 MINUTES

/datum/mood_event/quality_nice
	description = "Этот напиток был неплох."
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "Этот напиток был хорош."
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "Этот напиток был прекрасным!"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "Этот напиток был невероятен!"
	mood_change = 8
	timeout = 7 MINUTES

/datum/mood_event/amazingtaste
	description = "Невероятный вкус!"
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/wellcheers
	description = "Ах, хороший экземпляр Wellcheers. Соленый виноградный вкус отлично поднимает настроение."
	mood_change = 3
	timeout = 7 MINUTES
