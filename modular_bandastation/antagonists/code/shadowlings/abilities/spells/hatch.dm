/datum/action/cooldown/shadowling/hatch
	name = "Вылупиться"
	desc = "Обратить свою оболочку и явить истинную тень."
	button_icon_state = "shadow_hatch"
	cooldown_time = 30 SECONDS
	requires_dark_user = TRUE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

	var/steps = 3
	var/step_time = 10 SECONDS

	var/static/sfx_start = 'sound/effects/splat.ogg'
	var/static/sfx_end = 'sound/effects/ghost.ogg'
	var/static/list/sfx_tick = list('sound/items/weapons/slice.ogg', 'sound/items/weapons/slash.ogg', 'sound/items/weapons/slashmiss.ogg')

	var/obj/structure/shadowling_cocoon/cover
	var/prev_alpha

/datum/action/cooldown/shadowling/hatch/proc/build_ring_walls(turf/center)
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
		var/obj/structure/alien/resin/wall/shadowling/W = new(T)
		walls += W
	return walls

/datum/action/cooldown/shadowling/hatch/proc/cleanup(list/to_clean)
	if(!islist(to_clean))
		return
	for(var/atom/movable/A as anything in to_clean)
		if(!QDELETED(A))
			qdel(A)

/datum/action/cooldown/shadowling/hatch/proc/play_tick_fx(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(!T)
		return
	new /obj/effect/temp_visual/shadowling/hatch_pulse(T)
	playsound(T, pick(sfx_tick), 35, TRUE, -1)

/datum/action/cooldown/shadowling/hatch/proc/attach_cover()
	if(cover)
		return
	cover = new /obj/structure/shadowling_cocoon(get_turf(owner))

/datum/action/cooldown/shadowling/hatch/proc/detach_cover()
	if(!cover)
		return
	qdel(cover)
	cover = null

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

	StartCooldown()
	var/list/walls = build_ring_walls(start)

	attach_cover()
	playsound(start, sfx_start, 60, TRUE)
	to_chat(H, span_notice("Вы начинаете разрывать оболочку..."))

	var/turf/anchor_turf = get_turf(H)
	var/area/anchor_area = get_area(H)
	prev_alpha = H.alpha
	H.alpha = 0
	H.drop_all_held_items()

	for(var/i = 1, i <= steps, i++)
		if(QDELETED(H) || H.stat == DEAD)
			detach_cover()
			cleanup(walls)
			H.alpha = prev_alpha
			return FALSE

		var/turf/cur = get_turf(H)
		if(!cur || cur != anchor_turf || get_area(H) != anchor_area)
			to_chat(H, span_warning("Вы вырвались из кокона — вылупление прервано."))
			detach_cover()
			cleanup(walls)
			H.alpha = prev_alpha
			return FALSE

		if(cur.get_lumcount() >= SHADOWLING_DIM_THRESHOLD)
			to_chat(H, span_warning("Свет разгоняет тьму — вылупление сорвано."))
			detach_cover()
			cleanup(walls)
			H.alpha = prev_alpha
			return FALSE

		play_tick_fx(H)

		var/total = steps * (step_time / (1 SECONDS))
		var/passed = (i - 1) * (step_time / (1 SECONDS))
		if(i == 1)
			to_chat(H, span_notice("Тьма собирается внутри вас (0/[total] сек)."))
		else
			to_chat(H, span_notice("Тьма сгущается ([passed]/[total] сек)."))

		if(!do_after(H, step_time, H)) {
			to_chat(H, span_warning("Вы вырвались из кокона — вылупление прервано."))
			detach_cover()
			cleanup(walls)
			H.alpha = prev_alpha
			return FALSE
		}

	if(QDELETED(H))
		detach_cover()
		cleanup(walls)
		H.alpha = prev_alpha
		return FALSE

	H.shadowling_strip_quirks()
	H.set_species(/datum/species/shadow/shadowling)
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	hive.grant_sync_action(H)
	hive.sync_after_event(H)
	H.refresh_eye_overlays()
	playsound(start, sfx_end, 70, TRUE)
	new /obj/effect/temp_visual/shadowling/hatch_pulse(start)
	to_chat(H, span_boldnotice("Вы разрываете оболочку и становитесь Тенью."))

	var/datum/action/cooldown/shadowling/toggle_night_vision/nightvision = hive.shadowling_grant_nightvision(H)
	nightvision.DoEffect(H)

	detach_cover()
	cleanup(walls)
	H.alpha = prev_alpha
	Remove(H)
	qdel(src)
	return TRUE

/obj/structure/shadowling_cocoon
	name = "shadow cocoon"
	desc = "Пульсирующий кокон живой тени."
	icon = 'modular_bandastation/antagonists/icons/shadowling/shadowling_objects.dmi'
	icon_state = "shadowcocoon"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/alien/resin/wall/shadowling
	name = "umbral mass"
	desc = "Скользкая, гнетущая тьма, затвердевшая в непробиваемый барьер."
	color = "#5e545a"
	move_resist = MOVE_FORCE_VERY_STRONG
	resistance_flags = INDESTRUCTIBLE

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
