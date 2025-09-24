/obj/effect/temp_visual/shadowling/ascend_circle
	name = "umbral circle"
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadow_acendence_circle"
	plane = GAME_PLANE
	layer = MOB_LAYER - 0.2
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	randomdir = FALSE
	duration = 300

	var/alpha_min = 140
	var/alpha_max = 255
	var/pulse_half = 0.4 SECONDS
	var/pulse_delta_y = 1
	var/base_y = 0
	var/is_pulsing = FALSE
	var/_pulse_dir = 1

/obj/effect/temp_visual/shadowling/ascend_circle/Initialize(mapload)
	. = ..()
	base_y = pixel_y
	alpha = alpha_min
	return .

/obj/effect/temp_visual/shadowling/ascend_circle/proc/start_pulse()
	if(is_pulsing) return
	is_pulsing = TRUE
	_pulse_step()

/obj/effect/temp_visual/shadowling/ascend_circle/proc/_pulse_step()
	if(!is_pulsing) return
	var/target_alpha = (_pulse_dir > 0) ? alpha_max : alpha_min
	var/target_y = (_pulse_dir > 0) ? (base_y + pulse_delta_y) : base_y
	var/ease = (_pulse_dir > 0) ? EASE_OUT : EASE_IN
	animate(src)
	animate(src, alpha = target_alpha, pixel_y = target_y, time = pulse_half, easing = ease)
	_pulse_dir = -_pulse_dir
	addtimer(CALLBACK(src, PROC_REF(_pulse_step)), pulse_half)

/obj/effect/temp_visual/shadowling/ascend_circle/proc/stop_and_fade(fade_time = 0.3 SECONDS)
	if(is_pulsing) is_pulsing = FALSE
	animate(src)
	animate(src, alpha = 0, pixel_y = base_y, time = fade_time)
	QDEL_IN(src, fade_time)

/obj/effect/temp_visual/circle_wave/shadow_shreek_wave/dark
	color = "#131a22"
	max_alpha = 220
	duration = 0.5 SECONDS
	amount_to_scale = 5

/obj/effect/temp_visual/circle_wave/shadow_shreek_wave/dark/slow
	duration = 1.2 SECONDS
	amount_to_scale = 8

/datum/action/cooldown/shadowling/ascend
	name = "Возвышение"
	desc = "Разрывая оболочку, вы восходите к истинной форме. Требует темноты."
	button_icon_state = "shadow_ascend"
	cooldown_time = 30 SECONDS
	requires_dark_user = TRUE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0
	required_thralls = 0

	var/steps = 3
	var/step_time = 10 SECONDS

	var/static/sfx_start = 'sound/effects/splat.ogg'
	var/static/sfx_end = 'sound/effects/magic/mutate.ogg'
	var/static/list/sfx_tick = list('sound/items/weapons/slice.ogg', 'sound/items/weapons/slash.ogg', 'sound/items/weapons/slashmiss.ogg')

	/// параметры парения персонажа
	var/levitate_offset = 4
	var/levitate_half = 0.5 SECONDS
	var/levitate_until = 0
	var/_levitate_base_y = null
	var/_levitating = FALSE

	min_req = 1
	max_req = 30
	required_thralls = 100

/datum/action/cooldown/shadowling/ascend/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	if(istype(H.dna?.species, /datum/species/shadow/shadowling/ascended))
		return FALSE

	var/turf/start_turf = get_turf(H)
	if(!start_turf)
		return FALSE

	if(start_turf.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
		to_chat(H, span_warning("Свет мешает Возвышению."))
		return FALSE

	StartCooldown()

	playsound(start_turf, sfx_start, 60, TRUE)
	to_chat(H, span_notice("Вы начинаете собирать тьму в себе."))

	var/ritual_total = (steps * step_time) + 1 SECONDS

	_begin_levitate(H, ritual_total)

	var/obj/effect/temp_visual/shadowling/ascend_circle/circle = new(get_turf(H))
	circle.start_pulse()

	for(var/i = 1, i <= steps, i++)
		var/turf/current_turf = get_turf(H)
		if(!current_turf)
			_end_levitate(H)
			if(circle)
				circle.stop_and_fade()
			return FALSE

		if(current_turf.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
			to_chat(H, span_warning("Яркий свет рассеивает тьму — Возвышение сорвано."))
			_end_levitate(H)
			if(circle)
				circle.stop_and_fade()
			return FALSE

		_play_tick_fx(H)

		var/total_secs = steps * (step_time / (1 SECONDS))
		if(i == 1)
			to_chat(H, span_notice("Тьма собирается (0/[total_secs] сек)."))
		else
			var/past_secs = (i - 1) * (step_time / (1 SECONDS))
			to_chat(H, span_notice("Тьма сгущается ([past_secs]/[total_secs] сек)."))

		if(!do_after(H, step_time, H))
			to_chat(H, span_warning("Вы теряете концентрацию — Возвышение прервано."))
			_end_levitate(H)
			if(circle)
				circle.stop_and_fade()
			return FALSE

	if(QDELETED(H))
		_end_levitate(null)
		if(circle)
			circle.stop_and_fade()
		return FALSE

	var/old_turf = get_turf(H)

	_pop_burst(H, 1.2 SECONDS)

	H.shadowling_strip_quirks()
	H.set_species(/datum/species/shadow/shadowling/ascended)

	if(H.mind)
		for(var/datum/antagonist/shadowling/AD in H.mind.antag_datums)
			AD.set_higher(TRUE)
			break

	new /obj/effect/temp_visual/shadowling/hatch_pulse(old_turf)
	new /obj/effect/temp_visual/circle_wave/shadow_shreek_wave/dark/slow(old_turf)

	to_chat(H, span_boldnotice("Вы разрываете оболочку и восходите в высшую форму Тени."))
	playsound(get_turf(H), 'sound/effects/magic/mutate.ogg', 70, TRUE)

	for(var/datum/action/cooldown/ability in H.actions)
		if(ability.type in typesof(/datum/action/cooldown/shadowling) && !(istype(ability.type, /datum/action/cooldown/shadowling/engine_sabotage)))
			ability.Remove(H)

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	if(hive)
		hive.grant_sync_action(H)
		hive.sync_after_event(H)

	_end_levitate(H)

	if(circle)
		circle.stop_and_fade()
	shadowling_begin_roundender(H)
	StartCooldown()
	return TRUE

/datum/action/cooldown/shadowling/ascend/proc/_begin_levitate(mob/living/carbon/human/H, total_time)
	if(!istype(H))
		return
	_levitating = TRUE
	_levitate_base_y = H.pixel_y
	levitate_until = world.time + total_time
	_levitate_up(H)

/datum/action/cooldown/shadowling/ascend/proc/_levitate_up(mob/living/carbon/human/H)
	if(!_levitating)
		return
	if(!istype(H))
		return

	if(world.time >= levitate_until)
		_end_levitate(H)
		return

	animate(H)
	animate(H, pixel_y = _levitate_base_y + levitate_offset, time = levitate_half, easing = EASE_OUT)

	addtimer(CALLBACK(src, PROC_REF(_levitate_down), H), levitate_half)

/datum/action/cooldown/shadowling/ascend/proc/_levitate_down(mob/living/carbon/human/H)
	if(!_levitating)
		return
	if(!istype(H))
		return

	if(world.time >= levitate_until)
		_end_levitate(H)
		return

	animate(H)
	animate(H, pixel_y = _levitate_base_y, time = levitate_half, easing = EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(_levitate_up), H), levitate_half)

/datum/action/cooldown/shadowling/ascend/proc/_end_levitate(mob/living/carbon/human/H)
	if(!_levitating)
		return
	_levitating = FALSE

	if(istype(H))
		animate(H)
		animate(H, pixel_y = _levitate_base_y, time = 0.2 SECONDS, easing = EASE_IN)

/datum/action/cooldown/shadowling/ascend/proc/_pop_burst(mob/living/carbon/human/H, total = 1.2 SECONDS)
	if(!istype(H))
		return

	var/half = total * 0.5

	animate(H)
	animate(H, pixel_y = H.pixel_y + 3, time = 0.25 SECONDS, easing = EASE_OUT)
	animate(time = half - 0.25 SECONDS)
	animate(H, pixel_y = H.pixel_y, time = 0.45 SECONDS, easing = EASE_IN)

/datum/action/cooldown/shadowling/ascend/proc/_play_tick_fx(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(!T)
		return
	new /obj/effect/temp_visual/shadowling/hatch_pulse(T)
	playsound(T, pick(sfx_tick), 35, TRUE, -1)
