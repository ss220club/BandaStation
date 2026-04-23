/obj/item/bodypart/generate_icon_key()
	. = ..()
	if(!should_draw_greyscale && icon_static)
		. += "[icon_static]"
