/datum/quirk/item_quirk/blindness
	name = "Blind"
	desc = "Вы полностью слепой, это необратимо."
	icon = FA_ICON_EYE_SLASH
	value = -16
	gain_text = span_danger("Вы ослепли и ничего не видите.")
	lose_text = span_notice("Чудесным образом к вам вернулось зрение.")
	medical_record_text = "У пациента необратимая слепота."
	hardcore_value = 15
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/sunglasses, /obj/item/cane/white)

/datum/quirk/item_quirk/blindness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/glasses/blindfold/white, list(LOCATION_EYES = ITEM_SLOT_EYES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/blindness/add(client/client_source)
	quirk_holder.become_blind(QUIRK_TRAIT)

/datum/quirk/item_quirk/blindness/remove()
	quirk_holder.cure_blind(QUIRK_TRAIT)
