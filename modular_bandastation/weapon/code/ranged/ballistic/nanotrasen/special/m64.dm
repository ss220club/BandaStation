/obj/item/gun/ballistic/shotgun/riot/m64
	name = "M64 shotgun"
	desc = "Надежный дробовик 12-го калибра с восьмизарядным трубчатым магазином, расположенным сверху. Изготовлен для различных военных и полицейских сил НТ и используется ими."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "m64"
	base_icon_state = "m64"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "m64"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "m64"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	SET_BASE_PIXEL(-8, 0)
	fire_sound = 'modular_bandastation/weapon/sound/ranged/shotgun_heavy.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/shotgun_rack.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	can_suppress = TRUE
	rack_delay = 0.5 SECONDS
	fire_delay = 0.5 SECONDS
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/large
	suppressor_x_offset = 9
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

/obj/item/gun/ballistic/shotgun/riot/m64/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 32, \
		overlay_y = 12, \
	)

/obj/item/gun/ballistic/shotgun/riot/m64/black
	desc = parent_type::desc + "<br>Окрашен в тактический черный цвет."
	base_icon_state = "m64_black"
	icon_state = "m64_black"
	worn_icon_state = "m64_black"
	inhand_icon_state = "m64_black"

/obj/item/gun/ballistic/shotgun/riot/m64/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/shotgun/riot/m64/update_icon_state()
	. = ..()
	if(sawn_off)
		inhand_icon_state = "[base_icon_state]_sawoff"
		worn_icon_state = "[base_icon_state]_sawoff"
		suppressor_x_offset = 0
	else
		inhand_icon_state = "[base_icon_state]"
		worn_icon_state = "[base_icon_state]"

/obj/item/gun/ballistic/shotgun/riot/m64/sawoff
	sawn_off = TRUE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/ballistic/shotgun/riot/m64/black/sawoff
	sawn_off = TRUE
	w_class = WEIGHT_CLASS_NORMAL
