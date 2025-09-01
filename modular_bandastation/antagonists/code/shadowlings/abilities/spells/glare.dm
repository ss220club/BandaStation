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

/datum/action/cooldown/shadowling/glare/CollectTargets(mob/living/carbon/human/H, atom/explicit)
	var/list/targets = list()
	var/datum/shadow_hive/hive = get_shadow_hive()

	for(var/mob/living/carbon/human/T in range(max_range, H))
		if(T == H)
			continue
		if(!in_front_semiplane(H, T))
			continue
		if(hive && ((T in hive.lings) || (T in hive.thralls)))
			continue
		targets += T

	return targets

/datum/action/cooldown/shadowling/glare/proc/in_front_semiplane(mob/living/carbon/human/H, atom/A)
	if(!H.dir)
		return TRUE
	var/tdir = get_dir(H, A)
	if(!tdir)
		return FALSE
	var/list/allowed = list(H.dir, turn(H.dir, 45), turn(H.dir, -45), turn(H.dir, 90), turn(H.dir, -90))
	return (tdir in allowed)

/datum/action/cooldown/shadowling/glare/ValidateTarget(mob/living/carbon/human/H, atom/target)
	var/mob/living/carbon/human/T = target
	if(!istype(T))
		return FALSE

	if(T.glasses)
		return FALSE

	return TRUE

/datum/action/cooldown/shadowling/glare/DoEffectOnTargets(mob/living/carbon/human/H, list/targets)
	if(!islist(targets) || !length(targets))
		to_chat(H, span_warning("Перед вами никого нет."))
		return FALSE

	var/hit = FALSE
	for(var/mob/living/carbon/human/T in targets)
		if(QDELETED(T)) continue
		var/d = get_dist(H, T)

		if(d <= 5)
			apply_stamina(T, 30)
			apply_stamina_dot(T, 10, 15, 1 SECONDS)
			mute_for(T, 10 SECONDS)
			force_drop_items(T)
			apply_slow(T, 10 SECONDS)
			hit = TRUE
		else if(d <= 10)
			apply_stamina(T, 20)
			stun_for(T, 2 SECONDS)
			mute_for(T, 5 SECONDS)
			hit = TRUE

	return hit

/datum/action/cooldown/shadowling/glare/proc/apply_stamina(mob/living/L, amount)
	if(!istype(L))
		return
	L.adjustStaminaLoss(amount)

/datum/action/cooldown/shadowling/glare/proc/apply_stamina_dot(mob/living/L, amount, ticks, period)
	if(!istype(L))
		return
	for(var/i = 1 to ticks)
		addtimer(CALLBACK(src, PROC_REF(_stamina_tick), L, amount), i * period)

/datum/action/cooldown/shadowling/glare/proc/_stamina_tick(mob/living/L, amount)
	if(QDELETED(L))
		return
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
