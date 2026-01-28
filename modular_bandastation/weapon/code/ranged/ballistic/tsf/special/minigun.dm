/obj/item/minigun_backpack
	name = "backpack minigun ammo stash"
	desc = "Массивный рюкзак который может держать много патронов на вашей спине."
	icon = 'modular_bandastation/weapon/icons/ranged/minigun.dmi'
	icon_state = "holstered"
	inhand_icon_state = "backpack"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/minigun_back.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/gun/ballistic/minigun/gun
	var/armed = FALSE //whether the gun is attached, FALSE is attached, TRUE is the gun is wielded.
	var/overheat = 0
	var/overheat_max = 100
	var/heat_stage = 0
	var/heat_diffusion = 2

/obj/item/minigun_backpack/Initialize(mapload)
	. = ..()
	gun = new(src)
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/drag_pickup)

/obj/item/minigun_backpack/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(gun && isatom(gun))
		gun.ammo_pack = null
		gun = null
	return ..()

/obj/item/minigun_backpack/process()
	overheat = max(0, overheat - heat_diffusion)
	if(overheat == 0 && heat_stage > 0)
		heat_stage = 0

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigun_backpack/attack_hand(mob/living/carbon/user)
	if(loc == user)
		if(!armed)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				armed = TRUE
				if(!user.put_in_hands(gun))
					armed = FALSE
					to_chat(user, span_warning("Вам нужна свободная рука, чтобы держать оружие!"))
					return
				update_appearance(UPDATE_ICON)
				user.update_worn_back()
		else
			to_chat(user, span_warning("Вы уже держите оружие!"))
	else
		..()

/obj/item/minigun_backpack/attackby(obj/item/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/minigun_backpack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Текущий уровень нагрева: [overheat] / [overheat_max]"

/obj/item/minigun_backpack/dropped(mob/user)
	. = ..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/minigun_backpack/update_icon_state()
	icon_state = armed ? "notholstered" : "holstered"
	return ..()

/obj/item/minigun_backpack/proc/attach_gun(mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = FALSE
	if(user)
		to_chat(user, span_notice("Вы прикрепляете [gun.name] к [name]."))
	else
		visible_message(span_warning("[gun.name] автоматически прикрепляется к [name]!"))
	update_appearance(UPDATE_ICON)
	user.update_worn_back()

/obj/item/gun/ballistic/minigun
	name = "M-546 \"Osprey\""
	desc = "Миниган разработанный в ТСФ в калибре .40 Long, обладающий невероятной скорострельностью и механизмом блокировки при перегреве. Требуется объемный рюкзак для хранения всех этих патронов."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic64x32.dmi'
	icon_state = "minigun_fire"
	inhand_icon_state = "minigun"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	burst_size = 1
	fire_delay = 0.1 SECONDS
	recoil = 1
	spread = 15
	fire_sound_volume = 80
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'modular_bandastation/weapon/sound/ranged/minigun.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/minigun
	actions_types = list()
	tac_reloads = FALSE
	casing_ejector = FALSE
	slowdown = 1
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	var/obj/item/minigun_backpack/ammo_pack

/obj/item/gun/ballistic/minigun/Initialize(mapload)
	if(!istype(loc, /obj/item/minigun_backpack)) //We should spawn inside an ammo pack so let's use that one.
		return INITIALIZE_HINT_QDEL //No pack, no gun
	ammo_pack = loc
	AddElement(/datum/element/update_icon_blocker)
	AddComponent(/datum/component/automatic_fire, fire_delay)
	return ..()

//To prevent unloading the gun
/obj/item/gun/ballistic/minigun/attack_hand(mob/user)
	return

/obj/item/gun/ballistic/minigun/attack_self(mob/living/user)
	return

/obj/item/gun/ballistic/minigun/dropped(mob/user)
	. = ..()
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		QDEL_NULL(src)

/obj/item/gun/ballistic/minigun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack)
		if(ammo_pack.overheat > ammo_pack.overheat_max * (1 / 3) && ammo_pack.heat_stage < 1)
			to_chat(user, span_notice("Вы чувствуете тепло от рукоятки оружия."))
			ammo_pack.heat_stage += 1
			..()
			playsound(user, 'sound/effects/wounds/sizzle2.ogg', 70, TRUE)

		if(ammo_pack.overheat > ammo_pack.overheat_max * (2 / 3) && ammo_pack.heat_stage < 2)
			to_chat(user, span_notice("Датчик температуры оружия быстро пищит, как только достигает предела!"))
			ammo_pack.heat_stage += 1
			..()
			playsound(user, 'sound/items/weapons/gun/general/empty_alarm.ogg', 50, TRUE)

		if(ammo_pack.overheat < ammo_pack.overheat_max)
			ammo_pack.overheat += burst_size
			..()
		else
			to_chat(user, span_notice("Датчик температуры оружия заблокировал спусковой крючок, чтобы предотвратить повреждение от перегрева."))
			playsound(user, 'sound/effects/wounds/sizzle1.ogg', 100, TRUE)

/obj/item/gun/ballistic/minigun/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, "Вам нужно больше патронов, чтобы стрелять из оружия!")
	. = ..()

/obj/item/gun/ballistic/minigun/Destroy()
	// detach from ammo pack so the pack won't reference a deleted gun
	if(ammo_pack && isatom(ammo_pack))
		ammo_pack.gun = null
		ammo_pack = null
	return ..()

/obj/item/gun/ballistic/minigun/dropped(mob/user)
	. = ..()
	if(ammo_pack && isatom(ammo_pack) && ammo_pack.loc == user)
		// put it back into the pack owned by this user
		ammo_pack.attach_gun(user)
	else
		QDEL_NULL(src)

/obj/item/ammo_box/magazine/internal/minigun
	name = "Minigun back stash box"
	ammo_type = /obj/item/ammo_casing/c40sol
	caliber = CALIBER_SOL40LONG
	max_ammo = 500
