/obj/item/gun/ballistic/automatic/bogseo
	name = "Bogseo Submachine Gun"
	desc = "Оружие, которое едва ли можно назвать 'пистолетом'- пулеметом, стреляющее чудовищными патронами калибра .585. \
        Оно обладает достаточной отдачей, чтобы сильно ушибить плечо, если использовать его без защиты."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "bogseo"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "bogseo"
	special_mags = TRUE
	bolt_type = BOLT_TYPE_STANDARD
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/c585sol
	spawn_magazine_type = /obj/item/ammo_box/magazine/c585sol/extended
	fire_sound = 'modular_bandastation/weapon/sound/ranged/smg_heavy_2.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 9
	burst_size = 1
	fire_delay = 0.15 SECONDS
	actions_types = list()
	spread = 12.5
	recoil = 1.5

/obj/item/gun/ballistic/automatic/bogseo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/bogseo/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/bogseo/examine_more(mob/user)
	. = ..()
	. += "Пистолет-пулемёт \"Богсео\" воспринимается по-разному в зависимости от того, кого вы спросите. \
		Спросите жителя Юпитера, и он будет весь день рассказывать, как он любит это оружие. \
		Большое оружие для стрельбы по большим целям, таким как налетчики-топливщики в своих больших доспехах. \
		Однако спросите космического пирата, и вы услышите совсем другую историю. Это благодаря тому, что многие \
		антипиратские подразделения ТСФ выбрали \"Богсео\" в качестве своего стандартного оружия для абордажа. \
		В конце концов, что может быть лучше, чем пуля, достаточно большая, чтобы превратить бандита в красный туман при стрельбе в автоматическом режиме?"

/obj/item/gun/ballistic/automatic/bogseo/no_mag
	spawnwithmagazine = FALSE
