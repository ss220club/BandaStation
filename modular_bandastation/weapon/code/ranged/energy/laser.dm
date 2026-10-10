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
