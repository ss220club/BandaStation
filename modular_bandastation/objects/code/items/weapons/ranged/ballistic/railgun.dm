/obj/item/gun/ballistic/automatic/railgun
	name = "HEMC-62"
	desc = "Ручной Электромагнитный Ускоритель Масс изделие номер 62 или же простыми словами 'Рельсотрон'. Большая и увесистая пушка для уничтожения самых сильных противников Нанотрейзен."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic40x32.dmi'
	icon_state = "railgun"
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/railgun_lefthand40x32.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/railgun_righthand40x32.dmi'
	inhand_icon_state = "railgun_worn"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/railgun_back.dmi'
	worn_icon_state = "railgun_back"
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/railgun
	actions_types = null
	can_suppress = FALSE
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_alarm = TRUE
	tac_reloads = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	semi_auto = FALSE
	fire_sound = 'modular_bandastation/objects/sounds/weapons/railgun_fire.ogg'
	rack_sound = 'modular_bandastation/objects/sounds/weapons/railgun_cock.ogg'
	lock_back_sound = 'modular_bandastation/objects/sounds/weapons/railgun_open.ogg'
	bolt_drop_sound = 'modular_bandastation/objects/sounds/weapons/railgun_cock.ogg'
	load_sound = 'modular_bandastation/objects/sounds/weapons/railgun_magin.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/railgun_magin.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/railgun_magout.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/railgun_magout.ogg'
	fire_delay = 7 SECONDS
	recoil = 1

/obj/item/gun/ballistic/automatic/railgun/update_icon()
	. = ..()
	if(!magazine)
		icon_state = "railgun_open"
	else
		icon_state = "railgun_closed"

/obj/item/gun/ballistic/automatic/railgun/nomag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/railgun/scoped
	name = "HEMC-60"
	desc = "Ручной Электромагнитный Ускоритель Масс изделие номер 60 или же простыми словами 'Рельсотрон'. Более увесистая модель с более сильной отдачей, но взамен оснащенная оптическим прицелом."
	recoil = 3
	slowdown = 0.25

/obj/item/gun/ballistic/automatic/railgun/scoped/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)
