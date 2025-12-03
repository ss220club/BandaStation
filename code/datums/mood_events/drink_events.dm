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
			description = "Everything just feels better after a drink or two."
		if(30 to 45)
			mood_change = 4
			description = "Is it getting hotter, or is it just me? I need another drink to cool down."
		if(45 to 60)
			mood_change = 5
			description = "Who keeps moving the floor? I'm going to talk to them... after this drink."
		if(60 to 90)
			mood_change = 6
			description = "I'm noooot drunk, you're drunk! In fact... I need another drink!"
		if(90 to INFINITY)
			mood_change = 3 // crash out
			description = "You're my BESSST frien'... You and me agains' th' world, buddy. Le's get another drink."
	if(HAS_PERSONALITY(owner, /datum/personality/teetotal))
		mood_change *= -1.5
		description = "I don't like drinking... It makes me feel horrible."
	if(HAS_PERSONALITY(owner, /datum/personality/bibulous))
		mood_change *= 1.5
	if(old_mood != mood_change)
		owner.mob_mood.update_mood()

/datum/mood_event/drunk/remove_effects()
	QDEL_NULL(blush_overlay)

/datum/mood_event/drunk_after
	mood_change = 2
	description = "The buzz might be gone, but I still feel good."
	timeout = 5 MINUTES

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
