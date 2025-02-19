/datum/quirk/item_quirk/colorist
	name = "Colorist"
	desc = "Вам нравится носить с собой краску-спрей для волос, чтобы быстро покрасить себе волосы."
	icon = FA_ICON_FILL_DRIP
	value = 0
	medical_record_text = "Пациент любит красить волосы в красивые цвета."
	mail_goodies = list(/obj/item/dyespray)

/datum/quirk/item_quirk/colorist/add_unique(client/client_source)
	give_item_to_holder(/obj/item/dyespray, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
