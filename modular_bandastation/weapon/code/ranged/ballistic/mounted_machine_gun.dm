/obj/item/mounted_machine_gun_folded
	name = "folded M2T9 mounted machine gun"
	desc = "Сложенный и разряженный станковый пулемет, готовый к развертыванию и использованию."
	icon = 'modular_bandastation/weapon/icons/ranged/turret_objects.dmi'
	icon_state = "folded_hmg"
	max_integrity = 250
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

/obj/item/mounted_machine_gun_folded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/mounted_machine_gun)

/obj/machinery/deployable_turret/mounted_machine_gun
	name = "M2T9 Mounted Machine Gun"
	desc = "Крупнокалиберный станковый пулемет, способный вести огонь на подавление."
	icon = 'modular_bandastation/weapon/icons/ranged/turret.dmi'
	icon_state = "mmg"
	base_icon_state = "mmg"
	max_integrity = 250
	projectile_type = /obj/projectile/bullet/p50/mmg
	anchored = TRUE
	number_of_shots = 5
	cooldown_duration = 1 SECONDS
	rate_of_fire = 2
	firesound = 'modular_bandastation/weapon/sound/ranged/50cal_box_01.ogg'
	overheatsound = 'sound/effects/wounds/sizzle2.ogg'
	can_be_undeployed = TRUE
	spawned_on_undeploy = /obj/item/mounted_machine_gun_folded
	SET_BASE_PIXEL(-8, -8)
	always_anchored = TRUE

/obj/machinery/deployable_turret/mounted_machine_gun/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || target == get_turf(src))
		return
	target_turf = get_turf(target)
	fire_helper(user)
