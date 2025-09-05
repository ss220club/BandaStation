/datum/action/cooldown/shadowling/shadow_smoke
	name = "Теневой дым"
	desc = "Заполняет область дымом: лечит союзных теней и их слуг, ослепляет и иногда оглушает остальных."
	button_icon_state = "blindness_smoke"
	cooldown_time = 60 SECONDS
	requires_dark_user = FALSE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0
	var/smoke_radius = 4
	var/smoke_ticks = 6
	var/heal_amount = 10
	var/blind_time = 5 SECONDS
	var/stun_chance = 25
	var/stun_time = 2 SECONDS

/datum/action/cooldown/shadowling/shadow_smoke/DoEffect(mob/living/carbon/human/H, atom/_)
	var/turf/T = get_turf(H)
	if(!T)
		return FALSE
	playsound(T, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	shadow_spawn_smoke(T, H, smoke_radius, smoke_ticks, heal_amount, blind_time, stun_chance, stun_time)
	return TRUE


/obj/effect/particle_effect/fluid/smoke/shadow
	name = "shadow smoke"
	opacity = FALSE
	lifetime = 10 SECONDS
	color = "#000000"
	alpha = 220
	var/heal_amount = 10
	var/blind_time = 5 SECONDS
	var/stun_chance = 25
	var/stun_time = 2 SECONDS

/obj/effect/particle_effect/fluid/smoke/shadow/spread(seconds_per_tick)
	return

/obj/effect/particle_effect/fluid/smoke/shadow/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	if(!..())
		return FALSE
	var/datum/team/shadow_hive/hive = get_shadow_hive()
	var/is_ally = FALSE
	if(hive)
		is_ally = (smoker in hive.lings) || (smoker in hive.thralls)
	if(is_ally)
		smoker.adjustBruteLoss(-heal_amount)
		smoker.adjustFireLoss(-heal_amount)
		smoker.adjustToxLoss(-heal_amount)
		smoker.adjustOxyLoss(-heal_amount)
		var/mob/living/carbon/C = smoker
		if(istype(C))
			C.adjustStaminaLoss(-heal_amount)
	else
		var/mob/living/carbon/C2 = smoker
		if(istype(C2))
			C2.adjust_temp_blindness(blind_time)
		if(prob(stun_chance))
			smoker.Stun(stun_time)
	return TRUE


/datum/effect_system/shadow_smoke
	var/range = 4
	var/amount
	var/heal_amount = 10
	var/blind_time = 5 SECONDS
	var/stun_chance = 25
	var/stun_time = 2 SECONDS
	var/total_ticks = 6

/datum/effect_system/shadow_smoke/set_up(range = 4, amount = 0, atom/holder, atom/location)
	src.range = range
	src.amount = amount
	src.holder = holder
	src.location = location

/datum/effect_system/shadow_smoke/start(log = FALSE)
	var/turf/center = location || get_turf(holder)
	if(!center)
		return
	var/datum/fluid_group/G = new
	var/list/visited = list()
	var/list/queue = list()
	visited[center] = 0
	queue += center
	while(length(queue))
		var/turf/current = queue[1]
		queue.Cut(1, 2)
		var/dist = visited[current]
		var/life_secs = max(total_ticks - dist, 0)
		if(life_secs > 0)
			var/obj/effect/particle_effect/fluid/smoke/shadow/node = new /obj/effect/particle_effect/fluid/smoke/shadow(current, G)
			node.heal_amount = heal_amount
			node.blind_time = blind_time
			node.stun_chance = stun_chance
			node.stun_time = stun_time
			node.lifetime = life_secs SECONDS
		if(dist >= range)
			continue
		for(var/turf/N in current.get_atmos_adjacent_turfs())
			if(!visited[N])
				visited[N] = dist + 1
				queue += N


/proc/shadow_spawn_smoke(turf/where, mob/living/holder, r = 4, ticks = 6, heal = 10, blind = 5 SECONDS, schance = 25, stun = 2 SECONDS)
	if(!istype(where))
		return
	var/datum/effect_system/shadow_smoke/S = new
	S.set_up(r, holder = holder, location = where)
	S.heal_amount = heal
	S.blind_time = blind
	S.stun_chance = schance
	S.stun_time = stun
	S.total_ticks = ticks
	S.start()
