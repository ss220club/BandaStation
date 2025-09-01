/datum/movespeed_modifier/shadowling/cold_wave
	// ~25% медленнее
	multiplicative_slowdown = 1.25
	priority = 20
	movetypes = GROUND

/datum/action/cooldown/shadowling/cold_wave
	name = "Волна холода"
	desc = "Выплеск ледяной тьмы в 90° конусе на 4 тайла, наносящий 30 урона по выносливости и замедляющий врагов на 6 секунд."
	button_icon_state = "shadow_cold_wave"
	cooldown_time = 20 SECONDS

	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 4
	channel_time = 0

/datum/action/cooldown/shadowling/cold_wave/DoEffect(mob/living/carbon/human/H, atom/_)
	var/list/targets = collect_cone_targets(H)
	if(!length(targets))
		to_chat(H, span_warning("Перед вами никого нет."))
		return FALSE

	var/hit = FALSE
	for(var/mob/living/carbon/human/T in targets)
		if(QDELETED(T))
			continue

		T.adjustStaminaLoss(30)
		apply_slow(T, 10 SECONDS)
		hit = TRUE

	return hit

/datum/action/cooldown/shadowling/cold_wave/collect_cone_targets(mob/living/carbon/human/H)
	var/list/out = list()
	var/datum/shadow_hive/hive = get_shadow_hive()
	for(var/mob/living/carbon/human/T in range(max_range, H))
		if(T == H)
			continue

		if(!in_cone_90(H, T))
			continue

		if(hive && ((T in hive.lings) || (T in hive.thralls)))
			continue

		out += T
	return out

/datum/action/cooldown/shadowling/cold_wave/proc/in_cone_90(mob/living/carbon/human/H, atom/A)
	if(!H.dir)
		return TRUE

	var/tdir = get_dir(H, A)
	if(!tdir)
		return FALSE

	var/list/allowed = list(H.dir, turn(H.dir, 45), turn(H.dir, -45))
	return (tdir in allowed)

/datum/action/cooldown/shadowling/cold_wave/proc/apply_slow(mob/living/L, duration)
	if(!istype(L))
		return

	L.add_movespeed_modifier(/datum/movespeed_modifier/shadowling/cold_wave)
	addtimer(CALLBACK(src, PROC_REF(_remove_slow), L), duration)

/datum/action/cooldown/shadowling/cold_wave/proc/_remove_slow(mob/living/L)
	if(!istype(L))
		return

	L.remove_movespeed_modifier(/datum/movespeed_modifier/shadowling/cold_wave)
