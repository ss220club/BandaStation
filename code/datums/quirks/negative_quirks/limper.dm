/datum/quirk/item_quirk/limper
	name = "Limper"
	desc = "У вас выраженная хромота, она значительно замедляет передвижение. Хорошо, что вы взяли с собой трость."
	icon = FA_ICON_PERSON_CANE
	gain_text = span_danger("У вас немного подкашиваются ноги.")
	lose_text = span_notice("Ваши ноги снова в норме.")
	medical_record_text = "У пациента наблюдается слабость в ноге."
	value = -6
	hardcore_value = 3

	mail_goodies = list(
		/obj/item/cane,
		/obj/item/cane/crutch,
		/obj/item/cane/white,
	)

/datum/quirk/item_quirk/limper/add_unique(client/client_source)
	give_item_to_holder(new /obj/item/cane(get_turf(quirk_holder)), list(
			LOCATION_HANDS,
			LOCATION_BACKPACK,
		))
	return

/datum/quirk/item_quirk/limper/add(client/client_source)
	quirk_holder.apply_status_effect(/datum/status_effect/limp/quirk)

/datum/quirk/item_quirk/limper/remove(client/client_source)
	quirk_holder.remove_status_effect(/datum/status_effect/limp/quirk)

