/obj/item/gun/ballistic/automatic/bison
	name = "PP-542L 'Bison'"
	desc = "Компактный пистолет-пулемет в калибре .27 с уникальными магазинами шнекового типа."
	icon = 'modular_bandastation/weapon/icons/ranged/32x32.dmi'
	icon_state = "bison"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "bison"
	accepted_magazine_type = /obj/item/ammo_box/magazine/cm5    //bison
	dual_wield_spread = 10
	spread = 10
	can_suppress = TRUE
	mag_display = TRUE
	empty_indicator = TRUE
	//fire_sound = 'sound/weapons/gun/smg/shot_alt.ogg'
	fire_delay = 1 SECONDS
	actions_types = list()
	burst_size = 0

/obj/item/gun/ballistic/automatic/bison/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/bison/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/bison/examine_more(mob/user)
	. = ..()
	. += "Пистолет-пулемет ПП-542 или же 'Бисон' был разработан Оборонной Коллегией СССП для экипажей истребителей и сотрудников милиции, нуждающихся в компактном и скорострельном оружии ближнего боя. <br>\
		Созданный на основе древнего чертежа, этот пистолет-пулемет адаптирован для условий 2569 года с использованием легких полимерных материалов и усовершенствованных сплавов. \
		Комбинированние шнекового магазина на 64 патрона калибра .27 и высокой скорострельности позволяет получать эффективный подавляющий огонь. \
		Его уникальная конструкция с размещением шнекового магазина перед спусковым крючком минимизирует габариты, что идеально подходит для условий ближнего боя в тесных пространствах. \
		В этот дизайн также были добавлены крепления для тактических аксессуаров, таких как фонарики, ЛЦУ и глушители."
