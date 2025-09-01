/datum/action/cooldown/shadowling/shreek
	name = "Крик"
	desc = "Выпускает ударную волну тьмы: рядом оглушает и швыряет, дальше — дезориентирует. Бьёт стёкла."
	background_icon_state = "shadow_demon_bg"
	button_icon = 'modular_bandastation/antagonists/icons/shadowlings_actions.dmi'
	button_icon_state = "shadow_scream"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 30 SECONDS

	var/strong_radius = 5
	var/weak_radius = 10

	var/scream_sound = 'sound/mobs/humanoids/shadow/shadow_wail.ogg'

/datum/action/cooldown/shadowling/shreek/DoEffect(mob/living/carbon/human/H, atom/_)
	if(scream_sound)
		playsound(get_turf(H), scream_sound, 70, TRUE)
	H.visible_message(
		span_boldwarning("[H] издаёт пронзительный нечеловеческий крик!"),
		span_userdanger("Вы издаёте пронзительный крик, и тьма рвётся наружу!")
	)

	var/datum/shadow_hive/hive = get_shadow_hive()

	for(var/mob/living/L in range(weak_radius, H))
		if(L == H) continue
		if(istype(L, /mob/living/carbon/human) && hive && ((L in hive.lings) || (L in hive.thralls)))
			continue

		var/dist = get_dist(H, L)
		var/in_strong = (dist <= strong_radius)

		L.adjustOrganLoss(ORGAN_SLOT_EARS, (in_strong ? 10 : 5))
		L.adjust_confusion_up_to(in_strong ? (10 SECONDS) : (2 SECONDS), in_strong ? (10 SECONDS) : (2 SECONDS))

		if(dist <= 1)
			L.adjustOrganLoss(ORGAN_SLOT_EARS, 10)
			knockback_away_from(H, L, 3)

	for(var/obj/item/I in range(strong_radius, H))
		if(!isturf(I.loc))
			continue
		if(I.anchored)
			continue
		throw_away_from(H, I, 3, 2)

	for(var/obj/structure/window/W in range(weak_radius, H))
		damage_glass_with_falloff(H, W)
	empulse(owner, heavy_range = 5, light_range = 10)
	return TRUE

/datum/action/cooldown/shadowling/shreek/proc/damage_glass_with_falloff(mob/living/carbon/human/H, obj/structure/W)
	if(QDELETED(W)) return
	var/d = clamp(get_dist(H, W), 1, weak_radius)
	var/damage = max(10, 110 - 10 * d)
	W.take_damage(damage, damage_type = BRUTE, damage_flag = MELEE, sound_effect = TRUE)

/datum/action/cooldown/shadowling/shreek/proc/knockback_away_from(mob/living/source, mob/living/target, range)
	if(!istype(target) || target.anchored) return
	var/dir = get_dir(source, target)
	if(!dir) dir = pick(NORTH, SOUTH, EAST, WEST)
	var/turf/end = get_turf(target)
	for(var/i in 1 to range)
		var/turf/next = get_step(end, dir)
		if(!next || next.density) break
		end = next
	target.throw_at(end, range, 2)

/datum/action/cooldown/shadowling/shreek/proc/throw_away_from(mob/living/source, atom/movable/AM, range, speed)
	if(!istype(AM) || AM.anchored) return
	var/dir = get_dir(source, AM)
	if(!dir) dir = pick(NORTH, SOUTH, EAST, WEST)
	var/turf/end = get_turf(AM)
	for(var/i in 1 to range)
		var/turf/next = get_step(end, dir)
		if(!next || next.density) break
		end = next
	AM.throw_at(end, range, speed)
