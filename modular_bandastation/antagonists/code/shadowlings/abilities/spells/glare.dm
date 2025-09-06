/datum/action/cooldown/shadowling/glare
	name = "Взгляд"
	desc = "Сокрующий взгляд в сторону, куда вы смотрите, позволяющий оглушать и обесиливать ваших врагов."
	button_icon_state = "glare"
	cooldown_time = 30 SECONDS
	required_thralls = 0
	max_range = 4
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	channel_time = 0
	var/const/fov_degree = 90
	var/const/baton_stamina = 35
	var/const/knock_delay = 0.6 SECONDS
	var/const/knock_time = 1 SECONDS

/datum/action/cooldown/shadowling/glare/CollectTargets(mob/living/carbon/human/H, atom/explicit)
	var/list/targets = list()
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	for(var/mob/living/carbon/human/T in range(max_range, H))
		if(T == H)
			continue
		if(!in_front_cone(H, T, fov_degree))
			continue
		if(hive)
			if(T in hive.lings)
				continue
			if(T in hive.thralls)
				continue
		var/turf/tt = get_turf(T)
		if(!tt)
			continue
		if(tt.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
			continue
		targets += T
	return targets

/datum/action/cooldown/shadowling/glare/ValidateTarget(mob/living/carbon/human/H, atom/target)
	var/mob/living/carbon/human/T = target
	if(!istype(T))
		return FALSE
	if(T.glasses)
		return FALSE
	if(!in_front_cone(H, T, fov_degree))
		return FALSE
	var/turf/tt = get_turf(T)
	if(!tt)
		return FALSE
	if(tt.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
		return FALSE
	return TRUE

/datum/action/cooldown/shadowling/glare/DoEffectOnTargets(mob/living/carbon/human/H, list/targets)
	if(!islist(targets))
		owner.balloon_alert(owner, "Нет доступных целей")
		return FALSE
	if(!length(targets))
		owner.balloon_alert(owner, "Нет доступных целей")
		return FALSE
	play_glare_fx(H)
	var/hit = FALSE
	for(var/mob/living/carbon/human/T in targets)
		if(QDELETED(T))
			continue
		if(T.stat == DEAD)
			continue
		var/d = get_dist(H, T)
		if(d > max_range)
			continue
		apply_glare_primary(T)
		addtimer(CALLBACK(src, PROC_REF(apply_glare_knock), T), knock_delay)
		hit = TRUE
	return hit

/datum/action/cooldown/shadowling/glare/proc/apply_glare_primary(mob/living/carbon/human/T)
	if(!istype(T))
		return
	T.Stun(1 SECONDS)
	T.adjustStaminaLoss(baton_stamina)
	apply_slow(T, 2 SECONDS)
	apply_shake(T, 8, 0.6 SECONDS)

/datum/action/cooldown/shadowling/glare/proc/apply_glare_knock(mob/living/carbon/human/T)
	if(!istype(T))
		return
	if(QDELETED(T))
		return
	T.Knockdown(knock_time)

/datum/action/cooldown/shadowling/glare/proc/play_glare_fx(mob/living/carbon/human/H)
	if(!istype(H))
		return
	H.set_light(2, 0.6, "#ff2a2a")
	addtimer(CALLBACK(src, PROC_REF(stop_glare_fx), H), 0.6 SECONDS)
	show_cone_fx(H)
	playsound(H, 'sound/effects/nightmare_poof.ogg', 50, TRUE)

/datum/action/cooldown/shadowling/glare/proc/stop_glare_fx(mob/living/carbon/human/H)
	if(!istype(H))
		return
	H.set_light(0)

/datum/action/cooldown/shadowling/glare/proc/apply_slow(mob/living/L, duration)
	if(!istype(L))
		return
	L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/glare_slow)
	addtimer(CALLBACK(src, PROC_REF(_remove_slow), L), duration)

/datum/action/cooldown/shadowling/glare/proc/_remove_slow(mob/living/L)
	if(!istype(L))
		return
	L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/glare_slow)

/datum/action/cooldown/shadowling/glare/proc/apply_shake(mob/living/L, strength, dur)
	if(!istype(L))
		return
	L.adjust_dizzy(2)

/datum/movespeed_modifier/shadowling/glare_slow
	multiplicative_slowdown = 1.35
	priority = 20
	movetypes = GROUND

/obj/effect/temp_visual/shadowling/glare_cone_tile
	name = "glare cone"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_GAME_PLANE
	layer = EFFECTS_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	alpha = 180
	color = "#ff2a2a"

/obj/effect/temp_visual/shadowling/glare_cone_tile/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = 6)
	QDEL_IN(src, 0.6 SECONDS)

/datum/action/cooldown/shadowling/glare/proc/collect_cone_turfs(mob/living/carbon/human/H, range_tiles, fov_deg)
	var/list/turfs_in_cone = list()
	if(!istype(H))
		return turfs_in_cone
	var/turf/origin = get_turf(H)
	if(!origin)
		return turfs_in_cone
	for(var/turf/T in range(range_tiles, origin))
		if(!in_front_cone(H, T, fov_deg))
			continue
		turfs_in_cone += T
	return turfs_in_cone

/datum/action/cooldown/shadowling/glare/proc/show_cone_fx(mob/living/carbon/human/H)
	if(!istype(H))
		return
	var/list/cone_turfs = collect_cone_turfs(H, max_range, fov_degree)
	if(!length(cone_turfs))
		return
	for(var/turf/T as anything in cone_turfs)
		new /obj/effect/temp_visual/shadowling/glare_cone_tile(T)
