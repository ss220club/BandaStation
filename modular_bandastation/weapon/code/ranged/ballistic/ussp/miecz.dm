/obj/item/gun/ballistic/automatic/miecz
	name = "АМК-462 'Miecz' assault rifle"
	desc = "Модернизированный дизайн автомата АМК под патрон 7.62мм. Стандартный и надежный автомат солдат СССП."
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
	fire_delay = 0.35 SECONDS
	actions_types = list()
	spread = 5

/obj/item/gun/ballistic/automatic/miecz/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/miecz/examine_more(mob/user)
	. = ..()
	. += "Это усовершенствованная версия самого культового огнестрельного оружия, когда-либо созданного человеком, \
	перепроектированная для уменьшения веса, улучшения управляемости и точности стрельбы, под патрон 7.62мм. \
	На затворе выгравировано «Оборонная Коллегия СССП». По центру приклада мелким шрифтом написано: 'Изделие-462 не использует компановку Бул-пап'."

/obj/item/gun/ballistic/automatic/miecz/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/miecz/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/miecz/army
	icon_state = "miecz_army"
	worn_icon_state = "miecz_army"
	inhand_icon_state = "miecz_army"
