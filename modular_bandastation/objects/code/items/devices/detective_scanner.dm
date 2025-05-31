/obj/item/detective_scanner/examine(mob/user)
	. = ..()
	. += span_notice("ПКМ для взаимодействия со скрытыми объектами")
