/obj/item/gun
	obj_flags = UNIQUE_RENAME

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
	base_icon_state = "riotshotgun"

/obj/item/gun/ballistic/shotgun/riot/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 31, \
		overlay_y = 11)

/obj/item/gun/ballistic/shotgun/riot/update_icon_state()
	. = ..()
	if(sawn_off)
		inhand_icon_state = "[base_icon_state]_sawn"
		SET_BASE_PIXEL(0, 0)
	else
		inhand_icon_state = "[base_icon_state]"

/obj/item/gun/ballistic/shotgun/riot/sawoff(mob/user, obj/item/saw, handle_modifications)
	. = ..()
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 20, \
		overlay_y = 11 \
	)

/obj/item/gun/ballistic/shotgun/riot/lethal
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/riot/lethal

/obj/item/ammo_box/magazine/internal/shot/riot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	max_ammo = 6

/obj/item/gun/ballistic/shotgun/automatic/combat/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 30, \
		overlay_y = 11)

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 20, \
		overlay_y = 11)

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

/obj/item/gun/ballistic/shotgun/china_lake
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	SET_BASE_PIXEL(0, 0)

// Other guns stuff
/obj/item/gun/ballistic/revolver
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	recoil = 0.4

/obj/item/gun/ballistic/revolver/cowboy
	icon_state = "cowboy"

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

/obj/item/gun/ballistic/revolver/reverse/mateba
	icon = 'icons/obj/weapons/guns/ballistic.dmi'

/obj/item/gun/ballistic/revolver/russian
	icon = 'icons/obj/weapons/guns/ballistic.dmi'

/obj/item/gun/ballistic/revolver/c38
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	recoil = 0.3

/obj/item/gun/ballistic/revolver/grenadelauncher
	icon = 'icons/obj/weapons/guns/ballistic.dmi'

/obj/item/gun/ballistic/automatic/pistol
	recoil = 0.2

/obj/item/gun/ballistic/automatic/pistol/clandestine
	recoil = 0.3

/obj/item/gun/ballistic/automatic/pistol/deagle
	recoil = 1.2

/obj/item/gun/ballistic/automatic/smartgun
	recoil = 0.1

/obj/item/gun/ballistic/automatic/ar
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/ranged/guns_back.dmi'
	recoil = 0.3
	accepted_magazine_type = /obj/item/ammo_box/magazine/c223
	spawn_magazine_type = /obj/item/ammo_box/magazine/c223
	SET_BASE_PIXEL(-8, 0)
	can_suppress = TRUE
	suppressor_x_offset = 7
	weapon_weight = WEAPON_HEAVY
	var/extended = TRUE

/obj/item/gun/ballistic/automatic/ar/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 29, \
		overlay_y = 12)

/obj/item/gun/ballistic/automatic/ar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/ar/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][extended ? "_extended" : ""]"
	inhand_icon_state = "[icon_state][magazine ? "":"_nomag"]"
	worn_icon_state = "[icon_state][magazine ? "":"_nomag"]"

/obj/item/gun/ballistic/automatic/ar/examine(mob/user)
	. = ..()
	. += "<b>АЛЬТ + ЛКМ</b> чтобы [extended ? "сложить" : "разложить"] приклад."

/obj/item/gun/ballistic/automatic/ar/click_alt(mob/user)
	if(!user.is_holding(src))
		balloon_alert(user, "Оружие должно быть в руках!")
		return CLICK_ACTION_BLOCKING
	if(!do_after(user, 5, src))
		return
	extended = !extended
	if(!extended)
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = ITEM_SLOT_BELT
		recoil = 1
	else
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		weapon_weight = WEAPON_HEAVY
		recoil = 0.3

	balloon_alert(user, "[extended ? "разложен" : "сложен"]")
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/automatic/mini_uzi
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	recoil = 0.4
	burst_size = 1
	suppressor_x_offset = 7

/obj/item/gun/ballistic/automatic/mini_uzi/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/mini_uzi/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 21, \
		overlay_y = 11)

/obj/item/gun/ballistic/automatic/proto
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	suppressor_x_offset = 9
	recoil = 0.2

/obj/item/gun/ballistic/automatic/proto/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 24, \
		overlay_y = 11)

/obj/item/gun/ballistic/automatic/battle_rifle
	recoil = 0.3

/obj/item/gun/ballistic/automatic/wt550
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic.dmi'
	recoil = 0.3
	suppressor_x_offset = 11
	can_suppress = TRUE

/obj/item/gun/ballistic/automatic/wt550/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 25, \
		overlay_y = 10)

/obj/item/gun/ballistic/automatic/m90
	recoil = 0.3

/obj/item/gun/ballistic/automatic/c20r
	recoil = 0.2

/obj/item/gun/ballistic/automatic/proto
	recoil = 0.2

/obj/item/gun/ballistic/automatic/tommygun
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	SET_BASE_PIXEL(-8, 0)
	recoil = 0.2

/obj/item/gun/ballistic/automatic/laser
	recoil = 0

/obj/item/gun/ballistic/automatic/l6_saw
	recoil = 0.5

/obj/item/gun/ballistic/automatic/gyropistol
	recoil = 0.1

/obj/item/gun/grenadelauncher
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic48x32.dmi'
	SET_BASE_PIXEL(-8, 0)

/obj/item/gun/ballistic/rifle/sniper_rifle
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic64x32.dmi'
	SET_BASE_PIXEL(-16, 0)
	suppressor_x_offset = 11
	suppressor_y_offset = 0

/obj/item/gun/ballistic/rifle/sniper_rifle/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 36, \
		overlay_y = 11)

/obj/item/gun/ballistic/automatic/bow
	recoil = 0

//Toy guns
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
