/obj/item/gun/energy/pulse/pistol/egn1984
	name = "EG-N1984"
	desc = "Эксперементальный импульсный энерго-пистолет."
	icon = 'modular_bandastation/prime_only/icons/weapons40x32.dmi'
	icon_state = "n1984"
	lefthand_file = 'modular_bandastation/prime_only/icons/weapons_lefthand.dmi'
	righthand_file = 'modular_bandastation/prime_only/icons/weapons_righthand.dmi'
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	modifystate = FALSE
	light_color = COLOR_BLUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire/alt, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/pulse)
	cell_type = /obj/item/stock_parts/power_store/cell/pulse/pistol
	selfcharge = 1
	fire_delay = 0.5
	projectile_speed_multiplier = 1.3
	display_empty = FALSE
	fire_mode_switch_sound = 'modular_bandastation/weapon/sound/ranged/pulse_push.ogg'
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/ammo_casing/energy/laser/hellfire/alt
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pulse_shoot.ogg'
