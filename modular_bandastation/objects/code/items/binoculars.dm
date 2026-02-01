/obj/item/binoculars/recon
	name = "Recon binoculars"
	desc = "Особая модификация бинокля, предназначенная для наводки артеллерии."

/obj/item/binoculars/recon/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /atom/movable/screen/fullscreen/cursor_catcher/scope))
		var/atom/movable/screen/fullscreen/cursor_catcher/scope/binocular_scope = interacting_with
		if(!binocular_scope.given_turf)
			to_chat(user, span_big("Ошибка расчёта координат..."))
		else
			to_chat(user, span_big("Координаты: X: [binocular_scope.given_turf.x], Y: [binocular_scope.given_turf.y]"))
	else
		to_chat(user, span_big("Координаты: X: [interacting_with.x], Y: [interacting_with.y]"))
	return ITEM_INTERACT_BLOCKING
