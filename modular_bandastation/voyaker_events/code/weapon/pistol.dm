// .585 super revolver
/obj/item/gun/ballistic/revolver/takbok
	name = "Takbok revolver"
	desc = "Массивный револьвер с не менее массивным барабаном, вмещающим пять патронов калибра .50 AE."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ballistic.dmi'
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

/obj/item/gun/ballistic/revolver/eland
	name = "Eland revolver"
	desc = "Небольшой револьвер с комично коротким стволом и барабаном на восемь патронов калибра .35 Sol Short."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ballistic.dmi'
	icon_state = "eland"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/eland
	suppressor_x_offset = 3
	w_class = WEIGHT_CLASS_SMALL
	can_suppress = TRUE

/obj/item/gun/ballistic/revolver/eland/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/revolver/eland/examine_more(mob/user)
	. = ..()
	. += "\"Эланд\" — одно из немногих оружий компании \"Траписте\", не изготовленных по военному контракту. \
		Вместо этого \"Эланд\" начал свою жизнь как полицейское оружие, предлагаемое в качестве пистолета, \
		который наконец-то превзошел все остальные на рынке дешевого полицейского оружия. К сожалению, это \
		совпало с тем, что почти все полицейские силы ТСФ осознали, что они на самом деле \
		комично перефинансированы. Поскольку военное оружие, купленное для полицейских сил, захватило \
		рынок, \"Эланд\" нашел свое место на рынке гражданского оружия для личной защиты. \
		Вероятно, именно по этой причине вы сейчас смотрите на него."

/obj/item/gun/ballistic/revolver/eland/army
	desc = "Небольшой револьвер с комично коротким стволом и барабаном на шесть патронов калибра .38."
	icon_state = "eland_army"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/eland/army

/obj/item/gun/ballistic/automatic/pistol/skild
	name = "Skild pistol"
	desc = "Довольно редкий пистолет ТСФ, стреляющий патронами большого калибра .585 Sol. \
		Используется редко, в основном из-за того, что вызывает сильный дискомфорт в запястье."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ballistic.dmi'
	icon_state = "skild"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_light_2.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	special_mags = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/c585sol
	suppressor_x_offset = 8
	suppressor_y_offset = 0
	recoil = 1.2

/obj/item/gun/ballistic/automatic/pistol/skild/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 21, \
		overlay_y = 11 \
	)

/obj/item/gun/ballistic/automatic/pistol/skild/army/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/skild/army
	icon_state = "skild_army"
	desc = parent_type::desc + "<br>Армейская версия c бул-пап компоновкой в сером полимере."
	recoil = 1

/obj/item/gun/ballistic/automatic/pistol/skild/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/skild/army/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 23, \
		overlay_y = 11 \
	)

/obj/item/gun/ballistic/automatic/pistol/wespe_civ
	name = "'Wespe' pistol"
	desc = "Гражданская версия служебного пистолета различных военных подразделений ТСФ. Использует патрон .35 Sol Short и имеет встроенный фонарик."
	icon_state = "wespe_wood"
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ballistic.dmi'
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_light.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	special_mags = TRUE
	suppressor_x_offset = 7
	suppressor_y_offset = 0
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/wespe_civ/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/wespe_civ)

/obj/item/gun/ballistic/automatic/pistol/wespe_civ/no_mag
	spawnwithmagazine = FALSE

/datum/atom_skin/wespe_civ
	abstract_type = /datum/atom_skin/wespe_civ
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/wespe_civ/default
	preview_name = "Default"
	new_icon_state = "wespe_wood"

/datum/atom_skin/wespe_civ/blue
	preview_name = "Blue"
	new_icon_state = "wespe_blue"
