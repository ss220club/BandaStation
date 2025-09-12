/datum/movespeed_modifier/shadowling/cold_wave
	multiplicative_slowdown = 1.25
	priority = 20
	movetypes = GROUND

/datum/action/cooldown/shadowling/cold_wave
	name = "Волна холода"
	desc = "Выплеск ледяной тьмы в 90° конусе на 4 тайла, наносящий 30 урона по выносливости и замедляющий врагов на 10 секунд."
	button_icon_state = "icy_veins"
	cooldown_time = 20 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 4
	channel_time = 0
	var/const/fov_degree = 90
	var/static/sfx_cold = 'modular_bandastation/antagonists/sound/shadowlings/frost.ogg'
	var/reagent_type = /datum/reagent/consumable/frostoil

/datum/action/cooldown/shadowling/cold_wave/DoEffect(mob/living/carbon/human/H, atom/_)
	var/list/targets = collect_cone_targets(H)
	if(!length(targets))
		owner.balloon_alert(owner, "Нет доступных целей")
		return FALSE

	play_cold_fx(H)

	var/hit = FALSE
	for(var/mob/living/carbon/human/T in targets)
		if(QDELETED(T))
			continue

		var/is_vulp = istype(T?.dna?.species, /datum/species/vulpkanin)
		var/temp_drop = is_vulp ? -400 : -260
		var/frostoil_amt = is_vulp ? 20 : 12

		T.adjustStaminaLoss(30)
		apply_slow(T, 10 SECONDS)
		T.adjust_bodytemperature(temp_drop)

		if(T.reagents)
			T.reagents.add_reagent(reagent_type, frostoil_amt)

		hit = TRUE

	return hit

/datum/action/cooldown/shadowling/cold_wave/collect_cone_targets(mob/living/carbon/human/H)
	var/list/out = list()
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
		out += T
	return out

/datum/action/cooldown/shadowling/cold_wave/proc/collect_cold_cone_turfs(mob/living/carbon/human/H, range_tiles, fov_deg)
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

/datum/action/cooldown/shadowling/cold_wave/proc/apply_slow(mob/living/L, duration)
	if(!istype(L))
		return
	L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/cold_wave)
	addtimer(CALLBACK(src, PROC_REF(_remove_slow), L), duration)

/datum/action/cooldown/shadowling/cold_wave/proc/_remove_slow(mob/living/L)
	if(!istype(L))
		return
	L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/cold_wave)

/datum/action/cooldown/shadowling/cold_wave/proc/play_cold_fx(mob/living/carbon/human/H)
	if(!istype(H))
		return
	playsound(get_turf(H), sfx_cold, 70, TRUE)

	var/turf/anchor = get_step(H, H.dir)
	if(!anchor) anchor = get_turf(H)
	new /obj/effect/temp_visual/dir_setting/shadow_plume(anchor, H.dir)

/obj/effect/temp_visual/dir_setting/shadow_plume
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 0.6 SECONDS
	color = "#66ccff"
	alpha = 220

/obj/effect/temp_visual/dir_setting/shadow_plume/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128
