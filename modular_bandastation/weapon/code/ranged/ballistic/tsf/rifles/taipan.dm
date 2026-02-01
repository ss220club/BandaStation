/obj/item/gun/ballistic/automatic/taipan
	name = "AMSR-83 \"Taipan\""
	desc = "Монструозная полуавтоматическая антиматериальная винтовка в калибре 20x138мм, удивительно короткая для своего класса. \
	Предназначена для уничтожения мехов, легких транспортных средств и оборудования, но более чем способна уничтожать обычный военный персонал."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "taipan"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "taipan"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "taipan"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/taipan.ogg'
	fire_sound_volume = 90
	rack_sound = 'modular_bandastation/weapon/sound/ranged/sniper_heavy_cocked.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/sniper_heavy_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/sniper_heavy_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/sniper_heavy_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/sniper_heavy_unload.ogg'
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/taipan
	w_class = WEIGHT_CLASS_BULKY
	bolt_type = BOLT_TYPE_LOCKING
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	spread = 1
	recoil = 3
	burst_size = 1
	fire_delay = 1 SECONDS
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/taipan/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/taipan/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 4)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/taipan/update_icon_state()
	. = ..()
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

