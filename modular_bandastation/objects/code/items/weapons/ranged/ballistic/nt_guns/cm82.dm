/obj/item/gun/ballistic/automatic/cm82
	name = "CM-82"
	desc = "Стандартная штурмовая винтовка Нанотрейзен в калибре 5.56мм, относительно новое боевое оружие. Точная, надежная и простая в использовании, CM-82 практически в одночасье заменила АРГ \"Пограничник\" в качестве штурмовой винтовки Нанотрейзен и с тех пор пользуется огромной популярностью."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "cm82"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "cm82"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "cm82"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c223
	spawn_magazine_type = /obj/item/ammo_box/magazine/c223
	fire_sound = 'modular_bandastation/objects/sounds/weapons/cm82.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 10
	burst_size = 1
	fire_delay = 0.18 SECONDS
	actions_types = list()
	spread = 2.5
	recoil = 0.1
	obj_flags = UNIQUE_RENAME
	load_sound = 'modular_bandastation/objects/sounds/weapons/cm82_reload.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/cm82_reload.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/cm82_unload.ogg'
	eject_empty_sound = 'modular_bandastation/objects/sounds/weapons/cm82_unload.ogg'
	rack_sound = 'modular_bandastation/objects/sounds/weapons/ar_cock.ogg'

/obj/item/gun/ballistic/automatic/cm82/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/cm82/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 33, \
		overlay_y = 13)

/obj/item/gun/ballistic/automatic/cm82/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/ar
	accepted_magazine_type = /obj/item/ammo_box/magazine/c223
	spawn_magazine_type = /obj/item/ammo_box/magazine/c223
