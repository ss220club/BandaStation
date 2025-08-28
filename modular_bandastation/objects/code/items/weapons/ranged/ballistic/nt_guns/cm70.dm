/obj/item/gun/ballistic/automatic/pistol/cm70
	name = "GP-45"
	desc = "Стандартный служебный пистолет Нанотрейзен под патроны калибра .45."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "cm70"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "cm_pistol"
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'modular_bandastation/objects/sounds/weapons/cm70.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	load_sound = 'modular_bandastation/objects/sounds/weapons/cm357_reload.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/cm357_reload.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/cm357_unload.ogg'
	eject_empty_sound = 'modular_bandastation/objects/sounds/weapons/cm357_unload.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/c45
	can_suppress = TRUE
	obj_flags = UNIQUE_RENAME
	suppressor_x_offset = 0
	suppressor_y_offset = 0

/obj/item/gun/ballistic/automatic/pistol/cm70/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 22, \
		overlay_y = 13)

/obj/item/gun/ballistic/automatic/pistol/cm70/no_mag
	spawnwithmagazine = FALSE
