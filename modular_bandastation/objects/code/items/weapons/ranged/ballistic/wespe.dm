/obj/item/gun/ballistic/automatic/pistol/wespe
	name = "'Wespe' pistol"
	desc = "Стандартный служебный пистолет различных военных подразделений ТСФ. Использует патрон .35 Sol Short имеет встроенный фонарик."
	icon = 'modular_bandastation/objects/icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "wespe"
	fire_sound = 'modular_bandastation/objects/sounds/weapons/pistol_light.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/c35sol_pistol
	special_mags = TRUE
	suppressor_x_offset = 7
	suppressor_y_offset = 0
	obj_flags = UNIQUE_RENAME
	unique_reskin = list(
		"Default" = "wespe",
		"Black" = "wespe_black",
	)

/obj/item/gun/ballistic/automatic/pistol/wespe/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете [EXAMINE_HINT("изучить подробнее")], чтобы узнать немного больше об этом оружии.")

/obj/item/gun/ballistic/automatic/pistol/wespe/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		starting_light = new /obj/item/flashlight/seclite(src), \
		is_light_removable = FALSE, \
		)

/obj/item/gun/ballistic/automatic/pistol/wespe/examine_more(mob/user)
	. = ..()
	. += "'Оса' - пистолет, созданный исключительно для военных целей. \
		Он должен был использовать стандартные патроны, стандартные магазины и быть способным \
		функционировать во всех условиях, в которых обычно работает ТСФ. \
		Так получилось, что эти качества сделали это оружие популярным \
		в пограничном пространстве, и, скорее всего, именно поэтому вы сейчас смотрите на \
		этот пистолет."

/obj/item/gun/ballistic/automatic/pistol/wespe/no_mag
	spawnwithmagazine = FALSE
