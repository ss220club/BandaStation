/datum/action/cooldown/shadowling/glare
	name = "Glare"
	desc = "Сокрующий взгляд в сторону, куда вы смотрите, позволяющий оглушать и обесиливать ваших врагов."
	button_icon_state = "glare"
	cooldown_time = 30 SECONDS

	required_thralls = 0
	max_range = 10
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	channel_time = 0

	var/const/fov_degree = 90

/datum/action/cooldown/shadowling/glare/CollectTargets(mob/living/carbon/human/H, atom/explicit)
	var/list/targets = list()
	var/datum/shadow_hive/hive = get_shadow_hive()

	for(var/mob/living/carbon/human/T in range(max_range, H))
		if(T == H)
			continue
		if(!in_front_cone(H, T, fov_degree))
			continue
		if(hive && ((T in hive.lings) || (T in hive.thralls)))
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
		var/d = get_dist(H, T)
		if(d <= 5)
			T.Stun(0.6 SECONDS)
			T.adjustStaminaLoss(30)
			apply_stamina_dot(T, 10, 15, 1 SECONDS)
			mute_for(T, 10 SECONDS)
			force_drop_items(T)
			apply_slow(T, 10 SECONDS)
			hit = TRUE
		else if(d <= 10)
			T.adjustStaminaLoss(20)
			stun_for(T, 2 SECONDS)
			mute_for(T, 5 SECONDS)
			hit = TRUE

	return hit

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

/datum/action/cooldown/shadowling/glare/proc/apply_stamina_dot(mob/living/L, amount, ticks, period)
	if(!istype(L))
		return
	if(ticks <= 0)
		return
	if(period <= 0)
		return
	stamina_tick(L, amount)
	if(ticks > 1)
		addtimer(CALLBACK(src, PROC_REF(stamina_dot_continue), L, amount, ticks - 1, period), period)

/datum/action/cooldown/shadowling/glare/proc/stamina_dot_continue(mob/living/L, amount, ticks_left, period)
	if(!istype(L))
		return
	if(ticks_left <= 0)
		return
	stamina_tick(L, amount)
	if(ticks_left > 1)
		addtimer(CALLBACK(src, PROC_REF(stamina_dot_continue), L, amount, ticks_left - 1, period), period)

/datum/action/cooldown/shadowling/glare/proc/stamina_tick(mob/living/L, amount)
	if(!istype(L))
		return
	if(QDELETED(L))
		return
	if(istype(L, /mob/living/carbon))
		var/mob/living/carbon/C = L
		C.adjustStaminaLoss(amount)
	else
		L.adjustStaminaLoss(amount)

/datum/action/cooldown/shadowling/glare/proc/mute_for(mob/living/L, duration)
	if(!istype(L))
		return
	L.adjust_silence(duration)

/datum/action/cooldown/shadowling/glare/proc/stun_for(mob/living/L, duration)
	if(!istype(L))
		return
	L.Knockdown(duration)

/datum/action/cooldown/shadowling/glare/proc/force_drop_items(mob/living/carbon/C)
	if(!istype(C))
		return
	C.drop_all_held_items()

/datum/movespeed_modifier/shadowling/glare_slow
	multiplicative_slowdown = 1.35
	priority = 20
	movetypes = GROUND

/datum/action/cooldown/shadowling/glare/proc/apply_slow(mob/living/L, duration)
	if(!istype(L))
		return
	L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/glare_slow)
	addtimer(CALLBACK(src, PROC_REF(_remove_slow), L), duration)

/datum/action/cooldown/shadowling/glare/proc/_remove_slow(mob/living/L)
	if(!istype(L))
		return
	L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/glare_slow)

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
