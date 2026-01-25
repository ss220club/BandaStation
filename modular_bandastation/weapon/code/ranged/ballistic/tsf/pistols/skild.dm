/obj/item/gun/ballistic/automatic/pistol/skild
	name = "Skild pistol"
	desc = "Довольно редкий пистолет ТСФ, стреляющий патронами большого калибра .585 Sol. \
		Используется редко, в основном из-за того, что вызывает сильный дискомфорт в запястье."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "skild"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_light_2.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	special_mags = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/c585sol
	suppressor_x_offset = 8
	suppressor_y_offset = 0
	recoil = 1.2

/obj/item/gun/ballistic/automatic/pistol/skild/army/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/skild/army
	icon_state = "skild_army"
	desc = parent_type::desc + "<br>Армейская версия c бул-пап компоновкой в сером полимере."
	recoil = 1

/obj/item/gun/ballistic/automatic/pistol/skild/no_mag
	spawnwithmagazine = FALSE
