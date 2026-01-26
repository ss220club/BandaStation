/obj/item/gun
	obj_flags = UNIQUE_RENAME

// Base recoil
/obj/item/gun/ballistic
	recoil = 1

// Shotguns stuff
/obj/item/gun/ballistic/shotgun
	obj_flags = UNIQUE_RENAME
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/ballistic/shotgun/riot
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	base_icon_state = "riotshotgun"

/obj/item/gun/ballistic/shotgun/riot/update_icon_state()
	. = ..()
	if(sawn_off)
		inhand_icon_state = "[base_icon_state]_sawoff"
	else
		inhand_icon_state = "[base_icon_state]"

/obj/item/gun/ballistic/shotgun/riot/sawoff(mob/user, obj/item/saw, handle_modifications)
	. = ..()
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'

/obj/item/gun/ballistic/shotgun/sc_pump
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/doublebarrel
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/hook
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/monkey
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/musket
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/bulldog
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	recoil = 0.5
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/riot_one_hand
	name = "one-hand riot shotgun"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot
	weapon_weight = WEAPON_MEDIUM
	inhand_x_dimension = 64
	inhand_y_dimension = 64

/obj/item/gun/ballistic/shotgun/ctf
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	SET_BASE_PIXEL(0, 0)

// Other guns stuff
/obj/item/gun/ballistic/revolver
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	recoil = 0.4

/obj/item/gun/ballistic/revolver/badass
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	recoil = 0.3

/obj/item/gun/ballistic/revolver/mateba
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	recoil = 0.2

/obj/item/gun/ballistic/revolver/golden
	icon = 'icons/obj/weapons/guns/ballistic.dmi'

/obj/item/gun/ballistic/revolver/nagant
	icon = 'icons/obj/weapons/guns/ballistic.dmi'

/obj/item/gun/ballistic/revolver/peashooter
	icon = 'icons/obj/weapons/guns/ballistic.dmi'

/obj/item/gun/ballistic/revolver/c38
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol
	recoil = 0.2

/obj/item/gun/ballistic/automatic/pistol/clandestine
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/deagle
	recoil = 1.2

/obj/item/gun/ballistic/automatic/smartgun
	recoil = 0.1

/obj/item/gun/ballistic/automatic/ar
	recoil = 0.3

/obj/item/gun/ballistic/automatic/proto
	recoil = 0.2

/obj/item/gun/ballistic/automatic/battle_rifle
	recoil = 0.3

/obj/item/gun/ballistic/automatic/wt550
	recoil = 0.3

/obj/item/gun/ballistic/automatic/m90
	recoil = 0.3

/obj/item/gun/ballistic/automatic/c20r
	recoil = 0.2

/obj/item/gun/ballistic/automatic/proto
	recoil = 0.2

/obj/item/gun/ballistic/automatic/laser
	recoil = 0

/obj/item/gun/ballistic/automatic/l6_saw
	recoil = 0.5

/obj/item/gun/ballistic/automatic/gyropistol
	recoil = 0.1

/obj/item/gun/ballistic/automatic/bow
	recoil = 0

/obj/item/gun/ballistic/automatic/pistol/toy
	recoil = 0

/obj/item/gun/ballistic/automatic/toy
	recoil = 0

/obj/item/gun/ballistic/shotgun/toy
	recoil = 0

/obj/item/gun/ballistic/automatic/c20r/toy
	recoil = 0

/obj/item/gun/ballistic/automatic/l6_saw/toy
	recoil = 0

/obj/item/gun/ballistic/shotgun/riot/lethal
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot/lethal

/obj/item/ammo_box/magazine/internal/shot/riot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	max_ammo = 6

// MARK: Uplink items
/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm
	item = /obj/item/storage/fancy/a40mm_box

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/stun
	item = /obj/item/storage/fancy/a40mm_box/stun

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/incendiary
	item = /obj/item/storage/fancy/a40mm_box/incendiary

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/frag
	item = /obj/item/storage/fancy/a40mm_box/frag

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/smoke
	item = /obj/item/storage/fancy/a40mm_box/smoke

/datum/uplink_item/ammo_nuclear/basic/carbine/a40mm/hedp
	item = /obj/item/storage/fancy/a40mm_box/hedp

// Ammo casing random drop rotation
/obj/item/ammo_casing/update_icon_state()
	. = ..()
	if(!loaded_projectile)
		var/random_angle = rand(0,360)
		transform = transform.Turn(random_angle)

// Prevents gun sizes from changing due to suppressors
/obj/item/gun/ballistic/install_suppressor(obj/item/suppressor/new_suppressor)
	. = ..()
	w_class -= suppressor.w_class

// Prevents gun sizes from changing due to suppressors
/obj/item/gun/ballistic/clear_suppressor()
	w_class = initial(w_class)
	return ..()

/obj/item/firing_pin/alert_level
	name = "alert level firing pin"
	var/desired_minimum_alert = SEC_LEVEL_GREEN

/obj/item/firing_pin/alert_level/blue
	desired_minimum_alert = SEC_LEVEL_BLUE
	desc = "Небольшое устройство аутентификации, которое вставляется в спусковой механизм оружия для обеспечения его работоспособности. Данное устройство настроено на стрельбу только при синем уровне тревоги или выше."
	fail_message = "низкий уровень тревоги!"

/obj/item/firing_pin/alert_level/pin_auth(mob/living/user)
	return (SSsecurity_level.current_security_level.number_level >= desired_minimum_alert)
