/obj/item/trash
	icon = 'icons/obj/service/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	desc = "This is rubbish."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	item_flags = NOBLUDGEON|SKIP_FANTASY_ON_SPAWN
	custom_materials = list(/datum/material/plastic=SMALL_MATERIAL_AMOUNT*2)

/obj/item/trash/can
	icon = 'modular_bandastation/objects/icons/obj/items/cannedfood.dmi'
	icon_state = "Expiredcannedfood_empty"

/obj/item/trash/can/Expiredcannedfood
	name = "expired canned food"
	icon_state = "Expiredcannedfood_empty"

/obj/item/trash/can/cannedbeef
	name = "canned beef"
	icon_state = "cannedbeef_empty"

/obj/item/trash/can/cannedmushrooms
	name = "canned mushrooms"
	icon_state = "cannedmushrooms_empty"

/obj/item/trash/can/condensedmilk
	name = "condensed milk"
	icon_state = "condensedmilk_empty"

/obj/item/trash/can/cannedpizza
	name = "canned pizza"
	icon_state = "cannedpizza_empty"

/obj/item/trash/can/cannedtuna
	name = "canned tuna"
	icon_state = "cannedtuna_empty"
