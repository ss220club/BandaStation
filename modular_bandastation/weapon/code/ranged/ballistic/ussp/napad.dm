/obj/item/gun/ballistic/automatic/napad
	name = "PP-694 'Napad' submachine gun"
	desc = "Пистолет пулемет калибра 10мм, используемый специальными силами СССП."
	icon = 'modular_bandastation/weapon/icons/ranged/48x32.dmi'
	icon_state = "napad"
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back2.dmi'
	worn_icon_state = "napad"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand2.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand2.dmi'
	inhand_icon_state = "napad"
	special_mags = FALSE
	bolt_type = BOLT_TYPE_OPEN
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/smg10mm
	fire_sound = 'modular_bandastation/weapon/sound/ranged/smg_heavy_2.ogg'
	fire_sound_volume = 80
	load_sound = 'modular_bandastation/weapon/sound/ranged/napad_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/napad_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/napad_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/napad_unload.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0.3 SECONDS
	actions_types = list()
	spread = 6

/obj/item/gun/ballistic/automatic/napad/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/napad/examine_more(mob/user)
	. = ..()
	. += "ПП-694 \"Напад\" - одно из новейших оружий, созданных Оборонной Коллегией для армии СССП. \
		Этот пистолет-пулемет был разработан для специальных сил СССП, в качестве скорострельного, компактного и мощного оружия для ближнего боя. \
		Поэтому он оснащен складным прикладом, магазином на 30 калибра 10мм, а также множественными планками для установки тактических аксессуаров. \
		Хотя он немного больше, чем пистолеты пулеметы, используемые в ТСФ, он с лихвой компенсирует это легкостью управления и значительной скорострельностью."

/obj/item/gun/ballistic/automatic/napad/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/napad/no_mag
	spawnwithmagazine = FALSE
