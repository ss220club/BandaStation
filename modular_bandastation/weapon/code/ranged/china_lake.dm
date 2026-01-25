/obj/item/gun/ballistic/shotgun/china_lake
	name = "China Lake 40mm"
	desc = "Oh, they're goin' ta have to glue you back together...IN HELL!"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/china_lake
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	icon_state = "china_lake"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "china_lake"
	worn_icon_state = "shotgun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	SET_BASE_PIXEL(0, 0)
	fire_sound = 'modular_bandastation/weapon/sound/ranged/grenade_launcher.ogg'

/obj/item/ammo_box/magazine/internal/china_lake
	name = "china lake internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 3
