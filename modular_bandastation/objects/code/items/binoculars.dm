/obj/item/binoculars/recon
	name = "Бинокль разведчика"
	desc = "Особая модификация бинокля, предназначенная для наводки артеллерии."

/obj/item/binoculars/recon/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	to_chat(user, span_big("Координаты: X: [interacting_with.x], Y: [interacting_with.y]"))
	return ITEM_INTERACT_BLOCKING
