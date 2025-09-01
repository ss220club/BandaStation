/datum/action/cooldown/shadowling/root
	name = "Путы"
	desc = "Опутать цель тенями на 15 секунд. Работает только если цель стоит в тени."
	background_icon_state = "shadow_demon_bg"
	button_icon = 'modular_bandastation/antagonists/icons/shadowlings_actions.dmi'
	button_icon_state = "shadow_bind"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 25 SECONDS

	click_to_activate = TRUE
	unset_after_click = TRUE

/datum/action/cooldown/shadowling/root/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/mob/living/carbon/human/T = target
	if(!istype(T))
		to_chat(H, span_warning("Это не подходящая цель."))
		return FALSE
	if(T == H)
		to_chat(H, span_warning("На себя — нельзя."))
		return FALSE

	var/datum/shadow_hive/hive = get_shadow_hive()
	if(hive && ((T in hive.lings) || (T in hive.thralls)))
		to_chat(H, span_warning("Тьма не трогает своих."))
		return FALSE

	var/turf/tturf = get_turf(T)
	if(!tturf || tturf.get_lumcount() >= L_DIM)
		to_chat(H, span_warning("Цель не в тени."))
		return FALSE

	// Ограничение дистанции
	// if(get_dist(H, T) > 6) return FALSE

	var/obj/effect/shadow_bind_anchor/A = new /obj/effect/shadow_bind_anchor(tturf, H)
	if(!A.apply_to(T))
		qdel(A)
		to_chat(H, span_warning("Тени не смогли схватить цель."))
		return FALSE

	StartCooldown()
	return TRUE

/obj/effect/shadow_bind_anchor
	name = "writhing shadows"
	desc = "Tendrils of shadow coil here."
	icon = 'icons/effects/effects.dmi'
	icon_state = null
	layer = EFFECTS_LAYER
	anchored = TRUE
	density = FALSE

	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = FALSE
	buckle_requires_restraints = FALSE

	var/grapple_time = 15 SECONDS

	var/mob/living/caster

/obj/effect/shadow_bind_anchor/Initialize(mapload, mob/living/caster_ref)
	. = ..()
	caster = caster_ref
	addtimer(CALLBACK(src, PROC_REF(_gc_if_empty)), 2 SECONDS)

/obj/effect/shadow_bind_anchor/Destroy()
	for(var/mob/living/L in buckled_mobs)
		unbuckle_mob(L, force = TRUE)
	return ..()

/obj/effect/shadow_bind_anchor/proc/apply_to(mob/living/victim)
	if(!istype(victim) || QDELETED(victim) || victim.stat == DEAD)
		qdel(src)
		return FALSE

	if(has_buckled_mobs())
		return FALSE

	if(!buckle_mob(victim, force = TRUE))
		qdel(src)
		return FALSE

	if(isturf(loc))
		visible_message(
			span_danger("Тени хватают [victim]!"),
			span_userdanger("Тени сковывают ваши ноги — вы не можете двигаться!")
		)

	addtimer(CALLBACK(src, PROC_REF(release)), grapple_time, TIMER_STOPPABLE)
	return TRUE

/obj/effect/shadow_bind_anchor/proc/release()
	if(QDELETED(src)) return
	if(!has_buckled_mobs())
		qdel(src)
		return
	for(var/mob/living/L in buckled_mobs)
		unbuckle_mob(L, force = TRUE)
	qdel(src)

/obj/effect/shadow_bind_anchor/proc/_gc_if_empty()
	if(!has_buckled_mobs())
		qdel(src)
