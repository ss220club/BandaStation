/obj/item/gun/ballistic/automatic/akm
	name = "АКМ rifle"
	desc = "Нестареющий дизайн автомата под патрон 7.62 мм. Оружие настолько простое и надежное что им сможет пользоватся любой."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic40x32.dmi'
	icon_state = "akm"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "akm"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm
	can_suppress = FALSE
	fire_delay = 0.25 SECONDS
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "akm"
	fire_sound = 'modular_bandastation/objects/sounds/weapons/akm_fire.ogg'
	rack_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_cock.ogg'
	load_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_magin.ogg'
	load_empty_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_magin.ogg'
	eject_sound = 'modular_bandastation/objects/sounds/weapons/ltrifle_magout.ogg'
	burst_size = 1
	actions_types = list()
	recoil = 0.5
	spread = 6.5

/obj/item/gun/ballistic/automatic/akm/Initialize(mapload)
	. = ..()

	give_autofire()

/obj/item/gun/ballistic/automatic/akm/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/akm/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете <b>изучить подробнее</b>, чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/akm/examine_more(mob/user)
	. = ..()

	. += "АКМ — надежная штурмовая винтовка под патрон 7.62×39 мм. Обладает высокой убойной силой, \
	хорошей пробиваемостью и стабильной эффективностью на средних дистанциях.\
	Имеет заметную отдачу, но компенсируется уроном и доступностью боеприпасов. \
	Подходит как для ближнего боя, так и для уверенной стрельбы на расстоянии."

	return .

/obj/item/gun/ballistic/automatic/akm/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/civ
	name = "Sabel-42 carbine"
	desc = "Нестареющий дизайн карабина под патрон 7.62 мм. Оружие настолько простое и надежное что им сможет пользоватся любой."
	icon_state = "akm_civ"
	inhand_icon_state = "akm_civ"
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm/civ
	fire_delay = 0.75 SECONDS
	dual_wield_spread = 15
	spread = 1.5
	worn_icon_state = "akm_civ"
	recoil = 0.2

/obj/item/gun/ballistic/automatic/akm/civ/give_autofire()
	return

/obj/item/gun/ballistic/automatic/akm/civ/examine_more(mob/user)
	. = ..()

	. += "Внутренние изменения, внесенные в оружие для невоенного использования, \
	    сделали его несовместимым с обычными боеприпасами и лишили возможности вести автоматический огонь. \
	    'Cабля-42' предназначен для стрельбы низкосортными гражданскими патронами, \
	    более мощные патроны разрушат нарезку и сделают оружие бесполезным."

	return .

/obj/item/gun/ballistic/automatic/akm/civ/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/upp
	name = "AK-462 rifle"
	desc = "Модернизированный дизайн автомата под патрон 7.62 мм. Стадартный и надежный автомат солдат СССП."
	icon_state = "akm_new"
	inhand_icon_state = "akm_new"
	worn_icon_state = "akm_new"
	can_suppress = TRUE
	fire_delay = 0.20 SECONDS
	spread = 2.5
	recoil = 0

/obj/item/gun/ballistic/automatic/akm/upp/examine_more(mob/user)
	. = ..()

	. += "Усовершенствованная версия самого культового огнестрельного оружия, когда-либо созданного человеком, \
	    перепроектированная для уменьшения веса, улучшения управляемости и точности стрельбы, под патрон 7.62 мм. \
	    На затворе выгравировано «Оборонная Коллегия СССП». По центру приклада мелким шрифтом написано: 'Изделие-462 не использует компановку Бул-пап'."

	return .


/obj/item/gun/ballistic/automatic/akm/upp/no_mag
    spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/akm/modern
	name = "modern АКМ rifle"
	desc = "Нестареющий дизайн автомата под патрон 7.62 мм. Оружие настолько простое и надежное что им сможет пользоватся любой."
	icon_state = "akm_modern"
	inhand_icon_state = "akm_modern"
	worn_icon_state = "akm_modern"
	fire_delay = 0.20 SECONDS
	spread = 2.5
	recoil = 0

/obj/item/gun/ballistic/automatic/akm/modern/examine_more(mob/user)
	. = ..()

	. += "Модернизированная версия автомата АКМ с использованием более совершенных деталей. \
	    На замену оригинальных деталей были установлены новые, обновленные версии. \
	    Внутренний механизм был смазан и настроен, что повышает боевые способности \
	    данного варианта."

	return .

/obj/item/gun/ballistic/automatic/akm/modern/no_mag
    spawnwithmagazine = FALSE
