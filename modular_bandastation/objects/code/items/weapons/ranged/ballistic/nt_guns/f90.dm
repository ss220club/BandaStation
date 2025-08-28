/obj/item/gun/ballistic/automatic/f90
	name = "F90"
	desc = "Мощная снайперская винтовка в калибре .338, используемая крайне редкими специалистами Нанотрейзен, обладающая впечатляющей дальностью стрельбы и пробивной способностью пули."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "f90"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "f90"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "f90"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c338
	spawn_magazine_type = /obj/item/ammo_box/magazine/c338
	special_mags = TRUE
	fire_sound = 'modular_bandastation/objects/sounds/weapons/cmf90.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	fire_delay = 1 SECONDS
	actions_types = list()
	recoil = 1
	obj_flags = UNIQUE_RENAME
	rack_sound = 'modular_bandastation/objects/sounds/weapons/smg_rack.ogg'

/obj/item/gun/ballistic/automatic/f90/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/f90/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 3)
