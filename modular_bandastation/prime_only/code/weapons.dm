/obj/item/gun/energy/pulse/pistol/egn1984
	name = "EG-N1984"
	desc = "Эксперементальный импульсный энерго-пистолет."
//	icon = 'modular_bandastation/prime_only/icons/weapons.dmi'
	icon_state = "pulse_pistol"
	lefthand_file = 'modular_bandastation/prime_only/icons/weapons_lefthand.dmi'
	righthand_file = 'modular_bandastation/prime_only/icons/weapons_righthand.dmi'
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	modifystate = FALSE
	light_color = COLOR_BLUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/hellfire)
	cell_type = /obj/item/stock_parts/power_store/cell/pulse/pistol
	selfcharge = 1
	fire_delay = 0.5
