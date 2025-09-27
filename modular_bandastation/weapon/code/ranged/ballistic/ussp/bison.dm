/obj/item/gun/ballistic/automatic/bison
	name = "PP-542L 'Bison'"
	desc = "Компактный пистолет-пулемет в калибре 9мм с уникальными магазинами шнекового типа."
	icon = 'modular_bandastation/weapon/icons/ranged/32x32.dmi'
	icon_state = "bison"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "bison"
	accepted_magazine_type = /obj/item/ammo_box/magazine/bison
	spread = 10
	weapon_weight = WEAPON_MEDIUM
	can_suppress = TRUE
	mag_display = TRUE
	empty_indicator = TRUE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/bison_fire.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/ak_cocked.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/bison_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/bison_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/bison_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/bison_unload.ogg'
	fire_delay = 0.2 SECONDS
	actions_types = list()
	burst_size = 1
	recoil = 0.3

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
		Комбинированние шнекового магазина на 64 и высокой скорострельности позволяет получать эффективный подавляющий огонь. \
		Его уникальная конструкция с размещением шнекового магазина перед спусковым крючком минимизирует габариты, что идеально подходит для условий ближнего боя в тесных пространствах. \
		В этот дизайн также были добавлены крепления для тактических аксессуаров, таких как фонарики, ЛЦУ и глушители."
