/obj/item/gun/ballistic/automatic/miecz
	name = "AMC-874 'Miecz' assault carbine"
	desc = "Модернизированный дизайн штурмового карабина на базе АМК под патрон 7.62x39мм."
	icon = 'modular_bandastation/weapon/icons/ranged/48x32.dmi'
	icon_state = "miecz"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "miecz"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "miecz"
	SET_BASE_PIXEL(-8, 0)
	special_mags = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/c762x39mm
	fire_sound = 'modular_bandastation/weapon/sound/ranged/ak_shoot.ogg'
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_cock.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_magin.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_magin.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/ltrifle_magout.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 5
	suppressor_y_offset = 3
	burst_size = 1
	fire_delay = 0.20 SECONDS
	actions_types = list()
	spread = 2.5
	recoil = 0.1

/obj/item/gun/ballistic/automatic/miecz/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/miecz/examine_more(mob/user)
	. = ..()
	. += "Штурмовой карабин AMC-874 'Мечь', это усовершенственная конструкция на основе автомата АМК под патрон 7.62x39мм. \
	Этот карабин был создан для штурмовых операций внутри очень тесных пространств, для этого карабин имеет короткий ствол и малые габариты. \
	На затворе выгравировано «Оборонная Коллегия СССП»."

/obj/item/gun/ballistic/automatic/miecz/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/miecz/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/miecz/army
	icon_state = "miecz_army"
	worn_icon_state = "miecz_army"
	inhand_icon_state = "miecz_army"

/obj/item/gun/ballistic/automatic/miecz/examine_more(mob/user)
	. = ..()
	. += "<br>Этот вариант сделан с армейским зеленым полимерным корпусом."
