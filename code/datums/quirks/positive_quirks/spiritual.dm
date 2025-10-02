/datum/quirk/item_quirk/spiritual
	name = "Spiritual"
	desc = "Вы придерживаетесь духовных убеждений, будь то Бог, природа или тайные правила мироздания. Вы получаете утешение от присутствия святых людей и верите, что ваши молитвы более особенные, чем у других. Нахождение в часовне делает вас счастливым."
	icon = FA_ICON_BIBLE
	value = 4
	mob_trait = TRAIT_SPIRITUAL
	gain_text = span_notice("Вы верите в высшие силы.")
	lose_text = span_danger("Вы утратили вашу веру!")
	medical_record_text = "Пациент сообщает, что верит в высшие силы."
	mail_goodies = list(
		/obj/item/book/bible/booze,
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/bedsheet/chaplain,
		/obj/item/toy/cards/deck/tarot,
		/obj/item/storage/fancy/candle_box,
	)

/datum/quirk/item_quirk/spiritual/add_unique(client/client_source)
	give_item_to_holder(/obj/item/storage/fancy/candle_box, list(LOCATION_BACKPACK, LOCATION_HANDS))
	give_item_to_holder(/obj/item/storage/box/matches, list(LOCATION_BACKPACK, LOCATION_HANDS))
