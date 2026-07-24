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
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_zombies
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "modular_bandastation/voyaker_events/code/mobs/hyperzombie.bt.json"

/datum/bt_node/ai_behavior/hyper_spit

/datum/bt_node/ai_behavior/hyper_spit/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/hyperzombie/zombie = controller.pawn
	if(!zombie)
		return AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[BB_CURRENT_TARGET]
	if(!target)
		return AI_BEHAVIOR_FAILED
	if(zombie.stat != CONSCIOUS)
		return AI_BEHAVIOR_FAILED
	var/dist = get_dist(zombie, target)
	if(dist <= 1)
		return AI_BEHAVIOR_FAILED
	if(dist > 5)
		return AI_BEHAVIOR_FAILED
	if(!los_check(zombie, target))
		return AI_BEHAVIOR_FAILED
	if(world.time < zombie.next_spit)
		return AI_BEHAVIOR_FAILED
	zombie.next_spit = world.time + zombie.spit_cooldown
	zombie.visible_message(span_warning("[zombie] извергает поток радиоактивной желчи!"))
	addtimer(CALLBACK(zombie, TYPE_PROC_REF(/mob/living/basic/hyperzombie, do_spit)), 5)
	return AI_BEHAVIOR_SUCCEEDED

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

/mob/living/basic/hyperzombie/proc/do_spit()
	var/atom/target = ai_controller.blackboard[BB_CURRENT_TARGET]
	if(!target)
		return
	var/dir = get_dir(src, target)
	spit_step(get_turf(src), dir, 5)

/mob/living/basic/hyperzombie/proc/spit_step(turf/current, dir, remaining)
	if(remaining <= 0)
		return
	current = get_step(current, dir)
	if(!current)
		return
	if(isclosedturf(current))
		return
	for(var/obj/O in current)
		if(O.density)
			return
	var/obj/effect/decal/cleanable/greenglow/radioactive/puddle = new(current)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), puddle), 3 SECONDS)
	playsound(current, 'sound/effects/splat.ogg', 50)
	for(var/mob/living/L in current)
		L.Knockdown(2 SECONDS)
		L.apply_damage(20, BURN)
		radiation_pulse(L, max_range = 1, threshold = 0.1, chance = 60)
		break
	addtimer(CALLBACK(src, PROC_REF(spit_step), current, dir, remaining - 1), 2 DECISECONDS)
