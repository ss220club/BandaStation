/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "Сколько вы себя помните, вы всегда боялись темноты. Находясь в темноте без источника света, вы инстинктивно ведете себя осторожно и постоянно испытываете чувство страха."
	icon = FA_ICON_LIGHTBULB
	value = -3
	medical_record_text = "Пациент демонстрирует страх темноты. (Серьезно?)"
	hardcore_value = 5
	mail_goodies = list(/obj/effect/spawner/random/engineering/flashlight)

/datum/quirk/nyctophobia/add(client/client_source)
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list(/datum/terror_handler/simple_source/nyctophobia))

/datum/quirk/nyctophobia/remove()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)
