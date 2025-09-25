/obj/item/gun/ballistic/automatic/wylom
	name = "AMV-90 'Wyłom'"
	desc = "Массивное чудовище в виде анти-материальной винтовки, предназначенное для уничтожения вражеской легкой техники и экзокостюмов, а также для «контроля агрессивной фауны». Стреляет разрушительными безгильзовыми патронами калибра .60 Strela, \
		чрезвычайно высокая пробивная способность которых стала причиной того, что в конечном итоге это оружие было запрещено к торговле в галактике."
	icon = 'modular_bandastation/weapon/icons/ranged/64x32.dmi'
	icon_state = "wylom"
	SET_BASE_PIXEL(-16, 0)
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/inhands_64_left.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/inhands_64_right.dmi'
	inhand_icon_state = "wylom"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "wylom"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c338    //wylom
	can_suppress = FALSE
	//fire_sound = 'modular_bandastation/weapon/sound/ranged/amr_fire.ogg'
	fire_sound_volume = 100
	recoil = 4
	burst_size = 1
	fire_delay = 2 SECONDS
	actions_types = list()
	force = 15 // I mean if you're gonna beat someone with the thing you might as well get damage appropriate for how big the fukken thing is

/obj/item/gun/ballistic/automatic/wylom/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/wylom/examine_more(mob/user)
	. = ..()
	. += "Крупнокалиберная винтовка \"Wyłom\" изначально не была создана для использования без вспомогательных средств. \
		Первоначальная версия винтовки имела крепления для экзокостюмов, но эта идея быстро провалилась после \
		ее анонса, поскольку не получила одобрения в связи с существованием более эффективных аналогов для экзокостюмов. \
		Обычно считается сильным претендентом на определение \"противо-бронебойного\" оружия, \
		но есть веские аргументы, чтобы считать его ближе к \"противо-всему\".<br><br>\
		Лазерная этикетка предупреждает пользователей о необходимости остерегаться ударной волны от дульного тормоза... \
		и не стрелять без опоры, если человек не имеет достаточной силы, чтобы \"справиться\" с отдачей."

/obj/item/gun/ballistic/automatic/wylom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/ballistic/automatic/wylom/bulpup
	name = "Wyłom bulpup AMR"
	icon_state = "wylom_bulpup"
	inhand_icon_state = "wylom_bulpup"
	worn_icon_state = "wylom_bulpup"
	recoil = 2

/obj/item/gun/ballistic/automatic/wylom/bulpup/examine_more(mob/user)
	. = ..()
	. += "Эта модель \"Wyłom\" сделана в компоновке булпап, что серьезно снизило отдачу, повысило точность, взамен удобства пользования."
