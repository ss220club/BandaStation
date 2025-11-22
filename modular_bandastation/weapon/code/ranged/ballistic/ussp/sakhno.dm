/obj/item/gun/ballistic/rifle/boltaction
	icon = 'modular_bandastation/weapon/icons/ranged/48x32.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	recoil = 1

/obj/item/gun/ballistic/rifle/boltaction/surplus
	inhand_icon_state = "sakhno"
	worn_icon_state = "sakhno"

/obj/item/gun/ballistic/rifle/boltaction/donkrifle
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'

/obj/item/gun/ballistic/rifle/boltaction/army
	name = "Sakhno M2500 Army"
	desc = "Давно устаревшая винтовка Сахно поздней армейской модели. Эта конкретная модель винтовки датируется 2500 годом."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\". \
		Вероятно, была причина, по которой изначально она не производилась такой короткой. \
		Несмотря на ужасающий характер модификации, оружие в остальном выглядит в хорошем состоянии."

	icon_state = "sakhno_army"
	inhand_icon_state = "sakhno_army"
	worn_icon_state = "sakhno_army"

/obj/item/gun/ballistic/rifle/boltaction/army/surplus
	desc = "Давно устаревшая винтовка Сахно поздней армейской модели. Эта конкретная модель винтовки датируется 2500 годом. \
		По какой-то причине все внутренние детали покрыты влагой."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\" \
		Вероятно, была причина, по которой изначально она не производилась такой короткой. \
		Обрезка оружия, по-видимому, не помогла решить проблему влажности."
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/army/tactical
	desc = "Модификация устаревшей винтовки Сахно поздней армейской модели, на боковой стороне которой выбита надпись \"Сахно M2550 Армейская\". \
		Неизвестно, для какой армии была изготовлена эта модель винтовки и использовалась ли она когда-либо в армии какого-либо рода."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\" \
		На боковой стороне винтовки выбита надпись \"Сахно M2550 Армейская\". \
		Вероятно, изначально было веское основание не производить винтовки такой короткой длины."

	icon_state = "sakhno_army_tactifucked"

/obj/item/gun/ballistic/rifle/boltaction/army/tactical/surplus
	desc = "Модификация устаревшей винтовки Сахно поздней армейской модели, на боковой стороне которой выбита надпись \"Сахно M2550 Армейская\". \
		Неизвестно, для какой армии была изготовлена эта модель винтовки и использовалась ли она когда-либо в армии какого-либо рода. \
		Однако можно с уверенностью сказать, что предыдущий владелец не бережно относился к оружию. \
        По какой-то причине все внутренние детали покрыты влагой."
	sawn_desc = "Обрезанная военная модель винтовки Сахно, широко известная как \"Обрез\" \
		На боковой стороне винтовки выбита надпись \"Сахно M2550 Армейская\". \
		Вероятно, изначально было веское основание не производить винтовки такой короткой длины. \
		Обрезка оружия, по-видимому, не помогла решить проблему влажности."
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/krov
	name = "Krov precision rifle"
	desc = "Сильно модифицированная винтовка Сахно, с деталями изготовленными компанией Xhihao. \
		Имеет корпус, в котором вместо внутреннего магазина используются магазины от винтовок Lanca, что обеспечивает большую вместимость."
	icon = 'modular_bandastation/weapon/icons/ranged/48x32.dmi'
	icon_state = "rengo"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "sakhno"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "sakhno"
	slot_flags = ITEM_SLOT_BACK
	SET_BASE_PIXEL(-8, 0)
	accepted_magazine_type = /obj/item/ammo_box/magazine/strilka310 //lanca
	mag_display = TRUE
	tac_reloads = TRUE
	internal_magazine = FALSE
	can_be_sawn_off = FALSE
	weapon_weight = WEAPON_HEAVY
	recoil = 0.5

/obj/item/gun/ballistic/rifle/krov/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/rifle/krov/examine_more(mob/user)
	. = ..()
	. += "Винтовка 'Krov' является модификацией известной винтовки Сахно, обладающей \"современными\" характеристиками, такими как направляющие для аксессуаров и съемные магазины. <br>\
		Первоначально набор деталей продавался в одном комплекте компанией Xhihao, комплект 'Krov' предназначен для замены большей части деталей типичной винтовки Сахно \
		с целью улучшения эргономики, уменьшения веса и общего повышения удобства для пользователя. <br>\
		Хотя это и не особо повышает характеристики винтовки, совместимость с магазинами от винтовок Lanca \
		позволяет увеличить вместимость по сравнению с внутренними магазинами на пять патронов, которые входят в стандартную комплектацию Сахно, \
		а прицел входящий в комплект, изначально предназначенный для использования с винтовками Lanca, вполне подходит благодаря общей компоновке. \
		Оружие также в целом немного короче, что облегчает его обращение для стрелков небольшого роста и/или \
		в неудобных условиях близкого боя для высокоточного оружия. Из-за уменьшенного пространства между компонентами Krov нельзя обрезать \
		срезание любой части этого оружия, по сути, сделает его либо опасным для стрельбы, либо нефункциональным."


/obj/item/gun/ballistic/rifle/krov/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/rifle/krov/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 35, offset_y = 12)

/obj/item/gun/ballistic/rifle/krov/empty
	bolt_locked = TRUE // so the bolt starts visibly open
	spawn_magazine_type = /obj/item/ammo_box/magazine/strilka310/starts_empty

