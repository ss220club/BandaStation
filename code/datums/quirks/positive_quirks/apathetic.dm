/datum/quirk/apathetic
	name = "Apathetic"
	desc = "В целом вам все безразлично, в отличии от других людей. Тут прикольно... наверное..."
	icon = FA_ICON_MEH
	value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Пациенту была предложена шкала оценки апатии, но он не стал ее даже заполнять."
	mail_goodies = list(/obj/item/hourglass)

/datum/quirk/apathetic/add(client/client_source)
	quirk_holder.mob_mood?.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	quirk_holder.mob_mood?.mood_modifier += 0.2
