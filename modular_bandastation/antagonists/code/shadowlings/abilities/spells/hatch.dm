/obj/structure/shadowling/cocoon
	name = "shadow cocoon"
	desc = "A pulsing cocoon of living shadow."
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	plane = GAME_PLANE
	layer = MOB_LAYER+0.1
	icon = 'icons/effects/effects.dmi'
	icon_state = "bluespace" // замените на нужный спрайт, если есть
	alpha = 230

/obj/structure/shadowling/cocoon/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 3)
	return .

/obj/structure/shadowling/wall
	name = "umbral mass"
	desc = "Slick, oppressive darkness hardened into a barrier."
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	resistance_flags = INDESTRUCTIBLE
	plane = GAME_PLANE
	layer = OBJ_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke" // замените на спрайт стен, если будет
	color = "#1a0f1f"
	alpha = 220

/obj/structure/shadowling/wall/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 3)
	return .

/obj/effect/temp_visual/shadowling/hatch_pulse
	name = "shadow pulse"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_GAME_PLANE
	layer = EFFECTS_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	color = "#6e00a8"
	alpha = 220

/obj/effect/temp_visual/shadowling/hatch_pulse/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = 6)
	QDEL_IN(src, 0.6 SECONDS)
	return .

/datum/action/cooldown/shadowling/hatch
	name = "Вылупиться"
	desc = "Обратить свою оболочку и явить истинную тень."
	button_icon_state = "shadow_hatch"
	cooldown_time = 0

	requires_dark_user = TRUE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

	var/static/sfx_tick = 'sound/effects/nightmare_poof.ogg'
	var/static/sfx_start = 'sound/effects/nightmare_poof.ogg'
	var/static/sfx_end = 'sound/effects/nightmare_poof.ogg'

/datum/action/cooldown/shadowling/hatch/proc/_build_ring_walls(turf/center)
	var/list/walls = list()
	if(!istype(center))
		return walls

	var/list/dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	for(var/d in dirs)
		var/turf/T = get_step(center, d)
		if(!istype(T))
			continue
		if(T.density)
			continue
		var/obj/structure/shadowling/wall/W = new(T)
		walls += W

	return walls

/datum/action/cooldown/shadowling/hatch/proc/_cleanup(list/to_clean)
	if(!islist(to_clean))
		return
	for(var/atom/movable/A as anything in to_clean)
		if(!QDELETED(A))
			qdel(A)

/datum/action/cooldown/shadowling/hatch/proc/_play_tick_fx(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(!T)
		return
	new /obj/effect/temp_visual/shadowling/hatch_pulse(T)
	playsound(T, sfx_tick, 35, TRUE, -1)

/datum/action/cooldown/shadowling/hatch/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	if(istype(H.dna?.species, /datum/species/shadow/shadowling))
		return FALSE

	var/turf/start = get_turf(H)
	if(!start)
		return FALSE

	if(start.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
		to_chat(H, span_warning("Свет мешает вылуплению."))
		return FALSE

	var/obj/structure/shadowling/cocoon/cocoon = new(start)
	var/list/walls = _build_ring_walls(start)
	var/list/spawned = list(cocoon) + walls

	playsound(start, sfx_start, 60, TRUE)
	to_chat(H, span_notice("Вы начинаете разрывать оболочку..."))

	var/steps = 6
	var/step_time = 5 SECONDS

	for(var/i = 1, i <= steps, i++)
		var/turf/cur = get_turf(H)
		if(!cur)
			_cleanup(spawned)
			return FALSE

		if(cur.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
			to_chat(H, span_warning("Свет разгоняет тьму — вылупление сорвано."))
			_cleanup(spawned)
			return FALSE

		_play_tick_fx(H)

		if(i == 1)
			to_chat(H, span_notice("Тьма собирается внутри вас (0/30 сек)."))
		else
			to_chat(H, span_notice("Тьма сгущается ([(i - 1) * 5]/30 сек)."))

		if(!do_after(H, step_time, H))
			to_chat(H, span_warning("Вы теряете концентрацию — вылупление прервано."))
			_cleanup(spawned)
			return FALSE

	if(QDELETED(H))
		_cleanup(spawned)
		return FALSE
	H.shadowling_strip_quirks()
	H.set_species(/datum/species/shadow/shadowling)

	playsound(start, sfx_end, 70, TRUE)
	new /obj/effect/temp_visual/shadowling/hatch_pulse(start)

	to_chat(H, span_boldnotice("Вы разрываете оболочку и становитесь Тенью."))

	_cleanup(spawned)
	Remove(H)
	qdel(src)
	return TRUE
