/obj/item/minigun_backpack
	name = "backpack minigun ammo stash"
	desc = "Массивный рюкзак который может держать много патронов на вашей спине."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/minigun.dmi'
	icon_state = "holstered"
	inhand_icon_state = "backpack"
	worn_icon = 'modular_bandastation/voyaker_events/icons/weapon/minigun_back.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/gun/ballistic/minigun/gun
	var/armed = FALSE //whether the gun is attached, FALSE is attached, TRUE is the gun is wielded.
	var/overheat = 0
	var/overheat_max = 100
	var/heat_stage = 0
	var/heat_diffusion = 2

/obj/item/minigun_backpack/Initialize(mapload)
	. = ..()
	gun = new(src)
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/drag_pickup)

/obj/item/minigun_backpack/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(gun && isatom(gun))
		gun.ammo_pack = null
		gun = null
	return ..()

/obj/item/minigun_backpack/process()
	overheat = max(0, overheat - heat_diffusion)
	if(overheat == 0 && heat_stage > 0)
		heat_stage = 0

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigun_backpack/attack_hand(mob/living/carbon/user)
	if(loc == user)
		if(!armed)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				armed = TRUE
				if(!user.put_in_hands(gun))
					armed = FALSE
					to_chat(user, span_warning("Вам нужна свободная рука, чтобы держать оружие!"))
					return
				update_appearance(UPDATE_ICON)
				user.update_worn_back()
		else
			to_chat(user, span_warning("Вы уже держите оружие!"))
	else
		..()

/obj/item/minigun_backpack/attackby(obj/item/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/minigun_backpack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Текущий уровень нагрева: [overheat] / [overheat_max]"

/obj/item/minigun_backpack/dropped(mob/user)
	. = ..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/minigun_backpack/update_icon_state()
	icon_state = armed ? "notholstered" : "holstered"
	return ..()

/obj/item/minigun_backpack/proc/attach_gun(mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = FALSE
	if(user)
		to_chat(user, span_notice("Вы прикрепляете [gun.name] к [name]."))
	else
		visible_message(span_warning("[gun.name] автоматически прикрепляется к [name]!"))
	update_appearance(UPDATE_ICON)
	user.update_worn_back()

/obj/item/gun/ballistic/minigun
	name = "M-546 \"Osprey\""
	desc = "Миниган разработанный в ТСФ в калибре .40 Long, обладающий невероятной скорострельностью и механизмом блокировки при перегреве. Требуется объемный рюкзак для хранения всех этих патронов."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ballistic64x32.dmi'
	icon_state = "minigun_fire"
	inhand_icon_state = "minigun"
	lefthand_file = 'modular_bandastation/voyaker_events/icons/weapon/lefthand.dmi'
	righthand_file = 'modular_bandastation/voyaker_events/icons/weapon/righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	burst_size = 1
	fire_delay = 0.1 SECONDS
	recoil = 1
	spread = 15
	fire_sound_volume = 80
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'modular_bandastation/voyaker_events/sounds/weapon/minigun.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/minigun
	actions_types = list()
	tac_reloads = FALSE
	casing_ejector = FALSE
	slowdown = 1
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	var/obj/item/minigun_backpack/ammo_pack

/obj/item/gun/ballistic/minigun/Initialize(mapload)
	if(!istype(loc, /obj/item/minigun_backpack)) //We should spawn inside an ammo pack so let's use that one.
		return INITIALIZE_HINT_QDEL //No pack, no gun
	ammo_pack = loc
	AddElement(/datum/element/update_icon_blocker)
	AddComponent(/datum/component/automatic_fire, fire_delay)
	return ..()

//To prevent unloading the gun
/obj/item/gun/ballistic/minigun/attack_hand(mob/user)
	return

/obj/item/gun/ballistic/minigun/attack_self(mob/living/user)
	return

/obj/item/gun/ballistic/minigun/dropped(mob/user)
	. = ..()
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		QDEL_NULL(src)
	if(ammo_pack && isatom(ammo_pack) && ammo_pack.loc == user)
		// put it back into the pack owned by this user
		ammo_pack.attach_gun(user)
	else
		QDEL_NULL(src)

/obj/item/gun/ballistic/minigun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack)
		if(ammo_pack.overheat > ammo_pack.overheat_max * (1 / 3) && ammo_pack.heat_stage < 1)
			to_chat(user, span_notice("Вы чувствуете тепло от рукоятки оружия."))
			ammo_pack.heat_stage += 1
			..()
			playsound(user, 'sound/effects/wounds/sizzle2.ogg', 70, TRUE)

		if(ammo_pack.overheat > ammo_pack.overheat_max * (2 / 3) && ammo_pack.heat_stage < 2)
			to_chat(user, span_notice("Датчик температуры оружия быстро пищит, как только достигает предела!"))
			ammo_pack.heat_stage += 1
			..()
			playsound(user, 'sound/items/weapons/gun/general/empty_alarm.ogg', 50, TRUE)

		if(ammo_pack.overheat < ammo_pack.overheat_max)
			ammo_pack.overheat += burst_size
			..()
		else
			to_chat(user, span_notice("Датчик температуры оружия заблокировал спусковой крючок, чтобы предотвратить повреждение от перегрева."))
			playsound(user, 'sound/effects/wounds/sizzle1.ogg', 100, TRUE)

/obj/item/gun/ballistic/minigun/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, "Вам нужно больше патронов, чтобы стрелять из оружия!")
	. = ..()

/obj/item/gun/ballistic/minigun/Destroy()
	// detach from ammo pack so the pack won't reference a deleted gun
	if(ammo_pack && isatom(ammo_pack))
		ammo_pack.gun = null
		ammo_pack = null
	return ..()

/obj/item/ammo_box/magazine/internal/minigun
	name = "Minigun back stash box"
	ammo_type = /obj/item/ammo_casing/c40sol
	caliber = CALIBER_SOL40LONG
	max_ammo = 500


/obj/item/gun/ballistic/automatic/kiboko
	name = "Kiboko grenade launcher"
	desc = "Уникальный гранатомет ТСФ, стреляющий гранатами калибра .980. Лазерная прицельная система позволяет пользователю задать дальность, на которой должны взрываться выпущенные гранаты."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ballistic48x32.dmi'
	icon_state = "kiboko"
	worn_icon = 'modular_bandastation/voyaker_events/icons/weapon/guns_back.dmi'
	worn_icon_state = "kiboko"
	lefthand_file = 'modular_bandastation/voyaker_events/icons/weapon/lefthand.dmi'
	righthand_file = 'modular_bandastation/voyaker_events/icons/weapon/righthand.dmi'
	inhand_icon_state = "kiboko"
	SET_BASE_PIXEL(-8, 0)
	special_mags = TRUE
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/c980_grenade
	fire_sound = 'modular_bandastation/voyaker_events/sounds/weapon/grenade_launcher.ogg'
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
