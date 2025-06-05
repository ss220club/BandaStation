/obj/item/gun/ballistic/automatic/carwo
	name = "Carwo-Cawil Battle Rifle"
	desc = "Тяжелая боевая винтовка, стреляющая патронами калибра .40 Sol. Часто встречается в руках военных ТСФ. Принимает любой стандартный магазин от винтовок ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic48x32.dmi'
	icon_state = "infanterie"
	worn_icon = 'modular_bandastation/objects/icons/mob/back/guns_back.dmi'
	worn_icon_state = "infanterie"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/guns_righthand.dmi'
	inhand_icon_state = "infanterie"
	SET_BASE_PIXEL(-8, 0)
	special_mags = TRUE
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/standard
	fire_sound = 'modular_bandastation/objects/sounds/weapons/rifle_heavy.ogg'
	suppressed_sound = 'modular_bandastation/objects/sounds/weapons/suppressed_rifle.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 12
	burst_size = 1
	fire_delay = 0.35 SECONDS
	actions_types = list()
	spread = 5.5
	projectile_wound_bonus = -10
	recoil = 0.4
	obj_flags = UNIQUE_RENAME

/obj/item/gun/ballistic/automatic/carwo/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/carwo/examine_more(mob/user)
	. = ..()
	. += "Винтовки Карво-Кэвил создаются компанией Карво для использования различными пехотными подразделениями ТСФ. \
	В соответствии с довольно разумными военными требованиями, предусматривающими использование одного и того же ассортимента патронов и магазинов, \
	срок службы координаторов по логистике и квартирмейстеров повсеместно был продлен на несколько лет. \
	Хотя в прошлом они обычно продавались только военным, недавний крах некоторых неназванных производителей оружия \
	заставил Карво открыть многие образцы военного оружия для гражданской продажи, в том числе и этот."

/obj/item/gun/ballistic/automatic/carwo/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/carwo/auto

/obj/item/gun/ballistic/automatic/carwo/auto/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

// MARK: Sol marksman rifle
/obj/item/gun/ballistic/automatic/carwo/marksman
	name = "Cawil Marksman Rifle"
	desc = "Тяжелая марксманская винтовка, стреляющая патронами калибра .40 Sol. Часто встречается в руках военных ТСФ. Принимает любой стандартный магазин винтовок ТСФ."
	icon_state = "elite"
	worn_icon_state = "elite"
	inhand_icon_state = "elite"
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle
	fire_delay = 0.75 SECONDS
	spread = 0
	projectile_damage_multiplier = 1.1
	projectile_wound_bonus = 10
	recoil = 0.1

/obj/item/gun/ballistic/automatic/carwo/marksman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2)

/obj/item/gun/ballistic/automatic/carwo/marksman/examine_more(mob/user)
	. = ..()
	. += "Этот вариант представляет собой марксманскую винтовку. \
	Автоматическая стрельба была упразднена ради полуавтоматического режима, \
	более удобной ложи и, чаще всего, оптического прицела. \
	Как правило, для удобства стрелка используется магазин меньшего размера, \
	но, как и для любой другой винтовки ТСФ, подходят все стандартные типы магазинов."

/obj/item/gun/ballistic/automatic/carwo/marksman/no_mag
	spawnwithmagazine = FALSE

// MARK: Machineguns based on the base Sol rifle
/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/top_fed
	name = "Qarad Light Machinegun"
	desc = "Увесистый пулемет, стреляющий патронами калибра .40 Sol, часто встречающийся в руках военных ТСФ. Принимает любой стандартный магазин от винтовок ТСФ."
	icon_state = "qarad"
	bolt_type = BOLT_TYPE_OPEN
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/box
	fire_delay = 0.1 SECONDS
	recoil = 1
	spread = 12.5
	projectile_wound_bonus = -10

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/top_fed/examine_more(mob/user)
	. = ..()
	. += "Вариант винтовки под названием «Кварад», который вы сейчас видите, - это модификация, превратившая оружие в сносный, \
	хотя и неоптимальный легкий пулемет. Для поддержки роли пулемета внутренности винтовки были переделаны таким образом, \
	чтобы превратить ее в более скорострельный автомат с открытым затвором. \
	Эти дополнения в сочетании с особенностями боевой винтовки, которая изначально не предназначалась \
	для использования в автоматическом режиме, сделали ее довольно громоздкой. \
	Однако пулемет остается пулеметом, как бы трудно ни было удерживать ствол на цели. \
	Данный экземляр является вариантом, где подача боеприпасов идет сверху, а не снизу. \
	Благодаря этой особенности скорострельность намного выше чем у 'Дарака', но точность намного хуже из-за неудобства прицеливания."

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/bottom_fed
	name = "Daraq Light Machinegun"
	desc = "Увесистый пулемет, стреляющий патронами калибра .40 Sol, часто встречающийся в руках военных ТСФ. Принимает любой стандартный магазин от винтовок ТСФ."
	icon_state = "outomaties"
	worn_icon_state = "outomaties"
	inhand_icon_state = "outomaties"
	bolt_type = BOLT_TYPE_OPEN
	spawn_magazine_type = /obj/item/ammo_box/magazine/c40sol_rifle/box
	fire_delay = 0.2 SECONDS
	recoil = 1
	spread = 10.5
	projectile_wound_bonus = -10

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/update_overlays()
	. = ..()
	if(istype(magazine, /obj/item/ammo_box/magazine/c40sol_rifle/box) && !magazine.ammo_count())
		. += "[icon_state]_mag_rifle_box_empty"
	return .

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/bottom_fed/examine_more(mob/user)
	. = ..()
	. += "Вариант винтовки под названием «Дарак», который вы сейчас видите, - это модификация, превратившая оружие в сносный, \
	хотя и неоптимальный легкий пулемет. Для поддержки роли пулемета внутренности винтовки были переделаны таким образом, \
	чтобы превратить ее в более скорострельный автомат с открытым затвором. \
	Эти дополнения в сочетании с особенностями боевой винтовки, которая изначально не предназначалась \
	для использования в автоматическом режиме, сделали ее довольно громоздкой. \
	Однако пулемет остается пулеметом, как бы трудно ни было удерживать ствол на цели."

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/bottom_fed/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/top_fed/no_mag
	spawnwithmagazine = FALSE

// MARK: Black Sol rifle
/obj/item/gun/ballistic/automatic/carwo/auto/black
	desc = "Тяжелая боевая винтовка, стреляющая патронами калибра .40 Sol, окрашенная в тактический черный цвет. Принимает любой стандартный магазин от винтовок ТСФ."
	icon_state = "infanterie_black"
	worn_icon_state = "infanterie_black"
	inhand_icon_state = "infanterie_black"

/obj/item/gun/ballistic/automatic/carwo/auto/black/no_mag
	spawnwithmagazine = FALSE

// MARK: Sol rifles with wooden grips
/obj/item/gun/ballistic/automatic/carwo/auto/wooden
	desc = "Тяжелая боевая винтовка, стреляющая патронами калибра .40 Sol. Принимает любой стандартный магазин от винтовок ТСФ. Укороченный вариант с деревянной фурнитурой."
	icon_state = "infanterie_wooden"
	worn_icon_state = "infanterie_wooden"
	inhand_icon_state = "infanterie_wooden"

/obj/item/gun/ballistic/automatic/carwo/auto/wooden/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/carwo/marksman/wooden
	desc = "Тяжелая марксманская винтовка, стреляющая патронами калибра .40 Sol. Принимает любой стандартный магазин винтовок ТСФ. Немного упрощенный вариант с деревянной фурнитурой."
	icon_state = "elite_wooden"
	worn_icon_state = "elite_wooden"
	inhand_icon_state = "elite_wooden"
	projectile_damage_multiplier = 1
	projectile_wound_bonus = 5
	fire_delay = 0.80 SECONDS

/obj/item/gun/ballistic/automatic/carwo/marksman/wooden/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/bottom_fed/wooden
	name = "Daraq Light Machinegun"
	desc = "Увесистый пулемет, стреляющий патронами калибра .40 Sol. Принимает любой стандартный магазин от винтовок ТСФ. Немного упрощенный вариант с деревянной фурнитурой."
	icon_state = "outomaties_wooden"
	worn_icon_state = "outomaties_wooden"
	inhand_icon_state = "outomaties_wooden"

/obj/item/gun/ballistic/automatic/carwo/auto/machinegun/bottom_fed/wooden/no_mag
	spawnwithmagazine = FALSE
