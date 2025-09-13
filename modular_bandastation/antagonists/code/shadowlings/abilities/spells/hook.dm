/datum/action/cooldown/shadowling/hook
	name = "Теневой крюк"
	desc = "Кликни по направлению/цели, чтобы выпустить щупальце и притянуть первую попавшуюся цель."
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
	if(!istype(clicker))
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(!IsAvailable(TRUE))
		unset_click_ability(clicker, TRUE)
		return FALSE

	if(!CanUse(clicker))
		unset_click_ability(clicker, TRUE)
		return FALSE

	var/mob/living/carbon/human/H = clicker
	var/turf/start = get_turf(H)
	var/turf/click_turf = get_turf(target)

	if(!istype(start))
		unset_click_ability(clicker, TRUE)
		return TRUE

	if(!istype(click_turf))
		unset_click_ability(clicker, TRUE)
		return TRUE

	if(istype(H.loc, /obj/effect/dummy/phased_mob/shadowling))
		var/obj/effect/dummy/phased_mob/shadowling/P = H.loc
		P.eject_jaunter(FALSE)

	var/list/mods = params2list(params)

	var/obj/item/gun/magic/shadow_hook_virt/G = new
	G.owner = H
	G.max_range = max_range
	G.mods = mods
	G.fire_at_turf(start, click_turf)

	unset_click_ability(clicker, FALSE)
	StartCooldown()
	return TRUE



/obj/item/gun/magic/shadow_hook_virt
	name = "shadow hook (virt)"
	desc = ""
	icon = null
	icon_state = ""
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON
	flags_1 = NONE
	w_class = WEIGHT_CLASS_TINY
	slot_flags = NONE
	antimagic_flags = NONE
	pinless = TRUE
	lefthand_file = null
	righthand_file = null
	inhand_icon_state = ""
	var/mob/living/owner
	var/list/mods
	var/max_range = 8


/obj/item/gun/magic/shadow_hook_virt/Destroy()
	owner = null
	mods = null
	return ..()

/obj/effect/movable/shadow_hook_anchor
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadow_hand"
	anchored = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_GAME_PLANE
	layer = EFFECTS_LAYER

/obj/item/gun/magic/shadow_hook_virt/proc/fire_at_turf(turf/start, turf/goal)
	if(!istype(owner))
		qdel(src)
		return

	if(!istype(start))
		qdel(src)
		return

	if(!istype(goal))
		qdel(src)
		return

	var/list/path = build_path(start, goal, max_range)

	if(!islist(path))
		qdel(src)
		return

	if(length(path) <= 1)
		to_chat(owner, span_warning("слишком близко"))
		qdel(src)
		return

	var/obj/effect/movable/shadow_hook_anchor/A = new(start)
	A.pixel_y = 8

	var/obj/effect/beam/beam = owner.Beam(
		BeamTarget = A,
		icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi',
		icon_state = "shadow_grabber",
		time = 10 SECONDS,
		maxdistance = max_range,
		emissive = FALSE
	)

	playsound(start, 'sound/effects/splat.ogg', 55, TRUE)

	var/pix_per_sec_fwd = 4 * 32
	var/pix_per_sec_back = 8 * 32

	var/handled = FALSE
	var/turf/hit_from = null

	var/i = 2
	while(i <= length(path))
		if(QDELETED(A))
			break

		if(QDELETED(owner))
			break

		var/turf/prev = path[i - 1]
		var/turf/next = path[i]

		var/dx_px_total = (next.x - prev.x) * 32
		var/dy_px_total = (next.y - prev.y) * 32

		var/angle = arctan(dy_px_total, dx_px_total)
		A.transform = matrix().Turn(-angle)

		var/time_tile = max(0.01, sqrt(dx_px_total * dx_px_total + dy_px_total * dy_px_total) / pix_per_sec_fwd)

		var/step = 0.05 SECONDS
		var/steps = max(1, round(time_tile / step))

		if(A.loc != prev)
			A.forceMove(prev)

		var/px = A.pixel_x
		var/py = A.pixel_y - 8

		var/step_dx = dx_px_total / steps
		var/step_dy = dy_px_total / steps

		var/s = 1
		while(s <= steps)
			if(QDELETED(A))
				break

			if(QDELETED(owner))
				break

			px += step_dx
			py += step_dy

			var/wrap_x = px
			var/wrap_y = py
			var/tx = prev.x
			var/ty = prev.y

			while(wrap_x >= 32)
				wrap_x -= 32
				tx++

			while(wrap_x <= -32)
				wrap_x += 32
				tx--

			while(wrap_y >= 32)
				wrap_y -= 32
				ty++

			while(wrap_y <= -32)
				wrap_y += 32
				ty--

			var/turf/cur = locate(tx, ty, start.z)

			if(istype(cur))
				if(cur != A.loc)
					A.forceMove(cur)

			A.pixel_x = round(wrap_x)
			A.pixel_y = round(wrap_y) + 8

			var/atom/target = find_first_target_on_turf(owner, cur)

			if(!isnull(target))
				hit_from = cur
				handled = resolve_hit(owner, target)
				s = steps + 1
				i = length(path) + 1
				break

			s++
			sleep(step)

		i++

	if(!handled)
		to_chat(owner, span_warning("промах"))

	spawn()
		retract(owner, A, hit_from, pix_per_sec_back, beam)

	qdel(src)

/obj/item/gun/magic/shadow_hook_virt/proc/build_path(turf/start, turf/goal, max_steps)
	if(!istype(start))
		return null

	if(!istype(goal))
		return null

	var/list/L = list()
	var/turf/cur = start
	L += cur

	var/i = 1
	while(i <= max_steps)
		var/turf/next = get_step_towards(cur, goal)

		if(!istype(next))
			break

		if(next == cur)
			break

		if(next.density)
			break

		L += next
		cur = next
		i++

	return L

/obj/item/gun/magic/shadow_hook_virt/proc/find_first_target_on_turf(mob/living/carbon/human/H, turf/T)
	if(!istype(T))
		return null

	for(var/mob/living/L in T)
		if(L == H)
			continue

		if(L.stat == DEAD)
			continue

		if(L.anchored)
			continue

		if(L.throwing)
			continue

		if(is_shadow_ally(L))
			continue

		return L

	for(var/obj/item/I in T)
		if(I.anchored)
			continue

		if(!isturf(I.loc))
			continue

		return I

	return null



/obj/item/gun/magic/shadow_hook_virt/proc/resolve_hit(mob/living/carbon/human/H, atom/target)
	if(isitem(target))
		var/obj/item/it = target

		to_chat(H, span_notice("Вы притягиваете [it.declent_ru(ACCUSATIVE)] к себе."))

		H.throw_mode_on(THROW_MODE_TOGGLE)

		it.throw_at(
			target = H,
			range = 10,
			speed = 2,
			thrower = H,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(reset_throw), H),
			gentle = TRUE
		)

		playsound(get_turf(H), 'sound/items/weapons/shove.ogg', 55, TRUE)
		return TRUE

	if(isliving(target))
		var/mob/living/V = target

		if(LAZYACCESS(mods, RIGHT_CLICK))
			var/obj/item/stealing = V.get_active_held_item()

			if(isnull(stealing))
				to_chat(H, span_danger("[capitalize(V.declent_ru(NOMINATIVE))] не держит ничего подходящего!"))
				return TRUE

			if(V.dropItemToGround(stealing))
				V.visible_message(
					span_danger("Из руки [V.declent_ru(GENITIVE)] выдергивается [stealing.declent_ru(NOMINATIVE)] теневым щупальцем!"),
					span_userdanger("[capitalize(stealing.declent_ru(NOMINATIVE))] утягивается!")
				)

				to_chat(H, span_notice("Вы притягиваете [stealing.declent_ru(ACCUSATIVE)] к себе."))

				H.throw_mode_on(THROW_MODE_TOGGLE)

				stealing.throw_at(
					target = H,
					range = 10,
					speed = 2,
					thrower = H,
					diagonals_first = TRUE,
					callback = CALLBACK(src, PROC_REF(reset_throw), H),
					gentle = TRUE
				)

				playsound(get_turf(H), 'sound/items/weapons/shove.ogg', 55, TRUE)
				return TRUE

			to_chat(H, span_warning("Не получается вырвать [stealing.declent_ru(ACCUSATIVE)] из рук [V.declent_ru(GENITIVE)]!"))
			return TRUE

		var/turf/v_to = get_step_towards(H, V)

		if(!iscarbon(V) || !ishuman(H) || !H.combat_mode)
			V.visible_message(
				span_danger("[capitalize(V.declent_ru(NOMINATIVE))] притягивается к [H.declent_ru(DATIVE)] теневой нитью!"),
				span_userdanger("Вас притягивает к [H.declent_ru(DATIVE)]!")
			)

			V.throw_at(
				target = v_to,
				range = 8,
				speed = 2,
				thrower = H,
				diagonals_first = TRUE,
				gentle = TRUE
			)

			playsound(v_to, 'sound/items/weapons/shove.ogg', 55, TRUE)
			return TRUE

		V.visible_message(
			span_danger("[capitalize(V.declent_ru(NOMINATIVE))] брошен к [H.declent_ru(DATIVE)] теневой нитью!"),
			span_userdanger("Вас бросает к [H.declent_ru(DATIVE)]!")
		)

		V.throw_at(
			target = v_to,
			range = 8,
			speed = 2,
			thrower = H,
			diagonals_first = TRUE,
			callback = CALLBACK(src, PROC_REF(tentacle_grab), H, V),
			gentle = TRUE
		)

		playsound(v_to, 'sound/items/weapons/shove.ogg', 55, TRUE)
		return TRUE

	return FALSE



/obj/item/gun/magic/shadow_hook_virt/proc/retract(mob/living/carbon/human/H, obj/effect/movable/shadow_hook_anchor/A, turf/from_turf, pix_per_sec_back, obj/effect/beam/beam)
	if(QDELETED(A))
		return

	if(QDELETED(H))
		if(beam)
			qdel(beam)
		qdel(A)
		return

	var/turf/start_turf
	var/turf/end_turf

	if(istype(from_turf))
		start_turf = from_turf
	else
		start_turf = get_turf(A)

	end_turf = get_turf(H)

	if(!istype(start_turf))
		if(beam)
			qdel(beam)
		qdel(A)
		return

	if(!istype(end_turf))
		if(beam)
			qdel(beam)
		qdel(A)
		return

	var/dx_px_total = (end_turf.x - start_turf.x) * 32
	var/dy_px_total = (end_turf.y - start_turf.y) * 32
	var/angle = arctan(dy_px_total, dx_px_total)
	A.transform = matrix().Turn(-angle)

	var/dist_px = max(1, round(sqrt(dx_px_total * dx_px_total + dy_px_total * dy_px_total)))
	var/time_back = dist_px / max(1, pix_per_sec_back)

	var/step = 0.05 SECONDS
	var/steps = max(1, round(time_back / step))

	if(A.loc != start_turf)
		A.forceMove(start_turf)

	var/px = A.pixel_x
	var/py = A.pixel_y - 8

	var/cur_tx = start_turf.x
	var/cur_ty = start_turf.y

	var/i = 1
	while(i <= steps)
		if(QDELETED(A))
			break

		if(QDELETED(H))
			break

		var/turf/to_turf = get_turf(H)
		var/dx_px = ((to_turf.x - cur_tx) * 32) - px
		var/dy_px = ((to_turf.y - cur_ty) * 32) - py

		var/step_dx = dx_px / (steps - i + 1)
		var/step_dy = dy_px / (steps - i + 1)

		px += step_dx
		py += step_dy

		var/wrap_x = px
		var/wrap_y = py

		while(wrap_x >= 32)
			wrap_x -= 32
			cur_tx++

		while(wrap_x <= -32)
			wrap_x += 32
			cur_tx--

		while(wrap_y >= 32)
			wrap_y -= 32
			cur_ty++

		while(wrap_y <= -32)
			wrap_y += 32
			cur_ty--

		var/turf/cur = locate(cur_tx, cur_ty, start_turf.z)

		if(istype(cur))
			if(cur != A.loc)
				A.forceMove(cur)

		A.pixel_x = round(wrap_x)
		A.pixel_y = round(wrap_y) + 8

		i++
		sleep(step)

	if(beam)
		qdel(beam)

	qdel(A)

/obj/item/gun/magic/shadow_hook_virt/proc/reset_throw(mob/living/carbon/human/user)
	if(!istype(user))
		return

	if(user.throw_mode)
		user.throw_mode_off(THROW_MODE_TOGGLE)



/obj/item/gun/magic/shadow_hook_virt/proc/tentacle_grab(mob/living/carbon/human/user, mob/living/carbon/victim)
	if(!istype(user))
		return

	if(!istype(victim))
		return

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
			victim.visible_message(
				span_danger("[capitalize(user.declent_ru(NOMINATIVE))] протыкает [capitalize(victim.declent_ru(ACCUSATIVE))] [weapon.declent_ru(INSTRUMENTAL)]!"),
				span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] протыкает вас [weapon.declent_ru(INSTRUMENTAL)]!")
			)

			victim.apply_damage(weapon.force, BRUTE, BODY_ZONE_CHEST, attacking_item = weapon)
			user.do_item_attack_animation(victim, used_item = weapon, animation_type = ATTACK_ANIMATION_PIERCE)
			user.add_blood_DNA_to_items(victim.get_blood_dna_list(), ITEM_SLOT_ICLOTHING | ITEM_SLOT_OCLOTHING)
			playsound(get_turf(user), weapon.hitsound, 75, TRUE)
			return



/obj/item/gun/magic/shadow_hook_virt/proc/is_shadow_ally(mob/living/L)
	var/datum/team/shadow_hive/hive = get_shadow_hive()

	if(!hive)
		return FALSE

	if(!istype(L, /mob/living/carbon/human))
		return FALSE

	if(L in hive.lings)
		return TRUE

	if(L in hive.thralls)
		return TRUE

	return FALSE
