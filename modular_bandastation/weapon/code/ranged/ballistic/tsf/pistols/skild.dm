/obj/item/gun/ballistic/automatic/pistol/skild
	name = "Skild Pistol"
	desc = "Довольно редкий пистолет ТСФ, стреляющий патронами большого калибра .585, разработанными той же компанией. \
		Используется редко, в основном из-за того, что вызывает сильный дискомфорт в запястье."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "skild"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/pistol_light_2.ogg'
	suppressed_sound = 'modular_bandastation/weapon/sound/ranged/suppressed_heavy.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/c585sol
	suppressor_x_offset = 8
	suppressor_y_offset = 0
	recoil = 3

/obj/item/gun/ballistic/automatic/pistol/skild/army
	icon_state = "skild_army"
	desc = parent_type::desc + "<br>Армейская версия в сером полимере."
