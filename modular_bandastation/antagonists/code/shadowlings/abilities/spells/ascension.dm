/datum/action/cooldown/shadowling/ascend
	name = "Возвышение"
	desc = "Разрывая оболочку, вы восходите к истинной форме. Требует темноты."
	button_icon_state = "shadow_ascend"
	cooldown_time = 0

	requires_dark_user = TRUE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

	required_thralls = 0

	var/steps = 3
	var/step_time = 10 SECONDS

	var/static/sfx_start = 'sound/effects/splat.ogg'
	var/static/sfx_end   = 'sound/effects/magic/mutate.ogg'
	var/static/list/sfx_tick = list('sound/items/weapons/slice.ogg', 'sound/items/weapons/slash.ogg', 'sound/items/weapons/slashmiss.ogg')

/datum/action/cooldown/shadowling/ascend/IsAvailable(feedback = FALSE)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(istype(H) && istype(H.dna?.species, /datum/species/shadow/shadowling/ascended))
		if(feedback) to_chat(H, span_warning("Вы уже достигли высшей формы."))
		return FALSE
	return TRUE

/datum/action/cooldown/shadowling/ascend/proc/cleanup(list/to_clean)
	if(!islist(to_clean))
		return
	for(var/atom/movable/A as anything in to_clean)
		if(!QDELETED(A))
			qdel(A)

/datum/action/cooldown/shadowling/ascend/proc/play_tick_fx(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(!T) return
	new /obj/effect/temp_visual/shadowling/hatch_pulse(T)
	playsound(T, pick(sfx_tick), 35, TRUE, -1)

/datum/action/cooldown/shadowling/ascend/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	if(istype(H.dna?.species, /datum/species/shadow/shadowling/ascended))
		return FALSE

	var/turf/start = get_turf(H)
	if(!start)
		return FALSE
	if(start.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
		to_chat(H, span_warning("Свет мешает Возвышению."))
		return FALSE

	// декорации: кокон и «стены»
	var/obj/structure/shadowling_cocoon/cocoon = new(start)
	var/list/spawned = list(cocoon)
	playsound(start, sfx_start, 60, TRUE)

	to_chat(H, span_notice("Вы начинаете собирать тьму в себе..."))

	for(var/i = 1, i <= steps, i++)
		var/turf/cur = get_turf(H)
		if(!cur)
			cleanup(spawned)
			return FALSE

		if(cur.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
			to_chat(H, span_warning("Яркий свет рассеивает тьму — Возвышение сорвано."))
			cleanup(spawned)
			return FALSE

		play_tick_fx(H)
		if(i == 1)
			to_chat(H, span_notice("Тьма собирается (0/[steps * (step_time / (1 SECONDS))] сек)."))
		else
			to_chat(H, span_notice("Тьма сгущается ([(i - 1) * (step_time / (1 SECONDS))]/[steps * (step_time / (1 SECONDS))] сек)."))

		if(!do_after(H, step_time, H))
			to_chat(H, span_warning("Вы теряете концентрацию — Возвышение прервано."))
			cleanup(spawned)
			return FALSE

	if(QDELETED(H))
		cleanup(spawned)
		return FALSE

	var/old_turf = get_turf(H)
	H.shadowling_strip_quirks()
	H.set_species(/datum/species/shadow/shadowling/ascended)

	if(H.mind)
		for(var/datum/antagonist/shadowling/AD in H.mind.antag_datums)
			AD.set_higher(TRUE)
			break

	playsound(old_turf, sfx_end, 70, TRUE)
	new /obj/effect/temp_visual/shadowling/hatch_pulse(old_turf)
	to_chat(H, span_boldnotice("Вы разрываете оболочку и восходите в высшую форму Тени!"))

	for(var/datum/action/cooldown/ability in H.actions)
		if(ability.type in typesof(/datum/action/cooldown/shadowling))
			ability.Remove(H)

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	hive.grant_sync_action(H)

	cleanup(spawned)
	Remove(H)
	qdel(src)
	return TRUE
