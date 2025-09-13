/obj/effect/temp_visual/shadowling/ascend_circle
	name = "umbral circle"
	desc = "Пульсирующий круг тьмы."
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadow_acendence_circle"

	// визуал под мобом, но над полом
	plane = GAME_PLANE
	layer = MOB_LAYER - 0.2

	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/// Сколько жить (включая время на fade-out)
	var/lifetime = 3 SECONDS
	/// Время на появление/исчезновение
	var/fade_in_time  = 0.6 SECONDS
	var/fade_out_time = 0.6 SECONDS

/obj/effect/temp_visual/shadowling/ascend_circle/Initialize(mapload, custom_lifetime)
	. = ..()
	if(isnum(custom_lifetime))
		lifetime = max(custom_lifetime, fade_in_time + fade_out_time)

	alpha = 0
	// плавный вход
	animate(src, alpha = 255, time = fade_in_time)

	// запланировать плавный выход и удаление
	var/time_visible = max(lifetime - fade_in_time - fade_out_time, 0)
	addtimer(CALLBACK(src, PROC_REF(_begin_fade_out)), time_visible)
	return .

/obj/effect/temp_visual/shadowling/ascend_circle/proc/_begin_fade_out()
	animate(src, alpha = 0, time = fade_out_time)
	QDEL_IN(src, fade_out_time)

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
	var/static/sfx_end   = 'sound/effects/magic/mutate.ogg'
	var/static/list/sfx_tick = list('sound/items/weapons/slice.ogg', 'sound/items/weapons/slash.ogg', 'sound/items/weapons/slashmiss.ogg')

/datum/action/cooldown/shadowling/ascend/proc/levitate_pop(mob/living/carbon/human/H, total = 1.2 SECONDS)
	if(!istype(H)) return
	var/half = total * 0.5
	animate(H)
	animate(H, pixel_y = H.pixel_y + 3, time = 0.25 SECONDS, easing = EASE_OUT)
	animate(time = half - 0.25 SECONDS)
	animate(H, pixel_y = H.pixel_y, time = 0.45 SECONDS, easing = EASE_IN)

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

	StartCooldown()
	var/total_time = (steps * step_time) + 1 SECONDS
	var/obj/effect/temp_visual/shadowling/ascend_circle/circle = new(get_turf(H), total_time)
	var/list/spawned = list(circle)

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

	levitate_pop(H, 1.2 SECONDS)

	H.shadowling_strip_quirks()
	H.set_species(/datum/species/shadow/shadowling/ascended)

	if(H.mind)
		for(var/datum/antagonist/shadowling/AD in H.mind.antag_datums)
			AD.set_higher(TRUE)
			break

	new /obj/effect/temp_visual/shadowling/hatch_pulse(old_turf)
	new /obj/effect/temp_visual/circle_wave/shadow_shreek_wave/dark/slow(old_turf)

	to_chat(H, span_boldnotice("Вы разрываете оболочку и восходите в высшую форму Тени!"))

	for(var/datum/action/cooldown/ability in H.actions)
		if(ability.type in typesof(/datum/action/cooldown/shadowling))
			ability.Remove(H)

	var/datum/team/shadow_hive/hive = get_shadow_hive()
	hive.grant_sync_action(H)
	hive.sync_after_event(H)

	cleanup(spawned)

	StartCooldown()
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
