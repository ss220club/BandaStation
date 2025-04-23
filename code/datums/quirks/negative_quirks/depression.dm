/datum/quirk/depression
	name = "Depression"
	desc = "Иногда вы просто ненавидите жизнь."
	icon = FA_ICON_FROWN
	mob_trait = TRAIT_DEPRESSION
	value = -3
	gain_text = span_danger("У вас начинается депрессия.")
	lose_text = span_notice("Вы больше не испытываете депрессию.") //if only it were that easy!
	medical_record_text = "У пациента легкое расстройство настроения, вызывающее острые приступы депрессии."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)
