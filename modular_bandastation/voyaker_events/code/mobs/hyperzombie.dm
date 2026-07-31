/mob/living/basic/hyperzombie
	name = "гиперзомби"
	desc = "Его плоть светится ядовито-зелёным светом - видимо, это последствия радиоактивного излучнеия. Постоянно дёргающийся, с прижатыми к груди руками и истощающий резкий запах. Пасть постоянно открыта так, словно готова что-то извергнуть из себя."
	icon = 'modular_bandastation/voyaker_events/icons/hyperzombie.dmi'
	icon_state = "hyperzombie"
	maxHealth = 270
	health = 270
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	attack_sound = 'sound/items/weapons/bite.ogg'
	light_color = COLOR_GREEN
	light_power = 1.4
	light_range = 2
	var/next_spit = 0
	var/spit_cooldown = 10 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/hyperzombie

/datum/ai_controller/basic_controller/hyperzombie
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_zombies,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/hyperzombie.bt.json"

/datum/bt_node/ai_behavior/hyper_spit
	var/target_key
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/hiding_location_key

/datum/bt_node/ai_behavior/hyper_spit/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/hyperzombie/zombie = controller.pawn
	if(!zombie)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[hiding_location_key]
	if(!target)
		target = controller.blackboard[target_key]
	if(!target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(zombie.stat != CONSCIOUS)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/dist = get_dist(zombie, target)
	if(dist <= 1 || dist > 5)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!los_check(zombie, target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(world.time < zombie.next_spit)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(zombie, TYPE_PROC_REF(/mob/living/basic/hyperzombie, radioactive_spit), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/mob/living/basic/hyperzombie/Initialize(mapload)
	. = ..()
	faction = list("cult")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	addtimer(CALLBACK(src, PROC_REF(radiation_aura)), 1 SECONDS)

/mob/living/basic/hyperzombie/proc/radiation_aura()
	if(QDELETED(src))
		return
	radiation_pulse(src, max_range = 1, threshold = 0.1, chance = 80)
	addtimer(CALLBACK(src, PROC_REF(radiation_aura)), 1 SECONDS)

/mob/living/basic/hyperzombie/proc/radioactive_spit(mob/living/target)
	if(QDELETED(src) || stat == DEAD)
		return FALSE
	if(QDELETED(target))
		return FALSE
	next_spit = world.time + spit_cooldown
	visible_message(span_warning("[src] извергает поток радиоактивной желчи!"))
	sleep(0.5 SECONDS)
	var/dir = get_dir(src, target)
	var/turf/current = get_turf(src)
	for(var/i in 1 to 5)
		current = get_step(current, dir)
		if(!current)
			break
		if(isclosedturf(current))
			break
		var/blocked = FALSE
		for(var/obj/O in current)
			if(O.density)
				blocked = TRUE
				break
		if(blocked)
			break
		var/obj/effect/decal/cleanable/greenglow/radioactive/puddle = new(current)
		QDEL_IN(puddle, 3 SECONDS)
		playsound(current, 'sound/effects/splat.ogg', 50)
		for(var/mob/living/L in current)
			L.Knockdown(2 SECONDS)
			L.apply_damage(20, BURN)
			radiation_pulse(L, max_range = 1, threshold = 0.1, chance = 60)
			break
		sleep(0.2 SECONDS)
	return TRUE
