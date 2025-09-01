/datum/action/cooldown/shadowling/veil
	name = "Veil"
	desc = "Ваше присутствие отключает источники света поблизости, тушит пламя и свет, а уже погруженные во тьму противники получают ослабление, а АПЦ теряют весь свой заряд и светогрибы чахнут."
	button_icon_state = "veil"
	cooldown_time = 15 SECONDS

	required_thralls = 0

	var/dark_square_radius = 5
	var/shroom_square_radius = 2
	var/blind_duration = 6 SECONDS

/datum/action/cooldown/shadowling/veil/DoEffect(mob/living/carbon/human/H, atom/_)
	var/turf/center = get_turf(H)
	if(!center)
		return FALSE

	// Список турфов 11x11
	var/list/turfs5 = RANGE_TURFS(shroom_square_radius, H)
	var/list/turfs11 = RANGE_TURFS(dark_square_radius, H)
	replace_glowshrooms(turfs5)
	break_apcs_in_dark(turfs5) //Сделано для баланса, возможно стоит удалить или изменить
	weaken_shaded_mobs(turfs11, blind_duration)
	disable_lights_in_area(turfs11)

	to_chat(H, span_notice("Пелена тьмы накрывает всё вокруг."))
	return TRUE

/datum/action/cooldown/shadowling/veil/proc/disable_lights_in_area(list/turfs)
	if(!islist(turfs)) return
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
		if(!is_dark(T))
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
	var/datum/shadow_hive/hive = get_shadow_hive()
	for(var/turf/T in turfs)
		for(var/mob/living/carbon/human/M in T)
			if(!M)
				continue
			if(!is_dark(T))
				continue
			if(M.glasses)
				continue
			if((M in hive.thralls) || (M in hive.lings))
				continue
			M.adjust_staggered(duration)
			M.adjust_eye_blur(duration)

/datum/action/cooldown/shadowling/veil/proc/replace_glowshrooms(list/turfs)
	if(!islist(turfs))
		return
	var/glow_path = text2path("/obj/structure/glowshroom")
	for(var/turf/T in turfs)
		if(!T) continue
		for(var/obj/structure/G in T)
			if(glow_path && istype(G, glow_path))
				qdel(G)
