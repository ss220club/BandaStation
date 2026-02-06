// .585 super revolver
/obj/item/gun/ballistic/revolver/takbok
	name = "Takbok revolver"
	desc = "Массивный револьвер с не менее массивным барабаном, вмещающим пять патронов калибра .50 AE."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "takbok"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/revolver_fire_2.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/takbok
	suppressor_x_offset = 5
	can_suppress = TRUE
	fire_delay = 0.5 SECONDS
	recoil = 2

/obj/item/gun/ballistic/revolver/takbok/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/revolver/takbok/examine_more(mob/user)
	. = ..()
	. += "\"Такбок\" — уникальная разработка по той единственной причине, что изначально он был создан как единичный экземпляр. \
		Один из высокопоставленных генералов ТСФ заказал у компании \"Траписте\" спортивный револьвер. \
		Но в итоге ему доставили не револьвер для стрельбы по мишеням, а оружие, способное разгромить любую мишень. \
		Оружие стало популярным, поскольку побеждало во многих соревнованиях по стрельбе и его решили принять на вооружение \
		армии ТСФ в качестве офицерского вооружения. Благодаря большому количеству изготовленных револьверов, \
		их все еще достаточно легко увидеть в руках офицеров, несмотря на то, что производство было прекращено много лет назад."

/obj/item/gun/ballistic/revolver/takbok/army
	icon_state = "takbok_army"
	desc = parent_type::desc + "<br>Армейская версия в сером полимере."
	recoil = 1

/obj/item/gun/ballistic/revolver/takbok/army/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 16, \
		overlay_y = 11, \
	)
