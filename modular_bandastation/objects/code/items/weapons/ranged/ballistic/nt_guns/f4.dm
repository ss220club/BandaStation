/obj/item/gun/ballistic/automatic/f4
	name = "F4"
	desc = "Стандартная боевая винтовка Нанотрейзен под калибр 7.62x51мм."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "f4"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "f4"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "f4"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c762x51mm
	spawn_magazine_type = /obj/item/ammo_box/magazine/c762x51mm
	fire_sound = 'modular_bandastation/objects/sounds/weapons/f4.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 0.4 SECONDS
	actions_types = list()
	spread = 1
	recoil = 0.3
	obj_flags = UNIQUE_RENAME
	rack_sound = 'modular_bandastation/objects/sounds/weapons/smg_rack.ogg'

/obj/item/gun/ballistic/automatic/f4/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 31, \
		overlay_y = 12)

/obj/item/gun/ballistic/automatic/f4/no_mag
	spawnwithmagazine = FALSE
