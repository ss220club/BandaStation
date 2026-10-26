/obj/item/gun/ballistic/automatic/laser/pistol
	name = "X-02 Laser Pistol"
	desc = "Дорогостоящий экспериментальный лазерный пистолет X-02. Данная модель использует перезаряжаемые аккумуляторы, однако лишена возможности прямой подзарядки."
	icon = 'modular_bandastation/weapon/icons/ranged/energy.dmi'
	icon_state = "hoslaser"
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = "hoslaserkill4"
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/small
	fire_delay = 2 DECISECONDS
	rack_sound = 'modular_bandastation/weapon/sound/ranged/pulse_push.ogg'
	lock_back_sound = 'modular_bandastation/weapon/sound/ranged/pulse_pull.ogg'
	bolt_drop_sound = 'modular_bandastation/weapon/sound/ranged/pulse_push.ogg'

/obj/item/ammo_box/magazine/recharge
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	icon_state = "recharge-4"
	base_icon_state = "recharge"

/obj/item/ammo_box/magazine/recharge/small
	icon_state = "recharge_small-4"
	base_icon_state = "recharge_small"
	max_ammo = 10

/obj/item/ammo_box/magazine/recharge/try_load()
	return

/obj/item/gun/energy/lasercannon
	pin = /obj/item/firing_pin

/obj/item/gun/energy/laser/thermal/tng3
	name = "TNG-3 Thermal-Nanite pistol"
	desc = "Экспериментальный пистолет TNG-3 — специализированное энергетическое оружие, использующее гибридную технологию термально-нанитовой проекции."
	ammo_type = list(/obj/item/ammo_casing/energy/nanite/thermal_laser)
	icon_state = "cryopistol"
	light_color = COLOR_BLUE

/obj/item/ammo_casing/energy/nanite/thermal_laser
	projectile_type = /obj/projectile/energy/thermal_laser
	select_name = "therma-laser"
	fire_sound = 'sound/items/weapons/thermalpistol.ogg'

/obj/projectile/energy/thermal_laser
	icon_state = "pulse1_bl"
	speed = 1.5
	damage = 17
	stamina = 17
	range = 20
	projectile_piercing = PASSMOB
	light_color = LIGHT_COLOR_BLUE
	light_system = OVERLAY_LIGHT
	light_power = 1
	light_range = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
