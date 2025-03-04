/datum/mood_event/drunk
	mood_change = 3
	description = "После напитка-другого всё становится лучше."
	/// The blush overlay to display when the owner is drunk
	var/datum/bodypart_overlay/simple/emote/blush_overlay

/datum/mood_event/drunk/add_effects(param)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	blush_overlay = human_owner.give_emote_overlay(/datum/bodypart_overlay/simple/emote/blush)

/datum/mood_event/drunk/remove_effects()
	QDEL_NULL(blush_overlay)

/datum/mood_event/wrong_brandy
	description = "Я ненавижу такие напитки."
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/quality_revolting
	description = "Это был самый худший напиток из всей истории напитков."
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
