/datum/action/cooldown/shadowling/shreek
	name = "Крик"
	desc = "Ударная волна тьмы вокруг: рядом швыряет и оглушает, до 5 тайлов дезориентирует и трясёт. Бьёт стёкла и лампы."
	button_icon_state = "shadow_screech"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 30 SECONDS
	var/knock_radius = 1
	var/disorient_radius = 10
	var/sfx_activate = 'modular_bandastation/antagonists/sound/shadowlings/abilities/shreek.ogg'

/datum/action/cooldown/shadowling/shreek/DoEffect(mob/living/carbon/human/H, atom/_)
	playsound(get_turf(H), sfx_activate, 70, TRUE)
	new /obj/effect/temp_visual/circle_wave/shadow_shreek_wave(get_turf(H))
	H.visible_message(
		span_boldwarning("[H] издаёт пронзительный нечеловеческий крик!"),
		span_userdanger("Вы издаёте пронзительный крик, и тьма рвётся наружу!")
	)
	var/datum/team/shadow_hive/hive = get_shadow_hive()

	for(var/mob/living/L in range(disorient_radius, H))
		if(L == H)
			continue
		if(istype(L, /mob/living/carbon/human) && hive)
			if((L in hive.lings) || (L in hive.thralls))
				continue
		var/dist = get_dist(H, L)
		if(dist <= knock_radius)
			L.adjustOrganLoss(ORGAN_SLOT_EARS, 15)
			L.Knockdown(0.6 SECONDS)
			L.adjust_dizzy(4)
			knockback_away_from(H, L, 3)
		else
			L.adjustOrganLoss(ORGAN_SLOT_EARS, 8)
			L.adjust_confusion_up_to(6 SECONDS, 6 SECONDS)
			L.adjust_dizzy(3)

	for(var/obj/item/I in range(knock_radius, H))
		if(!isturf(I.loc))
			continue
		if(I.anchored)
			continue
		throw_away_from(H, I, 3, 2)

	for(var/obj/structure/window/W in range(disorient_radius, H))
		damage_glass_with_falloff(H, W)

	break_wall_lights_with_falloff(H)
	return TRUE

/obj/effect/temp_visual/circle_wave/shadow_shreek_wave
	color = "#9fd7ff"
	max_alpha = 220
	duration = 0.5 SECONDS
	amount_to_scale = 5

/datum/action/cooldown/shadowling/shreek/proc/damage_glass_with_falloff(mob/living/carbon/human/H, obj/structure/W)
	if(QDELETED(W))
		return
	var/d = clamp(get_dist(H, W), 1, disorient_radius)
	var/damage = max(10, 110 - 15 * d)
	W.take_damage(damage, damage_type = BRUTE, damage_flag = MELEE, sound_effect = TRUE)

/datum/action/cooldown/shadowling/shreek/proc/knockback_away_from(mob/living/source, mob/living/target, range)
	if(!istype(target) || target.anchored)
		return
	var/dir = get_dir(source, target)
	if(!dir)
		dir = pick(NORTH, SOUTH, EAST, WEST)
	var/turf/end = get_turf(target)
	for(var/i in 1 to range)
		var/turf/next = get_step(end, dir)
		if(!next || next.density)
			break
		end = next
	target.throw_at(end, range, 2)

/datum/action/cooldown/shadowling/shreek/proc/throw_away_from(mob/living/source, atom/movable/AM, range, speed)
	if(!istype(AM) || AM.anchored)
		return
	var/dir = get_dir(source, AM)
	if(!dir)
		dir = pick(NORTH, SOUTH, EAST, WEST)
	var/turf/end = get_turf(AM)
	for(var/i in 1 to range)
		var/turf/next = get_step(end, dir)
		if(!next || next.density)
			break
		end = next
	AM.throw_at(end, range, speed)

/datum/action/cooldown/shadowling/shreek/proc/break_wall_lights_with_falloff(mob/living/carbon/human/H)
	for(var/obj/machinery/light/L in range(disorient_radius, H))
		var/d = clamp(get_dist(H, L), 1, disorient_radius)
		var/chance = clamp(100 - (15 * d), 20, 100)
		if(prob(chance))
			L.break_light_tube()
