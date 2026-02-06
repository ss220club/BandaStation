/obj/item/gun/ballistic/automatic/vektor
	name = "Vektor submachine gun"
	desc = "Скорострельный и компактный пистолет-пулемет ТСФ стреляющий патронами калибра 9мм."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "vector"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "vector"
	bolt_type = BOLT_TYPE_OPEN
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/smgm9mm
	fire_sound = 'modular_bandastation/weapon/sound/ranged/cm70.ogg'
	can_suppress = TRUE
	suppressor_x_offset = 11
	burst_size = 1
	spread = 5
	fire_delay = 0.1 SECONDS
	actions_types = list()
	recoil = 0.4

/obj/item/gun/ballistic/automatic/vektor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/gun/ballistic/automatic/vektor/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 23, \
		overlay_y = 9 \
	)

/obj/item/gun/ballistic/automatic/vektor/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/vektor/black
	name = "tactical Vektor submachine gun"
	icon_state = "vector_black"
	inhand_icon_state = "vector_black"

/obj/item/gun/ballistic/automatic/vektor/black/no_mag
	spawnwithmagazine = FALSE
