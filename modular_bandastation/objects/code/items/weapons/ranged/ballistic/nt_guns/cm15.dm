/obj/item/gun/ballistic/automatic/cm15
	name = "CM-15"
	desc = "Большой автоматический дробовик 12-го калибра, используемый силами Нанотрейзен."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "cm15"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "cm15"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "cm15"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/cm15
	spawn_magazine_type = /obj/item/ammo_box/magazine/cm15
	fire_sound = 'modular_bandastation/objects/sounds/weapons/bulldog.ogg'
	fire_sound_volume = 50
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_heavy.ogg'
	can_suppress = TRUE
	special_mags = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 0.5 SECONDS
	actions_types = list()
	spread = 3
	recoil = 1
	obj_flags = UNIQUE_RENAME
	load_sound = 'modular_bandastation/objects/sounds/weapons/ar_reload.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/ar_reload.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/ar_unload.ogg'
	eject_empty_sound = 'modular_bandastation/objects/sounds/weapons/ar_unload.ogg'
	rack_sound = 'modular_bandastation/objects/sounds/weapons/ar_cock.ogg'

/obj/item/gun/ballistic/automatic/cm15/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/cm15/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 31, \
		overlay_y = 11)

/obj/item/gun/ballistic/automatic/cm15/no_mag
	spawnwithmagazine = FALSE
