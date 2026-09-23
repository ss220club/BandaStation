/obj/item/gun/ballistic/automatic/pistol/gp9
	name = "GP-9"
	desc = "Стандартный служебный пистолет общего назначения под малоимпульсные патроны калибра 9x25мм НТ."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic40x32.dmi'
	icon_state = "gp9"
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'sound/items/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/c9x25mm_pistol
	special_mags = TRUE
	suppressor_x_offset = 4
	suppressor_y_offset = -1
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/gp9/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/gp9)

/obj/item/gun/ballistic/automatic/pistol/gp9/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 13 \
	)

/obj/item/gun/ballistic/automatic/pistol/gp9/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "GP-9 - пистолет общего назначения, разработанный оружейным отделом Нанотрейзен \
	под малоимпульсные патроны калибра 9x25мм. Данный пистолет был создан для использования отделами \
	службы безопастности на обьектах Нанотрейзен во всех возможных условиях, в которых обычно работает НТ, \
	в частности в условиях повышенной ионической среды, где использование стандартного лазерного вооружения \
	менее эффективно.")

/obj/item/gun/ballistic/automatic/pistol/gp9/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/gp9/sec
	spawn_magazine_type = /obj/item/ammo_box/magazine/c9x25mm_pistol/rubber

/datum/atom_skin/gp9
	abstract_type = /datum/atom_skin/gp9
	change_base_icon_state = TRUE

/datum/atom_skin/gp9/default
	preview_name = "Default"
	new_icon_state = "gp9"

/datum/atom_skin/gp9/black
	preview_name = "Black"
	new_icon_state = "gp9_black"

/datum/atom_skin/gp9/red
	preview_name = "Red"
	new_icon_state = "gp9_red"

/datum/atom_skin/gp9/carmapple
	preview_name = "Black & Red"
	new_icon_state = "gp9_carmapple"

/datum/atom_skin/gp9/green
	preview_name = "Green & Wood"
	new_icon_state = "gp9_green"

/obj/item/gun/ballistic/automatic/pistol/gp9/spec
	name = "GP-93R"
	desc = "Стандартный служебный пистолет общего назначения под малоимпульсные патроны калибра 9x25мм НТ. Специальный вариант с возможностью вести автоматический огонь."
	icon_state = "gp93r"
	spread = 10
	fire_delay = 0.20 SECONDS
	recoil = 0.2
	burst_size = 1
	spawn_magazine_type = /obj/item/ammo_box/magazine/c9x25mm_pistol/stendo

/obj/item/gun/ballistic/automatic/pistol/gp9/spec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/automatic/pistol/gp9/spec/examine_more(mob/user)
	. = ..()
	. += "Модель GP-93R является модификацией GP-9 c добавлением возможности вести автоматический огонь \
	и улучшенной эргономикой. Данный вариант был разработан для использования корпоративными спецслужбами Нанотрейзен."

/obj/item/gun/ballistic/automatic/pistol/gp9/spec/no_mag
	spawnwithmagazine = FALSE
