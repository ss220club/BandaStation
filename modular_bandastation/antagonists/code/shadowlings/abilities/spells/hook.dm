/datum/action/cooldown/shadowling/hook
	name = "Теневой крюк"
	desc = "Кликни по направлению/цели, чтобы выпустить щупальце и притянуть первую попавшуюся цель (как у генокрада)."
	button_icon_state = "shadow_hook"
	cooldown_time = 10 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 8
	channel_time = 0

	click_to_activate = TRUE
	unset_after_click = TRUE

/datum/action/cooldown/shadowling/hook/DoEffect(mob/living/carbon/human/H, atom/_)
	to_chat(H, span_notice("Кликни по направлению/цели, чтобы выпустить щупальце."))
	return FALSE

/datum/action/cooldown/shadowling/hook/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!istype(clicker) || !IsAvailable(TRUE) || !CanUse(clicker))
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/mob/living/carbon/human/H = clicker
	var/turf/start = get_turf(H)
	var/turf/click_turf = get_turf(target)
	if(!start || !click_turf)
		unset_click_ability(clicker, TRUE)
		return TRUE

	if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
		var/obj/effect/dummy/phased_mob/shadowling/P = H.loc
		P.eject_jaunter(FALSE)

	var/list/fire_modifiers = params2list(params)

	var/turf/cur = start
	var/mob/living/victim = null
	var/obj/item/it = null

	for(var/i in 1 to max_range)
		var/turf/next = get_step_towards(cur, click_turf)
		if(!istype(next) || next.density)
			break
		cur = next

		for(var/mob/living/L in cur)
			if(L == H || L.stat == DEAD || L.anchored || L.throwing)
				continue
			if(_is_shadow_ally(L))
				continue
			victim = L
			break
		if(victim)
			break

		if(!victim)
			for(var/obj/item/I in cur)
				if(I.anchored || !isturf(I.loc))
					continue
				it = I
				break
		if(it)
			break

	var/atom/beam_target = victim || it || cur
	if(beam_target)
		show_beam(H, beam_target, get_dist(start, get_turf(beam_target)))

	if(!victim && !it)
		H.balloon_alert(H, "промах")
		unset_click_ability(clicker, TRUE)
		StartCooldown()
		return TRUE

	if(it)
		to_chat(H, span_notice("Вы притягиваете [it.declent_ru(ACCUSATIVE)] к себе."))
		H.throw_mode_on(THROW_MODE_TOGGLE)
		it.throw_at(
			target = H,
			range = 10,
			speed = 2,
			thrower = H,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(_reset_throw), H),
			gentle = TRUE,
		)
		StartCooldown()
		unset_click_ability(clicker, FALSE)
		return TRUE

	if(LAZYACCESS(fire_modifiers, RIGHT_CLICK))
		var/obj/item/stealing = victim.get_active_held_item()
		if(stealing && victim.dropItemToGround(stealing))
			victim.visible_message(
				span_danger("Из руки [victim.declent_ru(GENITIVE)] вырывается [stealing.declent_ru(NOMINATIVE)] теневой нитью!"),
				span_userdanger("[capitalize(stealing.declent_ru(NOMINATIVE))] вырывается из ваших рук!"),
			)
			H.throw_mode_on(THROW_MODE_TOGGLE)
			stealing.throw_at(
				target = H,
				range = 10,
				speed = 2,
				thrower = H,
				diagonals_first = TRUE,
				callback = CALLBACK(src, PROC_REF(_reset_throw), H),
				gentle = TRUE,
			)
		else
			to_chat(H, span_warning("Не получается вырвать предмет!"))

		StartCooldown()
		unset_click_ability(clicker, FALSE)
		return TRUE

	if(!iscarbon(victim) || !ishuman(H) || !H.combat_mode)
		victim.visible_message(
			span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] притягивается к [H.declent_ru(DATIVE)] теневой нитью!"),
			span_userdanger("Вас притягивает к [H.declent_ru(DATIVE)]!"),
		)
		victim.throw_at(
			target = get_step_towards(H, victim),
			range = 8,
			speed = 2,
			thrower = H,
			diagonals_first = TRUE,
			gentle = TRUE,
		)
	else
		victim.visible_message(
			span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] брошен к [H.declent_ru(DATIVE)] теневой нитью!"),
			span_userdanger("Вас бросает к [H.declent_ru(DATIVE)]!"),
		)
		victim.throw_at(
			target = get_step_towards(H, victim),
			range  = 8,
			speed = 2,
			thrower = H,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(_tentacle_grab), H, victim),
			gentle = TRUE,
		)

	StartCooldown()
	unset_click_ability(clicker, FALSE)
	return TRUE

/datum/action/cooldown/shadowling/hook/proc/_is_shadow_ally(mob/living/L)
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(!hive || !istype(L, /mob/living/carbon/human))
		return FALSE
	return (L in hive.lings) || (L in hive.thralls)

/datum/action/cooldown/shadowling/hook/proc/show_beam(mob/living/source, atom/target_atom, dist)
	if(!source || !target_atom)
		return
	var/time = clamp(dist, 0.01, max_range) * 0.2 SECONDS
	source.Beam(
		BeamTarget = target_atom,
		icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi',
		icon_state = "shadow_grabber",
		time = time,
		maxdistance = max_range,
		emissive = FALSE,
	)

	new /obj/effect/temp_visual/dir_setting/shadow_hand_tip(get_turf(target_atom), get_dir(get_turf(source), get_turf(target_atom)))

/obj/effect/temp_visual/dir_setting/shadow_hand_tip
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadow_hand"
	duration = 2

/datum/action/cooldown/shadowling/hook/proc/_reset_throw(mob/living/carbon/human/user)
	if(user?.throw_mode)
		user.throw_mode_off(THROW_MODE_TOGGLE)

/datum/action/cooldown/shadowling/hook/proc/_tentacle_grab(mob/living/carbon/human/user, mob/living/carbon/victim)
	if(!user?.Adjacent(victim))
		return
	if(user.get_active_held_item() && !user.get_inactive_held_item())
		user.swap_hand()
	if(user.get_active_held_item())
		return
	victim.grabbedby(user)
	victim.grippedby(user, instant = TRUE)
	for(var/obj/item/weapon in user.held_items)
		if(weapon.get_sharpness())
			victim.visible_message(
				span_danger("[capitalize(user.declent_ru(NOMINATIVE))] протыкает [capitalize(victim.declent_ru(ACCUSATIVE))] [weapon.declent_ru(INSTRUMENTAL)]!"),
				span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] протыкает вас [weapon.declent_ru(INSTRUMENTAL)]!"),
			)
			victim.apply_damage(weapon.force, BRUTE, BODY_ZONE_CHEST, attacking_item = weapon)
			user.do_item_attack_animation(victim, used_item = weapon, animation_type = ATTACK_ANIMATION_PIERCE)
			user.add_blood_DNA_to_items(victim.get_blood_dna_list(), ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)
			playsound(get_turf(user), weapon.hitsound, 75, TRUE)
			return
