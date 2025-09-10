/datum/action/cooldown/shadowling/hook
	name = "Теневой крюк"
	desc = "Подготовить теневое щупальце, чтобы притянуть предмет или существо. Работает как у генокрада: одно использование."
	button_icon_state = "shadow_hook"
	cooldown_time = 10 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 8
	channel_time = 0
	var/in_use = FALSE

/datum/action/cooldown/shadowling/hook/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H) || in_use)
		return FALSE

	var/obj/item/gun/magic/shadow_hook/G = new(H, TRUE)
	G.shadow_action = src
	G.action_owner = H

	H.put_in_hands(G)
	in_use = TRUE
	disable()
	to_chat(H, span_notice("Кликни по цели/предмету, чтобы выпустить щупальце."))

	return FALSE

/obj/item/gun/magic/shadow_hook
	name = "shadow hook"
	desc = "A lash of umbral matter that can reel things or people in."
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	icon_angle = 180
	lefthand_file = null
	righthand_file = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL | NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = NONE
	antimagic_flags = NONE
	pinless = TRUE
	ammo_type = /obj/item/ammo_casing/magic/shadow_hook
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	fire_delay = 1
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	can_hold_up = FALSE

	var/datum/action/cooldown/shadowling/hook/shadow_action
	var/mob/living/action_owner

/obj/item/gun/magic/shadow_hook/Initialize(mapload, silent)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
	if(ismob(loc))
		if(!silent)
			loc.visible_message(span_warning("Рука [capitalize(loc.declent_ru(GENITIVE))] начинает нечеловечески растягиваться!"), span_warning("Ваша рука скручивается и мутирует, превращаясь в теневое щупальце."), span_hear("Вы слышите, как рвётся и чавкает органика!"))
		else
			to_chat(loc, span_notice("Вы готовитесь вытянуть теневое щупальце."))

/obj/item/gun/magic/shadow_hook/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user.balloon_alert(user, "не готово!")

/obj/item/gun/magic/shadow_hook/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/obj/projectile/shadow_hook/hook_proj = chambered?.loaded_projectile
	if(hook_proj)
		hook_proj.fire_modifiers = params2list(params)
	. = ..()
	if(charges == 0)
		if(istype(shadow_action))
			shadow_action.in_use = FALSE
			shadow_action.StartCooldown()
			shadow_action.enable()
		qdel(src)

/obj/item/ammo_casing/magic/shadow_hook
	name = "shadow hook"
	desc = "A shadowy tentacle."
	projectile_type = /obj/projectile/shadow_hook
	caliber = CALIBER_TENTACLE
	firing_effect_type = null
	var/obj/item/gun/magic/shadow_hook/gun

/obj/item/ammo_casing/magic/shadow_hook/Initialize(mapload)
	gun = loc
	. = ..()

/obj/item/ammo_casing/magic/shadow_hook/Destroy()
	gun = null
	return ..()

/obj/projectile/shadow_hook
	name = "shadow hook"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/items/weapons/shove.ogg'
	var/chain
	var/obj/item/ammo_casing/magic/shadow_hook/source
	var/list/fire_modifiers

/obj/projectile/shadow_hook/Initialize(mapload)
	source = loc
	. = ..()

/obj/projectile/shadow_hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(
			BeamTarget = src,
			icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi',
			icon_state = "shadow_grabber",
			time = range * 1 SECONDS,
			maxdistance = range,
			emissive = FALSE
		)
	..()

/obj/projectile/shadow_hook/proc/reset_throw(mob/living/carbon/human/user)
	if(user.throw_mode)
		user.throw_mode_off(THROW_MODE_TOGGLE)

/obj/projectile/shadow_hook/proc/tentacle_grab(mob/living/carbon/human/user, mob/living/carbon/victim)
	if(!user.Adjacent(victim))
		return
	if(user.get_active_held_item() && !user.get_inactive_held_item())
		user.swap_hand()
	if(user.get_active_held_item())
		return
	victim.grabbedby(user)
	victim.grippedby(user, instant = TRUE)
	for(var/obj/item/weapon in user.held_items)
		if(weapon.get_sharpness())
			victim.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] протыкает [capitalize(victim.declent_ru(ACCUSATIVE))] [weapon.declent_ru(INSTRUMENTAL)]!"), span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] протыкает вас [weapon.declent_ru(INSTRUMENTAL)]!"))
			victim.apply_damage(weapon.force, BRUTE, BODY_ZONE_CHEST, attacking_item = weapon)
			user.do_item_attack_animation(victim, used_item = weapon, animation_type = ATTACK_ANIMATION_PIERCE)
			user.add_blood_DNA_to_items(victim.get_blood_dna_list(), ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)
			playsound(get_turf(user), weapon.hitsound, 75, TRUE)
			return

/obj/projectile/shadow_hook/on_hit(atom/movable/target, blocked = 0, pierce_hit)
	if(!isliving(firer) || !ismovable(target))
		return ..()
	if(blocked >= 100)
		return BULLET_ACT_BLOCK

	var/mob/living/ling = firer

	if(isitem(target) && iscarbon(ling))
		var/obj/item/catching = target
		if(catching.anchored)
			return BULLET_ACT_BLOCK
		var/mob/living/carbon/C = ling
		to_chat(C, span_notice("Вы притягиваете [catching.declent_ru(ACCUSATIVE)] к себе."))
		C.throw_mode_on(THROW_MODE_TOGGLE)
		catching.throw_at(
			target = C,
			range = 10,
			speed = 2,
			thrower = C,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(reset_throw), C),
			gentle = TRUE,
		)
		return BULLET_ACT_HIT

	. = ..()
	if(. != BULLET_ACT_HIT)
		return .
	var/mob/living/victim = target
	if(!isliving(victim) || target.anchored || victim.throwing)
		return BULLET_ACT_BLOCK

	if(LAZYACCESS(fire_modifiers, RIGHT_CLICK))
		var/obj/item/stealing = victim.get_active_held_item()
		if(!isnull(stealing))
			if(victim.dropItemToGround(stealing))
				victim.visible_message(
					span_danger("Из руки [victim.declent_ru(GENITIVE)] выдергивается [stealing.declent_ru(NOMINATIVE)] теневым щупальцем!"),
					span_userdanger("[capitalize(stealing.declent_ru(NOMINATIVE))] утягивается!")
				)
				return on_hit(stealing)
			to_chat(ling, span_warning("Не получается вырвать [stealing.declent_ru(ACCUSATIVE)] из рук [victim.declent_ru(GENITIVE)]!"))
			return BULLET_ACT_BLOCK

		to_chat(ling, span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] не держит ничего подходящего!"))
		return BULLET_ACT_HIT

	if(!iscarbon(victim) || !ishuman(ling) || !ling.combat_mode)
		victim.visible_message(
			span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] притягивается к [ling.declent_ru(DATIVE)] теневой нитью!"),
			span_userdanger("Вас притягивает к [ling.declent_ru(DATIVE)]!")
		)
		victim.throw_at(
			target = get_step_towards(ling, victim),
			range = 8,
			speed = 2,
			thrower = ling,
			diagonals_first = TRUE,
			gentle = TRUE,
		)
		return BULLET_ACT_HIT

	victim.visible_message(
		span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] брошен к [ling.declent_ru(DATIVE)] теневой нитью!"),
		span_userdanger("Вас бросает к [ling.declent_ru(DATIVE)]!")
	)
	victim.throw_at(
		target = get_step_towards(ling, victim),
		range  = 8,
		speed = 2,
		thrower = ling,
		diagonals_first = TRUE,
		callback = CALLBACK(src, PROC_REF(tentacle_grab), ling, victim),
		gentle = TRUE,
	)
	return BULLET_ACT_HIT

/obj/projectile/shadow_hook/Destroy()
	qdel(chain)
	source = null
	return ..()
