/// Imported HONK appearance on the native energy-gun firing and recharge system.
/obj/item/gun/energy/honk_rifle
	name = "security HONK rifle"
	desc = "Личное ХОНК-ружьё клоуна Службы Безопасности. Стреляет хлопушками."
	icon = 'modular_bandastation/donor_jobs/icons/honk_rifle.dmi'
	icon_state = "honkrifle_security"
	inhand_icon_state = null // Native energy guns select the existing charge states 0–4.
	lefthand_file = 'modular_bandastation/donor_jobs/icons/honk_rifle_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/honk_rifle_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/snap_pop)
	clumsy_check = FALSE
	selfcharge = TRUE
	self_charge_amount = 50
	charge_delay = 8
	cell_type = /obj/item/stock_parts/power_store/cell/honk_rifle
	ammo_x_offset = 3
	w_class = WEIGHT_CLASS_NORMAL
	automatic_charge_overlays = FALSE
	single_shot_type_overlay = FALSE
	display_empty = FALSE

/obj/item/gun/energy/honk_rifle/warden
	name = "warden's HONK rifle"
	desc = "Личное ХОНК-ружьё клоуна-смотрителя, выданное за заслуги перед Нанотрейзен."

/obj/item/stock_parts/power_store/cell/honk_rifle
	maxcharge = 1000

/obj/item/ammo_casing/energy/snap_pop
	projectile_type = /obj/projectile/snap_pop
	e_cost = 100
	fire_sound = 'sound/items/weapons/gun/smg/shot.ogg'
	firing_effect_type = null
	select_name = "clown"

/// A fired native snap-pop, without the banana honker's damage, slip or piercing.
/obj/projectile/snap_pop
	name = "snap-pop"
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "snappop"
	damage = 0

/obj/projectile/snap_pop/impact(atom/target)
	if(deletion_queued)
		return
	deletion_queued = PROJECTILE_IMPACT_DELETE
	var/obj/item/toy/snappop/snap_pop = new(get_turf(src))
	snap_pop.pop_burst()
	qdel(src)
