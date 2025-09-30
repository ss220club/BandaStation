/datum/quirk/extrovert
	name = "Extrovert"
	desc = "Вас заряжает общение с другими людьми, и вы с удовольствием проводите свободное время в баре."
	icon = FA_ICON_USERS
	value = 0
	mob_trait = TRAIT_EXTROVERT
	gain_text = span_notice("Вам хочется больше общаться с другими людьми.")
	lose_text = span_danger("Кажется, вам больше не требуется настолько много общения.")
	medical_record_text = "Пациент не может заткнуться."
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/flask)
