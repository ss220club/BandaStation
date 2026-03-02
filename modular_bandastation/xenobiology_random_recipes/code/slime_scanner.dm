/proc/xenobio_slime_type_to_extract_path(datum/slime_type/slime_type)
	if(!slime_type)
		return null
	var/path_str = "[slime_type.type]"
	path_str = replacetext(path_str, "/datum/slime_type", "/obj/item/slime_extract")
	return text2path(path_str)

/obj/item/slime_scanner
	var/stored_slime_extract_path = null

/obj/item/slime_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS && isliving(interacting_with) && isslime(interacting_with))
		var/mob/living/basic/slime/S = interacting_with
		stored_slime_extract_path = xenobio_slime_type_to_extract_path(S.slime_type)
		to_chat(user, span_notice("Данные слайма записаны в сканер. Загрузите их в консоль рецептов - вставьте сканнер в консоль."))
