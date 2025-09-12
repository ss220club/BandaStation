/datum/action/cooldown/shadowling/shadow_phase
	name = "Теневой вход"
	desc = "Стать нематериальным и проходить сквозь стены на ограниченное время. Яркий свет до набора достаточного числа слуг разрывает фазу."
	button_icon_state = "shadowling_crawl"
	cooldown_time = 30 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0
	var/phase_duration = 12 SECONDS
	var/light_immunity_thralls = 7
	var/static/sfx_enter = 'sound/effects/magic/teleport_app.ogg'

/datum/action/cooldown/shadowling/shadow_phase/Trigger(mob/clicker, trigger_flags, atom/target)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/obj/effect/dummy/phased_mob/shadowling/P = istype(H.loc, /obj/effect/dummy/phased_mob/shadowling) ? H.loc : null
	var/is_in_phase = !!P

	if(!is_in_phase)
		if(!CanUse(H))
			return FALSE
		if(channel_time > 0)
			if(!PerformChannel(H, null))
				return FALSE
		if(!enter_phase(H))
			return FALSE
		return TRUE

	if(!exit_phase(H, forced_out = FALSE))
		return FALSE

	StartCooldown()
	return TRUE

/datum/action/cooldown/shadowling/shadow_phase/proc/_auto_exit_if_still_inside(datum/weakref/p_ref)
	var/obj/effect/dummy/phased_mob/shadowling/P = p_ref?.resolve()
	if(!istype(P))
		return
	var/mob/living/L = P.jaunter
	if(!istype(L))
		return
	P.eject_jaunter(FALSE)

/proc/shadow_phase_start_entry_cooldown(mob/living/carbon/human/H)
	if(!istype(H))
		return
	for(var/datum/action/cooldown/shadowling/shadow_phase/A in H.actions)
		if(!A.IsAvailable())
			return
		A.StartCooldown()
		return

/obj/effect/temp_visual/shadow_phase_smoke
	name = "umbral plume"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_GAME_PLANE
	layer = EFFECTS_LAYER
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cloud_swirl"
	color = "#66ccff"
	alpha = 220

/obj/effect/temp_visual/shadow_phase_smoke/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix()*1.2, time = 4)
	animate(alpha = 0, time = 6)
	QDEL_IN(src, 0.6 SECONDS)
	return .

/datum/action/cooldown/shadowling/shadow_phase/proc/fade_out(mob/living/carbon/human/H, fade_time = 0.3 SECONDS)
	if(!istype(H)) return
	H.alpha = clamp(H.alpha, 0, 255)
	animate(H, alpha = 0, time = fade_time)

/// быстрый fade-in
/datum/action/cooldown/shadowling/shadow_phase/proc/fade_in(mob/living/carbon/human/H, fade_time = 0.3 SECONDS)
	if(!istype(H)) return
	animate(H, alpha = 255, time = fade_time)

/datum/action/cooldown/shadowling/shadow_phase/proc/enter_phase(mob/living/carbon/human/H)
	var/turf/start = get_turf(H)
	if(!start) return FALSE
	if(istype(H.loc, /obj/effect/dummy/phased_mob))
		to_chat(H, span_warning("Вы уже рассеялись во тьме."))
		return FALSE

	new /obj/effect/temp_visual/shadow_phase_smoke(start)
	playsound(start, sfx_enter, 65, TRUE)
	fade_out(H, 0.3 SECONDS)

	sleep(0.3 SECONDS)

	var/obj/effect/dummy/phased_mob/shadowling/P = new(start)
	P.dir = H.dir

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	var/nt = hive ? hive.count_nt() : 0
	P.light_immunity = (nt >= light_immunity_thralls)

	P.jaunter = H
	H.forceMove(P)

	addtimer(CALLBACK(src, PROC_REF(_auto_exit_if_still_inside), WEAKREF(P)), phase_duration)

	to_chat(H, span_notice("Вы растворяетесь во тени."))
	return TRUE

/datum/action/cooldown/shadowling/shadow_phase/proc/exit_phase(mob/living/carbon/human/H, forced_out = FALSE)
	var/turf/end_turf = get_turf(H)
	var/obj/effect/dummy/phased_mob/shadowling/P = H.loc

	if(istype(P))
		P.eject_jaunter(forced_out)
		if(end_turf)
			new /obj/effect/temp_visual/shadow_phase_smoke(end_turf)
		fade_in(H, 0.3 SECONDS)
		to_chat(H, span_notice("Вы возвращаетесь в материальность."))
		return TRUE

	if(end_turf)
		new /obj/effect/temp_visual/shadow_phase_smoke(end_turf)
	fade_in(H, 0.3 SECONDS)
	to_chat(H, span_notice("Вы возвращаетесь в материальность."))
	return TRUE
