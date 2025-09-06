/datum/action/cooldown/shadowling/veil
	name = "Вуаль"
	desc = "Ваше присутствие гасит свет и пламя поблизости; противники в тени слабеют, АПЦ обнуляют заряд, светогрибы чахнут."
	button_icon_state = "veil"
	cooldown_time = 15 SECONDS
	required_thralls = 0

	var/dark_square_radius = 5
	var/shroom_square_radius = 2
	var/blind_duration = 6 SECONDS
	var/sfx_emp = 'sound/effects/empulse.ogg'

/datum/action/cooldown/shadowling/veil/DoEffect(mob/living/carbon/human/H, atom/_)
	var/turf/center = get_turf(H)
	if(!center)
		return FALSE

	var/list/turfs_shrooms = RANGE_TURFS(shroom_square_radius, H)
	var/list/turfs_dark    = RANGE_TURFS(dark_square_radius, H)

	replace_glowshrooms(turfs_shrooms)
	break_apcs_in_dark(turfs_shrooms)
	weaken_shaded_mobs(turfs_dark, blind_duration)
	disable_lights_in_area(turfs_dark)

	playsound(center, sfx_emp, 70, TRUE)
	new /obj/effect/temp_visual/circle_wave/shadow_veil(center)

	to_chat(H, span_notice("Пелена тьмы накрывает всё вокруг."))
	return TRUE

/datum/action/cooldown/shadowling/veil/proc/_is_dark(atom/A)
	var/turf/T = get_turf(A)
	if(!T)
		return FALSE
	return (T.get_lumcount() < SHADOWLING_DIM_THRESHOLD)

/datum/action/cooldown/shadowling/veil/proc/disable_lights_in_area(list/turfs)
	if(!islist(turfs))
		return
	for(var/turf/T in turfs)
		for(var/obj/O in T)
			try_disable_light(O)
		for(var/mob/living/L in T)
			disable_lights_on_mob(L)

/datum/action/cooldown/shadowling/veil/proc/try_disable_light(atom/movable/A)
	if(!A)
		return
	if(ispath(A.type, /obj/machinery/power/apc))
		return
	A.extinguish()
	A.on_saboteur(src, 30 SECONDS)

/datum/action/cooldown/shadowling/veil/proc/break_apcs_in_dark(list/turfs)
	for(var/turf/T in turfs)
		if(!_is_dark(T))
			continue
		for(var/obj/machinery/power/apc/A in T)
			if(QDELETED(A))
				continue
			A.set_no_charge()

/datum/action/cooldown/shadowling/veil/proc/disable_lights_on_mob(mob/living/L)
	if(!istype(L))
		return
	for(var/obj/item/I in L.contents)
		try_disable_light(I)

/datum/action/cooldown/shadowling/veil/proc/weaken_shaded_mobs(list/turfs, duration)
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	for(var/turf/T in turfs)
		if(!_is_dark(T))
			continue
		for(var/mob/living/carbon/human/M in T)
			if(!M)
				continue
			if(M.glasses)
				continue
			if(hive)
				if(M in hive.lings)
					continue
				if(M in hive.thralls)
					continue
			M.adjust_staggered(duration)
			M.adjust_eye_blur(duration)

/datum/action/cooldown/shadowling/veil/proc/replace_glowshrooms(list/turfs)
	if(!islist(turfs))
		return
	for(var/turf/T in turfs)
		for(var/obj/structure/glowshroom/G in T)
			qdel(G)

/obj/effect/temp_visual/circle_wave/shadow_veil
	color = "#5a3a7e"
	max_alpha = 200
	duration = 0.6 SECONDS
	amount_to_scale = 6
