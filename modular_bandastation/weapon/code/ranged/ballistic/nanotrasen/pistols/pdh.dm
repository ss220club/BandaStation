
/obj/item/gun/ballistic/automatic/pistol/pdh
	name = "PDH-A2 'Osprey'"
	desc = "Крупнокалиберный пистолет PDH-A2 'Osprey' - это тяжелое полуавтоматическое оружие личной защиты, созданное для гарантированного поражения тяжелобронированных целей в замкнутых пространствах."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic40x32.dmi'
	icon_state = "pdh_alt"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m45a5
	can_suppress = FALSE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_heavy.ogg'
	rack_sound = 'modular_bandastation/weapon/sound/ranged/cm357_cocked.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'
	load_sound = 'modular_bandastation/weapon/sound/ranged/cm357_reload.ogg'
	load_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm357_reload.ogg'
	eject_sound = 'modular_bandastation/weapon/sound/ranged/cm357_unload.ogg'
	eject_empty_sound = 'modular_bandastation/weapon/sound/ranged/cm357_unload.ogg'
	recoil = 1
	fire_sound_volume = 100

/obj/item/gun/ballistic/automatic/pistol/pdh/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/pdh)

/datum/atom_skin/pdh
	abstract_type = /datum/atom_skin/pdh
	change_base_icon_state = TRUE
	change_worn_icon_state = FALSE

/datum/atom_skin/pdh/default
	preview_name = "Default"
	new_icon_state = "pdh_alt"

/datum/atom_skin/pdh/black
	preview_name = "Black"
	new_icon_state = "pdh_alt_black"

/datum/atom_skin/pdh/corporate
	preview_name = "Corporate"
	new_icon_state = "pdh_corpo"

/obj/item/gun/ballistic/automatic/pistol/pdh/ladon
	name = "PDH-A1 'Ladon'"
	desc = "Тяжелый тактический пистолет 'Ladon' — это полуавтоматическое оружие личной защиты, созданное для тех, кому требуется сокрушительная огневая мощь ручной пушки."
	icon_state = "ladon"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	fire_sound = 'modular_bandastation/weapon/sound/ranged/revolver_fire_2.ogg'

/obj/item/gun/ballistic/automatic/pistol/pdh/ladon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/ladon)

/datum/atom_skin/ladon
	abstract_type = /datum/atom_skin/ladon
	change_base_icon_state = TRUE
	change_worn_icon_state = FALSE

/datum/atom_skin/ladon/default
	preview_name = "Default"
	new_icon_state = "ladon"

/datum/atom_skin/ladon/tactical
	preview_name = "Tac"
	new_icon_state = "ladon_tactical"

/datum/atom_skin/ladon/dark
	preview_name = "Dark"
	new_icon_state = "dark_ladon"

/obj/item/gun/ballistic/automatic/pistol/pdh/hos
	name = "PDH-A2-NR 'Osprey'"
	desc = parent_type::desc + "<br>Модифицированный PDH 'Osprey' под более распространенный калибр .357 с уменьшенной летальной силой."
	icon_state = "pdh"
	projectile_damage_multiplier = 0.5
	accepted_magazine_type = /obj/item/ammo_box/magazine/c357

/obj/item/gun/ballistic/automatic/pistol/pdh/hos/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/pdh_hos)

/datum/atom_skin/pdh_hos
	abstract_type = /datum/atom_skin/pdh_hos
	change_base_icon_state = TRUE
	change_worn_icon_state = FALSE

/datum/atom_skin/pdh_hos/default
	preview_name = "Default"
	new_icon_state = "pdh"

/datum/atom_skin/pdh_hos/black
	preview_name = "Gray"
	new_icon_state = "pdh_gray"

/datum/atom_skin/pdh_hos/peacekeeper
	preview_name = "Peacekeeper"
	new_icon_state = "pdh_peacekeeper"
