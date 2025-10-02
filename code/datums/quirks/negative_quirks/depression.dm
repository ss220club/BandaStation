/datum/quirk/depression
	name = "Depression"
	desc = "Иногда вы просто ненавидите жизнь."
	icon = FA_ICON_FROWN
	value = -3
	gain_text = span_danger("У вас начинается депрессия.")
	lose_text = span_notice("Вы больше не испытываете депрессию.") //if only it were that easy!
	medical_record_text = "У пациента легкое расстройство настроения, вызывающее острые приступы депрессии."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED|QUIRK_PROCESSES
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)

/datum/quirk/depression/process(seconds_per_tick)
	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(SPT_PROB(0.416, seconds_per_tick))
		quirk_holder.add_mood_event("depression", /datum/mood_event/depression)

/datum/quirk/depression/remove()
	quirk_holder.clear_mood_event("depression")
