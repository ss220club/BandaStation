/datum/quirk/claustrophobia
	name = "Клаустрофобия"
	desc = "Вы боитесь маленьких пространств и некоторых праздничных персонажей. Если вы оказываетесь внутри какого-либо контейнера, шкафчика или механизма, у вас начинается приступ паники и вам становится труднее дышать."
	icon = FA_ICON_BOX_OPEN
	value = -4
	medical_record_text = "Пациент испытывает страх в замкнутых пространствах."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/reagent_containers/syringe/convermol) // to help breathing

/datum/quirk/claustrophobia/add(client/client_source)
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list(/datum/terror_handler/simple_source/claustrophobia, /datum/terror_handler/simple_source/clausophobia))

/datum/quirk/claustrophobia/remove()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)
