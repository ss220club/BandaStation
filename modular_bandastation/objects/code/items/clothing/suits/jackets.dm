/obj/item/clothing/suit/v_jacket
	name = "v jacket"
	desc = "Куртка так называемого V."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "v_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/takemura_jacket
	name = "takemura jacket"
	desc = "Куртка так называемого Такэмуры."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "takemura_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/katarina_jacket
	name = "katarina jacket"
	desc = "Куртка так называемой Катарины."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "katarina_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/katarina_cyberjacket
	name = "katarina cyberjacket"
	desc = "Кибер-куртка так называемой Катарины."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "katarina_cyberjacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/hooded/vi_arcane
	name = "vi jacket"
	desc = "Слегка потрёпанный жакет боевой девчушки Вай."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "vi_arcane"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	hoodtype = /obj/item/clothing/head/hooded/vi_arcane
	hood_up_affix = ""
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()

/obj/item/clothing/head/hooded/vi_arcane
	name = "vi hood"
	desc = "Капюшон, прикреплённый к жакету Вай."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hood.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hood.dmi'
	icon_state = "vi_arcane"

	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEEARS | HIDEHAIR
	hair_mask = /datum/hair_mask/winterhood

/obj/item/clothing/suit/soundhand_white_jacket
	name = "soundhand silver jacket"
	desc = "Редкая серебристая куртка Саундхэнд. Ограниченная серия."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_white_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_white_jacket/tag
	name = "soundhand tag silver jacket"
	desc = "Серебристая куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_white_jacket_teg"
	worn_icon_state = "soundhand_white_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/soundhand_black_jacket
	name = "soundhand fan black jacket"
	desc = "Черная куртка группы Саундхэнд, исполненая в духе оригинала, но без логотипа на спине. С любовью для фанатов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_black_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_black_jacket/tag
	name = "soundhand tag black jacket"
	desc = "Черная куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_black_jacket_teg"
	worn_icon_state = "soundhand_black_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/soundhand_olive_jacket
	name = "soundhand fan olive jacket"
	desc = "Оливковая куртка гурппы Саундхэнд, исполненая в духе оригинала, но без логотипа на спине. С любовью для фанатов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_olive_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_olive_jacket/tag
	name = "soundhand tag olive jacket"
	desc = "Оливковая куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_olive_jacket_teg"
	worn_icon_state = "soundhand_olive_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/soundhand_brown_jacket
	name = "soundhand fan brown jacket"
	desc = "Коричневая куртка Саундхэнд, исполненая в духе оригинала, но без логотипа на спине. С любовью для фанатов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_brown_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	allowed = list()

/obj/item/clothing/suit/soundhand_brown_jacket/tag
	name = "soundhand tag brown jacket"
	desc = "Коричневая куртка с тэгом группы Саундхэнд, которую носят исполнители группы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "soundhand_brown_jacket_teg"
	worn_icon_state = "soundhand_brown_jacket"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'

/obj/item/clothing/suit/driver_jacket
	name = "driver jacket"
	desc = "Водительская куртка с скорпионом на спине."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "driver_jacket"
	worn_icon_state = "driver_jacket"

/obj/item/clothing/suit/joker_jacket
	name = "joker jacket"
	desc = "Тёмно-лиловая куртка с налётом театрального безумия. Стиль, который говорит за вас."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "joker_jacket"
	worn_icon_state = "joker_jacket"

/obj/item/clothing/suit/tailer_jacket
	name = "red leather jacket"
	desc = "Красная кожаная куртка с потертостями — грубая, бунтарская, с историей. Для тех, кто не боится выглядеть так, будто уже дрался в подворотне и вышел победителем."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "tailer_jacket"
	worn_icon_state = "tailer_jacket"

/obj/item/clothing/suit/bubba_apron
	name = "bloody yellow apron"
	desc = "Промышленный желтый фартук. Теперь с пятнами крови."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	icon_state = "bubba_apron"
	worn_icon_state = "bubba_apron"
