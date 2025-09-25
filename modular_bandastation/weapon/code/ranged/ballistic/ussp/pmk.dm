/obj/item/gun/ballistic/automatic/pmk
	name = "PMK light machine gun"
	desc = "Легкий ручной пулемет оснащенный калибром 7.62x54ммР, разработанный в СССП как надежное оружие поддержки пехоты."
	icon = 'modular_bandastation/weapon/icons/ranged/64x32.dmi'
	icon_state = "pmk"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "pmk"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "pmkclosedmag"
	base_icon_state = "pmk"
	SET_BASE_PIXEL(-16, 0)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/m7mm
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	actions_types = list()
	can_suppress = TRUE
	spread = 7
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	mag_display = TRUE
	tac_reloads = FALSE
	fire_sound = 'sound/items/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/items/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/items/weapons/gun/general/heavy_shot_suppressed.ogg'
	var/cover_open = FALSE

/obj/item/gun/ballistic/automatic/pmk/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/pmk/examine(mob/user)
	. = ..()
	. += "<b>АЛЬТ + ЛКМ</b> чтобы [cover_open ? "закрыть" : "открыть"] крышку ствольной коробки."
	if(cover_open && magazine)
		. += span_notice("Кажется, вы могли бы использовать <b>пустую руку</b>, чтобы вынуть магазин.")
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/pmk/examine_more(mob/user)
	. = ..()
	. += "Легкий ручной пулемет ПМК был разработан Оборонной Коллегией СССП с целью создания компактного, \
		но надежного оружия для поддержки пехоты, способного выдерживать различные экстремальные условия. <br>\
		Оснащенный калибром .310 / 7.62x54 и ленточным питанием на 100 патронов, он предоставляет высокую скорострельность и кучную стрельбу. \
		ПМК имеет универсальные крепления для тактических аксессуаров, включая фонари и лазерные целеуказатели, \
		а эргономичный приклад с амортизирующей накладкой ослабляет отдачу и обеспечивает комфорт при длительном использовании. \
		Использовавшие ПМК отмечают высокую надежность пулемета, полученную благодаря использованию легких титановых сплавов и керамических покрытий при сборке."

/obj/item/gun/ballistic/automatic/pmk/click_alt(mob/user)
	cover_open = !cover_open
	balloon_alert(user, "крышка [cover_open ? "открыта" : "закрыта"]")
	playsound(src, 'sound/items/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/automatic/pmk/update_icon_state()
	. = ..()
	inhand_icon_state = "[base_icon_state][cover_open ? "open" : "closed"][magazine ? "mag":"nomag"]"

/obj/item/gun/ballistic/automatic/pmk/update_overlays()
	. = ..()
	. += "pmk_door_[cover_open ? "open" : "closed"]"


/obj/item/gun/ballistic/automatic/pmk/try_fire_gun(atom/target, mob/living/user, params)
	if(cover_open)
		balloon_alert(user, "закройте крышку!")
		return FALSE

	. = ..()
	if(.)
		update_appearance()
	return .

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/pmk/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open)
		balloon_alert(user, "откройте крышку!")
		return
	..()

/obj/item/gun/ballistic/automatic/pmk/attackby(obj/item/A, mob/user, list/modifiers, list/attack_modifiers)
	if(!cover_open && istype(A, accepted_magazine_type))
		balloon_alert(user, "откройте крышку!")
		return
	..()
