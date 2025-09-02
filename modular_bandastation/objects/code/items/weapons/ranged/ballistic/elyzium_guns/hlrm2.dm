/obj/item/gun/ballistic/rifle/hlrm
	name = "HLR-M2"
	desc = "Cнайперская винтовка в калибре .338 используемая в армии Республики Элизиум."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "hlrm"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "hlrm"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "hlrm"
	SET_BASE_PIXEL(-8, 0)
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c338
	spawn_magazine_type = /obj/item/ammo_box/magazine/c338
	special_mags = TRUE
	tac_reloads = TRUE
	fire_sound = 'modular_bandastation/objects/sounds/weapons/cmf90.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 8
	burst_size = 1
	rack_delay = 1 SECONDS
	actions_types = list()
	internal_magazine = FALSE
	recoil = 1
	obj_flags = UNIQUE_RENAME
	rack_sound = 'modular_bandastation/objects/sounds/weapons/smg_rack.ogg'
	fire_sound_volume = 90
	load_sound = 'sound/items/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/items/weapons/gun/sniper/rack.ogg'

/obj/item/gun/ballistic/rifle/hlrm/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 4)

/obj/item/gun/ballistic/rifle/hlrm/no_mag
	spawnwithmagazine = FALSE
