//Painting
/obj/item/wallframe/painting/event
	name = "Default Frame for Painting"
	desc = "Картина невозможного, созданная невозможной краской. Ей не место в этой реальности."
	icon = 'modular_bandastation/objects/icons/obj/structures/art.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "debug"
	result_path = /obj/structure/sign/painting/event
	pixel_shift = 35

/obj/structure/sign/painting/event
	name = "Default Painting"
	desc = "Картина невозможного, созданная невозможной краской. Ей не место в этой реальности."
	icon = 'modular_bandastation/objects/icons/obj/structures/art.dmi'
	icon_state = "debug"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	accepted_canvas_types = list()
	persistence_id = FALSE

/obj/item/wallframe/painting/event/father
	name = "Oll father paint"
	icon_state = "father"
	result_path = /obj/structure/sign/painting/event/father

/obj/structure/sign/painting/event/father
	name = "Oll father paint"
	desc = "eugene photo"
	icon_state = "father"

/obj/item/wallframe/painting/event/eugene
	name = "Oll eugene paint"
	icon_state = "eugene"
	result_path = /obj/structure/sign/painting/event/eugene

/obj/structure/sign/painting/event/eugene
	name = "Oll eugene paint"
	desc = "eugene photo"
	icon_state = "eugene"

/obj/item/wallframe/painting/event/wedding
	name = "Oll wedding paint"
	icon_state = "wedding"
	result_path = /obj/structure/sign/painting/event/wedding

/obj/structure/sign/painting/event/wedding
	name = "Oll wedding paint"
	desc = "wedding photo"
	icon_state = "wedding"

/obj/item/wallframe/painting/event/mother
	name = "Oll mother paint"
	icon_state = "mother"
	result_path = /obj/structure/sign/painting/event/mother

/obj/structure/sign/painting/event/mother
	name = "Oll mother paint"
	desc = "mother photo"
	icon_state = "mother"

/obj/item/wallframe/painting/event/family
	name = "Oll family paint"
	icon_state = "family"
	result_path = /obj/structure/sign/painting/event/family

/obj/structure/sign/painting/event/family
	name = "Oll family paint"
	desc = "family photo"
	icon_state = "family"

/obj/item/wallframe/painting/event/wine
	name = "Oll wine paint"
	icon_state = "wine"
	result_path = /obj/structure/sign/painting/event/wine

/obj/structure/sign/painting/event/wine
	name = "Oll wine paint"
	desc = "wine photo"
	icon_state = "wine"

/obj/item/wallframe/painting/event/fruit_art
	name = "Oll fruit art paint"
	icon_state = "fruit_art"
	result_path = /obj/structure/sign/painting/event/fruit_art

/obj/structure/sign/painting/event/fruit_art
	name = "Oll wine paint"
	desc = "fruit art photo"
	icon_state = "fruit_art"
