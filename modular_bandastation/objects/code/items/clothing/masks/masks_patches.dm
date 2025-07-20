//Fix surgery mask error icon to remove missing surgery maskicon issue
/obj/item/clothing/mask/breath/muzzle/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
