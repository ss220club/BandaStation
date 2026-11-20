/// Shared mechanics for the two service pistols; neither inherits GP-9 reskins or lore.
/obj/item/gun/ballistic/automatic/pistol/sec_force
	abstract_type = /obj/item/gun/ballistic/automatic/pistol/sec_force
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force
	spawn_magazine_type = /obj/item/ammo_box/magazine/c9x25mm_pistol/sec_force/rubber
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	can_suppress = FALSE
	burst_fire_selection = FALSE
	special_mags = FALSE
	mag_display_ammo = FALSE
	selector_switch_icon = FALSE
	empty_indicator = FALSE
	fire_sound = 'sound/items/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/sec_force/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 14)

/obj/item/gun/ballistic/automatic/pistol/sec_force/mk58
	name = "Mk58"
	desc = "Самозарядный пистолет СБ под патроны 9×25 мм НТ для точной одиночной стрельбы."
	icon = 'modular_bandastation/weapon/icons/sec_force/pistols/mk58/objects.dmi'
	icon_state = "mk58"
	base_icon_state = "mk58"
	inhand_icon_state = "mk58"
	lefthand_file = 'modular_bandastation/weapon/icons/sec_force/pistols/mk58/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/sec_force/pistols/mk58/righthand.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/sec_force/pistols/mk58/belt.dmi'
	worn_icon_state = "mk58"
	fire_delay = 0.6 SECONDS
	spread = 0
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/sec_force/mk58/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/sec_force/viper
	name = "Viper"
	desc = "Пистолет СБ под патроны 9×25 мм НТ с отсечкой по три выстрела и чудовищной отдачей."
	icon = 'modular_bandastation/weapon/icons/sec_force/pistols/viper/objects.dmi'
	icon_state = "viper"
	base_icon_state = "viper"
	inhand_icon_state = "viper"
	lefthand_file = 'modular_bandastation/weapon/icons/sec_force/pistols/viper/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/sec_force/pistols/viper/righthand.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/sec_force/pistols/viper/belt.dmi'
	worn_icon_state = "viper"
	// Uses the same burst selector and firing pipeline as the APS, with slower bursts.
	actions_types = list(/datum/action/item_action/toggle_firemode)
	burst_fire_selection = TRUE
	burst_size = 3
	burst_delay = 0.2 SECONDS
	fire_delay = 1 SECONDS
	spread = 20
	recoil = 0.5

/obj/item/gun/ballistic/automatic/pistol/sec_force/viper/burst_select()
	. = ..()
	// The generic selector resets semi-auto fire_delay to zero.
	fire_delay = burst_fire_selection ? initial(fire_delay) : 0.5 SECONDS

/obj/item/gun/ballistic/automatic/pistol/sec_force/viper/no_mag
	spawnwithmagazine = FALSE
