/datum/action/cooldown/shadowling/smoke_cloud
	name = "Дымное облако"
	desc = "Заполняет тьмой область 9×9, сужающуюся каждый тик. Тени исцеляются, прочие слепнут и могут быть оглушены."
	button_icon_state = "shadow_smoke"
	cooldown_time = 0 SECONDS

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/smoke_cloud/DoEffect(mob/living/carbon/human/H, atom/_)
	var/turf/T = get_turf(H)
	if(!T)
		return FALSE
	new /obj/effect/area_emitter/shadowling_smoke(T)
	return TRUE

/obj/effect/area_emitter/shadowling_smoke
	name = "shadow smoke"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/current_radius = 4
	var/steam_puffs = 12
	var/tick_interval = 1 SECONDS

/obj/effect/area_emitter/shadowling_smoke/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/area_emitter/shadowling_smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/area_emitter/shadowling_smoke/process(seconds_per_tick)
	if(QDELETED(src))
		return

	var/turf/center = get_turf(src)
	if(!center || current_radius < 0)
		qdel(src)
		return

	draw_visuals(center, current_radius)

	var/z = center.z
	var/tx1 = max(1, center.x - current_radius)
	var/ty1 = max(1, center.y - current_radius)
	var/tx2 = center.x + current_radius
	var/ty2 = center.y + current_radius
	var/list/turfs = block(locate(tx1, ty1, z), locate(tx2, ty2, z))
	apply_effects(turfs)

	current_radius--
	if(current_radius < 0)
		qdel(src)

/obj/effect/area_emitter/shadowling_smoke/proc/draw_visuals(turf/center, r)
	var/datum/effect_system/steam_spread/steam = new
	steam.set_up(steam_puffs, FALSE, center)
	steam.start()

/obj/effect/area_emitter/shadowling_smoke/proc/apply_effects(list/turfs)
	var/datum/shadow_hive/hive = get_shadow_hive()

	for(var/turf/T in turfs)
		if(!isturf(T)) continue

		for(var/mob/living/L in T)
			if(QDELETED(L)) continue

			if(hive && ((L in hive.lings) || (L in hive.thralls)))
				heal_shadow_ally(L)
				continue

			afflict_enemy(L)

/obj/effect/area_emitter/shadowling_smoke/proc/heal_shadow_ally(mob/living/L)
	L.adjustBruteLoss(-10)
	L.adjustFireLoss(-10)
	L.adjustToxLoss(-10)
	L.adjustStaminaLoss(-10)

/obj/effect/area_emitter/shadowling_smoke/proc/afflict_enemy(mob/living/L)
	L.adjust_temp_blindness(5)

	if(prob(25))
		L.Stun(2 SECONDS)
