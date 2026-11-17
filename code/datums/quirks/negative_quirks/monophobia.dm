/datum/quirk/monophobia
	name = "Monophobia"
	desc = "Вы до ужаса боитесь одиночества и всегда стараетесь держаться в больших группах."
	icon = FA_ICON_PEOPLE_GROUP
	value = -3
	medical_record_text = "У пациента выраженный страх остаться в одиночестве."
	hardcore_value = 5
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie)

/datum/quirk/monophobia/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(new /datum/brain_trauma/severe/monophobia(), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/monophobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)
