/obj/item/gun/ballistic/automatic/kiboko
	name = "Kiboko grenade launcher"
	desc = "Уникальный гранатомет ТСФ, стреляющий гранатами калибра .980. Лазерная прицельная система позволяет пользователю задать дальность, на которой должны взрываться выпущенные гранаты."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	icon_state = "kiboko"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	worn_icon_state = "kiboko"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "kiboko"
	SET_BASE_PIXEL(-8, 0)
	special_mags = TRUE
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c980_grenade
	fire_sound = 'modular_bandastation/weapon/sound/ranged/grenade_launcher.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 5
	actions_types = list()
	/// The currently stored range to detonate shells at
	var/target_range = 14
	/// The maximum range we can set grenades to detonate at, just to be safe
	var/maximum_target_range = 14

/obj/item/gun/ballistic/automatic/kiboko/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/kiboko)

/obj/item/gun/ballistic/automatic/kiboko/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 26, \
		overlay_y = 10, \
	)

/obj/item/gun/ballistic/automatic/kiboko/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")
	. += span_notice("С помощью <b>ПКМ</b> можно установить дистанцию, на которой будут взрываться снаряды.")
	. += span_notice("Небольшой индикатор в прицеле показывает текущую дистанцию детонации: <b>[target_range]</b>.")

/obj/item/gun/ballistic/automatic/kiboko/examine_more(mob/user)
	. = ..()
	. += "\"Кибоко\", легкий гранатомет, является одним из самых необычных видов оружия, предлагаемых \"Карво\", \
		и примечателен нестандартным размером и инновационными технологиями, используемыми в его гранатах.<br><br>\
		Более компактные, но не менее эффективные гранаты .980 \"Тайдхойер\", разработанные для этой системы, имеют много преимуществ \
		перед другими традиционными гранатометными системами. \
		Во-первых, гранаты \"Тайдхойер\" значительно легче и в сочетании с их малыми размерами \
		их легче перевозить в больших количествах по сравнению с другими современными боеприпасами для гранатометов.<br><br>\
		Однако главной причиной, по которой ТСФ профинансировал этот проект, был его надежный, программируемый на лету взрыватель с переменным временем срабатывания. \
		Используя дальномерный прицел (который, к огорчению интендантов, является большим, дорогим и компьютеризированным) \
		на гранатомете, пользователи могут установить точное расстояние, на котором граната должна самодетонировать и \
		наконец-то воплотить в жизнь военные мечты о надежных переносных боеприпасах с воздушным взрывом.<br><br>\
		Однако меньший размер снарядов не делает оружие более удобным для стрельбы. \
		Отдача от запускаемых гранат едва терпима благодаря массивному дульному тормозу в передней части."

/obj/item/gun/ballistic/automatic/kiboko/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with || !user)
		return ITEM_INTERACT_BLOCKING

	var/distance_ranged = get_dist(user, interacting_with)
	if(distance_ranged > maximum_target_range)
		user.balloon_alert(user, "вне радиуса")
		return ITEM_INTERACT_BLOCKING

	target_range = distance_ranged
	user.balloon_alert(user, "дистанция выставлена: [target_range]")
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/ballistic/automatic/kiboko/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/kiboko/black
	icon_state = "kiboko_black"
	worn_icon_state = "kiboko_black"
	inhand_icon_state = "kiboko_black"
	spawn_magazine_type = /obj/item/ammo_box/magazine/c980_grenade/drum

/obj/item/gun/ballistic/automatic/kiboko/black/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/kiboko/drum_gl
	spawn_magazine_type = /obj/item/ammo_box/magazine/c980_grenade/drum/shrapnel

/datum/atom_skin/kiboko
	abstract_type = /datum/atom_skin/kiboko
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/kiboko/default
	preview_name = "Default"
	new_icon_state = "kiboko"

/datum/atom_skin/kiboko/sand
	preview_name = "Desert"
	new_icon_state = "kiboko_sand"
