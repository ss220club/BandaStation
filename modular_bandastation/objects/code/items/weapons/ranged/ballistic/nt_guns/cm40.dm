/obj/item/gun/ballistic/automatic/cm40
	name = "CM-40"
	desc = "Легкий пулемет под калибр 7.62x51mm, используемый группами тяжелого вооружения Нанотрейзен, способный вести интенсивный подавляющий огонь."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "cm40"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "cm40"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "cm40"
	SET_BASE_PIXEL(-8, 0)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/cm40
	spawn_magazine_type = /obj/item/ammo_box/magazine/cm40
	fire_sound = 'modular_bandastation/objects/sounds/weapons/cm40.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_heavy.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 0.1 SECONDS
	actions_types = list()
	spread = 10
	recoil = 1.5
	obj_flags = UNIQUE_RENAME
	rack_sound = 'modular_bandastation/objects/sounds/weapons/cm40_cocked.ogg'
	load_sound = 'modular_bandastation/objects/sounds/weapons/cm40_reload.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/cm40_reload.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/cm40_unload.ogg'
	eject_empty_sound = 'modular_bandastation/objects/sounds/weapons/cm40_unload.ogg'

/obj/item/gun/ballistic/automatic/cm40/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/cm40/no_mag
	spawnwithmagazine = FALSE
