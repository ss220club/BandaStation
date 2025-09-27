/obj/item/gun/ballistic/automatic/lanca
	name = "BV-27 'Lanca' battle rifle"
	desc = "Боевая винтовка под патрон .310 Strilka. Имеет встроенный прицел с удивительно высокой кратностью увеличения, учитывая его происхождение."
	icon = 'modular_bandastation/weapon/icons/ranged/48x32.dmi'
	icon_state = "lanca"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "lanca"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "lanca"
	SET_BASE_PIXEL(-8, 0)
	special_mags = FALSE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/strilka310
	fire_sound = 'modular_bandastation/weapon/sound/ranged/rifle_heavy_2.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/dmr_cocked.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/dmr_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/dmr_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/dmr_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/dmr_unload.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 2
	suppressor_y_offset = 1
	burst_size = 1
	fire_delay = 1.2 SECONDS
	actions_types = list()
	recoil = 0.5
	spread = 2.5

/obj/item/gun/ballistic/automatic/lanca/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/lanca/examine_more(mob/user)
	. = ..()
	. += "Разработка боевой винтовки \"Ланка\" началась как попытка заменить устаревшую \"Сахно\", на новую полуавтоматическую винтовку для армии СССП. <br>\
		Первоначальная разработка на основе модернизированной \"Сахно\" с добавлением возможности вести полуавтоматический огонь не удовлетворило коммисию. \
		В связи с этим, новый вариант был основан на автомате АМК, изменение калибра потребовало обновления верхнего ресивера и установки мощной возвратной пружины, \
		что привело к увеличению веса винтовки. Чтобы компенсировать дополнительный вес, приклад был скелетонизирован, а ствольная нарезка заменена на минималистичный дизайн."

/obj/item/gun/ballistic/automatic/lanca/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/automatic/lanca/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/lanca/army
	name = "BV-30 'Lanca' battle rifle"
	desc = "Относительно компактная длинноствольная боевая винтовка под патрон .310 Strilka. Имеет встроенный прицел с \
		удивительно высокой кратностью увеличения, учитывая его происхождение."
	icon = 'modular_bandastation/weapon/icons/ranged/48x32.dmi'
	icon_state = "lanca_army"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "lanca"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "lanca_army"
