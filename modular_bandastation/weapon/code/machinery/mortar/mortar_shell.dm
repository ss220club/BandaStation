// MARK: BASIC SHELL

/obj/item/mortar_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'modular_bandastation/weapon/icons/machinery/mortar.dmi'
	icon_state = "mortar_ammo_cas"

/obj/item/mortar_shell/proc/detonate(turf/target_turf)
	forceMove(target_turf)

// MARK: MEDIUM EXPLOSIVE

/obj/item/mortar_shell/me
	name = "\improper 80mm medium explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a me explosive charge."
	icon_state = "mortar_ammo_frag"

/obj/item/mortar_shell/me/detonate(turf/target_turf)
	explosion(target_turf, 0, 2, 4, 0, explosion_cause = src)

// MARK: HIGH EXPLOSIVE

/obj/item/mortar_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"

/obj/item/mortar_shell/he/detonate(turf/target_turf)
	explosion(target_turf, 1, 3, 5, 0, explosion_cause = src)

/obj/item/mortar_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a Type B napalm charge. Perfect for long-range area denial."
	icon_state = "mortar_ammo_inc"

/obj/item/mortar_shell/incendiary/detonate(turf/target_turf)
	explosion(target_turf, 0, 1, 3, 7, explosion_cause = src)
