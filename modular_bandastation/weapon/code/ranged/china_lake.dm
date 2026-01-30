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

/datum/uplink_item/weapon_kits/medium_cost/china_lake
	name = "China Lake 40mm Grenade Launcher (Hard)"
	desc = "An old but trusty 40mm pump grenade launcher preloaded with a HE grenades. \
		Guaranteed to take your target out with a bang, or your money back! Comes with a box of additional grenades!"
	item = /obj/item/storage/toolbox/guncase/china_lake
	relevant_child_items = list(
		/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm,
		/datum/uplink_item/ammo_nuclear/special/carbine/a40mm/stun,
		/datum/uplink_item/ammo_nuclear/incendiary/carbine/a40mm/incendiary,
		/datum/uplink_item/ammo_nuclear/hp/carbine/a40mm/frag,
		/datum/uplink_item/ammo_nuclear/ap/carbine/a40mm/hedp,
		/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/smoke,
	)

/obj/item/storage/toolbox/guncase/china_lake
	name = "China Lake grenade launcher guncase"
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/china_lake
	extra_to_spawn = /obj/item/storage/fancy/a40mm_box

/obj/item/storage/toolbox/guncase/china_lake/PopulateContents()
	new weapon_to_spawn (src)
	new extra_to_spawn (src)
	new /obj/item/ammo_box/a40mm/rubber (src)
	new /obj/item/storage/fancy/a40mm_box/smoke (src)

/obj/item/gun/ballistic/revolver/grenadelauncher/sec
	name = "GL-41 40mm grenade launcher"
	desc = "40mm break-operated grenade launcher."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "riotgun"
	inhand_icon_state = "riotgun"
	fire_sound = 'modular_bandastation/weapon/sound/ranged/grenade_launcher.ogg'
	pin = /obj/item/firing_pin
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/grenadelauncher/sec

/obj/item/ammo_box/magazine/internal/grenadelauncher/sec
	name = "GL-41 grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm/rubber
