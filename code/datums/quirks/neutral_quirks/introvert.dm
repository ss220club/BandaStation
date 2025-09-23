/datum/quirk/introvert
	name = "Introvert"
	desc = "Вы наслаждаетесь свободным временем в одиночестве и с удовольствием проводите его в библиотеке."
	icon = FA_ICON_BOOK_READER
	value = 0
	mob_trait = TRAIT_INTROVERT
	gain_text = span_notice("Вам нравится безмятежно читать хорошую книгу.")
	lose_text = span_danger("Вам кажется, что в библиотеках скучно.")
	medical_record_text = "Пациент, по всей видимости, не слишком любит разговаривать."
	mail_goodies = list(/obj/item/book/random)
